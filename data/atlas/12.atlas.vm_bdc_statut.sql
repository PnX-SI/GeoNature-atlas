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
CREATE MATERIALIZED view atlas.cor_taxon_area_menace as 
SELECT DISTINCT
    s.cd_ref,
    max(ord.code_statut) as code_statut, -- le max necessitera ne faire une autre table pour ordonner les statuts
    cor_area.id_area
   FROM taxonomie.bdc_statut_taxons s
     JOIN taxonomie.bdc_statut_cor_text_values c ON s.id_value_text = c.id_value_text
     JOIN taxonomie.bdc_statut_text t ON t.id_text = c.id_text
     JOIN taxonomie.bdc_statut_values v ON v.id_value = c.id_value
     JOIN taxonomie.bdc_statut_cor_text_area cor_area on cor_area.id_text = t.id_text 
     JOIN atlas.order_liste_rouge ord ON ord.code_statut = v.code_statut
  WHERE t.enable = true AND v.code_statut  IN ('VU', 'CR', 'EN')
  GROUP BY  s.cd_ref, cor_area.id_area;


CREATE UNIQUE INDEX on atlas.cor_taxon_area_menace using btree(cd_ref, code_statut, id_area);
CREATE INDEX on atlas.cor_taxon_area_menace using btree(cd_ref);
CREATE INDEX on atlas.cor_taxon_area_menace using btree(id_area);
