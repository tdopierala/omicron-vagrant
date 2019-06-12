#!/usr/bin/env bash

# Variables
DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345
APPS=('phpmyadmin' 'odin' 'omicron' 'frontend' 'feeder' 'php-feed-scanner' 'cakephp-adminlte' 'myweather' 'symfony4-rest-api' 's4api')

echo -e "\n"

echo -e "\n=> Updating packages list...\n"
apt-get update >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get upgrade >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install base packages...\n"
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install Node.js...\n"
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash - >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install nodejs >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Installing Apache Server...\n"
apt-get -y install apache2 >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Installing PHP packages...\n"
apt-get -y install ca-certificates apt-transport-https >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

apt-get update >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install php7.2 php7.2-cli php7.2-common php7.2-curl php7.2-mbstring php7.2-mysql php7.2-xml libapache2-mod-php7.2 php7.2-gd php-gettext php7.2-intl php-pear >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install MySQL packages and settings...\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mysql-server >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* to '$DBUSER'@'%' identified by '$DBPASSWD' WITH GRANT OPTION;" >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

if [[ -f /vagrant-dir/backup/full-backup-latest.sql ]]; then
	echo -e "\n=> Loading database from backup...\n"
	#mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/full-backup-$(date +\%F).sql
	mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/full-backup-latest.sql
else
	echo -e "\n=> Initializing new database...\n"
	mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/database.sql
fi

echo -e "\n=> Enabling mod-rewrite...\n"
a2enmod rewrite >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Enabling ssl mod...\n"
sudo a2enmod ssl >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

sudo a2enmod headers >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Installing Composer\n"
curl -sS https://getcomposer.org/installer | php >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
mv composer.phar /usr/local/bin/composer >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
chmod +x /usr/local/bin/composer >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Setting document root to public directory...\n"
for dir in "${APPS[@]}"
do :
    rm -f "/var/www/html/"$dir >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
    ln -s "/mnt/repo/"$dir "/var/www/html/"$dir >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
    touch "/vagrant/configs/vhosts2/"$dir".conf" >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
done

echo -e "\n"