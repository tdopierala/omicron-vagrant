#!/usr/bin/env bash

# Variables
#DBHOST=localhost
#DBNAME=playground
#DBUSER=omicron
#DBPASSWD=12345

echo -e "\n=> Updating packages list\n"
apt-get update

echo -e "\n=> Install base packages\n"
apt-get -y install vim curl build-essential python-software-properties git zip unzip >> /vagrant/log/vm_build.log 2>&1

#echo -e "\n=> Install MySQL specific packages and settings\n"
#debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
#debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
#apt-get -y install mysql-server >> /vagrant/log/vm_build.log 2>&1

#echo -e "\n=> Setting up our MySQL user and db\n"
#mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME" >> /vagrant/log/vm_build.log 2>&1
#mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'" >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Apache Server\n"
apt-get -y install php5 apache2 >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing PHP packages\n"
apt-get -y install apt-transport-https lsb-release ca-certificates >> /vagrant/log/vm_build.log 2>&1
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg >> /vagrant/log/vm_build.log 2>&1
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
apt-get update
apt-get -y install php7.1 libapache2-mod-php7.1 php7.1-curl php7.1-gd php7.1-mysql php-gettext php7.1-intl php7.1-mbstring php7.1-xml php-pear >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Enabling php7.1\n"
a2dismod php5 >> /vagrant/log/vm_build.log 2>&1
a2enmod php7.1 >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Enabling mod-rewrite\n"
a2enmod rewrite >> /vagrant/log/vm_build.log 2>&1

#echo -e "\n=> Allowing Apache override to all\n"
#sed -i "s/AllowOverride None/AllowOverride All/g" /etc/apache2/apache2.conf

echo -e "\n=> Setting document root to public directory\n"
#rm -rf /var/www
#ln -fs /vagrant/public /var/www
#ln -s /mnt/repo/ /var/www/html/r >> /vagrant/log/vm_build.log 2>&1

#if ! [ -L /var/www ]; then
#  rm -rf /var/www
#  ln -fs /vagrant /var/www
#fi

echo -e "\n=> Restarting Apache\n"
service apache2 restart >> /vagrant/log/vm_build.log 2>&1

echo -e "\n=> Installing Composer\n"
curl --silent https://getcomposer.org/installer | php >> /vagrant/log/vm_build.log 2>&1
mv composer.phar /usr/local/bin/composer

cd /vagrant

if [[ -s /vagrant/composer.json ]] ;then
  sudo -u vagrant -H sh -c "composer install" >> /vagrant/log/vm_build.log 2>&1
fi

#echo -e "\n=> Aditional settings\n"
#cat /vagrant/configs/etc/motd > /etc/motd
#cat /vagrant/configs/.bashrc > /home/vagrant/.bashrc
#cat /vagrant/configs/.vimrc > /home/vagrant/.vimrc
#cat /vagrant/configs/etc/php7.1.ini > /etc/php/7.1/apache2/php.ini