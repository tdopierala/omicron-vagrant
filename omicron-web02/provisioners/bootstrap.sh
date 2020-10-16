#!/usr/bin/env bash

# Variables
phpv=5.6

DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345

IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

echo -e "\n"

echo -e "\n=> Updating packages list..."
#apt-get -y update >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
#apt-get -yq upgrade >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Install base packages..."
apt-get -y install vim net-tools curl build-essential software-properties-common git zip unzip >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Installing Apache Server..."
apt-get -y install apache2 >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Adding ServerName configuration..."
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
a2enconf servername >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

echo -e "\n=> Enabling mod-rewrite..."
a2enmod rewrite >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Enabling ssl mod..."
a2enmod ssl >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

echo -e "\n=> Enabling headers mod..."
a2enmod headers >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

service apache2 reload >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Installing PHP${phpv} packages..."
apt-get -y install ca-certificates apt-transport-https >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
echo "deb https://packages.sury.org/php/ buster main" | sudo tee /etc/apt/sources.list.d/php.list >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

apt-get update >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install php${phpv} php${phpv}-cli php${phpv}-common php${phpv}-mysql php${phpv}-xml php${phpv}-sqlite php${phpv}-gd php${phpv}-intl libapache2-mod-php${phpv} >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install php${phpv}-curl php${phpv}-mbstring >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
apt-get -y install php-gettext php-pear >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

#########################################################################################

echo -e "\n=> Install MySQL packages and settings..."
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
apt-get -y install mariadb-server >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* to '$DBUSER'@'%' identified by '$DBPASSWD' WITH GRANT OPTION;" >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1

if [[ -f /vagrant-dir/backup/full-backup-latest.sql ]]; then
	echo -e "\n=> Loading database from backup..."
	#mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/full-backup-$(date +\%F).sql
	mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/full-backup-latest.sql
else
	echo -e "\n=> Initializing new database..."
	mysql -uroot -p$DBPASSWD < /vagrant-dir/backup/database.sql
fi

#########################################################################################

#echo -e "\n=> Setting symlinks for vhosts..."
#for node in "${APPS[@]}"
#do
#	IFS='|' read -r -a dir <<< "$node"
#    ln -s "/mnt/repo/${dir[0]}" "/var/www/html/"$dir >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
#done

echo -e "\n"