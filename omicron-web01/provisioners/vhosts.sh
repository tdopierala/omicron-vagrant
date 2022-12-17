#!/usr/bin/env bash

url="omicron01.local"
IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

echo -e "\n=> Setting symlinks for vhosts..."

if [[ ! -L /mnt/repo/phpmyadmin ]]; then
	if [ -x "$(command -v git)" ]; then
		git clone https://github.com/phpmyadmin/phpmyadmin /mnt/repo/phpmyadmin >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
	fi
fi

for node in "${APPS[@]}"
do
	IFS='|' read -r -a dir <<< "$node"

	if [[ ! -L /mnt/repo/$dir ]]; then
		if [ -x "$(command -v git)" ]; then
			git clone https://github.com/tdopierala/$dir /mnt/repo/$dir >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
		fi
	fi

	if [[ ! -L /var/www/html/$dir ]]; then
    	ln -s "/mnt/repo/${dir[0]}" "/var/www/html/"$dir >> /vagrant-dir/log/vm-build-$(date +\%F).log 2>&1
	fi
done

#echo -e "\n=> Adding nonexistent symlinks for vhosts..."
#echo -e "\n Adding nonexistent symlinks for vhosts...\n" >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
#for node in "${APPS[@]}"
#do
#	IFS='|' read -r -a dir <<< "$node"
#    if [[ ! -L /var/www/html/$dir ]]; then
#		ln -s "/mnt/repo/${dir[0]}" "/var/www/html/"$dir >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
#        echo -e " > generating symlink for vhost $dir (/var/www/html/$dir)"
#	fi
#done

# usuwanie istniejących vhostów

echo -e "\n=> Disabling vhosts..."
echo -e "\n Disabling vhosts...\n" >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
for site in `apache2ctl -S | grep '80 namevhost' | grep -o 'sites-enabled/[^:]*' | cut -c 15-`
do
	if [[ "$site" != "000-default.conf" ]]
	then
		a2dissite $site >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ -f /etc/apache2/sites-available/${site} ]]; then
			rm /etc/apache2/sites-available/${site} >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
		fi

		echo -e " > vhost $site disabled"
	fi
done


# usuwanie pozostałych vhostów

echo -e "\n Removing old vhosts...\n" >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
for site in /etc/apache2/sites-available/*
do
	file=$(basename $site)
	if [[ "$file" != "000-default.conf" && "$file" != "default-ssl.conf" ]]
	then
		if [[ -f /etc/apache2/sites-available/${file} ]]; then
			rm /etc/apache2/sites-available/${file} >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
		fi
		echo -e " > removing old config: $file"
	fi
done

for site in /vagrant-dir/configs/vhosts/*
do
	file=$(basename $site)
	rm /vagrant-dir/configs/vhosts/${file} >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
done


#

echo -e "\n=> Generating and setuping vhosts..."
echo -e "\n Generating and setuping vhosts...\n" >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
for node in "${APPS[@]}"
do
	IFS='|' read -r -a vhost <<< "$node"

	host=${vhost[0]}
	domain="${host}.${url}"
	root=${vhost[2]}
	ssl=${vhost[1]}

	filename="${vhost[0]}.conf"

	if [[ -f /vagrant-dir/configs/vhosts/${host}.conf ]]; then
		rm /vagrant-dir/configs/vhosts/${host}.conf >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
	fi

	/vagrant-dir/provisioners/makeconf.sh ${url} ${host} ${ssl} ${root} > /vagrant-dir/configs/vhosts/${host}.conf
	echo -e " > vhost config for ${host} generated"

	if [[ -f /etc/apache2/sites-available/$filename ]]; then
		rm /etc/apache2/sites-available/$filename >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
	fi

	cp /vagrant-dir/configs/vhosts/$filename /etc/apache2/sites-available/$filename >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
	a2ensite $filename >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
	echo -e " > generating vhost $filename"

	if [[ ! -d /vagrant-dir/configs/cert ]]; then
		mkdir /vagrant-dir/configs/cert
	fi

	cd /vagrant-dir/configs/cert/

	key="${domain}.key"

	if [[ ! -f /vagrant-dir/configs/cert/$key ]]; then
		echo -e " > generating key for $domain..."
		openssl genrsa -out $key 2048 >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ ! -f /vagrant-dir/configs/cert/"${domain}.cert" ]]; then
			echo -e " > generating certificate for $domain..."
			openssl req -new -x509 -key $key -out $(echo "$domain.cert") -days 3650 -subj /CN=$domain >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
		fi
	else
		echo -e " > certificate for $domain was already generated..."
	fi

done


echo -e "\n=> Reloading Apache\n"

usermod -a -G vboxsf www-data >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

service apache2 restart >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
