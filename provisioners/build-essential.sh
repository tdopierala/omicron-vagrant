#!/usr/bin/env bash

#echo -e "\n=> Install base packages..."

packages=( vim net-tools curl build-essential software-properties-common git zip unzip )

for pkg in "${packages[@]}"
do

    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        #apt-get -y install $pkg;
        echo "apt-get -y install $pkg"
    fi

done
