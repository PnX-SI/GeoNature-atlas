from sqlalchemy.sql import select
from atlas.modeles.entities.vmStatutBdc import VmStatutBdc
from atlas.env import db


def get_taxons_statut_bdc(cd_ref):
    req = select(VmStatutBdc).filter(VmStatutBdc.cd_ref == cd_ref)
    results = db.session.execute(req).mappings().all()
    statuts = list()
    for row in results:
        obj = row["VmStatutBdc"]
        statut = {
            "rq_statut": obj.rq_statut,
            "code_statut": obj.code_statut,
            "label_statut": obj.label_statut,
            "cd_type_statut": obj.cd_type_statut,
            "lb_type_statut": obj.lb_type_statut,
            "lb_adm_tr": obj.lb_adm_tr,
            "cd_sig": obj.cd_sig,
        }
        statuts.append(statut)
    return statuts
