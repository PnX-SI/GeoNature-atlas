# -*- coding:utf-8 -*-

from atlas.modeles.entities.vmTaxons import VmCorTaxonOrganism


def getTaxonOrganism(session, cd_ref):
    result = (
        session.query(
            VmCorTaxonOrganism.nom_organism, 
            VmCorTaxonOrganism.nb_observations
        ).filter(VmCorTaxonOrganism.cd_ref == cd_ref)
    )

    return {el.nom_organism: el.nb_observations for el in result}
