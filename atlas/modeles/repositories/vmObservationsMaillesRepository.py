import json
from datetime import datetime

from geojson import Feature, FeatureCollection
from sqlalchemy import Interval
from sqlalchemy.orm import aliased
from sqlalchemy.sql import any_, cast, exists, func, literal, select, true

from atlas.env import db
from atlas.modeles.entities.vmAreas import VmAreas, VmCorAreaSynthese
from atlas.modeles.entities.vmObservations import VMCorMailleObservation, VmObservations


def format_taxon_name(observation):
    if observation.nom_vern:
        inter = observation.nom_vern.split(",")
        taxon_name_formated = inter[0] + " | <i>" + observation.lb_nom + "</i>"
    else:
        taxon_name_formated = "<i>" + observation.lb_nom + "</i>"
    return taxon_name_formated


def getObservationsMaillesChilds(params={}):
    """
    Retourne un geojson sous forme de maille des observations
    Le geojson contient les propriétés suivantes :
        - id_maille
        - type_code : le type de maille à la laquelle la géométrie a floutée
        - last_obs_year : l'année à laquel la dernière observation a été faite dans la maille
        - obs_nbr : le nombre d'observation dans la maille
        - ids_obs (optionnel si fields=ids_obs): la liste des id_observations de la maille
    Parameters
    ----------
    filters : dict, optional
        dictionnaire des filtres de la query
        Filtres disponible :
            - year_min / year_max : filtre les observation dans des bornes d'année
            - cd_ref : renvoie que les observation de ce taxon et de ces enfants
            - id_area : renvoie uniquement les observations présente dans l'aire demandée
            - last_obs : renvoie uniquement les observation de X derniers jours (définit en conf)
    with_taxons : bool, optional
        - Permet d'ajouter la liste des taxon d'une maille au Geojson

    Returns
    -------
    Geosjon
    """
    cd_ref = params.get("cd_ref", None)
    year_min = params.get("year_min", None)
    year_max = params.get("year_max", None)
    id_area = params.get("id_area", None)
    last_obs = params.get("last_obs", None)
    fields: list = params.get("fields", "").split(",")

    taxons_ids = []
    if cd_ref:
        query_child = func.atlas.find_all_taxons_childs(params["cd_ref"])
        taxons_ids = db.session.scalars(query_child).all()
        taxons_ids.append(int(params["cd_ref"]))

    query_select = [
        VMCorMailleObservation.id_maille,
        VmAreas.area_geojson,
        VMCorMailleObservation.type_code,
        VmObservations.cd_sensitivity,
        func.max(func.date_part("year", VmObservations.dateobs)).label("last_obs_year"),
        func.count(VmObservations.id_observation).label("obs_nbr"),
    ]

    if "ids_obs" in fields:
        query_select.append(func.array_agg(VmObservations.id_observation).label("ids_obs"))

    query = (
        select(*query_select)
        .select_from(VmObservations)
        .join(
            VMCorMailleObservation,
            VMCorMailleObservation.id_observation == VmObservations.id_observation,
        )
        .join(VmAreas, VmAreas.id_area == VMCorMailleObservation.id_maille)
        .group_by(
            VMCorMailleObservation.id_maille,
            VmAreas.area_geojson,
            VMCorMailleObservation.type_code,
            VmObservations.cd_sensitivity,
        )
    )

    if taxons_ids:
        query = query.where(VmObservations.cd_ref == any_(taxons_ids))

    if year_min and year_max:
        query = query.where(
            VmObservations.dateobs.between(
                datetime(int(year_min), 1, 1),
                datetime(int(year_max), 12, 31),
            )
        )

    if id_area:
        query = query.where(
            exists(
                select(true())
                .select_from(VmCorAreaSynthese)
                .where(
                    (VmCorAreaSynthese.id_area == id_area)
                    & (VmCorAreaSynthese.id_synthese == VmObservations.id_observation)
                    & (VmCorAreaSynthese.is_valid_for_display.is_(True))
                )
            )
        )
        VmAreasFilter = aliased(VmAreas)
        query = query.where(
            exists(
                select(true())
                .select_from(VmAreasFilter)
                .where(
                    (VmAreasFilter.id_area == id_area)
                    & (func.ST_Intersects(VmAreasFilter.the_geom, VmAreas.the_geom))
                )
            )
        )

    if last_obs:
        query = query.where(
            VmObservations.dateobs >= func.current_timestamp() - cast(literal(last_obs), Interval)
        )

    return FeatureCollection(
        [
            Feature(
                id=o.id_maille,
                geometry=json.loads(o.area_geojson),
                properties={
                    "id_maille": o.id_maille,
                    "type_code": o.type_code,
                    "cd_sensitivity": o.cd_sensitivity,
                    "nb_observations": int(o.obs_nbr),
                    "last_observation": int(o.last_obs_year),
                    "ids_obs": o.ids_obs if "ids_obs" in fields else None,
                },
            )
            for o in db.session.execute(query).all()
        ]
    )
