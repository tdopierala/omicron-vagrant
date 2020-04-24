#!/usr/bin/env bash

if [[ -f /vagrant-dir/backup/full-backup-latest.sql ]]; then
	mv /vagrant-dir/backup/full-backup-latest.sql /vagrant-dir/backup/full-backup-$(date +\%F)-$(echo $RANDOM | md5sum | cut -c -32).sql
fi

sudo mysqldump -u root -p --single-transaction --routines --lock-tables=false --all-databases > /vagrant-dir/backup/full-backup-latest.sql

IFS=' ' read -ra file <<< $(ls -lh /vagrant-dir/backup/full-backup-latest.sql)

echo "Created backup file 'full-backup-latest.sql' with ${file[4]} size of data"