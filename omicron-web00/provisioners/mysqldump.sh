#!/usr/bin/env bash

if [[ -f /vagrant-dir/backup/full-backup-latest.sql ]]; then
	mv /vagrant-dir/backup/full-backup.sql /vagrant-dir/backup/full-backup-$(date +\%F)-$(echo $RANDOM | md5sum | cut -c -32).sql
fi

mysqldump -u omicron -p12345 --single-transaction --quick --lock-tables=false --all-databases > /vagrant-dir/backup/full-backup-latest.sql