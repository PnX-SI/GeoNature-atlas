import json

from geojson import Feature, FeatureCollection
from sqlalchemy.sql import text, func, or_

from atlas.modeles.entities import vmOrganismes

def statOrganisme (connection,id_organisme):
    # Fiche organisme
    sql = """SELECT count(DISTINCT cd_ref) AS nb_taxons, SUM(nb_observations) AS nb_obs,
    nom_organisme, url_organisme, url_logo, adresse_organisme, cp_organisme, ville_organisme,
    tel_organisme, email_organisme
    FROM atlas.vm_organismes o
    WHERE o.id_organisme = :thisidorganisme"""
    req = connection.execute(text(sql), thisidorganisme=id_organisme)
    StatsOrga=list()
    for r in req:
        temp{
            'nb_taxons':r.nb_taxons,
            'nb_obs':r.nb_obs,
            'nom_organisme':r.nom_organisme,
            'url_organisme':r.url_organisme,
            'url_logo':r.url_logo
            'adresse_organisme':r.adresse_organisme,
            'cp_organisme':r.cp_organisme,
            'ville_organisme':r.ville_organisme,
            'tel_organisme':r.tel_organisme,
            'email_organisme':r.email_organisme
        }
        ListOrganisme.append(temp)
    return ListOrganisme


def getListOrganisme(connection,cd_ref):
    # Fiche espèce : Liste des organismes pour un taxon
    sql = """SELECT nb_observations, nom_organisme, url_organisme, url_logo
    FROM atlas.vm_organismes o 
    WHERE taxons.cd_ref = :thiscdref"""
    req = connection.execute(text(sql), thiscdref=cd_ref)
    ListOrganisme=list()
    for r in req:
        temp{
            'nb_observation':r.nb_observation,
            'nom_organisme':r.nom_organisme,
            'url_organisme':r.url_organisme,
            'url_logo':r.url_logo
        }
        ListOrganisme.append(temp)
    return ListOrganisme