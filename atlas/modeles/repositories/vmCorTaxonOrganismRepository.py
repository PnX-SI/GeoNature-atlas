# -*- coding:utf-8 -*-

from sqlalchemy.sql import text


def getTaxonOrganism(connection, cd_ref):
    sql = """
        select nom_organism, nb_observations
        from atlas.vm_cor_taxon_organism 
        where cd_ref = :cdref
    """
    result = connection.execute(text(sql), {"cdref":cd_ref})
    return {el.nom_organism: el.nb_observations for el in result}
