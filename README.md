<div class="markdown-heading" dir="auto">
<h1 class="heading-element" dir="auto" tabindex="-1">Nextcloud Installation Script</h1>
<a id="user-content-nextcloud-installation-script" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#nextcloud-installation-script" aria-label="Permalink: Nextcloud Installation Script"></a></div>
<p dir="auto">This script automates the installation and configuration of Nextcloud on an Ubuntu 22.04 server. It includes the setup of Apache, MariaDB, PHP 8.1, Redis, and Opcache. Additionally, it offers the option to install SSL certificates using Certbot.</p>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Author</h2>
<a id="user-content-author" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#author" aria-label="Permalink: Author"></a></div>
<ul dir="auto">
<li><strong>Kristian Gasic</strong></li>
<li>Forked by <strong>sokoban</strong> (different directory for nextcloud - data)</li>
<li>License: Free for use</li>
</ul>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Features</h2>
<a id="user-content-features" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#features" aria-label="Permalink: Features"></a></div>
<ul dir="auto">
<li>Automated installation of Nextcloud and necessary dependencies.</li>
<li>Configuration of MariaDB, PHP 8.1, Redis, and Opcache.</li>
<li>Option to install SSL certificates using Certbot.</li>
<li>Detection of existing Nextcloud installation and option to add SSL later..</li>
</ul>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Prerequisites</h2>
<a id="user-content-prerequisites" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#prerequisites" aria-label="Permalink: Prerequisites"></a></div>
<ul dir="auto">
<li>A fresh Ubuntu 22.04 server installation.</li>
<li>Root or sudo access to the server.</li>
</ul>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Usage</h2>
<a id="user-content-usage" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#usage" aria-label="Permalink: Usage"></a></div>
<ul>
<li>
<p dir="auto"><strong>Clone the repository:</strong></p>
<div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto">
<pre>git clone https://github.com/sokkoban/nextcloud.git</pre>
<div class="zeroclipboard-container">&nbsp;</div>
</div>
</li>
</ul>
<p dir="auto"><strong>Navigate to the script directory:</strong></p>
<div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto">
<pre><span class="pl-c1">cd</span> nextcloud</pre>
<div class="zeroclipboard-container">&nbsp;</div>
</div>
<p dir="auto"><strong>Make the script executable:</strong></p>
<div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto">
<pre>chmod +x install_nextcloud.sh</pre>
<div class="zeroclipboard-container">&nbsp;</div>
</div>
<p dir="auto"><strong>Run the script:</strong></p>
<div class="highlight highlight-source-shell notranslate position-relative overflow-auto" dir="auto">
<pre>sudo ./install_nextcloud.sh</pre>
<div class="zeroclipboard-container">&nbsp;</div>
</div>
<ol dir="auto">
<li value="5">
<p dir="auto"><strong>Follow the prompts:</strong></p>
<ul dir="auto">
<li>Enter the MariaDB username and password.</li>
<li>Enter the subdomain for your Nextcloud instance.</li>
</ul>
</li>
<li>
<p dir="auto"><strong>** SSL Installation:**</strong></p>
<ul dir="auto">
<li>You need to have FQDN or subdomain</li>
</ul>
</li>
</ol>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Script Details</h2>
<a id="user-content-script-details" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#script-details" aria-label="Permalink: Script Details"></a></div>
<ul dir="auto">
<li><strong>Function to gather user input:</strong> Prompts the user for MariaDB credentials and the subdomain.</li>
<li><strong>Function to create installation log:</strong> Records the details of the installation, including the MariaDB password in plain text, for future reference.</li>
<li><strong>Function to install Nextcloud:</strong> Installs and configures Apache, MariaDB, PHP 8.1, Redis, and Opcache. Downloads and sets up Nextcloud.</li>
<li><strong>Function to install SSL:</strong> Optionally installs SSL certificates using Certbot.</li>
</ul>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Notes</h2>
<a id="user-content-notes" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#notes" aria-label="Permalink: Notes"></a></div>
<ul dir="auto">
<li>Ensure your DNS settings point the subdomain to your server's IP address.</li>
<li>The script checks for an existing Nextcloud installation and will only offer SSL installation if Nextcloud is already set up.</li>
</ul>
<div class="markdown-heading" dir="auto">
<h2 class="heading-element" dir="auto" tabindex="-1">Troubleshooting</h2>
<a id="user-content-troubleshooting" class="anchor" href="https://github.com/sokkoban/nextcloud/blob/main/README.md#troubleshooting" aria-label="Permalink: Troubleshooting"></a></div>
<ul dir="auto">
<li>If you encounter issues, check the <code>log</code> files located at <code>/var/log/apache2/</code> for Apache errors.</li>
<li>For MariaDB issues, ensure the database and user are created correctly.</li>
<li>Verify firewall rules if you have connectivity issues.</li>
</ul>
<p dir="auto">#############################################################</p>
