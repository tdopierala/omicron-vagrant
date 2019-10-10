#!/usr/bin/env bash

# Variables
phpv=7.3

DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345

#APPS=('phpmyadmin' 'odin' 'omicron' 'frontend' 'feeder' 'php-feed-scanner' 'cakephp-adminlte' 'myweather' 'symfony4-rest-api' 's4api')
#IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

echo -e "\n"

echo -e "\n=> Updating packages list...\n"
apt-get -y update >> /vagrant-dir/log/vm-build.log 2>&1
#apt-get -y upgrade >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Install base packages...\n"
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Installing Java Runtime Environment (JRE)\n"
apt-get -y install default-jre >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Installing Java Development Kit (JDK)\n"
apt-get -y install default-jdk >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Installing Apache Server...\n"
apt-get -y install apache2 >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Installing PHP${phpv} packages...\n"
apt-get -y install ca-certificates apt-transport-https >> /vagrant-dir/log/vm-build.log 2>&1
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add - >> /vagrant-dir/log/vm-build.log 2>&1
echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list >> /vagrant-dir/log/vm-build.log 2>&1

apt-get update >> /vagrant-dir/log/vm-build.log 2>&1
apt-get -y install php${phpv} php${phpv}-cli php${phpv}-common php${phpv}-curl php${phpv}-mbstring php${phpv}-mysql php${phpv}-xml libapache2-mod-php${phpv} php${phpv}-gd php-gettext php${phpv}-intl php-pear >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Install MySQL packages and settings...\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Loading database from backup...\n"
if [[ -f /vagrant-dir/databases/promooglebis.sql ]]; then
	mysql -uroot -p$DBPASSWD < /vagrant-dir/databases/promooglebis.sql
fi

echo -e "\n=> Granting database users privileges...\n"
mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* to '$DBUSER'@'%' identified by '$DBPASSWD' WITH GRANT OPTION;" >> /vagrant-dir/log/vm-build.log 2>&1
mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* to 'promoogle'@'%' identified by 'promoogle' WITH GRANT OPTION;" >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Enabling remote connection to database...\n"
sed -i -e 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Enabling mod-rewrite...\n"
a2enmod rewrite >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n=> Enabling ssl mod...\n"
a2enmod ssl >> /vagrant-dir/log/vm-build.log 2>&1

a2enmod headers >> /vagrant-dir/log/vm-build.log 2>&1

echo -e "\n"