#!/usr/bin/env bash

#url="omicron00.local"
#host=${vhost[0]}
#root=${vhost[2]}
#ssl=${vhost[1]}

url=$1	# argument 1
host=$2	# argument 2
ssl=$3	# argument 3
root=$4	# argument 4

domain="${host}.${url}"
path="${host}${root}"

if [[ ${ssl} == "https" ]]; then

	echo "<VirtualHost *:80>"
	echo ""
	echo "	ServerName ${domain}"
	echo "	ServerAdmin webmaster@wardx.net"
	echo "	DocumentRoot /var/www/html/${path}"
	echo ""
	echo "	Redirect permanent / https://${domain}/"
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
	echo "	<Directory /var/www/html/"${path}"/>"
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

else

	echo "<VirtualHost *:80>"
	echo ""
	echo "	ServerName ${domain}"
	echo "	ServerAdmin webmaster@wardx.net"
	echo "	DocumentRoot /var/www/html/${path}"
	echo ""
	echo "	<Directory /var/www/html/"${path}"/>"
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

fi
