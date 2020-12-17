#!/usr/bin/env bash

#echo -e "\n=> Installing Apache Server..."

packages=( apache2 )
apache2mods=( rewrite ssl headers )

for pkg in "${packages[@]}"
do

    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo -e "\n--> installing $pkg..."
        sudo apt-get -y install $pkg

        echo -e "\n--> adding ServerName configuration..."
        echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/servername.conf
        sudo a2enconf servername

        echo -e "\n--> apache reload..."
        sudo service apache2 reload
    fi

done

for mod in "${apache2mods[@]}"
do

    if [ $(sudo apache2ctl -M | grep -c $mod) -eq 0 ];
    then
        echo -e "\n--> enabling apache2 mod: $mod..."
        sudo a2enmod $mod
    fi

done

echo -e "\n--> apache reload..."
sudo service apache2 reload