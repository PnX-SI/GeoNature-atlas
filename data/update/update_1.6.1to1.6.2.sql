DROP MATERIALIZED VIEW IF EXISTS atlas.vm_observations_mailles;

drop table atlas.t_mailles_territoire;

-- Création index sur les mailles du territoire
CREATE INDEX ON atlas.t_mailles_territoire
    USING spgist (the_geom);


CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS
    SELECT
        o.cd_ref,
        date_part('year', o.dateobs) AS annee,
        m.id_maille,
        COUNT(o.id_observation) AS nbr,
        ARRAY_AGG(o.id_observation) AS id_observations
    FROM atlas.vm_observations AS o
        JOIN atlas.t_mailles_territoire AS m
            ON (o.the_geom_point && m.the_geom)
    GROUP BY o.cd_ref, date_part('year', o.dateobs), m.id_maille
    ORDER BY o.cd_ref, annee
WITH DATA;

CREATE UNIQUE INDEX ON atlas.vm_observations_mailles
    USING btree (cd_ref, annee, id_maille);

CREATE INDEX ON atlas.vm_observations_mailles
    USING btree (annee);

CREATE INDEX ON atlas.vm_observations_mailles
    USING gin (id_observations);

CREATE INDEX ON atlas.vm_observations_mailles
    USING btree (id_maille, cd_ref);
 

CREATE INDEX index_gist_t_layer_territoire ON atlas.t_layer_territoire USING gist(the_geom);
CREATE INDEX index_gist_t_layers_communes ON atlas.l_communes USING gist (the_geom);
