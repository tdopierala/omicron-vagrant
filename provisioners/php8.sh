#!/usr/bin/env bash

#echo -e "\n=> Installing PHP${version} packages..."

version=8.0
base_pkg=( ca-certificates apt-transport-https )
php_pkg=( php${version} php${version}-cli php${version}-common php${version}-mysql php${version}-xml php${version}-sqlite php${version}-gd php${version}-intl libapache2-mod-php${version} php${version}-curl php${version}-mbstring php-gettext php-pear php-zip )

install_php() {

    for pkg in "${base_pkg[@]}"
    do
        if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            #echo "$pkg.. "
            sudo apt-get -y install $pkg
        fi
    done

    wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add -
    echo "deb https://packages.sury.org/php/ buster main" | sudo tee /etc/apt/sources.list.d/php.list

    sudo apt-get update

    for pkg in "${php_pkg[@]}"
    do
        if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            #echo "$pkg.. "
            sudo apt-get -y install $pkg
        fi
    done

}

if [ $(dpkg-query -l 2>/dev/null | grep -c php) -eq 0 ];
then
    ## install new php
    echo -e "\n--> installing php$version..."
    install_php
else
    phpv=$(php -v | head -n 1 | cut -d " " -f 2)

    if [ $(php -v | head -n 1 | cut -d " " -f 2 | grep -c $version) -eq 0 ];
    then
        ## remove old php
        echo -e "\n--> removing php$phpv... "
        for pkg in $(dpkg-query -l | grep php | cut -d " " -f 3)
        do
            #echo "$pkg.. "
            sudo apt-get -y remove $pkg
        done

        ## install new php
        echo -e "\n--> installing php$version..."
        install_php

    else
        echo -e "\n--> package php$phpv is up to date, nothing to do"
    fi

fi
