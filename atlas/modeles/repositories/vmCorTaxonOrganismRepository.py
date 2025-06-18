# -*- coding:utf-8 -*-

from atlas.modeles.entities.vmOrganisms import VmOrganisms
from atlas.env import db


def getTaxonOrganism(cd_ref):
    result = db.session.query(
        VmOrganisms.nom_organism, VmOrganisms.nb_observations
    ).filter(VmOrganisms.cd_ref == cd_ref)

    return {el.nom_organism: el.nb_observations for el in result}
