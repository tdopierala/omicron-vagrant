#!/usr/bin/env bash

echo -e "\n=> Setuping vhosts:"
for file in /vagrant/configs/vhosts/*
do
    if [[ -f $file ]]; then
        filename=$(basename $file)
        sudo cp /vagrant/configs/vhosts/$filename /etc/apache2/sites-available/$filename
        sudo a2ensite $filename
        echo -e " $filename"
    fi
done
#echo -e "\n"

echo -e "\n=> Reloading Apache\n"
service apache2 reload >> /vagrant/log/vhosts.log 2>&1