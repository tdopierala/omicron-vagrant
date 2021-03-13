#!/usr/bin/env bash

#echo -e "\n=> Install MySQL packages and settings..."

DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345

packages=( mariadb-server )

path=/vmdir/backup

for pkg in "${packages[@]}"
do

    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
        sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"
        sudo apt-get -y install $pkg

        sudo mysql -uroot -p$DBPASSWD -e "GRANT ALL PRIVILEGES ON *.* to '$DBUSER'@'%' identified by '$DBPASSWD' WITH GRANT OPTION;"

        if [[ -f $path/full-backup-latest.sql ]]; then
            echo -e "\n=> Loading database from backup..."
            #mysql -uroot -p$DBPASSWD < /vmdir/backup/full-backup-$(date +\%F).sql
            sudo mysql -uroot -p$DBPASSWD < $path/full-backup-latest.sql
        else
            echo -e "\n=> Initializing new database..."
            sudo mysql -uroot -p$DBPASSWD < $path/database.sql
        fi
    fi

done
