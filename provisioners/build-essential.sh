#!/usr/bin/env bash

#echo -e "\n=> Install base packages..."

sudo apt-get update

packages=( vim net-tools curl build-essential software-properties-common git zip unzip jq )

for pkg in "${packages[@]}"
do

    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo -e "\n--> installing package $pkg"
        sudo apt-get -y install $pkg
    fi

done
