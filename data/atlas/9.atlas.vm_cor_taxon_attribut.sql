-- Attributs TaxHub de chaque taxon
CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_attribut AS
    SELECT cta.cd_ref,
        ba.nom_attribut AS code,
        ba.label_attribut AS title,
        CASE
            WHEN ba.type_attribut = 'text' AND ba.type_widget = 'select'
                THEN REPLACE(cta.valeur_attribut, '&', '|')
            ELSE cta.valeur_attribut
        END AS "value"
    FROM taxonomie.cor_taxon_attribut AS cta
        JOIN taxonomie.bib_attributs AS ba
            ON cta.id_attribut = ba.id_attribut
    WHERE ba.nom_attribut IN (:taxhub_displayed_attr)
        AND cta.valeur_attribut IS NOT NULL
        AND cta.valeur_attribut != '' ;

CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_attribut (cd_ref, code);
