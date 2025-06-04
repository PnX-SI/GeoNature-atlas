# -*- coding:utf-8 -*-

from sqlalchemy.sql import select, func
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmAreas import VmAreas


# get nombre taxons protégés et nombre taxons patrimoniaux par communes
def get_nb_taxon_pro_pat_area(session, id_area):
    req = (
        select(
            func.count(VmTaxons.patrimonial)\
                .label("nb_taxon_patrimonial"),
            func.count(VmTaxons.protection_stricte)\
                .label("nb_taxon_protege")
        )
        .select_from(VmObservations)
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .join(
            VmAreas, 
            func.ST_intersects(VmObservations.the_geom_point, VmAreas.the_geom)
        )
        .filter(VmAreas.id_area == id_area)
    )   
    results = session.execute(req).all() 
    taxonProPatri = dict()
    for r in results:
        taxonProPatri = {"nbTaxonPro": r.nb_taxon_protege, 
                         "nbTaxonPatri": r.nb_taxon_patrimonial}
    return taxonProPatri


# # get stats sur les statuts des taxons par communes
# def getStatsStatutsTaxonsCommunes(connection, insee):
#     sql = """
#         SELECT
#         nb_taxon_que_pro,
#         nb_taxon_que_patri,
#         nb_taxon_pro_et_patri,
#         nb_taxon_sans_statut
#         FROM atlas.vm_stats_statut_taxon_comm a
#         WHERE a.insee = :thisinsee
#     """.encode('UTF-8')
#
#     mesStatutsTaxons = connection.execute(text(sql), thisinsee=insee)
#     for inter in mesStatutsTaxons:
#         return [
#             {'label': "Taxons protégés", 'y': inter.nb_taxon_que_pro},
#             {'label': "Taxons patrimoniaux", 'y': inter.nb_taxon_que_patri},
#             {'label': "Taxons protégés et patrimoniaux", 'y': inter.nb_taxon_pro_et_patri},
#             {'label': "Autres taxons", 'y': inter.nb_taxon_sans_statut},
#         ]
#
