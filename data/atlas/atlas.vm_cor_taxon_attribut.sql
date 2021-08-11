-- Attributs de chaque taxon (description, commentaire, milieu et chorologie)

CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_attribut attribut AS
    SELECT id_attribut,
           valeur_attribut,
           cd_ref
    FROM taxonomie.taxon_cor_attribut
    WHERE id_attribut IN (100, 101, 102, 103);
CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_attribut (cd_ref,id_attribut);
