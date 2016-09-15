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


sudo apt-get install -y postgresql-9.4 postgis

sudo apt-get install -y python-setuptools
sudo apt-get install libpq-dev python-dev

sudo apt-get install -y python python-pip
sudo apt-get install -y python-gdal
sudo apt-get install gdal-bin

sudo apt-get install -y python-virtualenv
virtualenv ./

source ./bin/activate
pip install -r requirements.txt


cp ./main/configuration/config.py.sample ./main/configuration/config.py
cp ./main/configuration/settings.ini.sample ./main/configuration/settings.ini
cp ./static/custom/templates/footer.html.sample ./static/custom/templates/footer.html
cp ./static/custom/templates/introduction.html.sample ./static/custom/templates/introduction.html
cp ./static/custom/templates/presentation.html.sample ./static/custom/templates/presentation.html
cp ./static/custom/custom.css.sample ./static/custom/custom.css






