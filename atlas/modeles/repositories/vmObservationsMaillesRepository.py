import json

from geojson import Feature, FeatureCollection
from sqlalchemy.sql import text, func, any_, extract, literal, cast, select
from sqlalchemy import Interval

from atlas.modeles.entities.vmObservations import VmObservations, VmObservationsMailles
from atlas.modeles.entities.vmAreas import VmAreas, VmCorAreaSynthese
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmMedias import VmMedias
from atlas.modeles.utils import deleteAccent, findPath
from atlas.app import create_app
from atlas.env import db
from flask import current_app


def getObservationsMaillesTerritorySpecies(cd_ref):
    """
    Retourne les mailles et le nombre d'observation par maille pour un taxon et ses enfants
    sous forme d'un geojson
    """
    query = func.atlas.find_all_taxons_childs(cd_ref)
    taxons_ids = db.session.scalars(query).all()
    taxons_ids.append(cd_ref)

    query = (
        db.session.query(
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson,
            func.max(extract("year", VmObservations.dateobs)).label("last_obs_year"),
            VmObservationsMailles.nbr.label("obs_nbr"),
            VmObservationsMailles.type_code,
        )
        .join(
            VmObservations,
            VmObservations.id_observation == any_(VmObservationsMailles.id_observations),
        )
        .join(
            VmAreas,
            VmAreas.id_area == VmObservationsMailles.id_maille,
        )
        .filter(VmObservations.cd_ref == any_(taxons_ids))
        .group_by(
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson,
            VmObservationsMailles.nbr,
            VmObservationsMailles.type_code,
        )
    )

    return FeatureCollection(
        [
            Feature(
                id=o.id_maille,
                geometry=json.loads(o.area_geojson),
                properties={
                    "id_maille": o.id_maille,
                    "type_code": o.type_code,
                    "nb_observations": int(o.obs_nbr),
                    "last_observation": o.last_obs_year,
                },
            )
            for o in query.all()
        ]
    )


def format_taxon_name(observation):
    if observation.nom_vern:
        inter = observation.nom_vern.split(",")
        taxon_name_formated = inter[0] + " | <i>" + observation.lb_nom + "</i>"
    else:
        taxon_name_formated = "<i>" + observation.lb_nom + "</i>"
    return taxon_name_formated


def getObservationsMaillesChilds(cd_ref, year_min=None, year_max=None):
    """
    Retourne les mailles et le nombre d'observation par maille pour un taxon et ses enfants
    sous forme d'un geojson
    """
    query = func.atlas.find_all_taxons_childs(cd_ref)
    taxons_ids = db.session.scalars(query).all()
    taxons_ids.append(cd_ref)

    query = (
        db.session.query(
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson,
            func.max(extract("year", VmObservations.dateobs)).label("last_obs_year"),
            func.count(VmObservations.id_observation).label("obs_nbr"),
            VmObservationsMailles.type_code,
        )
        .join(
            VmObservations,
            VmObservations.id_observation == any_(VmObservationsMailles.id_observations),
        )
        .join(
            VmAreas,
            VmAreas.id_area == VmObservationsMailles.id_maille,
        )
        .filter(VmObservations.cd_ref == any_(taxons_ids))
        .group_by(
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson,
            VmObservationsMailles.nbr,
            VmObservationsMailles.type_code,
        )
    )
    if year_min and year_max:
        query = query.filter(
            VmObservations.dateobs.between(str(year_min) + "-01-01", str(year_max) + "-12-31")
        )

    return FeatureCollection(
        [
            Feature(
                id=o.id_maille,
                geometry=json.loads(o.area_geojson),
                properties={
                    "id_maille": o.id_maille,
                    "type_code": o.type_code,
                    "nb_observations": int(o.obs_nbr),
                    "last_observation": o.last_obs_year,
                },
            )
            for o in query.all()
        ]
    )


def territoryObservationsMailles():
    features = (
        db.session.query(
            func.count(VmObservations.id_observation).label("nb_observations"),
            func.count(func.distinct(VmObservations.cd_ref)).label("nb_cd_ref"),
            func.json_agg(
                func.distinct(
                    func.jsonb_build_object(
                        'name', func.concat_ws(' | ', VmTaxons.nom_vern, VmTaxons.lb_nom),
                        'cdRef', VmTaxons.cd_ref
                    )
                )
            ).label("taxons"),
            VmObservationsMailles.type_code,
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson
        )
        .join(VmObservationsMailles, 
              VmObservations.id_observation == func.any(VmObservationsMailles.id_observations))
        .join(VmAreas, VmAreas.id_area == VmObservationsMailles.id_maille)
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .group_by(VmObservationsMailles.type_code, VmObservationsMailles.id_maille, VmAreas.area_geojson)
    )
    return json.dumps(
        FeatureCollection(
            [
                Feature(
                    id=o.id_maille,
                    geometry=json.loads(o.area_geojson),
                    properties={
                        "nb_observations": o.nb_observations,
                        "nb_cd_ref": o.nb_cd_ref,
                        "taxons": o.taxons,
                        "type_code": o.type_code,
                        "id_maille": o.id_maille 
                    }
                )
                for o in features.all()
            ]
        ),
        ensure_ascii = False # Empêche la sortie de caractères spéciaux au niveau de taxons
    ) 


