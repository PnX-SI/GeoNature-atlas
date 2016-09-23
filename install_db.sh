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

    sudo -u postgres psql -c "CREATE USER $user_pg WITH PASSWORD '$user_pg_pass' "
    sudo -u postgres psql -c "CREATE USER $admin_pg WITH PASSWORD '$user_pg_pass' "
    sudo -n -u postgres -s createdb -O $user_pg $db_name
    echo "Ajout de postgis à la base"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION  IF NOT EXISTS postgres_fdw;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$db_source_host', dbname '$db_source_name', port '$db_source_port');"
    sudo -n -u postgres -s psql -d $db_name -c "ALTER SERVER geonaturedbserver OWNER TO $admin_pg;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $admin_pg SERVER geonaturedbserver OPTIONS (user '$atlas_source_user', password '$atlas_source_pass') ;"


    # Mise en place de la structure de la base et des données permettant son fonctionnement avec l'atlas


    sudo -n -u postgres -s psql -d $db_name -c "CREATE SCHEMA synthese AUTHORIZATION $admin_pg;
                                                CREATE SCHEMA taxonomie AUTHORIZATION $admin_pg;
                                                CREATE SCHEMA utilisateurs AUTHORIZATION $admin_pg;
                                                CREATE SCHEMA meta AUTHORIZATION $admin_pg;
                                                CREATE SCHEMA atlas AUTHORIZATION $admin_pg;"
    
    #ajout du shape des limite du territoire
    ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 data/ref/emprise_territoire_3857.shp $limit_shp
    export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I ./data/ref/emprise_territoire_3857.shp atlas.t_layer_territoire | psql -h $db_host -U $admin_pg $db_name
    rm data/ref/emprise_territoire_3857.*
    #Creation de l'index GIST sur la layer territoire
    export PGPASSWORD=$admin_pg_pass; psql -h $db_host -U $admin_pg -d $db_name -c "CREATE INDEX index_gist_t_layer_territoire
                                                                                    ON atlas.t_layer_territoire
                                                                                    USING gist(geom);"


    ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 ./data/ref/communes_3857.shp $communes_shp
    export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I ./data/ref/communes_3857.shp atlas.l_communes | psql -h $db_host -U $admin_pg $db_name
    psql -h $db_host -U $admin_pg $db_name -c "ALTER TABLE atlas.l_communes RENAME COLUMN $colonne_nom_commune TO commune_maj;
                                               ALTER TABLE atlas.l_communes RENAME COLUMN $colonne_insee TO insee;
                                               CREATE INDEX index_gist_t_layers_communes
                                                ON atlas.l_communes USING gist (geom); "
    rm ./data/ref/communes_3857.*



    echo "Création de la structure de la base..."

    #Creation des foreign data
    sudo cp data/atlas_geonature.sql /tmp/atlas_geonature.sql
    sudo sed -i 's/TO myuser;/TO geonatadmin;/g' /tmp/atlas_geonature.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/atlas_geonature.sql  &>> log/install_db.log

    # Creation des VM
    sudo cp data/atlas.sql /tmp/atlas.sql
    sudo sed -i "s/WHERE id_attribut IN (100, 101, 102, 103);$/WHERE id_attribut  IN ($attr_desc, $attr_commentaire, $attr_milieu, $attr_chorologie);/" /tmp/atlas.sql
    sudo sed -i "s/FROM layers.l_communes$/FROM $table_commune/" /tmp/atlas.sql
    sudo sed -i "s/current_date -15;$/current_date -$time/" /tmp/atlas.sql
    sudo sed -i "s/current_date +15;$/current_date +$time/" /tmp/atlas.sql

    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/atlas.sql  &>> log/install_db.log

    echo "Affectation des droits sur la base source..."
    sudo cp data/grant_geonature.sql /tmp/grant_geonature.sql
    sudo sed -i "s/myuser;$/$admin_pg;/" /tmp/grant_geonature.sql
    export PGPASSWORD=$admin_source_pass;psql -h $db_source_host -U $admin_source_user -d $db_source_name -f /tmp/grant_geonature.sql  &>> log/install_db.log

    echo "Grant..."
    sudo cp data/grant.sql /tmp/grant.sql
    sudo sed -i "s/my_reader_user;$/$user_pg;/" /tmp/grant.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/grant.sql &> log/install_db.log
   

    # Mise en place des mailles et d la table de l'emprise du territoire
    echo "Découpage des mailles et creation de la table des mailles"
    cd data/ref


    rm -f L93*.dbf L93*.prj L93*.sbn L93*.sbx L93*.shp L93*.shx

    unzip L93_1K.zip 
    unzip L93_5K.zip 
    unzip L93_10K.zip

    if [ $metropole ]; then
    #ajout des mailles non decoupees
    ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 mailles_1.shp L93_1x1.shp
    ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 mailles_5.shp L93_5K.shp
    ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 mailles_10.shp L93_10K.shp


        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I mailles_1.shp atlas.t_mailles_1 | psql -h $db_host -U $admin_pg $db_name
        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I mailles_5.shp atlas.t_mailles_5 | psql -h $db_host -U $admin_pg $db_name
        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I mailles_10.shp atlas.t_mailles_10 | psql -h $db_host -U $admin_pg $db_name

        rm mailles_1.* mailles_5.* mailles_10.*


        #conversion en json
        rm  -f ../../static/custom/territoire.json
        ogr2ogr -f "GeoJSON" -t_srs "EPSG:4326" ../../static/custom/territoire.json $limit_shp

        cd ../../
        echo $taillemaille
        # Creation de la table t_maille_territoire avec la taille de maille passée en parametre
        export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -c "CREATE TABLE atlas.t_mailles_territoire as
                                                    SELECT m.geom, ST_AsGeoJSON(st_transform(t.geom, 4326))
                                                    FROM atlas.t_mailles_"$taillemaille" m, atlas.t_layer_territoire t
                                                    WHERE ST_Intersects(m.geom, t.geom);
                                                    CREATE INDEX index_gist_t_mailles_territoire
                                                    ON atlas.t_mailles_territoire
                                                    USING gist (geom); 
                                                    ALTER TABLE atlas.t_mailles_territoire
                                                    ADD COLUMN id_maille serial;
                                                    ALTER TABLE atlas.t_mailles_territoire
                                                    ADD PRIMARY KEY (id_maille);"
    else 
        ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 custom_mailles_3857.shp $chemin_custom_maille 
        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I custom_mailles_3857.shp atlas.t_mailles_custom | psql -h $db_host -U $admin_pg $db_name

                export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -c "CREATE TABLE atlas.t_mailles_territoire as
                                                    SELECT m.geom, ST_AsGeoJSON(st_transform(t.geom, 4326))
                                                    FROM atlas.t_mailles_custom m, atlas.t_layer_territoire t
                                                    WHERE ST_Intersects(m.geom, t.geom);
                                                    CREATE INDEX index_gist_t_mailles_custom
                                                    ON atlas.t_mailles_territoire
                                                    USING gist (geom); 
                                                    ALTER TABLE atlas.t_mailles_territoire
                                                    ADD COLUMN id_maille serial;
                                                    ALTER TABLE atlas.t_mailles_territoire
                                                    ADD PRIMARY KEY (id_maille);"
    fi


    echo "Creation de la table des mailles..."
    #ajout de la tabme vm_mailles_observations
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f data/mailles.sql  &> log/install_mailles.log

    echo "Grant..."
    sudo cp data/grant.sql /tmp/grant.sql
    sudo sed -i "s/my_reader_user;$/$user_pg;/" /tmp/grant.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/grant.sql &> log/install_db.log
    
    cd data/ref
    rm -f L*.shp L*.dbf L*.prj L*.sbn L*.sbx L*.shx output_clip.*
    cd ../..

fi
