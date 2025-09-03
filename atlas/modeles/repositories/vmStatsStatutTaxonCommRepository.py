# -*- coding:utf-8 -*-

from sqlalchemy.sql import select, func
from atlas.modeles.entities.vmObservations import VmObservations
from atlas.modeles.entities.vmTaxons import VmTaxons
from atlas.modeles.entities.vmAreas import VmAreas
from atlas.env import db


# get nombre taxons protégés et nombre taxons patrimoniaux par communes
def get_nb_taxon_pro_pat_area(id_area):
    req = (
        select(
            func.count(VmTaxons.patrimonial).label("nb_taxon_patrimonial"),
            func.count(VmTaxons.protection_stricte).label("nb_taxon_protege"),
        )
        .select_from(VmObservations)
        .join(VmTaxons, VmTaxons.cd_ref == VmObservations.cd_ref)
        .join(VmAreas, func.ST_intersects(VmObservations.the_geom_point, VmAreas.the_geom))
        .filter(VmAreas.id_area == id_area)
    )
    results = db.session.execute(req).all()
    taxonProPatri = dict()
    for r in results:
        taxonProPatri = {"nbTaxonPro": r.nb_taxon_protege, "nbTaxonPatri": r.nb_taxon_patrimonial}
    return taxonProPatri
