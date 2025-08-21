#!/bin/bash
SECONDS=0

# FR: S'assurer que le script n'est pas lancer en root (utilisation de whoami)
# EN: Make sure the script is not runn with root (use whoami)
if [ "$(id -u)" == "0" ];
    then
        echo -e "\e[91m\e[1mThis script should NOT be run as root\e[0m" >&2
        exit 1
fi

# FR: sudo ls pour demander le mot de passe une fois
# EN: sudo ls to request the password once
sudo ls

if [ ! -d 'log' ]
  then
        mkdir log
fi

. atlas/configuration/settings.ini
sudo mkdir /tmp/atlas
sudo cp data/atlas/* /tmp/atlas/
export PGPASSWORD=$owner_atlas_pass;

function print_time () {
    echo $(date +'%H:%M:%S')
}

function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf as appropriate.
    if [ -z $1 ]
        then
        # Argument is null
            return 0
    else
        # Grep db name in the list of database
        sudo -u postgres -s -- psql -tAl | grep -q "^$1|"
        return $?
    fi
}

function test_settings() {
    fields=('owner_atlas' 'user_pg' 'altitudes' 'time' 'taxhub_displayed_attr')
    echo "Checking the validity of settings.ini"
    for i in "${!fields[@]}"
    do
        if [ -z ${!fields[$i]} ];
            then
                echo -e "\033\033[31m Error : \033[0m attribut ${fields[$i]} manquant dans settings.ini"
                exit
        fi
    done
}

test_settings

# FR: Suppression du fichier de log d'installation s'il existe déjà puis création de ce fichier vide.
# EN: Delete the install log file if it already exists and create this empty file.

rm  -f ./log/install_db.log
touch ./log/install_db.log


# FR: Si la BDD existe, je verifie le parametre qui indique si je dois la supprimer ou non
# EN: If the DB exists, I check the parameter that indicates whether I should delete it or not
if database_exists $db_name
    then
        if $drop_apps_db
            then
                echo "Deleting DB..."
                sudo -u postgres -s dropdb $db_name  &>> log/install_db.log
        fi
fi

# FR: Sinon je créé la BDD
# EN: Else I create the DB
if ! database_exists $db_name
    then
        print_time
        echo "Creating DB..."

        sudo -u postgres psql -c "CREATE USER $owner_atlas WITH PASSWORD '$owner_atlas_pass' "  &>> log/install_db.log
        sudo -u postgres psql -c "CREATE USER $user_pg WITH PASSWORD '$user_pg_pass' "  &>> log/install_db.log
        sudo -u postgres -s createdb -O $owner_atlas $db_name
        echo "Adding postGIS and  pgSQL to DB"
        sudo -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"  &>> log/install_db.log
        sudo -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"  &>> log/install_db.log
        sudo -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS pg_trgm;" &>> log/install_db.log
        sudo -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS unaccent;"  &>> log/install_db.log

fi

# Test si la base de donnée contient déja des schéma qui indique que la BDD atlas a déjà été installée
# schema_already_exists=$(psql -d $db_name -U $owner_atlas -h $db_host -p $db_port -t -c "SELECT count(*) FROM information_schema.schemata WHERE schema_name in ('atlas', 'gn_meta', 'synthese');")


# if [[ $schema_already_exists > 0 ]]; then
#     echo "La base de donnée semble déjà contenir une installation de l'atlas... on s'arrête là"
#     exit 1
# fi

# FR: Si j'utilise GeoNature ($geonature_source = True), alors je créé les connexions en FWD à la BDD GeoNature
# EN: If I use GeoNature ($geonature_source = True), then I create the connections in FWD to the GeoNature DB
if $geonature_source
    then
        echo "Adding FDW and connection to the GeoNature parent DB"
        sudo -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"  &>> log/install_db.log
        sudo -u postgres -s psql -d $db_name -c "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$db_source_host', dbname '$db_source_name', port '$db_source_port', fetch_size '$db_source_fetch_size');"  &>> log/install_db.log
        sudo -u postgres -s psql -d $db_name -c "ALTER SERVER geonaturedbserver OWNER TO $owner_atlas;"  &>> log/install_db.log
        sudo -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $owner_atlas SERVER geonaturedbserver OPTIONS (user '$atlas_source_user', password '$atlas_source_pass') ;"  &>> log/install_db.log
        # si geonature source on crée le schéma utilisateur. Si gn_source =false, on a forcément deja taxhub et donc le schéma utilisateur
        sudo -u postgres -s psql -d $db_name -c "CREATE SCHEMA utilisateurs AUTHORIZATION "$owner_atlas";"  &>> log/install_db.log

fi

# FR: Création des schémas de la BDD
# EN: Creating DB schemes
sudo -u postgres -s psql -d $db_name -c "CREATE SCHEMA atlas AUTHORIZATION "$owner_atlas";"  &>> log/install_db.log
sudo -u postgres -s psql -d $db_name -c "CREATE SCHEMA synthese AUTHORIZATION "$owner_atlas";"  &>> log/install_db.log
sudo -u postgres -s psql -d $db_name -c "CREATE SCHEMA gn_meta AUTHORIZATION "$owner_atlas";"  &>> log/install_db.log

if $geonature_source
    then
        echo "Creating FDW from GN2" &>> log/install_db.log
        echo "--------------------" &>> log/install_db.log
        export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port -f data/gn2/atlas_gn2.sql  &>> log/install_db.log

        # FR: Creation des tables filles en FDW
        # EN: Creation of daughter tables in FDW
        echo "Creating the connection to GeoNature for the taxonomy tables"
        psql -d $db_name -U $owner_atlas -h $db_host -p $db_port -f data/gn2/atlas_ref_taxonomie.sql  &>> log/install_db.log
fi


echo "Creation of geographic tables from the ref_geo schema of from geonature or taxhub"
echo "--------------------" &>> log/install_db.log
echo "Creation of layers table from ref_geo of geonaturedb" &>> log/install_db.log
echo "--------------------" &>> log/install_db.log
export PGPASSWORD=$owner_atlas_pass; psql -d $db_name -U $owner_atlas -h $db_host -p $db_port \
    -v type_territoire=$type_territoire \
    -f data/gn2/atlas_ref_geo.sql &>> log/install_db.log



###########################
######    Occurence data
###########################
echo "Creating DB structure"
# FR: Si j'utilise GeoNature ($geonature_source = True), alors je créé les tables filles en FDW connectées à la BDD de GeoNature
# EN: If I use GeoNature ($geonature_source = True), then I create the child tables in FDW connected to the GeoNature DB
if $geonature_source
    then
        sudo cp data/gn2/atlas_synthese.sql /tmp/atlas/atlas_synthese_extended.sql
        sudo sed -i "s/myuser;$/$owner_atlas;/" /tmp/atlas/atlas_synthese_extended.sql
        export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port -f /tmp/atlas/atlas_synthese_extended.sql  &>> log/install_db.log
# FR: Sinon je créé une table synthese.syntheseff avec 2 observations exemple
# EN: Otherwise I created a table synthese.syntheseff with 2 observations example
else
    echo "Creating syntheseff example table"
    export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port -f /tmp/atlas/without_geonature.sql &>> log/install_db.log
fi


###########################
######   ATLAS
###########################
# FR: Creation des Vues Matérialisées (et remplacement éventuel des valeurs en dur par les paramètres)
# EN: Creation of Materialized Views (and possible replacement of hard values by parameters)
echo "----- Creating materialized views ------"

sudo sed -i "s/date - 15$/date - $time/" /tmp/atlas/10.atlas.vm_taxons_plus_observes.sql
sudo sed -i "s/date + 15$/date - $time/" /tmp/atlas/10.atlas.vm_taxons_plus_observes.sql

# FR: customisation de l'altitude
# EN: customisation of altitude
insert=""
for i in "${!altitudes[@]}"
    do
        if [ $i -gt 0 ];
        then
            let max=${altitudes[$i]}-1
            sql="INSERT INTO atlas.bib_altitudes VALUES ($i,${altitudes[$i-1]},$max);"
            insert="${insert}\n${sql}"
        fi
    done

sudo sed -i "s/INSERT_ALTITUDE/${insert}/" /tmp/atlas/4.atlas.vm_altitudes.sql
# FR: Execution des scripts sql de création des vm de l'atlas
# EN: Run sql scripts : build atlas vm
scripts_sql=(
    "1.atlas.vm_taxref.sql"
    "2.atlas.vm_observations.sql"
    "3.atlas.vm_taxons.sql"
    "4.atlas.vm_altitudes.sql"
    "5.atlas.vm_search_taxon.sql"
    "6.atlas.vm_mois.sql"
    "7.atlas.vm_communes.sql"
    "8.atlas.vm_medias.sql"
    "9.atlas.vm_cor_taxon_attribut.sql"
    "10.atlas.vm_taxons_plus_observes.sql"
    "11.atlas.vm_cor_taxon_organism.sql"
    "atlas.refresh_materialized_view_data.sql"
)
for script in "${scripts_sql[@]}"
do
    echo "[$(date +'%H:%M:%S')] Creating ${script}..."
    time_temp=$SECONDS
    export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port \
        -v taxhub_displayed_attr=${taxhub_displayed_attr} \
        -f /tmp/atlas/${script} &>> log/install_db.log
    echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"
done

echo "[$(date +'%H:%M:%S')] Creating atlas.vm_mailles_territoire..."
time_temp=$SECONDS
export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port  \
    -v type_maille=$type_maille \
    -f data/atlas/12.atlas.vm_mailles_territoire.sql &>> log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"

# FR: Création de la vue matérialisée vm_mailles_observations (nombre d'observations par maille et par taxon)
# EN: Creation of the materialized view vm_meshes_observations (number of observations per mesh and per taxon)
echo "[$(date +'%H:%M:%S')] Creating atlas.vm_observations_mailles..."
time_temp=$SECONDS
export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port -f /tmp/atlas/13.atlas.vm_observations_mailles.sql  &>> log/install_db.log
echo "[$(date +'%H:%M:%S')] Passed - Duration : $((($SECONDS-$time_temp)/60))m$((($SECONDS-$time_temp)%60))s"

# FR: Affectation de droits en lecture sur les VM à l'utilisateur de l'application ($user_pg)
# EN: Assign read rights on VMs to the application user ($user_pg)
echo "Grant..."
sudo sed -i "s/my_reader_user;$/$user_pg;/" /tmp/atlas/14.grant.sql
sudo -n -u postgres -s psql -d $db_name -f /tmp/atlas/14.grant.sql &>> log/install_db.log

# Clean file
echo "Cleaning files..."
sudo -n rm -r /tmp/atlas

echo "Install finished - Duration :$(($SECONDS/60))m$(($SECONDS%60))s"

