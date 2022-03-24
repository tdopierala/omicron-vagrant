#!/usr/bin/env bash

echo -e "\n"

echo -e "\n=> Updating packages list...\n"
apt-get update >> /vagrant/log/vm_build.log 2>&1
apt-get upgrade >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Install base packages...\n"
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip apt-transport-https >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Apache Server...\n"
apt-get -y install apache2 >> /vagrant/log/vm_build.log 2>&1

sudo chgrp -R www-data /var/www/html
sudo usermod -a -G www-data vagrant
sudo chmod -R 775 /var/www/html


#echo -e "\n=> Installing PHP packages...\n"
#apt-get -y install php >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Java JDK\n"
apt-get -y install default-jdk >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Apache Tomcat...\n"
TOMCAT=9.0.16
#apt-get -y install tomcat7 >> /vagrant/log/vm_build.log 2>&1
wget http://ftp.man.poznan.pl/apache/tomcat/tomcat-9/v$TOMCAT/bin/apache-tomcat-$TOMCAT.tar.gz  >> /vagrant/log/vm_build.log 2>&1
sudo tar -xzvf apache-tomcat-$TOMCAT.tar.gz  >> /vagrant/log/vm_build.log 2>&1

sudo mv apache-tomcat-$TOMCAT /opt/tomcat  >> /vagrant/log/vm_build.log 2>&1
sudo useradd -r tomcat9 --shell /bin/false  >> /vagrant/log/vm_build.log 2>&1
sudo chown -R tomcat9 /opt/tomcat/  >> /vagrant/log/vm_build.log 2>&1
sudo /opt/tomcat/bin/startup.sh >> /vagrant/log/vm_build.log 2>&1

#echo -e "\n=> Installing Lucee Server...\n"
#LUCEE=lucee-5.2.9.031-pl1-linux-x64-installer.run
#wget https://cdn.lucee.org/$LUCEE  >> /vagrant/log/vm_build.log 2>&1
#sudo chmod +x $LUCEE  >> /vagrant/log/vm_build.log 2>&1
#sudo ./$LUCEE --mode unattended --optionfile /vagrant/configs/lucee-options.txt >> /vagrant/log/vm_build.log 2>&1

#echo -e "\n=> Installing CommandBox...\n"
#curl -fsSl https://downloads.ortussolutions.com/debs/gpg | sudo apt-key add - >> /vagrant/log/vm_build.log 2>&1
#echo "deb http://downloads.ortussolutions.com/debs/noarch /" | sudo tee -a /etc/apt/sources.list.d/commandbox.list >> /vagrant/log/vm_build.log 2>&1
#sudo apt-get update && sudo apt-get install commandbox >> /vagrant/log/vm_build.log 2>&1

#cp /vagrant/index.cfm /var/www/html/

echo -e "\n=> Setting document root to public directory...\n"
APPS=('cfml-cfwheels-test' 'cfml-coldbox-test' 'cfml-monkey-express' 'playground')
for dir in "${APPS[@]}"
do :
    rm -f "/var/www/html/"$dir >> /vagrant/log/vm_build.log 2>&1
    ln -s "/mnt/repo/"$dir "/var/www/html/"$dir >> /vagrant/log/vm_build.log 2>&1
done

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