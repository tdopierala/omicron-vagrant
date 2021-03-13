#!/usr/bin/env bash

#echo -e "\n=> Installing Lynx for omi-search..."

packages=( lynx )

for pkg in "${packages[@]}"
do

    if [ $(dpkg-query -W -f='${Status}' $pkg 2>/dev/null | grep -c "ok installed") -eq 0 ];
    then
        echo -e "\n--> installing package $pkg"
        sudo apt-get -y install $pkg
    fi

done
