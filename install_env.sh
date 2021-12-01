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
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo apachectl restart

sudo apt-get install -y postgresql 

if [ "$OS_VERSION" == "11" ]
then
    sudo apt-get install -y postgresql-server-dev-13
    sudo apt install -y postgis postgresql-13-postgis-3
fi

if [ "$OS_VERSION" == "10" ]
then
    sudo apt-get install -y postgresql-server-dev-11
    sudo apt install -y postgis-2.5 postgis
fi

if [ "$OS_VERSION" == "9" ]
then
    sudo apt-get install -y postgresql-server-dev-9.6 
    sudo apt install -y postgis-2.3 postgis postgresql-9.6-postgis-2.3 
fi


sudo apt-get install -y python-setuptools
sudo apt-get install -y libpq-dev python3-dev

sudo apt-get install python-pip
sudo apt-get install -y python-gdal
sudo apt-get install -y gdal-bin

sudo apt-get install -y python3-virtualenv virtualenv

# install nvm
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

cd atlas/static 
nvm install