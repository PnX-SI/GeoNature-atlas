#!/bin/bash

if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root\e[0m" >&2
   exit 1
fi


sudo apt-get update
sudo apt-get -y upgrade


# Go to folder of install_env.sh
cd "$(dirname "$0")"

sudo apt-get install -y unzip
sudo apt-get install -y apache2
sudo apachectl restart

sudo apt-get install -y postgresql postgis

sudo apt-get install -y python-setuptools
sudo apt-get install -y libpq-dev python-dev

sudo apt-get install -y python python-pip
sudo apt-get install -y python-gdal
sudo apt-get install -y gdal-bin

sudo apt-get install -y python3-virtualenv virtualenv
sudo apt-get install -y supervisor
