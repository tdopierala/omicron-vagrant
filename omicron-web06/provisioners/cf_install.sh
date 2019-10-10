#!/usr/bin/env bash

## Url location
dir=lb0lbbyDr24YBGED0p138xm
url=https://filedn.com/${dir}/coldfusion

## Files
coldfusion=ColdFusion_2016_WWEJ_linux64_071316.bin
mysql_connector=mysql-connector-java-8.0.16.jar
jbcrypt=jBCrypt-0.4.jar
jbcrypt_java=jBCrypt-0.4-java7.jar
jdk8=jdk-8u192-linux-x64.tar.gz


## Coldfusion Download
echo -e "\nColdfusion Download..."
if [[ ! -f /vagrant-dir/lib/${coldfusion} ]]; then
	wget ${url}/${coldfusion}
    mv ./${coldfusion} /vagrant-dir/lib/
fi


## Coldfusion Install
echo -e "\nColdfusion Install..."
if [[ ! -f /opt/coldfusion2016/cfusion/bin/coldfusion ]]; then
    chmod a+x /vagrant-dir/lib/${coldfusion}
    sudo /vagrant-dir/lib/${coldfusion} -f /vagrant-dir/config/coldfusion2016_properties
fi


## MySql Connector
echo -e "\nMySql Connector Install..."
if [[ ! -f /vagrant-dir/lib/${mysql_connector} ]]; then
	wget ${url}/${mysql_connector}
    mv ./${mysql_connector} /vagrant-dir/lib/
fi

sudo cp -rf /vagrant-dir/lib/${mysql_connector} /opt/coldfusion2016/cfusion/lib/
sudo chown nobody /opt/coldfusion2016/cfusion/lib/${mysql_connector}
sudo chgrp bin /opt/coldfusion2016/cfusion/lib/${mysql_connector}


## jBCrypt Install
echo -e "\njBCrypt Install..."
if [[ ! -f /vagrant-dir/lib/${jbcrypt} ]]; then
	wget ${url}/${jbcrypt}
    mv ./${jbcrypt} /vagrant-dir/lib/
fi

sudo cp -rf /vagrant-dir/lib/${jbcrypt} /opt/coldfusion2016/cfusion/lib/
sudo chown nobody /opt/coldfusion2016/cfusion/lib/${jbcrypt}
sudo chgrp bin /opt/coldfusion2016/cfusion/lib/${jbcrypt}

if [[ ! -f /vagrant-dir/lib/${jbcrypt_java} ]]; then
	wget ${url}/${jbcrypt_java}
    mv ./${jbcrypt_java} /vagrant-dir/lib/
fi

sudo cp -rf /vagrant-dir/lib/${jbcrypt_java} /opt/coldfusion2016/cfusion/lib/
sudo chown nobody /opt/coldfusion2016/cfusion/lib/${jbcrypt_java}
sudo chgrp bin /opt/coldfusion2016/cfusion/lib/${jbcrypt_java}


## jdk-8u192 Install
#echo -e "\njdk-8u192 Install..."
#if [[ ! -f /vagrant-dir/lib/${jdk8} ]]; then
#	wget ${url}/${jdk8}
#    mv ./${jdk8} /vagrant-dir/lib/
#fi
#
#if [[ -d /vagrant-dir/lib/jdk1.8.0_192 ]]; then
#    sudo rm -R /vagrant-dir/lib/jdk1.8.0_192
#fi
#
#sudo tar -xzf /vagrant-dir/lib/jdk-8u192-linux-x64.tar.gz -C /vagrant-dir/lib/
#sudo rm -R /opt/coldfusion2016/jre
#sudo mv /vagrant-dir/lib/jdk1.8.0_192 /opt/coldfusion2016/jre

sudo /opt/coldfusion2016/cfusion/bin/coldfusion restart