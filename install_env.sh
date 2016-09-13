#!/bin/bash

if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root\e[0m" >&2
   exit 1
fi


sudo apt-get update
sudo apt-get -y upgrade


# Go to folder of install_env.sh
cd "$(dirname "$0")"

sudo apt-get install -y apache2
sudo apt-get install libapache2-mod-wsgi
sudo apachectl restart


sudo apt-get install -y postgresql-9.4

sudo apt-get install python-setuptools

sudo apt-get install -y python python-pip
sudo apt-get install -y python-gdal

sudo apt-get install python-virtualenv
virtualenv ./

source ./bin/activate

pip install flask


 pip install -r requirements.txt





