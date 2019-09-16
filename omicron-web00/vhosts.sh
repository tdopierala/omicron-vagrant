#!/usr/bin/env bash

url="omicron00.local"
IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

echo -e "\n=> Disabling vhosts:"
for site in `apache2ctl -S | grep namevhost | grep -o 'sites-enabled/[^:]*' | cut -c 15-`; do
    if [[ "$site" != "000-default.conf" ]]
    then
        a2dissite $site >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
        echo -e "> vhost $site disabled"
    fi
done

for node in "${APPS[@]}"
do
    IFS='|' read -r -a vhost <<< "$node"
    if [[ -f /etc/apache2/sites-available/${vhost[0]}.conf ]]; then
        rm /etc/apache2/sites-available/${vhost[0]}.conf
    fi

    host=${vhost[0]}
    domain=$(echo "$host.$url")
    root=${vhost[2]}

    read -r -d '' server <<- EOM
            ServerName $domain
            ServerAdmin webmaster@wardx.net
            DocumentRoot /var/www/html/$host$root
    EOM

    read -r -d '' directory <<- EOM
            <Directory /var/www/html/$domain$root>
                <IfModule mod_rewrite.c>
                    RewriteEngine On
                    RewriteCond %{REQUEST_FILENAME} !-f
                    RewriteRule ^ index.php [L]
                </IfModule>
                Options FollowSymLinks
                AllowOverride All
                    Order allow,deny
                    Allow from all
            </Directory>
    EOM

    read -r -d '' ssl <<- EOM
            SSLEngine on
            SSLCertificateFile /vagrant/configs/cert/$domain.cert
            SSLCertificateKeyFile /vagrant/configs/cert/$domain.key
    EOM

    if [[ ${vhost[1]} == "https" ]]; then

        read -r -d '' fileconf <<- EOM
        <VirtualHost *:80>
            $server

            Redirect permanent / https://$domain
        </VirtualHost>

        <VirtualHost *:443>
            $server

            $ssl

            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined

            $directory
        </VirtualHost>
        EOM

    else

        read -r -d '' fileconf <<- EOM
        <VirtualHost *:80>
            $server

            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined

            $directory
        </VirtualHost>
        EOM

    fi

    echo $fileconf > /vagrant-dir/configs/vhosts2/$host.conf
done