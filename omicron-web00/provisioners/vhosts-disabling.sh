#!/usr/bin/env bash

a2dissite local.wardx.net
a2dissite local.dopierala.net.pl

rm /etc/apache2/sites-available/local.*

service apache2 stop
service apache2 start
