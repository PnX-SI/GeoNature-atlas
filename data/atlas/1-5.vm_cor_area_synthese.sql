

CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese AS
    SELECT
        sa.id_synthese,
        sa.id_area,
        bat.id_type,
        bat.type_code
    FROM synthese.synthese AS s
        JOIN synthese.cor_area_synthese AS csa
            ON csa.id_synthese = s.id_synthese
        JOIN ref_geo.l_areas AS a
            ON csa.id_area = a.id_area
        JOIN ref_geo.bib_areas_types AS bat
            ON a.id_type = bat.id_type
    WHERE bat.type_code IN (
            SELECT string_to_table.string_to_table
            FROM string_to_table(:'type_code', ',')
        )
        OR a.id_type IN (SELECT id_area_type FROM synthese.cor_sensitivity_area_type)
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_synthese, id_area);

CREATE INDEX ON atlas.vm_cor_area_synthese
    USING btree (id_area);
