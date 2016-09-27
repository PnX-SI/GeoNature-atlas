#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

. main/configuration/settings.ini

function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf as appropriate.
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

# Si la BDD existe, je verifie le parametre qui indique si je dois la supprimer ou non
if database_exists $db_name
then
        if $drop_apps_db
            then
            echo "Suppression de la BDD..."
            sudo -n -u postgres -s dropdb $db_name
        else
            echo "La base de données existe et le fichier de settings indique de ne pas la supprimer."
        fi
fi 

# Sinon je créé la BDD
if ! database_exists $db_name 
then

    echo "Création de la BDD..."

    sudo -u postgres psql -c "CREATE USER $user_pg WITH PASSWORD '$user_pg_pass' "
    sudo -u postgres psql -c "CREATE USER $admin_pg WITH PASSWORD '$user_pg_pass' "
    sudo -n -u postgres -s createdb -O $admin_pg $db_name
    echo "Ajout de postGIS et pgSQL à la base de données"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"
	# Si j'utilise GeoNature ($geonature_source = True), alors je créé les connexions en FWD à la BDD GeoNature
	if [ $geonature_source ]; then
        echo "Ajout du FDW et connexion à la BDD mère GeoNature"
        sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"
        sudo -n -u postgres -s psql -d $db_name -c "CREATE SERVER geonaturedbserver FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host '$db_source_host', dbname '$db_source_name', port '$db_source_port');"
        sudo -n -u postgres -s psql -d $db_name -c "ALTER SERVER geonaturedbserver OWNER TO $admin_pg;"
        sudo -n -u postgres -s psql -d $db_name -c "CREATE USER MAPPING FOR $admin_pg SERVER geonaturedbserver OPTIONS (user '$atlas_source_user', password '$atlas_source_pass') ;"
    fi

    # Création des schémas de la BDD

	sudo -n -u postgres -s psql -d $db_name -c "CREATE SCHEMA atlas AUTHORIZATION $admin_pg;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE SCHEMA taxonomie AUTHORIZATION $admin_pg;"
	if [ $geonature_source ]; then
		sudo -n -u postgres -s psql -d $db_name -c "CREATE SCHEMA synthese AUTHORIZATION $admin_pg;"
	fi
    
    # Import du shape des limites du territoire ($limit_shp) dans la BDD / atlas.t_layer_territoire
    ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 data/ref/emprise_territoire_3857.shp $limit_shp
    export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I ./data/ref/emprise_territoire_3857.shp atlas.t_layer_territoire | psql -h $db_host -U $admin_pg $db_name
    rm data/ref/emprise_territoire_3857.*
    # Creation de l'index GIST sur la couche territoire atlas.t_layer_territoire
    export PGPASSWORD=$admin_pg_pass; psql -h $db_host -U $admin_pg -d $db_name -c "CREATE INDEX index_gist_t_layer_territoire
                                                                                    ON atlas.t_layer_territoire
                                                                                    USING gist(geom);
                                                                                    ALTER TABLE atlas.t_layer_territoire RENAME COLUMN geom TO the_geom;"
    # Conversion des limites du territoire en json
    rm  -f ../../static/custom/territoire.json
    ogr2ogr -f "GeoJSON" -t_srs "EPSG:4326" ../../static/custom/territoire.json $limit_shp

    # Import du shape des communes ($communes_shp) dans la BDD (si parametre import_commune_shp = TRUE) / atlas.l_communes
    if [ import_commune_shp ]; then
        ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 ./data/ref/communes_3857.shp $communes_shp
        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I ./data/ref/communes_3857.shp atlas.l_communes | psql -h $db_host -U $admin_pg $db_name
        psql -h $db_host -U $admin_pg $db_name -c "ALTER TABLE atlas.l_communes RENAME COLUMN $colonne_nom_commune TO commune_maj;
                                                   ALTER TABLE atlas.l_communes RENAME COLUMN $colonne_insee TO insee;
                                                   ALTER TABLE atlas.l_communes RENAME COLUMN geom TO the_geom;
                                                   CREATE INDEX index_gist_t_layers_communes
                                                    ON atlas.l_communes USING gist (the_geom); "
        rm ./data/ref/communes_3857.*
    fi

    echo "Création de la structure de la BDD..."
    # Si j'utilise GeoNature ($geonature_source = True), alors je créé les tables filles en FDW connectées à la BDD de GeoNature
    if [ $geonature_source ]; then
        #Creation des tables filles en FWD
        sudo cp data/atlas_geonature.sql /tmp/atlas_geonature.sql
        sudo sed -i "s/myuser;$/$admin_pg;/" /tmp/atlas_geonature.sql
        export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/atlas_geonature.sql  &>> log/install_db.log
    fi

    # Creation des Vues Matérialisées (et remplacement éventuel des valeurs en dur par les paramètres)
    sudo cp data/atlas.sql /tmp/atlas.sql
    sudo sed -i "s/WHERE id_attribut IN (100, 101, 102, 103);$/WHERE id_attribut  IN ($attr_desc, $attr_commentaire, $attr_milieu, $attr_chorologie);/" /tmp/atlas.sql
    sudo sed -i "s/date - 15$/date - $time/" /tmp/atlas.sql
    sudo sed -i "s/date + 15$/date - $time/" /tmp/atlas.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/atlas.sql  &>> log/install_db.log
	
	# Si j'utilise GeoNature ($geonature_source = True), alors je vais ajouter des droits en lecture à l'utilisateur Admin de l'atlas
    if [ $geonature_source ]; then
	    echo "Affectation des droits de lecture sur la BDD source GeoNature..."
        sudo cp data/grant_geonature.sql /tmp/grant_geonature.sql
        sudo sed -i "s/myuser;$/$admin_pg;/" /tmp/grant_geonature.sql
        export PGPASSWORD=$admin_source_pass;psql -h $db_source_host -U $admin_source_user -d $db_source_name -f /tmp/grant_geonature.sql  &>> log/install_db.log
    fi
	
    # Mise en place des mailles
    echo "Découpage des mailles et creation de la table des mailles"
    cd data/ref

    rm -f L93*.dbf L93*.prj L93*.sbn L93*.sbx L93*.shp L93*.shx
	
	# Si je suis en métropole (metropole=true), alors j'utilise les mailles fournies par l'INPN
    if [ $metropole ]; then
        # Je dézippe mailles fournies par l'INPN aux 3 échelles
        unzip L93_1K.zip 
        unzip L93_5K.zip 
        unzip L93_10K.zip
        # Je les reprojete les SHP en 3857 et les renomme
        ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 mailles_1.shp L93_1x1.shp
        ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 mailles_5.shp L93_5K.shp
        ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 mailles_10.shp L93_10K.shp
        # J'importe dans la BDD le SHP des mailles à l'échelle définie en parametre ($taillemaille)
        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I mailles_$taillemaille.shp atlas.t_mailles_$taillemaille | psql -h $db_host -U $admin_pg $db_name
    
        rm mailles_1.* mailles_5.* mailles_10.* L93_1x1.* L93_5K.* L93_10K.*

        cd ../../
        echo $taillemaille
        
		# Creation de la table atlas.t_mailles_territoire avec la taille de maille passée en parametre ($taillemaille). Pour cela j'intersecte toutes les mailles avec mon territoire
        export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -c "CREATE TABLE atlas.t_mailles_territoire as
                                                    SELECT m.geom AS the_geom, ST_AsGeoJSON(st_transform(t.the_geom, 4326))
                                                    FROM atlas.t_mailles_"$taillemaille" m, atlas.t_layer_territoire t
                                                    WHERE ST_Intersects(m.geom, t.the_geom);
                                                    CREATE INDEX index_gist_t_mailles_territoire
                                                    ON atlas.t_mailles_territoire
                                                    USING gist (the_geom); 
                                                    ALTER TABLE atlas.t_mailles_territoire
                                                    ADD COLUMN id_maille serial;
                                                    ALTER TABLE atlas.t_mailles_territoire
                                                    ADD PRIMARY KEY (id_maille);"
    
	# Sinon j'utilise un SHP des mailles fournies par l'utilisateur
	else 
        ogr2ogr -f "ESRI Shapefile" -t_srs EPSG:3857 custom_mailles_3857.shp $chemin_custom_maille 
        export PGPASSWORD=$admin_pg_pass;shp2pgsql -W "LATIN1" -s 3857 -D -I custom_mailles_3857.shp atlas.t_mailles_custom | psql -h $db_host -U $admin_pg $db_name

        export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -c "CREATE TABLE atlas.t_mailles_territoire as
                                            SELECT m.geom AS the_geom, ST_AsGeoJSON(st_transform(t.the_geom, 4326))
                                            FROM atlas.t_mailles_custom m, atlas.t_layer_territoire t
                                            WHERE ST_Intersects(m.geom, t.the_geom);
                                            CREATE INDEX index_gist_t_mailles_custom
                                            ON atlas.t_mailles_territoire
                                            USING gist (the_geom); 
                                            ALTER TABLE atlas.t_mailles_territoire
                                            ADD COLUMN id_maille serial;
                                            ALTER TABLE atlas.t_mailles_territoire
                                            ADD PRIMARY KEY (id_maille);"
    fi


    echo "Creation de la VM des observations de chaque taxon par mailles..."
    # Création de la vue matérialisée vm_mailles_observations (nombre d'observations par maille et par taxon)
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f data/observations_mailles.sql  &> log/install_mailles.log

	# Affectation de droits en lecture sur les VM à l'utilisateur de l'application ($user_pg)
    echo "Grant..."
    sudo cp data/grant.sql /tmp/grant.sql
    sudo sed -i "s/my_reader_user;$/$user_pg;/" /tmp/grant.sql
    export PGPASSWORD=$admin_pg_pass;psql -h $db_host -U $admin_pg -d $db_name -f /tmp/grant.sql &> log/install_db.log
    
	# Affectation de droits en lecture sur les VM à l'utilisateur de l'application ($user_pg)
    cd data/ref
    rm -f L*.shp L*.dbf L*.prj L*.sbn L*.sbx L*.shx output_clip.*
    cd ../..

fi
