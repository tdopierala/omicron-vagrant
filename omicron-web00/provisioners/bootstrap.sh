#!/usr/bin/env bash

echo -e "\n=> Updating packages list"
sudo apt-get -y update				>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install base packages"
/vmdir/prov/build-essential.sh		>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Installing Lynx"
/vmdir/prov/lynx.sh					>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install Node.js"
/vmdir/prov/nodejs.sh				>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Installing Apache Server"
/vmdir/prov/apache2.sh				>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Installing PHP packages"
/vmdir/prov/php7.sh					>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Install MySQL packages and settings"
/vmdir/prov/mysql.sh				>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Installing Composer"
/vmdir/prov/composer.sh				>> /vmdir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

cd ~
sudo apt-get -y install figlet		>> /vmdir/log/vm-build-$(date +\%F).log 2>&1
sudo figlet "omicron-web00" > motd
sudo mv motd /etc/motd

echo -e "\n"
