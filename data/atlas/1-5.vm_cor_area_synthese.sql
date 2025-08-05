

CREATE MATERIALIZED VIEW atlas.vm_cor_area_synthese AS
    SELECT
        sa.id_synthese,
        sa.id_area,
        a.id_type,
        t.type_code
    FROM synthese.synthese AS s
        JOIN synthese.cor_area_synthese AS sa
            ON sa.id_synthese = s.id_synthese
        JOIN ref_geo.l_areas AS a
            ON sa.id_area = a.id_area
        JOIN ref_geo.bib_areas_types AS t
            ON a.id_type = t.id_type
    WHERE t.type_code::text IN (
            SELECT string_to_table.string_to_table
            FROM string_to_table(:type_code, ',')
        )
        OR a.id_type IN (
            SELECT sat.id_area_type
            FROM synthese.cor_sensitivity_area_type AS sat
        )
WITH DATA;

CREATE UNIQUE INDEX i_vm_cor_area_synthese ON atlas.vm_cor_area_synthese
USING btree (id_synthese, id_area) ;
CREATE INDEX i_id_area ON atlas.vm_cor_area_synthese
USING btree (id_area) ;
