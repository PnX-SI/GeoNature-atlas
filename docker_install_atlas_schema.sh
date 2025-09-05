set -eof pipefail

# +---------------------------------------------------------------------+
# Check env variables
if [ -z "$ATLAS_TYPE_MAILLE" ]; then
    echo la variable ATLAS_TYPE_MAILLE n''est pas définie
fi

if [ -z "$ATLAS_TYPE_TERRITOIRE" ]; then
    echo la variable ATLAS_TYPE_TERRITOIRE n''est pas définie
fi

if [ -z "$ATLAS_ALTITUDES" ]; then
    echo la variable ATLAS_ALTITUDES n''est pas définie
fi

if [ -z "$ATLAS_TAXHUB_DISPLAYED_ATTRIBUTES" ]; then
    echo la variable ATLAS_TAXHUB_DISPLAYED_ATTR n''est pas définie
fi

if [ -z "$ATLAS_TYPE_MAILLE" ] || [ -z "$ATLAS_TYPE_TERRITOIRE" ] || [ -z "$ATLAS_ALTITUDES" ] || [ -z "$ATLAS_TAXHUB_DISPLAYED_ATTRIBUTES" ]; then
    exit 1
fi

# +---------------------------------------------------------------------+
# Create atlas schemas
export PGPASSWORD=${POSTGRES_PASSWORD}
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE SCHEMA atlas";
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE SCHEMA synthese";
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE SCHEMA sensitivity";


# +---------------------------------------------------------------------+
# Prepare SQL scripts

# Altitudes
altitudes=$(echo ${ATLAS_ALTITUDES} | sed 's/[\(\)]//g')
altitude_max=0
id_altitude=0
insert=""
for altitude in $(echo "${altitudes}"); do
    if [ ! -z "$last_altitude" ]; then
        id_altitude=$((id_altitude+1))
        sql="INSERT INTO atlas.bib_altitudes VALUES ($id_altitude, $last_altitude, $altitude);"
        insert="${insert}\n${sql}"
    fi
    last_altitude=$altitude
done

sed "s/INSERT_ALTITUDE/${insert}/" \
    data/atlas/4.atlas.vm_altitudes.sql > /tmp/4.atlas.vm_altitudes.sql

# Most observed taxons
sed "s/date - 15$/date - ${ATLAS_MOST_OBSERVED_TIME:-'15'}/" \
    data/atlas/10.atlas.vm_taxons_plus_observes.sql > /tmp/10.atlas.vm_taxons_plus_observes.sql
sed "s/date + 15$/date - ${ATLAS_MOST_OBSERVED_TIME:-'15'}/" \
    data/atlas/10.atlas.vm_taxons_plus_observes.sql > /tmp/10.atlas.vm_taxons_plus_observes.sql

# +---------------------------------------------------------------------+
# Execute SQL scripts

# REFGEO
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} \
    -v type_territoire=$ATLAS_TYPE_TERRITOIRE \
    -f data/gn2/atlas_ref_geo.sql

# Create views instead of FDW table in "synthese" and "senitivity" schema
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE VIEW synthese.cor_area_synthese AS SELECT * FROM gn_synthese.cor_area_synthese"
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE VIEW synthese.synthese AS SELECT * FROM gn_synthese.synthese"
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE VIEW synthese.t_nomenclatures AS SELECT * FROM ref_nomenclatures.t_nomenclatures"
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE VIEW synthese.bib_nomenclatures_types AS SELECT * FROM ref_nomenclatures.bib_nomenclatures_types"
psql -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -c "CREATE VIEW sensitivity.cor_sensitivity_area_type AS SELECT * FROM gn_sensitivity.cor_sensitivity_area_type"
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/gn2/atlas_synthese.sql
# Others
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/1.atlas.vm_taxref.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/2.atlas.vm_observations.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/3.atlas.vm_taxons.sql

psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f /tmp/4.atlas.vm_altitudes.sql

psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/5.atlas.vm_search_taxon.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/6.atlas.vm_mois.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/8.atlas.vm_medias.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} \
    -v taxhub_displayed_attr=${ATLAS_TAXHUB_DISPLAYED_ATTRIBUTES} \
    -f data/atlas/9.atlas.vm_cor_taxon_attribut.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f /tmp/10.atlas.vm_taxons_plus_observes.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/11.atlas.vm_cor_taxon_organism.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} \
    -v type_maille=$ATLAS_TYPE_MAILLE \
    -f data/atlas/12.atlas.vm_mailles_territoire.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/13.atlas.vm_observations_mailles.sql
psql -v ON_ERROR_STOP=1 -d ${POSTGRES_DB} -U ${POSTGRES_USER} -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -f data/atlas/atlas.refresh_materialized_view_data.sql
