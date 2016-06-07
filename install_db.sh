#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

. config/settings.ini

function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.
    if [ -z $1 ]
        then
        # Argument is null
        return 0
    else
        # Grep db name in the list of database
        sudo -n -u postgres -s -- psql -tAl | grep -q "^$1|"
        return $?
    fi
}


if database_exists $db_name
then
        if $drop_apps_db
            then
            echo "Suppression de la base..."
            sudo -n -u postgres -s dropdb $db_name
        else
            echo "La base de données existe et le fichier de settings indique de ne pas la supprimer."
        fi
fi        
if ! database_exists $db_name 
then
    echo "Création de la base..."
    sudo -n -u postgres -s createdb -O $user_pg $db_name
    echo "Ajout de postgis à la base"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION  IF NOT EXISTS postgres_fdw;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$source_host', dbname '$source_name', port '$source_port');"
    sudo -n -u postgres -s psql -d $db_name -c "ALTER SERVER geonaturedbserver OWNER TO $user_pg;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $user_pg SERVER geonaturedbserver OPTIONS (user '$user_pg', password '$user_pg_pass') ;"


    # Mise en place de la structure de la base et des données permettant son fonctionnement avec l'atlas
    echo "Grant..."
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f data/grant.sql &> log/install_db.log
    
    echo "Création de la structure de la base..."
    export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f data/atlas.sql  &>> log/install_db.log
    
    echo "Affectation des droits sur la base source..."
    export PGPASSWORD=$admin_pg_pass;psql -h $source_host -U $admin_pg -d $source_name -f data/atlas_source.sql  &>> log/install_db.log

fi