import json

from geojson import Feature, FeatureCollection
from sqlalchemy.sql import text, func, or_

from atlas.modeles.entities.vmObservations import VmObservationsMailles
from atlas.modeles.utils import deleteAccent, findPath


def getObservationsMaillesChilds(session, cd_ref, year_min=None, year_max=None):
    """
    Retourne les mailles et le nombre d'observation par maille pour un taxon et ses enfants
    sous forme d'un geojson
    """
    subquery = session.query(func.atlas.find_all_taxons_childs(cd_ref))
    query = (
        session.query(
            func.count(VmObservationsMailles.id_observation).label("nb_obs"),
            func.max(VmObservationsMailles.annee).label("last_observation"),
            VmObservationsMailles.id_maille,
            VmObservationsMailles.geojson_maille,
        )
            .group_by(VmObservationsMailles.id_maille, VmObservationsMailles.geojson_maille)
            .filter(
            or_(
                VmObservationsMailles.cd_ref.in_(subquery),
                VmObservationsMailles.cd_ref == cd_ref,
            )
        )
    )
    if year_min and year_max:
        query = query.filter(VmObservationsMailles.annee.between(year_min, year_max))

    return FeatureCollection(
        [
            Feature(
                id=o.id_maille,
                geometry=json.loads(o.geojson_maille),
                properties={
                    "id_maille": o.id_maille,
                    "nb_observations": o.nb_obs,
                    "last_observation": o.last_observation,
                },
            )
            for o in query.all()
        ]
    )


# last observation for index.html
def lastObservationsMailles(connection, mylimit, idPhoto):
    sql = """
        SELECT obs.*,
        tax.lb_nom, tax.nom_vern, tax.group2_inpn,
        o.dateobs, o.altitude_retenue,
        medias.url, medias.chemin, medias.id_media
        FROM atlas.vm_observations_mailles obs
        JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref
        JOIN atlas.vm_observations o ON o.id_observation=obs.id_observation
        LEFT JOIN atlas.vm_medias medias
            ON medias.cd_ref = obs.cd_ref AND medias.id_type = :thisID
        WHERE  o.dateobs >= (CURRENT_TIMESTAMP - INTERVAL :thislimit)
        ORDER BY o.dateobs DESC
    """

    observations = connection.execute(text(sql), thislimit=mylimit, thisID=idPhoto)
    obsList = list()
    for o in observations:
        if o.nom_vern:
            inter = o.nom_vern.split(",")
            taxon = inter[0] + " | " + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {
            "id_observation": o.id_observation,
            "id_maille": o.id_maille,
            "cd_ref": o.cd_ref,
            "dateobs": str(o.dateobs),
            "altitude_retenue": o.altitude_retenue,
            "taxon": taxon,
            "geojson_maille": json.loads(o.geojson_maille),
            "group2_inpn": deleteAccent(o.group2_inpn),
            "pathImg": findPath(o),
            "id_media": o.id_media,
        }
        obsList.append(temp)
    return obsList


def lastObservationsCommuneMaille(connection, mylimit, insee):
    sql = """
    WITH last_obs AS (
        SELECT
            obs.cd_ref, obs.dateobs, t.lb_nom,
            t.nom_vern, obs.the_geom_point AS l_geom
        FROM atlas.vm_observations obs
        JOIN atlas.vm_communes c
        ON ST_Intersects(obs.the_geom_point, c.the_geom)
        JOIN atlas.vm_taxons t
        ON  obs.cd_ref = t.cd_ref
        WHERE c.insee = :thisInsee
        ORDER BY obs.dateobs DESC
        LIMIT :thislimit
    )
    SELECT l.lb_nom, l.nom_vern, l.cd_ref, m.id_maille, m.geojson_maille
    FROM atlas.t_mailles_territoire m
    JOIN last_obs  l
    ON st_intersects(m.the_geom, l.l_geom)
    GROUP BY l.lb_nom, l.cd_ref, m.id_maille, l.nom_vern, m.geojson_maille
    """
    observations = connection.execute(text(sql), thisInsee=insee, thislimit=mylimit)
    obsList = list()
    for o in observations:
        if o.nom_vern:
            taxon = o.nom_vern + " | " + o.lb_nom
        else:
            taxon = o.lb_nom
        temp = {
            "cd_ref": o.cd_ref,
            "taxon": taxon,
            "geojson_maille": json.loads(o.geojson_maille),
            "id_maille": o.id_maille,
        }
        obsList.append(temp)
    return obsList


# Use for API
def getObservationsTaxonCommuneMaille(connection, insee, cd_ref):
    sql = """
        SELECT
            o.cd_ref, t.id_maille, t.geojson_maille,
            extract(YEAR FROM o.dateobs) AS annee
        FROM atlas.vm_observations o
        JOIN atlas.vm_communes c
        ON ST_INTERSECTS(o.the_geom_point, c.the_geom)
        JOIN atlas.t_mailles_territoire t
        ON ST_INTERSECTS(t.the_geom, o.the_geom_point)
        WHERE o.cd_ref = :thiscdref AND c.insee = :thisInsee
        ORDER BY id_maille
    """
    observations = connection.execute(text(sql), thisInsee=insee, thiscdref=cd_ref)
    tabObs = list()
    for o in observations:
        temp = {
            "id_maille": o.id_maille,
            "nb_observations": 1,
            "annee": o.annee,
            "geojson_maille": json.loads(o.geojson_maille),
        }
        tabObs.append(temp)

    return tabObs
