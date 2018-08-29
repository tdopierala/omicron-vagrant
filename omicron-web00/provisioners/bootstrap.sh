#!/usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345
APPS=('phpmyadmin' 'odin' 'omicron' 'frontend')

echo -e "\n"

echo -e "\n=> Updating packages list...\n"
apt-get update >> /vagrant/log/vm_build.log 2>&1
apt-get upgrade >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Install base packages...\n"
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Install Node.js...\n"
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash - >> /vagrant/log/vm_build.log 2>&1
apt-get -y install nodejs >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Apache Server...\n"
apt-get -y install apache2 >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing PHP packages...\n"
apt-get -y install ca-certificates apt-transport-https >> /vagrant/log/vm_build.log 2>&1
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - >> /vagrant/log/vm_build.log 2>&1
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list >> /vagrant/log/vm_build.log 2>&1

apt-get update >> /vagrant/log/vm_build.log 2>&1
apt-get -y install php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-mbstring php7.2-mysql php7.2-xml libapache2-mod-php7.2 php7.2-gd php-gettext php7.2-intl php-pear >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Install MySQL packages and settings...\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Loading database...\n"
mysql -uroot -p$DBPASSWD -e "GRANT ALL on *.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" >> /vagrant/log/vm_build.log 2>&1
mysql -uroot -p$DBPASSWD $DBNAME < /vagrant/provisioners/database.sql

echo -e "\n=> Enabling mod-rewrite...\n"
a2enmod rewrite >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Composer\n"
curl -sS https://getcomposer.org/installer | php >> /vagrant/log/vm_build.log 2>&1
mv composer.phar /usr/local/bin/composer >> /vagrant/log/vm_build.log 2>&1
chmod +x /usr/local/bin/composer >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Setting document root to public directory...\n"
for dir in "${APPS[@]}"
do :
    rm -f "/var/www/html/"$dir >> /vagrant/log/vm_build.log 2>&1
    ln -s "/mnt/repo/"$dir "/var/www/html/"$dir >> /vagrant/log/vm_build.log 2>&1
done

echo -e "\n"