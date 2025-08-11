# -*- coding:utf-8 -*-

from sqlalchemy.sql import text


# get nombre taxons protégés et nombre taxons patrimoniaux par communes
def get_nb_taxon_pro_pat_area(connection, id_area):
    sql = """
SELECT
    COUNT(t.patrimonial) AS nb_taxon_patrimonial, COUNT(t.protection_stricte) AS nb_taxon_protege
FROM atlas.vm_observations o
         JOIN atlas.vm_taxons t ON t.cd_ref=o.cd_ref
         JOIN atlas.vm_l_areas area ON st_intersects(o.the_geom_point, area.the_geom)
WHERE area.id_area = :thisIdArea
    """
    req = connection.execute(text(sql), thisIdArea=id_area)
    taxonProPatri = dict()
    for r in req:
        taxonProPatri = {"nbTaxonPro": r.nb_taxon_protege, "nbTaxonPatri": r.nb_taxon_patrimonial}
    return taxonProPatri
