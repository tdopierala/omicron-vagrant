#!/usr/bin/env bash

echo -e "\n=> Setting vhosts\n"
cat /vagrant/configs/vhosts/000-default.conf > /etc/apache2/sites-available/000-default.conf
cat /vagrant/configs/vhosts/default-ssl.conf > /etc/apache2/sites-available/default-ssl.conf
cat /vagrant/configs/vhosts/local.shrek.conf > /etc/apache2/sites-available/local.shrek.conf
cat /vagrant/configs/vhosts/local.shrek2.conf > /etc/apache2/sites-available/local.shrek2.conf
cat /vagrant/configs/vhosts/local.rodpodborem.net.conf > /etc/apache2/sites-available/local.rodpodborem.net.conf
cat /vagrant/configs/vhosts/local.szkolyjazdy.net.pl.conf > /etc/apache2/sites-available/local.szkolyjazdy.net.pl.conf

echo -e "\n=> Enabling vhosts\n"
a2ensite local.shrek.conf >> /vagrant/log/vhosts.log 2>&1
a2ensite local.shrek2.conf >> /vagrant/log/vhosts.log 2>&1
a2ensite local.rodpodborem.net.conf >> /vagrant/log/vhosts.log 2>&1
a2ensite local.szkolyjazdy.net.pl.conf >> /vagrant/log/vhosts.log 2>&1

echo -e "\n=> Reloading Apache\n"
service apache2 reload >> /vagrant/log/vhosts.log 2>&1