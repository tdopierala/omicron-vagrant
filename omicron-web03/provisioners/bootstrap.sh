#!/usr/bin/env bash

echo -e "\n"

echo -e "\n=> Updating packages list...\n"
apt-get update >> /vagrant/log/vm_build.log 2>&1
apt-get upgrade >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Install base packages...\n"
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Apache Server...\n"
apt-get -y install apache2 >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Lucee Server...\n"
wget https://cdn.lucee.org/lucee-5.2.8.050-pl0-linux-x64-installer.run
chmod +x lucee-5.2.8.050-pl0-linux-x64-installer.run
#./lucee-5.2.8.050-pl0-linux-x64-installer.run

#echo -e "\n=> Installing Java JRE\n"
#apt-get -y install default-jre >> /vagrant/log/vm_install.log 2>&1

#apt-get -y install libstdc++5 >> /vagrant/log/vm_install.log 2>&1

#echo -e "\n=> Installing ColdFusion 11 Server\n"
#cp /mnt/storage/ColdFusion_11_WWEJ_linux64.bin /home/vagrant/ >> /vagrant/log/vm_build.log 2>&1
#cd /home/vagrant/ >> /vagrant/log/vm_build.log 2>&1
#./ColdFusion_11_WWEJ_linux64.bin [-f /vagrant/configs/cf11_silent.properties] >> /vagrant/log/vm_build.log 2>&1

#echo -e "\n=> Setting document root to public directory\n"
#ln -s /mnt/repo/cf.pl.malpkaexpress.intranet/ /var/www/html/intranet >> /vagrant/log/vm_build.log 2>&1

#if ! [ -L /var/www ]; then
#  rm -rf /var/www
#  ln -fs /vagrant /var/www
#fi

#echo -e "\n=> Restarting Apache\n"
#service apache2 restart >> /vagrant/log/vm_build.log 2>&1

#filename="vm_install.log";
#touch /vagrant/log/${filename}

#echo -e "\n--- installing defults\n"
#cd /vagrant-base/provisioners/ >> /vagrant/log/vm_install.log 2>&1
#bash ./install-defaults.sh >> /vagrant/log/vm_install.log 2>&1

#echo -e "\n=> Aditional settings\n"
#cat /vagrant/configs/etc/motd > /etc/motd
#cat /vagrant/configs/etc/php7.1.ini > /etc/php/7.1/apache2/php.ini