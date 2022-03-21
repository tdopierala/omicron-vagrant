#!/usr/bin/env bash

json="/vagrant-dir/provisioners/vhosts.json"

for node in $(jq -c ".vhosts[]" $json)
do
  name=$(echo $node | jq ".name" | tr -d '"')
  path=$(echo $node | jq ".path" | tr -d '"')

  if [[ ! -d /mnt/repo/$name ]]; then
		echo "/mnt/repo/$name not exist"
  else
    echo "/mnt/repo/$name exist!"
	fi

  if [[ $(echo $node | jq ".ssl" | tr -d '"') == "true" ]]; then
		echo "https"
	else
		echo "http"
	fi
done
