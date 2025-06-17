# -*- coding:utf-8 -*-

from sqlalchemy.sql import text, func, select
from atlas.modeles.entities.tBibAltitudes import TBibAltitudes
from atlas.modeles.entities.vmAltitudes import VmAltitudes


def getAltitudesChilds(session, cd_ref):
    # construction du select  de la requete a partir des cles de la table

    # 1. Récupération des labels d'altitude (ex : _0_100, _100_200...)
    altitude_labels = (
        session.query(TBibAltitudes.label_altitude).order_by(TBibAltitudes.altitude_min).all()
    )
    alt_cols = [label[0] for label in altitude_labels]

    # 2. Récupération des cd_ref enfants (fonction PL/pgSQL)
    childs_ids = session.execute(select(func.atlas.find_all_taxons_childs(cd_ref))).scalars().all()
    all_ids = childs_ids + [cd_ref]  # inclut le parent

    # 3. Construire les colonnes dynamiques SUM(...) en ORM
    sum_columns = [func.sum(getattr(VmAltitudes, col)).label(col) for col in alt_cols]

    # 4. Exécuter la requête d'agrégation
    result = session.query(*sum_columns).filter(VmAltitudes.cd_ref.in_(all_ids)).one()

    # 5. Construire le résultat sous forme de liste de dictionnaires
    alti_list = []
    for k in alt_cols:
        alti_list.append(
            {
                "altitude": k.replace("_", "-")[1:],  # ex: _0_100 -> 0-100
                "value": getattr(result, k),
            }
        )

    return alti_list
