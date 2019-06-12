#!/usr/bin/env bash

url="omicron00.local"

echo -e "\n=> Disabling vhosts:"
for site in `apache2ctl -S | grep namevhost | grep -o 'sites-enabled/[^:]*' | cut -c 15-`; do
    if [[ "$site" != "000-default.conf" ]]
    then
        a2dissite $site >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
        echo -e "> vhost $site disabled"
    fi
done

echo -e "\n=> Setuping vhosts:"
for file in /vagrant/configs/vhosts/*
do
    if [[ -f $file ]]; then
        filename=$(basename $file)
        
        if [[ -f /etc/apache2/sites-available/$filename ]]; then
            rm /etc/apache2/sites-available/$filename
        fi

        #generating vhost file

        host=$(echo $filename | rev | cut -c 6- | rev)
        domain=$(echo "$host.$url")

        : '
        read -r -d '' fileconf <<- EOM
        <VirtualHost *:443>
            ServerName $domain
            ServerAdmin webmaster@wardx.net
            DocumentRoot /var/www/html/$host/public

            SSLEngine on
            SSLCertificateFile /vagrant/configs/cert/$domain.cert
            SSLCertificateKeyFile /vagrant/configs/cert/$domain.key

            #Redirect permanent / https://symfony4-rest-api.omicron00.local/

            ErrorLog ${APACHE_LOG_DIR}/error.log
            CustomLog ${APACHE_LOG_DIR}/access.log combined

            <Directory /var/www/html/$domain/public/>

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
        </VirtualHost>
        EOM
        '

        #coping vhost file
        
        if [[ -f /etc/apache2/sites-available/$filename ]]; then
            rm /etc/apache2/sites-available/$filename >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
        fi
        
        cp /vagrant/configs/vhosts/$filename /etc/apache2/sites-available/$filename >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
        a2ensite $filename >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
        echo -e "> generating vhost $filename"
        
        cd /vagrant-dir/configs/cert/
        
        key=$(echo "$domain.key")

        if [[ ! -f /vagrant-dir/configs/cert/$key ]]; then
            echo -e "> generating key for $domain..."
            openssl genrsa -out $key 2048 >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

            if [[ ! -f /vagrant-dir/configs/cert/"$domain.cert" ]]; then
                echo -e "> generating certificate for $domain..."
                openssl req -new -x509 -key $key -out $(echo "$domain.cert") -days 3650 -subj /CN=$domain >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
            fi
        else
            echo -e "> certificate for $domain was already generated..."
        fi
    fi
done

echo -e "\n=> Reloading Apache\n"
usermod -a -G vboxsf www-data >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
#service apache2 reload >> /vagrant/log/vhosts.log 2>&1
service apache2 start >> /vagrant/log/vhosts.log 2>&1