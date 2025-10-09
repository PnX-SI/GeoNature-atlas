CREATE materialized VIEW IF NOT EXISTS atlas.bdc_statut_cor_text_area AS 
SELECT * 
FROM taxonomie.bdc_statut_cor_text_area;



CREATE OR REPLACE VIEW atlas.vm_bdc_statut
AS SELECT 
   ROW_NUMBER() OVER () AS id,
    s.cd_nom,
    s.cd_ref,
    s.rq_statut,
    v.code_statut,
    v.label_statut,
    t.cd_type_statut,
    ty.thematique,
    ty.lb_type_statut,
    ty.regroupement_type,
    t.cd_st_text,
    t.cd_sig,
    t.cd_doc,
    t.niveau_admin,
    t.cd_iso3166_1,
    t.cd_iso3166_2,
    t.full_citation,
    t.doc_url,
    ty.type_value,
    t.lb_adm_tr,
    t.id_text
   FROM taxonomie.bdc_statut_taxons s
     JOIN taxonomie.bdc_statut_cor_text_values c ON s.id_value_text = c.id_value_text
     JOIN taxonomie.bdc_statut_text t ON t.id_text = c.id_text
     JOIN taxonomie.bdc_statut_values v ON v.id_value = c.id_value
     JOIN taxonomie.bdc_statut_type ty ON ty.cd_type_statut::text = t.cd_type_statut::text
  WHERE t.enable = true;

-- CREATE INDEX ON atlas.vm_bdc_statut
--     USING btree (cd_ref);

-- CREATE UNIQUE INDEX ON atlas.vm_bdc_statut
--     USING btree (id);


CREATE TABLE atlas.order_liste_rouge_niveau_ter (
id_order int primary key ,
level_statut character varying(10)
);

INSERT INTO atlas.order_liste_rouge_niveau_ter
VALUES (4, 'LRR'), (3, 'LRN'), (2, 'LRE'), (1, 'LRM');


-- VM qui remet à plat le niveau le plus local de menace (et le max s'il y en a plusieurs pour le meme niveau - LR- LRN ) et un booléen protegé, pour chaque cd_ref / id_area
-- Elle permet de savoir si un taxon et menacé / protégé sur un zonage
CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_statut_area AS
WITH menace_priorisee AS (
    SELECT
        s.cd_ref,
        c.id_area,
        s.code_statut AS statut_menace,
        s.cd_type_statut AS niveau_application_menace,
        o.id_order,
        ROW_NUMBER() OVER (
            PARTITION BY s.cd_ref, c.id_area
            ORDER BY o.id_order DESC,
                     CASE s.code_statut 
                        WHEN 'CR*' THEN 4
                        WHEN 'CR' THEN 3
                        WHEN 'EN' THEN 2
                        WHEN 'VU' THEN 1
                        ELSE 0
                     END DESC
        ) AS rang
    FROM atlas.vm_bdc_statut s
    JOIN atlas.bdc_statut_cor_text_area c 
      ON s.id_text = c.id_text
    JOIN atlas.order_liste_rouge_niveau_ter o
      ON s.cd_type_statut = o.level_statut
    WHERE s.code_statut IN ('VU','EN','CR','CR*')
),
menace_finale AS (
    SELECT cd_ref, id_area, statut_menace, niveau_application_menace
    FROM menace_priorisee
    WHERE rang = 1
),
protection AS (
    SELECT
      DISTINCT ON (cd_ref, id_area)
        s.cd_ref,
        c.id_area,
        TRUE AS protege
    FROM atlas.vm_bdc_statut s
    JOIN atlas.bdc_statut_cor_text_area c 
      ON s.id_text = c.id_text
    WHERE s.regroupement_type  = 'Protection'
)
SELECT
    COALESCE(m.cd_ref, p.cd_ref) AS cd_ref,
    COALESCE(m.id_area, p.id_area) AS id_area,
    m.statut_menace,
    m.niveau_application_menace,
    COALESCE(p.protege, FALSE) AS protege
FROM menace_finale m
FULL OUTER JOIN protection p
  ON m.cd_ref = p.cd_ref
 AND m.id_area = p.id_area;
   










