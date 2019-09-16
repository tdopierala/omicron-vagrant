#!/usr/bin/env bash


url="omicron00.local"
IFS=$'\n' read -d '' -r -a APPS < /vagrant-dir/provisioners/vhosts.txt

for node in "${APPS[@]}"
do
	IFS='|' read -r -a vhost <<< "$node"

	host=${vhost[0]}
	domain=$(echo "$host.$url")
	root=${vhost[2]}
	ssl=${vhost[1]}

	if [[ -f /vagrant-dir/configs/vhosts2/${host}.conf ]]; then
		rm /vagrant-dir/configs/vhosts2/${host}.conf
	fi

	#/vagrant-dir/provisioners/makeconf.sh ${url} ${host} ${ssl} ${root} > /vagrant-dir/configs/vhosts2/${host}.conf
done