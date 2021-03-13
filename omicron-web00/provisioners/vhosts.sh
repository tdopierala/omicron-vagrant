#!/usr/bin/env bash

server="omicron00.local"
#IFS=$'\n' read -d '' -r -a APPS < /vmdir/provisioners/vhosts.txt
json="/vmdir/provisioners/vhosts.json"

if [[ ! -f $json ]]; then
    echo -e "File $json don't exist. Script stoped."
    exit 1
fi

echo -e "\n=> Setting symlinks for vhosts..."

if [[ ! -d /mnt/repo/phpmyadmin ]]; then
	if [ -x "$(command -v git)" ]; then
		git clone https://github.com/phpmyadmin/phpmyadmin /mnt/repo/phpmyadmin >> /vmdir/log/vm-build-$(date +\%F).log 2>&1
	fi
fi

for node in $(jq -c ".vhosts[]" $json)
do
	name=$(echo $node | jq -r ".name")
    path=$(echo $node | jq -r ".path")
    gitrepo=$(echo $node | jq -r ".gitrepo")

	if [[ ! -z "$gitrepo" && ! -d /mnt/repo/$name ]]; then
		if [ -x "$(command -v git)" ]; then
			git clone https://github.com/tdopierala/$name /mnt/repo/$name >> /vmdir/log/vm-build-$(date +\%F).log 2>&1
		fi
	fi

    if [[ -L /var/www/html/$name ]]; then
        echo -e " - removing old symlink $name"
    	rm /var/www/html/$name
    fi

    echo -e " - creating new symlink $name"
    ln -s "/mnt/repo/$path$name" "/var/www/html/"$name >> /vmdir/log/vm-build-$(date +\%F).log 2>&1
done

#echo -e "\n=> Adding nonexistent symlinks for vhosts..."
#echo -e "\n Adding nonexistent symlinks for vhosts...\n" >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
#for node in "${APPS[@]}"
#do
#	IFS='|' read -r -a dir <<< "$node"
#    if [[ ! -L /var/www/html/$dir ]]; then
#		ln -s "/mnt/repo/${dir[0]}" "/var/www/html/"$dir >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
#        echo -e " > generating symlink for vhost $dir (/var/www/html/$dir)"
#	fi
#done

# usuwanie istniejących vhostów

echo -e "\n=> Disabling vhosts..."
echo -e "\n Disabling vhosts...\n" >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
for site in `sudo apache2ctl -S | grep '80 namevhost' | grep -o 'sites-enabled/[^:]*' | cut -c 15-`
do
	if [[ "$site" != "000-default.conf" ]]
	then
		a2dissite $site >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ -f /etc/apache2/sites-available/${site} ]]; then
			rm /etc/apache2/sites-available/${site} >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
		fi

		echo -e " - vhost $site disabled and removed"
	fi
done


# usuwanie pozostałych vhostów

echo -e "\n Removing old vhosts...\n" >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
for site in /etc/apache2/sites-available/*
do
	file=$(basename $site)
	if [[ "$file" != "000-default.conf" && "$file" != "default-ssl.conf" ]]
	then
		if [[ -f /etc/apache2/sites-available/${file} ]]; then
			rm /etc/apache2/sites-available/${file} >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
		fi
		echo -e " - removing old config: $file"
	fi
done

for site in /vmdir/configs/vhosts/*
do
	file=$(basename $site)
	rm /vmdir/configs/vhosts/${file} >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
done


echo -e "\n=> Generating and setuping vhosts..."
echo -e "\n Generating and setuping vhosts...\n" >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
for node in $(jq -c ".vhosts[]" $json)
do
	host=$(echo $node | jq -r ".name")
	domain="${host}.${server}"
	dir=$(echo $node | jq -r ".dir")
	config="$host.conf"

	if [[ $(echo $node | jq -r ".ssl") == "true" ]]; then
		ssl="https"
	else
		ssl="http"
	fi

	if [[ -f /vmdir/configs/vhosts/${host}.conf ]]; then
		rm /vmdir/configs/vhosts/${host}.conf >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	fi

	/vmdir/provisioners/makeconf.sh ${server} ${host} ${ssl} ${dir} > /vmdir/configs/vhosts/${host}.conf
	echo -e " - [$host]: vhost config generated"

	if [[ -f /etc/apache2/sites-available/$config ]]; then
		rm /etc/apache2/sites-available/$config >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	fi

	cp /vmdir/configs/vhosts/$config /etc/apache2/sites-available/$config >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	a2ensite $config >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	echo -e " - [$host]: vhost enabled from config $config"

	if [[ ! -d /vmdir/configs/cert ]]; then
		mkdir /vmdir/configs/cert
	fi

	cd /vmdir/configs/cert/

	key="${domain}.key"

	if [[ ! -f /vmdir/configs/cert/$key ]]; then
		echo -e " - [$host]: generating key for $domain..."
		openssl genrsa -out $key 2048 >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ ! -f /vmdir/configs/cert/"${domain}.cert" ]]; then
			echo -e " - [$host]: generating certificate for $domain..."
			openssl req -new -x509 -key $key -out $(echo "$domain.cert") -days 3650 -subj /CN=$domain >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
		fi
	else
		echo -e " - [$host]: certificate for $domain was already generated..."
	fi

done

usermod -a -G vboxsf www-data >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

echo -e "\n=> Reloading Apache\n"

service apache2 restart >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

echo " - "$(sudo service apache2 status | grep Active: | xargs)
