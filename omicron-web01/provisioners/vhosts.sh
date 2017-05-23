#!/usr/bin/env bash

echo -e "\n=> Setting vhosts\n"
cat /vagrant/configs/vhosts/000-default.conf > /etc/apache2/sites-available/000-default.conf
cat /vagrant/configs/vhosts/default-ssl.conf > /etc/apache2/sites-available/default-ssl.conf
cat /vagrant/configs/vhosts/local.wardx.net.conf > /etc/apache2/sites-available/local.wardx.net.conf
cat /vagrant/configs/vhosts/local.dopierala.net.pl.conf > /etc/apache2/sites-available/local.dopierala.net.pl.conf
cat /vagrant/configs/vhosts/local.skynet.omicron.net.pl.conf > /etc/apache2/sites-available/local.skynet.omicron.net.pl.conf

echo -e "\n=> Enabling vhosts\n"
a2ensite local.wardx.net.conf >> /vagrant/log/vhosts.log 2>&1
a2ensite local.dopierala.net.pl.conf >> /vagrant/log/vhosts.log 2>&1
a2ensite local.skynet.omicron.net.pl.conf >> /vagrant/log/vhosts.log 2>&1

echo -e "\n=> Reloading Apache\n"
service apache2 reload >> /vagrant/log/vhosts.log 2>&1