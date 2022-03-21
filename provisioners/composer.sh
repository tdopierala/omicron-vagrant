#!/usr/bin/env bash

#echo -e "\n=> Installing Composer"

if [ ! -x "$(command -v composer)" ]; then

    if [ -x "$(command -v php)" ]; then

        echo -e "\n--> downloading composer file..."
        curl -sS https://getcomposer.org/installer | php

        if [ -f "/usr/local/bin/composer" ]; then
            echo -e "\n--> removing old composer file..."
            sudo rm /usr/local/bin/composer
        fi

        echo -e "\n--> installing new composer file..."
        sudo mv -f composer.phar /usr/local/bin/composer
        sudo chmod +x /usr/local/bin/composer
    
    else
        echo -e "\n--> required php is not available"
    fi

else
    echo -e "\n--> package $(composer --version) is up to date, nothing to do"
fi

