#!/bin/bash

if [ ! -f ./atlas/configuration/settings.ini ]; then
  cp ./atlas/configuration/settings.ini.sample ./atlas/configuration/settings.ini
fi

. atlas/configuration/settings.ini

if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root but your user needs sudo rights\e[0m" >&2
   exit 1
fi

echo "Stopping application..."
sudo -s supervisorctl stop atlas

echo "Creating and activating Virtual env..."

if [ -d $venv_dir/ ]
then
  echo "Suppression du virtual env existant..."
  sudo rm -rf $venv_dir
fi

virtualenv -p $python_executable $venv_dir

. $venv_dir/bin/activate

echo "Installing requirements..."
pip install -r requirements.txt
deactivate

echo "Creating configuration files if they dont already exist"
if [ ! -f ./atlas/configuration/config.py ]; then
  cp ./atlas/configuration/config.py.sample ./atlas/configuration/config.py
fi

sudo sed -i "s/database_connection = .*$/database_connection = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" ./atlas/configuration/config.py


echo "Launching application..."
DIR=$(readlink -e "${0%/*}")
sudo -s cp  atlas-service.conf /etc/supervisor/conf.d/
sudo -s sed -i "s%APP_PATH%${DIR}%" /etc/supervisor/conf.d/atlas-service.conf

sudo -s supervisorctl reread
sudo -s supervisorctl reload

echo "Creating custom images folder if it doesnt already exist"
if [ ! -d ./static/custom/images/ ]; then
  mkdir -p ./static/custom/images/
fi



echo "Creating customisation files if they dont already exist"
if [ ! -f ./static/custom/templates/footer.html ]; then
  cp ./static/custom/templates/footer.html.sample ./static/custom/templates/footer.html
fi
if [ ! -f ./static/custom/templates/introduction.html ]; then
  cp ./static/custom/templates/introduction.html.sample ./static/custom/templates/introduction.html
fi
if [ ! -f ./static/custom/templates/presentation.html ]; then
  cp ./static/custom/templates/presentation.html.sample ./static/custom/templates/presentation.html
fi
if [ ! -f ./static/custom/templates/credits.html ]; then
  cp ./static/custom/templates/credits.html.sample ./static/custom/templates/credits.html
fi
if [ ! -f ./static/custom/templates/mentions-legales.html ]; then
  cp ./static/custom/templates/mentions-legales.html.sample ./static/custom/templates/mentions-legales.html
fi
if [ ! -f ./static/custom/custom.css ]; then
  cp ./static/custom/custom.css.sample ./static/custom/custom.css
fi
if [ ! -f ./static/custom/glossaire.json ]; then
  cp ./static/custom/glossaire.json.sample ./static/custom/glossaire.json
fi
if [ ! -f ./static/custom/images/favicon.ico ]; then
  cp ./static/images/sample.favicon.ico ./static/custom/images/favicon.ico
fi
if [ ! -f ./static/custom/images/accueil-intro.jpg ]; then
  cp ./static/images/sample.accueil-intro.jpg ./static/custom/images/accueil-intro.jpg
fi
if [ ! -f ./static/custom/images/logo-structure.png ]; then
  cp ./static/images/sample.logo-structure.png ./static/custom/images/logo-structure.png
fi
if [ ! -f ./static/custom/images/logo_patrimonial.png ]; then
  cp ./static/images/sample.logo_patrimonial.png ./static/custom/images/logo_patrimonial.png
fi
if [ ! -f ./static/custom/maps-custom.js ]; then
  cp ./static/custom/maps-custom.js.sample ./static/custom/maps-custom.js
fi

echo "Creating GIS files if they dont already exist"
if [ ! -f ./data/ref/communes.dbf ]; then
  cp ./data/ref/communes.dbf.sample ./data/ref/communes.dbf
fi
if [ ! -f ./data/ref/communes.prj ]; then
  cp ./data/ref/communes.prj.sample ./data/ref/communes.prj
fi
if [ ! -f ./data/ref/communes.shp ]; then
  cp ./data/ref/communes.shp.sample ./data/ref/communes.shp
fi
if [ ! -f ./data/ref/communes.shx ]; then
  cp ./data/ref/communes.shx.sample ./data/ref/communes.shx
fi
if [ ! -f ./data/ref/territoire.dbf ]; then
  cp ./data/ref/territoire.dbf.sample ./data/ref/territoire.dbf
fi
if [ ! -f ./data/ref/territoire.prj ]; then
  cp ./data/ref/territoire.prj.sample ./data/ref/territoire.prj
fi
if [ ! -f ./data/ref/territoire.shp ]; then
  cp ./data/ref/territoire.shp.sample ./data/ref/territoire.shp
fi
if [ ! -f ./data/ref/territoire.shx ]; then
  cp ./data/ref/territoire.shx.sample ./data/ref/territoire.shx
fi
