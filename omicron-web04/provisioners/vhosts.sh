#!/usr/bin/env bash

url="omicron00.local"
IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

# usuwanie istniejących vhostów

echo -e "\n=> Disabling vhosts..."
for site in `apache2ctl -S | grep namevhost | grep -o 'sites-enabled/[^:]*' | cut -c 15-`
do
	if [[ "$site" != "000-default" && "$site" != "default-ssl" ]]
	then
		a2dissite $site >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1

		if [[ -f /etc/apache2/sites-available/${site} ]]
		then
			rm /etc/apache2/sites-available/${site} >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1
		fi

		echo -e " > vhost $site disabled"
	fi
done

# usuwanie pozostałych vhostów

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
for node in "${APPS[@]}"
do
	IFS='|' read -r -a vhost <<< "$node"

	host=${vhost[0]}
	domain="${host}.${url}"
	root=${vhost[2]}
	ssl=${vhost[1]}

	filename="${vhost[0]}.conf"

	if [[ -f /vagrant-dir/configs/vhosts/${host}.conf ]]
	then
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

#service apache2 reload >> /vagrant/log/vhosts.log 2>&1
service apache2 start >> /vagrant-dir/log/vm-hosts-$(date +\%F).log 2>&1