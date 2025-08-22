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
envsubst '${USER} ${BASE_DIR} ${gun_num_workers} ${gun_port}' < geonature-atlas.service | sudo tee /etc/systemd/system/geonature-atlas.service || exit 1
sudo systemctl daemon-reload || exit 1
sudo systemctl enable geonature-atlas || exit 1
sudo systemctl start geonature-atlas || exit 1


echo "Creating custom images folder if it doesnt already exist"
if [ ! -d ./atlas/static/custom/images/ ]; then
  mkdir -p ./atlas/static/custom/images/
fi


echo "Creating customisation files if they dont already exist"
custom_templates=(
  "bandeaulogoshome"
  "credits"
  "footer"
  "introduction"
  "mentions-legales"
  "navbar"
  "personal-data"
  "presentation"
  "statuts"
)
for template_name in "${custom_templates[@]}"; do
  if [ ! -f "./atlas/static/custom/templates/${template_name}.html" ]; then
    cp "./atlas/static/custom/templates/${template_name}.html.sample" \
      "./atlas/static/custom/templates/${template_name}.html"
  fi
done

other_custom_files=(
  "templates/robots.txt"
  "custom.css"
  "glossaire.json"
  "maps-custom.js"
)
for file_path in "${other_custom_files[@]}"; do
  if [ ! -f "./atlas/static/custom/${file_path}" ]; then
    cp "./atlas/static/custom/${file_path}.sample" "./atlas/static/custom/${file_path}"
  fi
done

custom_images=(
  "accueil-intro.jpg"
  "external-website.png"
  "favicon.ico"
  "logo_patrimonial.png"
  "logo_protection.png"
  "logo-structure.png"
)
for img_file in "${custom_images[@]}"; do
  if [ ! -f "./atlas/static/custom/images/${img_file}" ]; then
    cp "./atlas/static/custom/images/sample.${img_file}" \
      "./atlas/static/custom/images/${img_file}"
  fi
done
