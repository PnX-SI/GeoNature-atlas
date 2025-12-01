-- +-----------------------------------------------------------------------------------------------+
-- bdc_statut_cor_text_area
CREATE MATERIALIZED VIEW IF NOT EXISTS atlas.bdc_statut_cor_text_area AS
    SELECT *
    FROM taxonomie.bdc_statut_cor_text_area
WITH DATA;

CREATE UNIQUE INDEX ON atlas.bdc_statut_cor_text_area
    USING btree (id_text, id_area);

-- +-----------------------------------------------------------------------------------------------+
-- vm_bdc_statut
CREATE MATERIALIZED VIEW IF NOT EXISTS atlas.vm_bdc_statut AS
SELECT
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
   FROM taxonomie.bdc_statut_taxons AS s
     JOIN taxonomie.bdc_statut_cor_text_values AS c
        ON s.id_value_text = c.id_value_text
     JOIN taxonomie.bdc_statut_text AS t
        ON t.id_text = c.id_text
     JOIN taxonomie.bdc_statut_values AS v
        ON v.id_value = c.id_value
     JOIN taxonomie.bdc_statut_type AS ty
        ON ty.cd_type_statut::text = t.cd_type_statut::text
  WHERE t.enable = true
WITH DATA ;

CREATE UNIQUE INDEX ON atlas.vm_bdc_statut
    USING btree (id);

CREATE INDEX ON atlas.vm_bdc_statut
     USING btree (id_text);

CREATE INDEX ON atlas.vm_bdc_statut
     USING btree (cd_type_statut);


-- +-----------------------------------------------------------------------------------------------+
-- order_liste_rouge_niveau_ter
CREATE TABLE atlas.order_liste_rouge_niveau_ter (
    id_order int primary key,
    level_statut character varying(10)
);

INSERT INTO atlas.order_liste_rouge_niveau_ter
VALUES (4, 'LRR'), (3, 'LRN'), (2, 'LRE'), (1, 'LRM');


-- +-----------------------------------------------------------------------------------------------+
-- vm_cor_taxon_statut_area
-- Flattens the most local threat level (and the highest if there are several
-- for the same level - e.g. Regional, National Red List) and a 'protected' boolean,
-- for each couple cd_ref and id_area.
-- It allows to know if a taxon is threatened or protected in a given area.
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
        FROM atlas.vm_bdc_statut AS s
            JOIN atlas.bdc_statut_cor_text_area AS c
                ON s.id_text = c.id_text
            JOIN atlas.order_liste_rouge_niveau_ter AS o
                ON s.cd_type_statut = o.level_statut
        WHERE s.code_statut IN ('VU','EN','CR','CR*')
    ),
    menace_finale AS (
        SELECT
            cd_ref,
            id_area,
            statut_menace,
            niveau_application_menace
        FROM menace_priorisee
        WHERE rang = 1
    ),
    protection AS (
        SELECT DISTINCT ON (cd_ref, id_area)
            s.cd_ref,
            c.id_area,
            TRUE AS protege
        FROM atlas.vm_bdc_statut AS s
            JOIN atlas.bdc_statut_cor_text_area AS c
                ON s.id_text = c.id_text
        WHERE s.regroupement_type = 'Protection'
    )
    SELECT
        COALESCE(m.cd_ref, p.cd_ref) AS cd_ref,
        COALESCE(m.id_area, p.id_area) AS id_area,
        m.statut_menace,
        m.niveau_application_menace,
        COALESCE(p.protege, FALSE) AS protege
    FROM menace_finale AS m
        FULL OUTER JOIN protection AS p
            ON (m.cd_ref = p.cd_ref AND m.id_area = p.id_area)
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_statut_area
    USING btree (cd_ref, id_area);


-- +-----------------------------------------------------------------------------------------------+
-- status_areas_buffered
CREATE MATERIALIZED VIEW atlas.status_areas_buffered AS
    SELECT
        a.id_area,
        a.id_type,
        a.the_geom AS geom,
        a.geom_local AS geom_local,
        st_envelope(a.geom_local) AS bbox_local_geom,
        st_buffer(a.geom_local, 100) AS buffered_local_geom
    FROM atlas.vm_l_areas AS a
    WHERE a.id_area IN (SELECT DISTINCT id_area FROM atlas.vm_cor_taxon_statut_area)
WITH DATA;

CREATE UNIQUE INDEX ON atlas.status_areas_buffered
    USING btree(id_area);


-- +-----------------------------------------------------------------------------------------------+
-- vm_cor_taxon_statut_area_spread
CREATE MATERIALIZED VIEW atlas.vm_cor_taxon_statut_area_spread AS
    WITH area_types AS (
        SELECT id_type
        FROM atlas.vm_bib_areas_types
        WHERE type_code = ANY(SELECT * FROM string_to_table(:'type_code', ','))
    ),
    parent_child_areas AS (
        SELECT
            parent.id_area AS id_area_parent,
            child.id_area AS id_area_child
        FROM atlas.status_areas_buffered AS parent
            JOIN atlas.vm_l_areas AS child
                ON (
                    parent.bbox_local_geom && child.geom_local AND
                    st_covers(parent.buffered_local_geom, child.geom_local)
                )
        WHERE child.id_type IN (SELECT * FROM area_types)
            AND parent.id_type != child.id_type
    )
    (
        SELECT
            cor.cd_ref,
            pca.id_area_child AS id_area,
            cor.statut_menace,
            cor.niveau_application_menace,
            cor.protege
        FROM atlas.vm_cor_taxon_statut_area AS cor
            JOIN parent_child_areas AS pca
                ON cor.id_area = pca.id_area_parent
    )
    UNION
    (
        SELECT *
        FROM atlas.vm_cor_taxon_statut_area
    )
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_cor_taxon_statut_area_spread
    USING btree (cd_ref, id_area);
