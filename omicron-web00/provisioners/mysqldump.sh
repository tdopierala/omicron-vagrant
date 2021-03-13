#!/usr/bin/env bash
path=/vmdir/backup

if [[ -f $path/full-backup-latest.sql ]]; then
	mv $path/full-backup-latest.sql $path/full-backup-$(date +\%F)-$(echo $RANDOM | md5sum | cut -c -32).sql
fi

sudo mysqldump -u root -p --single-transaction --routines --lock-tables=false --all-databases > $path/full-backup-latest.sql

IFS=' ' read -ra file <<< $(ls -lh $path/full-backup-latest.sql)

echo "Created backup file 'full-backup-latest.sql' with ${file[4]} size of data"
