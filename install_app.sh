#!/bin/bash
if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root\e[0m" >&2
   exit 1
fi

# Make nvm available
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

if [ ! -f ./atlas/configuration/settings.ini ]; then
  cp ./atlas/configuration/settings.ini.sample ./atlas/configuration/settings.ini
fi

set -a
. atlas/configuration/settings.ini
set +a

if [ "$(id -u)" == "0" ]; then
   echo -e "\e[91m\e[1mThis script should NOT be run as root but your user needs sudo rights\e[0m" >&2
   exit 1
fi

echo "Stopping application..."
sudo systemctl stop geonature-atlas

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
pip install -e .
deactivate

echo "Installing node packages"
cd atlas/static
nvm use
npm i
cd ../..

echo "Creating configuration files if they dont already exist"
if [ ! -f ./atlas/configuration/config.py ]; then
  cp ./atlas/configuration/config.py.sample ./atlas/configuration/config.py
fi

sudo sed -i "s/SQLALCHEMY_DATABASE_URI = .*$/SQLALCHEMY_DATABASE_URI = \"postgresql:\/\/$user_pg:$user_pg_pass@$db_host:$db_port\/$db_name\"/" ./atlas/configuration/config.py
sed -i "s/GUNICORN_PORT = .*$/GUNICORN_PORT = '${gun_port}'/g" ./atlas/configuration/config.py


echo "Launching application..."
export BASE_DIR=$(readlink -e "${0%/*}")
envsubst '${USER} ${BASE_DIR} ${gun_num_workers} ${gun_port}' < geonature-atlas-dev.service | sudo tee /etc/systemd/system/geonature-atlas-dev.service || exit 1
sudo systemctl daemon-reload || exit 1
sudo systemctl enable geonature-atlas-dev || exit 1
sudo systemctl start geonature-atlas-dev || exit 1



echo "Creating custom images folder if it doesnt already exist"
if [ ! -d ./atlas/static/custom/images/ ]; then
  mkdir -p ./atlas/static/custom/images/
fi



echo "Creating customisation files if they dont already exist"
if [ ! -f ./atlas/static/custom/templates/footer.html ]; then
  cp ./atlas/static/custom/templates/footer.html.sample ./atlas/static/custom/templates/footer.html
fi
if [ ! -f ./atlas/static/custom/templates/introduction.html ]; then
  cp ./atlas/static/custom/templates/introduction.html.sample ./atlas/static/custom/templates/introduction.html
fi
if [ ! -f ./atlas/static/custom/templates/presentation.html ]; then
  cp ./atlas/static/custom/templates/presentation.html.sample ./atlas/static/custom/templates/presentation.html
fi
if [ ! -f ./atlas/static/custom/templates/credits.html ]; then
  cp ./atlas/static/custom/templates/credits.html.sample ./atlas/static/custom/templates/credits.html
fi
if [ ! -f ./atlas/static/custom/templates/mentions-legales.html ]; then
  cp ./atlas/static/custom/templates/mentions-legales.html.sample ./atlas/static/custom/templates/mentions-legales.html
fi
if [ ! -f ./atlas/static/custom/templates/personal-data.html ]; then
 cp ./atlas/static/custom/templates/personal-data.html.sample ./atlas/static/custom/templates/personal-data.html
fi
if [ ! -f ./atlas/static/custom/templates/bandeaulogoshome.html ]; then
  cp ./atlas/static/custom/templates/bandeaulogoshome.html.sample ./atlas/static/custom/templates/bandeaulogoshome.html
fi

if [ ! -f ./atlas/static/custom/templates/navbar.html ]; then
  cp ./atlas/static/custom/templates/navbar.html.sample ./atlas/static/custom/templates/navbar.html
fi

if [ ! -f ./atlas/static/custom/templates/navbar.html ]; then
  cp ./atlas/static/custom/templates/statuts.html.sample ./atlas/static/custom/templates/statuts.html
fi

if [ ! -f ./atlas/static/custom/templates/robots.txt ]; then
  cp ./atlas/static/custom/templates/robots.txt.sample  ./atlas/static/custom/templates/robots.txt
fi

if [ ! -f ./atlas/static/custom/custom.css ]; then
  cp ./atlas/static/custom/custom.css.sample ./atlas/static/custom/custom.css
fi
if [ ! -f ./atlas/static/custom/glossaire.json ]; then
  cp ./atlas/static/custom/glossaire.json.sample ./atlas/static/custom/glossaire.json
fi
if [ ! -f ./atlas/static/custom/images/favicon.ico ]; then
  cp ./atlas/static/images/sample.favicon.ico ./atlas/static/custom/images/favicon.ico
fi
if [ ! -f ./atlas/static/custom/images/accueil-intro.jpg ]; then
  cp ./atlas/static/images/sample.accueil-intro.jpg ./atlas/static/custom/images/accueil-intro.jpg
fi
if [ ! -f ./atlas/static/custom/images/logo-structure.png ]; then
  cp ./atlas/static/images/sample.logo-structure.png ./atlas/static/custom/images/logo-structure.png
fi
if [ ! -f ./atlas/static/custom/images/logo_patrimonial.png ]; then
  cp ./atlas/static/images/sample.logo_patrimonial.png ./atlas/static/custom/images/logo_patrimonial.png
fi
if [ ! -f ./atlas/static/custom/maps-custom.js ]; then
  cp ./atlas/static/custom/maps-custom.js.sample ./atlas/static/custom/maps-custom.js
fi



