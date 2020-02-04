#!/usr/bin/env bash

# Variables
phpv=7.3

DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345

IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

echo -e "\n"

echo -e "\n=> Updating packages list...\n"
apt-get -y update >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
#apt-get -y upgrade >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install base packages...\n"
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Installing Lynx for omi-search...\n"
apt-get -y install lynx >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

#echo -e "\n=> Install Node.js...\n"
#curl -sL https://deb.nodesource.com/setup_12.x | sudo bash - >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
#apt-get -y install nodejs >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Installing Apache Server...\n"
apt-get -y install apache2 >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Adding ServerName configuration...\n"
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf
sudo a2enconf servername

echo -e "\n=> Enabling mod-rewrite...\n"
a2enmod rewrite >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Enabling ssl mod...\n"
sudo a2enmod ssl >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Enabling headers mod...\n"
sudo a2enmod headers >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Installing PHP${phpv} packages...\n"
apt-get -y install ca-certificates apt-transport-https >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
echo "deb https://packages.sury.org/php/ stretch main" | sudo tee /etc/apt/sources.list.d/php.list >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

apt-get update >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install php${phpv} php${phpv}-cli php${phpv}-common php${phpv}-curl php${phpv}-mbstring php${phpv}-mysql php${phpv}-xml php${phpv}-sqlite php${phpv}-gd php${phpv}-intl libapache2-mod-php${phpv} >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install php-gettext php-pear >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Install MySQL packages and settings...\n"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mariadb-server >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* to '$DBUSER'@'%' identified by '$DBPASSWD' WITH GRANT OPTION;" >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

if [[ -f /vagrant-dir/backup/full-backup-latest.sql ]]; then
	echo -e "\n=> Loading database from backup...\n"
	#mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/full-backup-$(date +\%F).sql
	mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/full-backup-latest.sql
else
	echo -e "\n=> Initializing new database...\n"
	mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/database.sql
fi

#########################################################################################

echo -e "\n=> Installing Composer\n"
curl -sS https://getcomposer.org/installer | php >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
mv -f composer.phar /usr/local/bin/composer >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
chmod +x /usr/local/bin/composer >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Setting symlinks for vhosts...\n"
for node in "${APPS[@]}"
do
	IFS='|' read -r -a dir <<< "$node"
    ln -s "/mnt/repo/${dir[0]}" "/var/www/html/"$dir >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
done

echo -e "\n"