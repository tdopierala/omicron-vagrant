#!/usr/bin/env bash

json="/vagrant-dir/provisioners/vhosts.json"

echo -e "\n=> Setting symlinks for vhosts..."

if [[ ! -d /mnt/repo/phpmyadmin ]]; then
	if [ -x "$(command -v git)" ]; then
		echo "git clone https://github.com/phpmyadmin/phpmyadmin /mnt/repo/phpmyadmin"
	fi
fi

for node in $(jq -c ".vhosts[]" $json)
do
  name=$(echo $node | jq ".name" | tr -d '"')
  path=$(echo $node | jq ".path" | tr -d '"')

	if [[ ! -d /mnt/repo/$name ]]; then
		if [ -x "$(command -v git)" ]; then
			echo "git clone https://github.com/tdopierala/$name /mnt/repo/$name"
		fi
	fi

done
