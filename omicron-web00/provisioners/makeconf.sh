#!/usr/bin/env bash

url=$1	# argument 1
host=$2	# argument 2
ssl=$3	# argument 3
root=$4	# argument 4

domain="${host}.${url}"

if [[ root == "" ]]; then
	path=${host}
else
	path="${host}/${root}"
fi

	echo "<VirtualHost *:80>"
	echo ""
	echo "	ServerName ${domain}"
	echo "	ServerAdmin webmaster@wardx.net"
	echo "	DocumentRoot /var/www/html/${path}"
	echo ""

if [[ ${ssl} == "https" ]]; then

	echo "	Redirect permanent / https://${domain}"
	echo "</VirtualHost>"
	echo ""
	echo "<VirtualHost *:443>"
	echo ""
	echo "	ServerName ${domain}"
	echo "	ServerAdmin webmaster@wardx.net>"
	echo "	DocumentRoot /var/www/html/${path}"
	echo ""
	echo "	SSLEngine on"
	echo "	SSLCertificateFile /vagrant/configs/cert/${domain}.cert"
	echo "	SSLCertificateKeyFile /vagrant/configs/cert/${domain}.key"
	echo ""

fi

	echo "	ErrorLog \${APACHE_LOG_DIR}/error.log"
	echo "	CustomLog \${APACHE_LOG_DIR}/access.log combined"
	echo ""
	echo "	<Directory /var/www/html/${path}/>"
	echo ""
	echo "		<IfModule mod_rewrite.c>"
	echo "			RewriteEngine On"
	echo "			RewriteCond %{REQUEST_FILENAME} !-f"
	echo "			RewriteRule ^ index.php [L]"
	echo "		</IfModule>"
	echo ""
	echo "		Options FollowSymLinks"
	echo "		AllowOverride All"
	echo "			Order allow,deny"
	echo "			Allow from all"
	echo "	</Directory>"
	echo "</VirtualHost>"
	echo ""
