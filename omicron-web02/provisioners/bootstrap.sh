#!/usr/bin/env bash

echo -e "\n=> Updating packages list\n"
apt-get update

echo -e "\n=> Install base packages\n"
apt-get -y install vim curl build-essential python-software-properties git zip unzip >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Apache Server\n"
apt-get -y install php5 apache2 >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing PHP packages\n"
apt-get -y install php5 libapache2-mod-php5 php5-curl php5-gd php5-mysql php-gettext php5-intl >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Enabling mod-rewrite\n"
a2enmod rewrite >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Setting document root to public directory\n"
ln -s /mnt/repo/php.shrek/ /var/www/html/local.shrek >> /vagrant/log/vm_build.log 2>&1
ln -s /mnt/repo/php.shrek2/ /var/www/html/local.shrek2 >> /vagrant/log/vm_build.log 2>&1
ln -s /mnt/repo/php.net.rodpodborem/ /var/www/html/local.rodpodborem.net >> /vagrant/log/vm_build.log 2>&1
ln -s /mnt/repo/php.pl.net.szkolyjazdy/ /var/www/html/local.szkolyjazdy.net.pl >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Restarting Apache\n"
service apache2 restart >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Composer\n"
curl --silent https://getcomposer.org/installer | php >> /vagrant/log/vm_build.log 2>&1
mv composer.phar /usr/local/bin/composer

cd /vagrant

if [[ -s /vagrant/composer.json ]] ;then
  sudo -u vagrant -H sh -c "composer install" >> /vagrant/log/vm_build.log 2>&1
fi

echo -e "\n=> Aditional settings\n"
cat /vagrant/configs/etc/motd > /etc/motd
cat /vagrant/configs/.bashrc > /home/vagrant/.bashrc
cat /vagrant/configs/.vimrc > /home/vagrant/.vimrc
cat /vagrant/configs/etc/php5.ini > /etc/php5/apache2/php.ini