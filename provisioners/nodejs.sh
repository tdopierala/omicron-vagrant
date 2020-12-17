#!/usr/bin/env bash

#echo -e "\n=> Install base packages..."

version=15
packages=( nodejs )

for pkg in "${packages[@]}"
do

    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then

        echo -e "\n--> installing $pkg v$version.x"
        curl -sL https://deb.nodesource.com/setup_$version.x | sudo bash -
        sudo apt-get -y install $pkg

    else

        if [ ! $(nodejs -v | grep v$version) ];
        then
            echo -e "\n--> removing $pkg $(nodejs -v)"
            sudo apt-get -y remove nodejs
            echo -e "\n--> installing $pkg v$version.x"
            curl -sL https://deb.nodesource.com/setup_$version.x | sudo bash -
            sudo apt-get -y install nodejs
        else
            echo -e "\n--> package $pkg $(nodejs -v) is up to date, nothing to do"
        fi

    fi

done
