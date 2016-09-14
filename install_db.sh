#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

. main/configuration/settings.ini

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

    sudo -u postgres psql -c "CREATE ROLE $user_pg WITH PASSWORD '$user_pg_pass' "
    sudo -u postgres psql -c "CREATE ROLE $admin_pg WITH PASSWORD '$user_pg_pass' "
    sudo -n -u postgres -s createdb -O $user_pg $db_name
    echo "Ajout de postgis à la base"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION  IF NOT EXISTS postgres_fdw;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$db_source_host', dbname '$db_source_name', port '$db_source_port');"
    sudo -n -u postgres -s psql -d $db_name -c "ALTER SERVER geonaturedbserver OWNER TO $user_pg;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $atlas_source_user SERVER geonaturedbserver OPTIONS (user '$atlas_source_user', password '$atlas_source_pass') ;"


    # Mise en place de la structure de la base et des données permettant son fonctionnement avec l'atlas
    echo "Grant..."
    sed -i "s/TO geonatatlas;$/TO $user_pg;/" data/grant.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f data/grant.sql &> log/install_db.log

    sudo -n -u postgres -s psql -d $db_name -c "CREATE SCHEMA synthese AUTHORIZATION geonatatlas;
                                                CREATE SCHEMA taxonomie AUTHORIZATION geonatatlas;
                                                CREATE SCHEMA utilisateurs AUTHORIZATION geonatatlas;
                                                CREATE SCHEMA meta AUTHORIZATION geonatatlas;
                                                CREATE SCHEMA layers AUTHORIZATION geonatatlas;
                                                CREATE SCHEMA atlas AUTHORIZATION geonatatlas;"
    
    #ajout du shape des limite du territoire
    export PGPASSWORD=$user_pg_pass;shp2pgsql -W "cp850" -s 2154 -D -I $limit_shp atlas.t_layer_territoire | psql -h $db_host -U $user_pg $db_name
    #Creation de l'index GIST sur la layer territoire
    sudo -n -u postgres -s psql -d $db_name -c "CREATE INDEX index_gist_t_layer_territoire
                                                ON atlas.t_layer_territoire
                                                USING gist(geom);"
    
    echo "Création de la structure de la base..."
    sed -i "s/WHERE id_attribut  IN (100, 101, 102, 103);$/WHERE id_attribut  IN ($attr_desc, $attr_commentaire, $attr_milieu, $attr_corrologie)/" data/atlas.sql
    sed -i "s/current_date -15;$/current_date -$time/" data/atlas.sql
    sed -i "s/current_date +15;$/current_date +$time/" data/atlas.sql
    
    export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f data/atlas.sql  &>> log/install_db.log

    echo "Affectation des droits sur la base source..."
    sed -i "s/TO geonatatlas;$/TO $user_pg;/" data/atlas_source.sql
    export PGPASSWORD=$admin_source_pass;psql -h $db_source_host -U $admin_source_user -d $db_source_name -f data/atlas_source.sql  &>> log/install_db.log
   

    # Mise en place des mailles et d la table de l'emprise du territoire
    echo "Découpage des mailles et creation de la table des mailles"
    cd data/ref


    rm -f L93*.dbf L93*.prj L93*.sbn L93*.sbx L93*.shp L93*.shx

    unzip L93_1K.zip 
    unzip L93_5K.zip 
    unzip L93_10K.zip


    #ajout des mailles non decoupees
    export PGPASSWORD=$user_pg_pass;shp2pgsql -W "cp850" -s 2154 -D -I L93_1x1.shp atlas.t_mailles_1 | psql -h $db_host -U $user_pg $db_name
    export PGPASSWORD=$user_pg_pass;shp2pgsql -W "cp850" -s 2154 -D -I L93_5K.shp atlas.t_mailles_5 | psql -h $db_host -U $user_pg $db_name
    export PGPASSWORD=$user_pg_pass;shp2pgsql -W "cp850" -s 2154 -D -I L93_10K.shp atlas.t_mailles_10 | psql -h $db_host -U $user_pg $db_name


    #conversion en json
    rm  -f ../../static/custom/territoire.json
    ogr2ogr -f "GeoJSON" -t_srs "EPSG:4326" ../../static/custom/territoire.json $limit_shp

    cd ../../
   
    # Creation de la table t_maille_territoire avec la taille de maille passée en parametre
    sudo -n -u postgres -s psql -d $db_name -c "CREATE TABLE atlas.t_mailles_territoire as
                                                SELECT m.geom, ST_AsGeoJSON(st_transform(t.geom, 4326))
                                                FROM atlas.t_mailles_"$taillemaille" m, atlas.t_layer_territoire t
                                                WHERE ST_Intersects(m.geom, t.geom);
                                                CREATE INDEX index_gist_t_mailles_territoire
                                                ON atlas.t_mailles_territoire
                                                USING gist (geom); 
                                                ALTER TABLE atlas.t_mailles_territoire
                                                ADD COLUMN id_maille serial;
                                                ALTER TABLE atlas.t_mailles_territoire
                                                OWNER TO geonatatlas;
                                                ALTER TABLE atlas.t_mailles_territoire
                                                ADD PRIMARY KEY (id_maille);"

    echo "Creation de la table des mailles..."
    #ajout de la tabme vm_mailles_observations
    export PGPASSWORD=$user_pg_pass;psql -h $db_host -U $user_pg -d $db_name -f data/mailles.sql  &> log/install_mailles.log
    
    cd data/ref
    rm -f L*.shp L*.dbf L*.prj L*.sbn L*.sbx L*.shx output_clip.*
    cd ../..
fi
