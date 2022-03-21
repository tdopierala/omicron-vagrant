#!/usr/bin/env bash

# Variables
phpv=7.3

DBHOST=localhost
DBNAME=vagrant
DBUSER=omicron
DBPASSWD=12345

cp /vagrant-dir/lib/mysql-connector-java-8.0.16.jar /opt/coldfusion2016/cfusion/lib/
cp /vagrant-dir/lib/jBCrypt-0.4* /opt/coldfusion2016/cfusion/lib/

cd /vagrant-dir/lib/
tar -xzf /vagrant-dir/lib/jdk-8u192-linux-x64.tar.gz
mv /vagrant-dir/lib/jdk1.8.0_192 /opt/coldfusion2016/
mv /opt/coldfusion2016/jre /opt/coldfusion2016/jre_old
mv /opt/coldfusion2016/jdk1.8.0_192 /opt/coldfusion2016/jre

/opt/coldfusion2016/cfusion/bin/coldfusion restart
