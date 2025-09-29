CREATE MATERIALIZED VIEW IF NOT EXISTS atlas.vm_bdc_statut AS
SELECT ROW_NUMBER() OVER () AS id,
       t.id_text,
       s.cd_ref,
       s.rq_statut,
       v.code_statut,
       v.label_statut,
       t.cd_type_statut,
       ty.lb_type_statut,
	  ty.regroupement_type,
       t.cd_sig,
       t.lb_adm_tr,
	  t.full_citation,
	  t.doc_url
FROM taxonomie.bdc_statut_taxons AS s
         JOIN taxonomie.bdc_statut_cor_text_values AS c
              ON s.id_value_text = c.id_value_text
         JOIN taxonomie.bdc_statut_text AS t
              ON t.id_text = c.id_text
         JOIN taxonomie.bdc_statut_values AS v
              ON v.id_value = c.id_value
         JOIN taxonomie.bdc_statut_type AS ty
              ON ty.cd_type_statut = t.cd_type_statut
WHERE t.ENABLE = true;

CREATE materialized VIEW IF NOT EXISTS atlas.bsc_statut_cor_text_area AS 
SELECT * 
FROM taxonomie.bdc_statut_cor_text_area;

CREATE INDEX ON atlas.vm_bdc_statut
    USING btree (cd_ref);

CREATE UNIQUE INDEX ON atlas.vm_bdc_statut
    USING btree (id);


CREATE TABLE atlas.order_liste_rouge (
id_order int primary key,
code_statut character varying(10)
);


INSERT INTO atlas.order_liste_rouge
VALUES (1, 'VU'), (2, 'EN'), (3, 'CR');

-- Vue renvoyant le niveau maximal de menace (liste rouge) pour un taxon et un territoire (département)
CREATE MATERIALIZED VIEW atlas.cor_taxon_area_menace  AS
WITH cor_taxon_area_menace_dep AS (
    SELECT DISTINCT ON (s.cd_ref, cor_area.id_area)
        s.cd_ref,
        v.code_statut,
        ord.id_order,
        cor_area.id_area
    FROM taxonomie.bdc_statut_taxons s
    JOIN taxonomie.bdc_statut_cor_text_values c ON s.id_value_text = c.id_value_text
    JOIN taxonomie.bdc_statut_text t ON t.id_text = c.id_text
    JOIN taxonomie.bdc_statut_values v ON v.id_value = c.id_value
    JOIN taxonomie.bdc_statut_cor_text_area cor_area ON cor_area.id_text = t.id_text 
    JOIN atlas.order_liste_rouge ord ON ord.code_statut = v.code_statut
    WHERE t.enable = true AND v.code_statut IN ('VU', 'CR', 'EN')
    ORDER BY s.cd_ref, cor_area.id_area, ord.id_order DESC
)
SELECT DISTINCT
    child.id_area   AS id_area,
    tam.cd_ref,
    tam.code_statut
FROM cor_taxon_area_menace_dep tam
    JOIN atlas.vm_l_areas parent
       ON parent.id_area = tam.id_area
    JOIN atlas.vm_l_areas child
       ON ST_Intersects(child.the_geom, parent.the_geom)
    JOIN atlas.vm_bib_areas_types bat
       ON bat.id_type = child.id_type
WHERE bat.type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
GROUP BY child.id_area, tam.cd_ref, tam.code_statut
UNION
-- on garde aussi les départements eux-mêmes
SELECT
    tam.id_area,
    tam.cd_ref,
    tam.code_statut
FROM cor_taxon_area_menace_dep tam;


CREATE UNIQUE INDEX ON atlas.cor_taxon_area_menace 
    USING btree (cd_ref, code_statut, id_area);
CREATE INDEX ON atlas.cor_taxon_area_menace 
    USING btree (cd_ref);
CREATE INDEX ON atlas.cor_taxon_area_menace 
    USING btree (id_area);
