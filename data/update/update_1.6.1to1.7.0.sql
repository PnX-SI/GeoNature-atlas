-- Vérifier les évolutions de BDD sur https://github.com/PnX-SI/GeoNature-atlas/pull/629/files#diff-1b1113bdb3d6f07008e26543f9033ea896c3f2d6d133e1233abe19d4b8f07601

DROP TABLE atlas.t_mailles_territoire;

CREATE MATERIALIZED VIEW atlas.vm_mailles_territoire AS
    SELECT
        st_transform(a.geom, 4326) AS the_geom,
        st_asgeojson(st_transform(a.geom, 4326)) AS geojson_maille,
        a.id_area AS id_maille
    FROM ref_geo.l_areas AS a
        JOIN ref_geo.bib_areas_types AS t
            ON t.id_type = a.id_type
        JOIN atlas.t_layer_territoire AS l
            ON ST_intersects(a.geom, st_transform(l.the_geom, find_srid('ref_geo', 'l_areas', 'geom')))
    WHERE a.enable = true
        AND t.type_code = :type_maille ;

CREATE UNIQUE INDEX ON atlas.vm_mailles_territoire
    USING btree (id_maille);
CREATE INDEX ON atlas.vm_mailles_territoire
    USING spgist (the_geom);

-- Création index sur les mailles du territoire
CREATE INDEX ON atlas.t_mailles_territoire
    USING spgist (the_geom);

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_observations_mailles;

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

DROP MATERIALIZED VIEW IF EXISTS atlas.vm_medias;
CREATE MATERIALIZED VIEW atlas.vm_medias AS
   SELECT t_medias.id_media,
      t_medias.cd_ref,
      t_medias.titre,
      t_medias.url,
      t_medias.chemin,
      t_medias.auteur,
      t_medias.desc_media,
      t_medias.date_media,
      t_medias.id_type,
      t_medias.licence,
      t_medias.source
   FROM taxonomie.t_medias
WHERE NOT t_medias.supprime = true;
   FROM taxonomie.t_medias;

-- Faut faire des GRAND SELECT sur les 3 VM créées ?
-- Voir https://github.com/PnX-SI/GeoNature-atlas/pull/629/files#diff-e53167aeace735e10049b339b3f045aa65f7f994bfd6f0d6143861d4110ec186R39
-- Mais on ne connait pas le nom de l'utilisateur qui n'est pas forcément geonatatlas ?
-- Dans les précédentes UPDATE, on le mettait quand même en dur car quasiment tout le monde utilise ce nom... https://github.com/PnX-SI/GeoNature-atlas/blob/develop/data/update/update_1.5.2to1.6.0.sql#L85
-- Donc on peut faire ça je pense
