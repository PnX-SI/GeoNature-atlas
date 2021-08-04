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
    WHERE o.id_organisme = :thisidorganisme
    GROUP BY nom_organisme, url_organisme, url_logo, adresse_organisme, cp_organisme, ville_organisme,
    tel_organisme, email_organisme"""
    req = connection.execute(text(sql), thisidorganisme=id_organisme)
    StatsOrga = dict()
    for r in req:
        StatsOrga={
            'nb_taxons':r.nb_taxons,
            'nb_obs':r.nb_obs,
            'nom_organisme':r.nom_organisme,
            'url_organisme':r.url_organisme,
            'url_logo':r.url_logo,
            'adresse_organisme':r.adresse_organisme,
            'cp_organisme':r.cp_organisme,
            'ville_organisme':r.ville_organisme,
            'tel_organisme':r.tel_organisme,
            'email_organisme':r.email_organisme
        }

    return StatsOrga


def topObsOrganism(connection, id_organisme):
    #Stats avancées organisme
    sql = """SELECT cd_ref, nb_observations as nb_obs 
    FROM atlas.vm_organismes o
    WHERE o.id_organisme = :thisidorganisme
    ORDER BY nb_observations DESC
    LIMIT 3
    """
    req = connection.execute(text(sql), thisidorganisme=id_organisme)
    topSpecie = list()
    for r in req:
        temp={
            'cd_ref':r.cd_ref,
            'nb_obs':r.nb_obs,
        }
        topSpecie.append(temp)
    return topSpecie



def getListOrganisme(connection,cd_ref):
    # Fiche espèce : Liste des organismes pour un taxon
    sql = """SELECT nb_observations, id_organisme, nom_organisme, url_organisme, url_logo
    FROM atlas.vm_organismes o 
    WHERE cd_ref = :thiscdref
    ORDER BY nb_observations DESC"""
    req = connection.execute(text(sql), thiscdref=cd_ref)
    ListOrganisme=list()
    for r in req:
        temp={
            'nb_observation':r.nb_observations,
            'id_organisme':r.id_organisme,
            'nom_organisme':r.nom_organisme,
            'url_organisme':r.url_organisme,
            'url_logo':r.url_logo
        }
        ListOrganisme.append(temp)
    return ListOrganisme 

def getTaxonRepartitionOrganisme(connection, id_organisme):
    #Fiche organisme : réparition du type d'observations
    sql="""SELECT  SUM(o.nb_observations) as nb_obs_group, g.group2_inpn
    FROM atlas.vm_organismes o
    JOIN atlas.vm_taxref g on g.cd_nom=o.cd_ref
    WHERE o.id_organisme = :thisidorganisme
   	GROUP BY g.group2_inpn, o.id_organisme
    """;
    req = connection.execute(text(sql), thisidorganisme=id_organisme)
    ListGroup=list()
    for r in req:   
        temp={
            'group2_inpn': r.group2_inpn,
            'nb_obs_group': int(r.nb_obs_group)
        }
        ListGroup.append(temp)
    return ListGroup