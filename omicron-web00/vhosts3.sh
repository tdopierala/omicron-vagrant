#!/usr/bin/env bash

url="omicron00.local"
IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

#for node in "${APPS[@]}"
#do
	IFS='|' read -r -a vhost <<< "${APPS[8]}"
	if [[ -f /vagrant-dir/configs/vhosts2/${vhost[0]}.conf ]]; then
		rm /vagrant-dir/configs/vhosts2/${vhost[0]}.conf
	fi

	host=${vhost[0]}
	domain="${host}.${url}"
	root=${vhost[2]}
	path="${host}${root}"

	echo $1
	echo $2
	echo $3

	if [[ ${vhost[1]} == "https" ]]; then

		echo "<VirtualHost *:80>"
		echo "	ServerName ${domain}"
		echo "	ServerAdmin webmaster@wardx.net>"
		echo "	DocumentRoot /var/www/html/${path}"
		echo ""
		echo "	Redirect permanent / https://${domain}/"
		echo "</VirtualHost>"
		echo ""
		echo "<VirtualHost *:443>"
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
		echo "	ServerName ${domain}"
		echo "	ServerAdmin webmaster@wardx.net>"
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

	#echo $fileconf > /vagrant-dir/configs/vhosts2/$host.conf
	#echo $server

#done
