#!/usr/bin/env bash
echo -e "\n"

echo -e "\n=> Setting vhosts...\n"
cat /vagrant/configs/vhosts/000-default.conf    > /etc/apache2/sites-available/000-default.conf
cat /vagrant/configs/vhosts/default-ssl.conf    > /etc/apache2/sites-available/default-ssl.conf
cat /vagrant/configs/vhosts/omicron.conf        > /etc/apache2/sites-available/omicron.conf
cat /vagrant/configs/vhosts/odin.conf           > /etc/apache2/sites-available/odin.conf

echo -e "\n=> Enabling vhosts...\n"
a2ensite omicron.conf >> /vagrant/log/vhosts.log 2>&1
a2ensite odin.conf >> /vagrant/log/vhosts.log 2>&1

echo -e "\n=> Reloading Apache...\n"
usermod -a -G vboxsf www-data
service apache2 reload >> /vagrant/log/vhosts.log 2>&1