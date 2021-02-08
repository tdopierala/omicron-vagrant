#!/usr/bin/env bash

url="omicron00.local"
#IFS=$'\n' read -d '' -r -a APPS < /vmdir/provisioners/vhosts.txt
json="/vmdir/provisioners/vhosts.json"

echo -e "\n=> Setting symlinks for vhosts..."

if [[ ! -d /mnt/repo/phpmyadmin ]]; then
	if [ -x "$(command -v git)" ]; then
		git clone https://github.com/phpmyadmin/phpmyadmin /mnt/repo/phpmyadmin >> /vmdir/log/vm-build-$(date +\%F).log 2>&1
	fi
fi

for node in $(jq -c ".vhosts[]" $json)
do
	name=$(echo $node | jq ".name" | tr -d '"')
	path=$(echo $node | jq ".path" | tr -d '"')

	if [[ ! -d /mnt/repo/$name ]]; then
		if [ -x "$(command -v git)" ]; then
			git clone https://github.com/tdopierala/$name /mnt/repo/$name >> /vmdir/log/vm-build-$(date +\%F).log 2>&1
		fi
	fi

	if [[ ! -L /var/www/html/$name ]]; then
    	ln -s "/mnt/repo/$name/$path" "/var/www/html/"$name >> /vmdir/log/vm-build-$(date +\%F).log 2>&1
	fi
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
for site in `apache2ctl -S | grep '80 namevhost' | grep -o 'sites-enabled/[^:]*' | cut -c 15-`
do
	if [[ "$site" != "000-default.conf" ]]
	then
		a2dissite $site >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ -f /etc/apache2/sites-available/${site} ]]; then
			rm /etc/apache2/sites-available/${site} >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
		fi

		echo -e " > vhost $site disabled"
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
		echo -e " > removing old config: $file"
	fi
done

for site in /vmdir/configs/vhosts/*
do
	file=$(basename $site)
	rm /vmdir/configs/vhosts/${file} >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
done


#

echo -e "\n=> Generating and setuping vhosts..."
echo -e "\n Generating and setuping vhosts...\n" >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
for node in $(jq -c ".vhosts[]" $json)
do
	host=$(echo $node | jq ".name" | tr -d '"')
	domain="${host}.${url}"
	root=$(echo $node | jq ".path" | tr -d '"')
	filename="$host.conf"

	if [[ $(echo $node | jq ".ssl" | tr -d '"') == "true" ]]; then
		ssl="https"
	else
		ssl="http"
	fi

	if [[ -f /vmdir/configs/vhosts/${host}.conf ]]; then
		rm /vmdir/configs/vhosts/${host}.conf >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	fi

	/vmdir/provisioners/makeconf.sh ${url} ${host} ${ssl} ${root} > /vmdir/configs/vhosts/${host}.conf
	echo -e " > vhost config for ${host} generated"

	if [[ -f /etc/apache2/sites-available/$filename ]]; then
		rm /etc/apache2/sites-available/$filename >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	fi

	cp /vmdir/configs/vhosts/$filename /etc/apache2/sites-available/$filename >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	a2ensite $filename >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
	echo -e " > generating vhost $filename"

	if [[ ! -d /vmdir/configs/cert ]]; then
		mkdir /vmdir/configs/cert
	fi

	cd /vmdir/configs/cert/

	key="${domain}.key"

	if [[ ! -f /vmdir/configs/cert/$key ]]; then
		echo -e " > generating key for $domain..."
		openssl genrsa -out $key 2048 >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ ! -f /vmdir/configs/cert/"${domain}.cert" ]]; then
			echo -e " > generating certificate for $domain..."
			openssl req -new -x509 -key $key -out $(echo "$domain.cert") -days 3650 -subj /CN=$domain >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
		fi
	else
		echo -e " > certificate for $domain was already generated..."
	fi

done


echo -e "\n=> Reloading Apache\n"

usermod -a -G vboxsf www-data >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1

service apache2 start >> /vmdir/log/vm-hosts-$(date +\%F).log 2>&1
