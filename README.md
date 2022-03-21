# Omicron Vagrant Virtual Machines

Configuration files for building virtual machines based on Vagrant/VirtualBox


## omicron-web00

Main machine for php7 projects

System: debian/buster64

Config: Apache2 | PHP7.3 | MySql5 | Node.js | Composer | Lynx

```
vagrant up
```

## omicron-web01

Backup/test copy of omicron-web00

System: debian/buster64

Config: Apache2 | PHP7.3 | MySql5 | Node.js | Composer | Lynx


## omicron-web02

Machine for old php5 projects

System: debian/stretch64

Config: Apache2 | PHP5.3 | MySql5 | Node.js | Composer | Lynx


## omicron-web06

System: debian/stretch64

Config: Apache2 | PHP7.3 | MySql5 | Coldfusion2016 | Java8 (jre/jdk)

```
vagrant up
```
