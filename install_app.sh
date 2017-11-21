#!/bin/bash

. main/configuration/settings.ini

if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root par contre vous devez disposer des droits sudo\e[0m" >&2
   exit 1
fi

echo "Arret de l'application..."
sudo -s supervisorctl stop atlas

virtualenv $venv_dir

. $venv_dir/bin/activate
pip install -r requirements.txt


#Lancement de l'application
DIR=$(readlink -e "${0%/*}")
sudo -s cp  atlas-service.conf /etc/supervisor/conf.d/
sudo -s sed -i "s%APP_PATH%${DIR}%" /etc/supervisor/conf.d/atlas-service.conf

sudo -s supervisorctl reread
sudo -s supervisorctl reload


mkdir -p ./static/custom/images/

cp -n ./main/configuration/config.py.sample ./main/configuration/config.py
cp -n ./main/configuration/settings.ini.sample ./main/configuration/settings.ini
cp -n ./static/custom/templates/footer.html.sample ./static/custom/templates/footer.html
cp -n ./static/custom/templates/introduction.html.sample ./static/custom/templates/introduction.html
cp -n ./static/custom/templates/presentation.html.sample ./static/custom/templates/presentation.html
cp -n ./static/custom/templates/credits.html.sample ./static/custom/templates/credits.html
cp -n ./static/custom/templates/mentions-legales.html.sample ./static/custom/templates/mentions-legales.html
cp -n ./static/custom/custom.css.sample ./static/custom/custom.css
cp -n ./static/custom/glossaire.json.sample ./static/custom/glossaire.json
cp -n ./static/images/sample.favicon.ico ./static/custom/images/favicon.ico
cp -n ./static/images/sample.accueil-intro.jpg ./static/custom/images/accueil-intro.jpg
cp -n ./static/images/sample.logo-structure.png ./static/custom/images/logo-structure.png
cp -n ./static/images/sample.logo_patrimonial.png ./static/custom/images/logo_patrimonial.png

cp -n ./data/ref/communes.dbf.sample ./data/ref/communes.dbf
cp -n ./data/ref/communes.prj.sample ./data/ref/communes.prj
cp -n ./data/ref/communes.shp.sample ./data/ref/communes.shp
cp -n ./data/ref/communes.shx.sample ./data/ref/communes.shx

cp -n ./data/ref/territoire.dbf.sample ./data/ref/territoire.dbf
cp -n ./data/ref/territoire.prj.sample ./data/ref/territoire.prj
cp -n ./data/ref/territoire.shp.sample ./data/ref/territoire.shp
cp -n ./data/ref/territoire.shx.sample ./data/ref/territoire.shx