# last observation for index.html
def lastObservationsMailles(mylimit, idPhoto):
    query = (
        select(
            VmObservationsMailles,
            VmTaxons.lb_nom, VmTaxons.nom_vern, VmTaxons.group2_inpn,
            VmObservations.dateobs, VmObservations.altitude_retenue,
            VmObservations.id_observation, VmObservations.cd_ref,
            VmMedias.url,  VmMedias.chemin, VmMedias.id_media,
            VmAreas.area_geojson

        )
        .join(VmObservations, 
              VmObservations.id_observation == func.any(VmObservationsMailles.id_observations))
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .join(VmAreas, VmAreas.id_area == VmObservationsMailles.id_maille)
        .outerjoin(
            VmMedias, (VmMedias.cd_ref == VmObservations.cd_ref) & (VmMedias.id_type == idPhoto)
        )
        .filter(VmObservations.dateobs >= (func.current_timestamp() - cast(literal(mylimit), Interval)))
        .order_by(VmObservations.dateobs.desc())
    )

    results = db.session.execute(query).mappings().all()
    obsList = list()
    for row in results:
        obj = row["VmObservationsMailles"] # Objet ORM VmObservationsMailles
        if row.nom_vern:
            inter = row.nom_vern.split(",")
            taxon = inter[0] + " | <i>" + row.lb_nom + "</i>"
        else:
            taxon = "<i>" + row.lb_nom + "</i>"
        temp = {
            "id_observation": row.id_observation,
            "id_maille": obj.id_maille,
            "type_code": obj.type_code,
            "cd_ref": row.cd_ref,
            "dateobs": row.dateobs,
            "altitude_retenue": row.altitude_retenue,
            "taxon": taxon,
            "geojson_maille": json.loads(row.area_geojson),
            "group2_inpn": deleteAccent(row.group2_inpn),
            "pathImg": findPath(row),
            "id_media": row.id_media,
        }
        obsList.append(temp)

    return obsList


def getObservationsByArea(id_area):
    obs_in_area = (
        select(
            VmObservations.id_observation,
            VmObservations.cd_ref,
            func.date_part('year', VmObservations.dateobs).label("annee")
        )
        .join(VmCorAreaSynthese, 
              VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
        .filter(VmCorAreaSynthese.id_area == id_area)
        .subquery("obs_in_area")
    )
    features = (
        db.session.query(
            func.count(obs_in_area.c.id_observation).label("nb_observations"),
            func.count(func.distinct(obs_in_area.c.cd_ref)).label("nb_cd_ref"),
            func.json_agg(
                func.distinct(
                    func.jsonb_build_object(
                        'name', (func.concat(func.coalesce(VmTaxons.nom_vern + ' | ', '') + VmTaxons.lb_nom)),
                        'cdRef', VmTaxons.cd_ref
                    ) 
                )
            ).label('taxons'),
            VmObservationsMailles.type_code,
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson
        )
        .join(VmObservationsMailles, obs_in_area.c.id_observation == func.any(VmObservationsMailles.id_observations))
        .join(VmAreas, VmAreas.id_area == VmObservationsMailles.id_maille)
        .join(VmTaxons, VmTaxons.cd_ref == obs_in_area.c.cd_ref)
        .group_by(VmObservationsMailles.type_code, VmObservationsMailles.id_maille, VmAreas.area_geojson)
    )

    return json.dumps(
        FeatureCollection(
            [
                Feature(
                    id=o.id_maille,
                    geometry = json.loads(o.area_geojson),
                    properties={
                        "nb_observations": o.nb_observations,
                        "nb_cd_ref": o.nb_cd_ref,
                        "taxons": o.taxons,
                        "type_code": o.type_code,
                        "id_maille": o.id_maille
                    }
                )
                for o in features.all()
            ]
        ),
        ensure_ascii=False 
    ) 


# Use for API
def getObservationsTaxonAreaMaille(id_area, cd_ref):
    obs_in_area = (
        select(
            VmObservations.id_observation,
            VmObservations.cd_ref,
            func.date_part('year', VmObservations.dateobs).label("annee"),
            func.count(VmObservations.id_observation).label("nb_observations")
        )
        .join(VmCorAreaSynthese, VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
        .filter(VmCorAreaSynthese.id_area == id_area, VmObservations.cd_ref == cd_ref)
        .group_by(VmObservations.id_observation, VmObservations.cd_ref, func.date_part('year', VmObservations.dateobs))
        .subquery("obs_in_area")
    ) 
    query = (
        select(
            obs_in_area.c.cd_ref,
            obs_in_area.c.annee,
            obs_in_area.c.nb_observations,
            VmObservationsMailles.type_code,
            VmObservationsMailles.id_maille,
            VmAreas.area_geojson,
            VmTaxons.nom_vern,
            VmTaxons.lb_nom
        )
        .join(VmObservationsMailles, 
              obs_in_area.c.id_observation == func.any(VmObservationsMailles.id_observations))
        .join(VmAreas, VmAreas.id_area == VmObservationsMailles.id_maille)
        .join(VmTaxons, VmTaxons.cd_ref == obs_in_area.c.cd_ref)
        .order_by(obs_in_area.c.annee.desc())
    )
    observations = db.session.execute(query).all()
    tabObs = list()
    for o in observations:
        temp = {
            "id_maille": o.id_maille,
            "cd_ref": o.cd_ref,
            "taxon": format_taxon_name(o),
            "type_code": o.type_code,
            "nb_observations": o.nb_observations,
            "annee": o.annee,
            "geojson_maille": json.loads(o.area_geojson),
        }
        tabObs.append(temp)

    return tabObs
