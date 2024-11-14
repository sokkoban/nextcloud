############################################################
#                          Nextcloud Installation           #
#                          Author: Kristian Gasic           #
#                          Forked by sokoban                #
############################################################

# Variables
DATA_DIR="/mnt/nextcloud/data"
DB_NAME="nextcloud"

# Function to capture user input
get_user_input() {
    read -p "Enter MariaDB Username: " MARIADB_USER
    read -sp "Enter MariaDB Password: " MARIADB_PASSWORD
    echo
    read -p "Enter Subdomain (e.g., nextcloud.example.com): " SUBDOMAIN
    IP_ADDRESS=$(hostname -I | awk '{print $1}')
    echo "Detected IP Address: $IP_ADDRESS"
}

# Function for creating the installation log
create_install_log() {
    cat << EOF > install.log
Nextcloud Installation Log
===========================
MariaDB Username: ${MARIADB_USER}
Database Name: ${DB_NAME}
IP Address: ${IP_ADDRESS}
Subdomain: ${SUBDOMAIN}
Data Directory: ${DATA_DIR}
================================================
EOF
}

# Function to install Nextcloud and set up SSL
install_nextcloud() {
    echo "Updating system packages..." | tee -a install.log
    sudo apt update && sudo apt upgrade -y || { echo "Failed to update packages" | tee -a install.log; exit 1; }

    echo "Installing necessary packages..." | tee -a install.log
    sudo apt install apache2 mariadb-server software-properties-common unzip certbot python3-certbot-apache -y || { echo "Failed to install necessary packages" | tee -a install.log; exit 1; }

    echo "Adding PHP repository..." | tee -a install.log
    sudo add-apt-repository ppa:ondrej/php -y || { echo "Failed to add PHP repository" | tee -a install.log; exit 1; }
    sudo apt update || { echo "Failed to update package list after adding PHP repository" | tee -a install.log; exit 1; }

    echo "Installing PHP 8.3 and required modules..." | tee -a install.log
    sudo apt install php8.3 libapache2-mod-php8.3 php8.3-gd php8.3-mysql php8.3-curl php8.3-mbstring php8.3-intl php8.3-imagick php8.3-xml php8.3-zip php8.3-opcache php8.3-redis redis-server -y || { echo "Failed to install PHP packages" | tee -a install.log; exit 1; }

    echo "Starting and securing MariaDB..." | tee -a install.log
    sudo systemctl start mariadb || { echo "Failed to start MariaDB" | tee -a install.log; exit 1; }

    # Secure MariaDB and set up Nextcloud database
    sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
CREATE DATABASE ${DB_NAME};
CREATE USER '${MARIADB_USER}'@'localhost' IDENTIFIED BY '${MARIADB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${MARIADB_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF
    if [ $? -ne 0 ]; then
        echo "Database setup failed" | tee -a install.log
        exit 1
    fi

    echo "Configuring PHP Opcache and upload settings..." | tee -a install.log
    sudo mkdir -p /etc/php/8.3/apache2/conf.d
    sudo bash -c 'cat > /etc/php/8.3/apache2/conf.d/10-opcache.ini <<EOF
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=10000
opcache.revalidate_freq=1
opcache.save_comments=1
EOF'

    sudo bash -c 'cat > /etc/php/8.3/apache2/conf.d/20-upload.ini <<EOF
upload_max_filesize=5G
post_max_size=5G
memory_limit=512M
max_execution_time=3600
max_input_time=3600
EOF'

    echo "Configuring Redis..." | tee -a install.log
    if [ -f /etc/redis/redis.conf ]; then
        sudo sed -i "s/^# *port .*/port 6379/" /etc/redis/redis.conf
        sudo sed -i "s/^# *bind 127.0.0.1 ::1/bind 127.0.0.1 ::1/" /etc/redis/redis.conf
        sudo sed -i "s/^# *maxmemory <bytes>/maxmemory 256mb/" /etc/redis/redis.conf
    fi
    sudo systemctl restart redis-server || { echo "Failed to start Redis" | tee -a install.log; exit 1; }

    echo "Setting up Nextcloud data directory..." | tee -a install.log
    sudo mkdir -p ${DATA_DIR}
    sudo chown -R www-data:www-data ${DATA_DIR}
    sudo chmod 750 ${DATA_DIR}

    # Download and set up Nextcloud
    echo "Downloading and configuring Nextcloud..." | tee -a install.log
    wget https://download.nextcloud.com/server/releases/latest.zip -P /tmp || { echo "Failed to download Nextcloud" | tee -a install.log; exit 1; }
    sudo unzip /tmp/latest.zip -d /var/www/
    sudo chown -R www-data:www-data /var/www/nextcloud
    sudo chmod -R 755 /var/www/nextcloud

    echo "Configuring Apache for Nextcloud with HTTPS redirection..." | tee -a install.log
    sudo bash -c "cat > /etc/apache2/sites-available/nextcloud.conf <<EOF
<VirtualHost *:80>
    ServerAdmin admin@${SUBDOMAIN}
    DocumentRoot /var/www/nextcloud
    ServerName ${SUBDOMAIN}
    
    Alias /nextcloud "/var/www/nextcloud/"

    <Directory /var/www/nextcloud/>
        Require all granted
        AllowOverride All
        Options FollowSymlinks MultiViews
        <IfModule mod_dav.c>
            Dav off
        </IfModule>
    </Directory>

    RewriteEngine on
    RewriteCond %{SERVER_NAME} =${SUBDOMAIN}
    RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

    sudo a2ensite nextcloud.conf
    sudo a2enmod rewrite headers env dir mime
    sudo systemctl reload apache2 || { echo "Failed to reload Apache" | tee -a install.log; exit 1; }

    echo "Obtaining SSL certificate with Certbot..." | tee -a install.log
    sudo certbot --apache -d ${SUBDOMAIN} --non-interactive --agree-tos -m admin@${SUBDOMAIN} || { echo "Failed to obtain SSL certificate" | tee -a install.log; exit 1; }

    echo "Running Nextcloud CLI installer..." | tee -a install.log
    sudo -u www-data php /var/www/nextcloud/occ maintenance:install --database "mysql" --database-name "${DB_NAME}" --database-user "${MARIADB_USER}" --database-pass "${MARIADB_PASSWORD}" --admin-user "admin" --admin-pass "admin-password" --data-dir="${DATA_DIR}" || { echo "Nextcloud CLI installation failed" | tee -a install.log; exit 1; }

    # Set trusted domains to resolve the admin error
    echo "Configuring trusted domains..." | tee -a install.log
    sudo -u www-data php /var/www/nextcloud/occ config:system:set trusted_domains 0 --value=${SUBDOMAIN}

    echo "Nextcloud installation completed successfully!" | tee -a install.log
}

# Display admin login info at the end of the installation
echo -e "\033[0;31m============================================\033[0m" | tee -a install.log
echo -e "\033[0;31mAdmin Login Information:\033[0m" | tee -a install.log
echo -e "\033[0;31mUsername: admin\033[0m" | tee -a install.log
echo -e "\033[0;31mPassword: admin-password\033[0m" | tee -a install.log
echo -e "\033[0;31m============================================\033[0m" | tee -a install.log

# Run the script functions
get_user_input
create_install_log
install_nextcloud
