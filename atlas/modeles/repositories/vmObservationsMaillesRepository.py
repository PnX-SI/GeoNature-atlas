import json
from datetime import datetime

from geojson import Feature, FeatureCollection
from sqlalchemy.sql import text, func, any_, extract, literal, cast, select, exists, true
from sqlalchemy import Interval

from atlas.modeles.entities.vmObservations import VmObservations, VmObservationsMailles, VMCorMailleObservation
from atlas.modeles.entities.vmAreas import VmAreas, VmCorAreaSynthese
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmMedias import VmMedias
from atlas.modeles.utils import deleteAccent, findPath
from atlas.app import create_app
from atlas.env import db
from flask import current_app


def format_taxon_name(observation):
    if observation.nom_vern:
        inter = observation.nom_vern.split(",")
        taxon_name_formated = inter[0] + " | <i>" + observation.lb_nom + "</i>"
    else:
        taxon_name_formated = "<i>" + observation.lb_nom + "</i>"
    return taxon_name_formated


def getObservationsMaillesChilds(filters={}, with_taxons=False):
    """
    Retourne un geojson sous forme de maille des observations
    Le geojson contient les propriétés suivantes :
        - id_maille
        - type_code : le type de maille à la laquelle la géométrie a floutée
        - last_obs_year : l'année à laquel la dernière observation a été faite dans la maille
        - obs_nbr : le nombre d'observation dans la maille
        - taxons (optionnel: si with taxon est True) : une liste des taxons dans la maille
    Parameters
    ----------
    filters : dict, optional
        dictionnaire des filtres de la query
        Filtres disponible :
            - year_min / year_max : filtre les observation dans des bornes d'année
            - cd_ref : renvoie que les observation de ce taxon et de ces enfants
            - id_area : renvoie uniquement les observations présente dans l'aire demandée
    with_taxons : bool, optional
        - Permet d'ajouter la liste des taxon d'une maille au Geojson

    Returns
    -------
    Geosjon
    """
    taxons_ids = []
    if "cd_ref" in filters and filters["cd_ref"]:
        query_child = func.atlas.find_all_taxons_childs(filters["cd_ref"])
        taxons_ids = db.session.scalars(query_child).all()
        taxons_ids.append(int(filters["cd_ref"]))

    query_select = [
            VMCorMailleObservation.id_maille,
            VmAreas.area_geojson,
            VMCorMailleObservation.type_code,
            func.max(func.date_part('year', VmObservations.dateobs)).label("last_obs_year"),
            func.count(VmObservations.id_observation).label("obs_nbr"),
    ]
    if with_taxons:
        query_select.append(
            func.json_agg(
                func.distinct(
                    func.jsonb_build_object(
                        'name', (func.concat(func.coalesce(VmTaxons.nom_vern + ' | ', '') + VmTaxons.lb_nom)),
                        'cdRef', VmTaxons.cd_ref
                    )
                )
            ).label('taxons'),
        )
    query = select(
        *query_select
    ).select_from(VmObservations).join(
        VMCorMailleObservation, VMCorMailleObservation.id_observation == VmObservations.id_observation
    ).join(
        VmAreas, VmAreas.id_area == VMCorMailleObservation.id_maille
    ).group_by(
            VMCorMailleObservation.id_maille,
            VmAreas.area_geojson,
            VMCorMailleObservation.type_code,
    )
    if with_taxons:
        query = query.join(
                VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref
            )
    if taxons_ids:
        query = query.where(
             VmObservations.cd_ref == any_(taxons_ids)
        )
    if ("year_min" in filters and filters["year_min"]) and ("year_max" in filters and filters["year_max"] ):
        query = query.where(
            VmObservations.dateobs.between(
                datetime(int(filters["year_min"]), 1,1), datetime(int(filters["year_max"]), 12, 31))
            )
    if "id_area" in filters and filters["id_area"]:
        query = query.where(exists(
                select(true()).select_from(VmCorAreaSynthese).where(
                    (VmCorAreaSynthese.id_area == filters["id_area"]) & (VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
                )
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
                    "taxons": o.taxons if with_taxons else None
                },
            )
            for o in db.session.execute(query).all()
        ]
    )

# last observation for index.html
def lastObservationsMailles(mylimit, idPhoto):
    query = (
            select(
                VmObservations,
                VMCorMailleObservation,
                VmTaxons.lb_nom, 
                VmTaxons.nom_vern, 
                VmTaxons.group2_inpn,
                VmMedias.url,  
                VmMedias.chemin, 
                VmMedias.id_media,
                VmAreas.area_geojson
            )
            .select_from(
                VmObservations
            ).join(
                VMCorMailleObservation, VMCorMailleObservation.id_observation == VmObservations.id_observation
            ).join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
            .join(VmAreas, VmAreas.id_area == VMCorMailleObservation.id_maille)
            .outerjoin(
                VmMedias, (VmMedias.cd_ref == VmObservations.cd_ref) & (VmMedias.id_type == idPhoto)
            ).where(VmObservations.dateobs >= (func.current_timestamp() - cast(literal(mylimit), Interval)))
            .order_by(VmObservations.dateobs.desc())
        )

    results = db.session.execute(query).mappings().all()
    
    obsList = list()
    for row in results:
        print(row)
        vm_obj_maille_obj = row["VMCorMailleObservation"] # Objet ORM VmObservationsMailles
        vm_obs_obj = row["VmObservations"]
        if row.nom_vern:
            inter = row.nom_vern.split(",")
            taxon = inter[0] + " | <i>" + row.lb_nom + "</i>"
        else:
            taxon = "<i>" + row.lb_nom + "</i>"
        temp = {
            "id_observation": vm_obs_obj.id_observation,
            "id_maille": vm_obj_maille_obj.id_maille,
            "type_code": vm_obj_maille_obj.type_code,
            "cd_ref": vm_obs_obj.cd_ref,
            "dateobs": vm_obs_obj.dateobs,
            "altitude_retenue": vm_obs_obj.altitude_retenue,
            "taxon": taxon,
            "geojson_maille": json.loads(row.area_geojson),
            "group2_inpn": deleteAccent(row.group2_inpn),
            "pathImg": findPath(row),
            "id_media": row.id_media,
        }
        obsList.append(temp)
    return obsList