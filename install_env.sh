#!/bin/bash

if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root\e[0m" >&2
   exit 1
fi


. /etc/os-release
OS_NAME=$ID
OS_VERSION=$VERSION_ID
OS_BITS="$(getconf LONG_BIT)"

if [ !"$OS_BITS" == "64" ]; then
   echo "GeoNature must be installed on a 64-bits operating system ; your is $OS_BITS-bits" 1>&2
   exit 1
fi


sudo apt-get update
sudo apt-get -y upgrade


# Go to folder of install_env.sh
cd "$(dirname "$0")"

sudo apt-get install -y unzip
sudo apt-get install -y apache2
sudo apachectl restart

sudo apt-get install -y postgresql 

if [ "$OS_VERSION" == "9" ]
then
    sudo apt-get install -y postgresql-server-dev-9.6 
    sudo apt install -y postgis-2.3 postgis postgresql-9.6-postgis-2.3 
fi
if [ "$OS_VERSION" == "8" ]
then
    sudo apt-get install -y postgresql-server-dev-9.4 
    sudo apt install -y postgis-2.3 postgis 
fi


sudo apt-get install -y python-setuptools
sudo apt-get install -y libpq-dev python-dev

sudo apt-get install -y python python-pip
sudo apt-get install -y python-gdal
sudo apt-get install -y gdal-bin

sudo apt-get install -y python3-virtualenv virtualenv
sudo apt-get install -y supervisor
