-- Vérifier les évolutions de BDD sur https://github.com/PnX-SI/GeoNature-atlas/pull/629/files#diff-1b1113bdb3d6f07008e26543f9033ea896c3f2d6d133e1233abe19d4b8f07601

DROP TABLE atlas.t_mailles_territoire CASCADE;
DROP MATERIALIZED VIEW atlas.vm_medias CASCADE;


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
   FROM taxonomie.t_medias;

CREATE UNIQUE INDEX ON atlas.vm_medias(id_media);

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


 CREATE MATERIALIZED VIEW atlas.vm_observations_mailles AS
        SELECT
            o.cd_ref,
            date_part('year', o.dateobs) AS annee,
            m.id_maille,
            COUNT(o.id_observation) AS nbr,
            ARRAY_AGG(o.id_observation) AS id_observations
        FROM atlas.vm_observations AS o
            JOIN atlas.vm_mailles_territoire AS m
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



CREATE MATERIALIZED VIEW atlas.vm_taxons_plus_observes AS
SELECT count(*) AS nb_obs,
  obs.cd_ref,
  tax.lb_nom,
  tax.group2_inpn,
  tax.nom_vern,
  m.id_media,
  m.url,
  m.chemin,
  m.id_type
 FROM atlas.vm_observations obs
JOIN atlas.vm_taxons tax ON tax.cd_ref = obs.cd_ref
LEFT JOIN atlas.vm_medias m ON m.cd_ref = obs.cd_ref AND m.id_type = 1
WHERE date_part('day'::text, obs.dateobs) >= date_part('day'::text, 'now'::text::date - 15) AND date_part('month'::text, obs.dateobs) = date_part('month'::text, 'now'::text::date - 15) OR date_part('day'::text, obs.dateobs) <= date_part('day'::text, 'now'::text::date + 15) AND date_part('month'::text, obs.dateobs) = date_part('day'::text, 'now'::text::date + 15)
GROUP BY obs.cd_ref, tax.lb_nom, tax.nom_vern, m.url, m.chemin, tax.group2_inpn, m.id_type, m.id_media
ORDER BY (count(*)) DESC
LIMIT 12;
-- DROP INDEX atlas.vm_taxons_plus_observes_cd_ref_idx;

CREATE UNIQUE INDEX vm_taxons_plus_observes_cd_ref_idx
  ON atlas.vm_taxons_plus_observes
  USING btree
  (cd_ref);


GRANT SELECT ON TABLE atlas.vm_taxons_plus_observes TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_observations_mailles TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_mailles_territoire TO geonatatlas;
GRANT SELECT ON TABLE atlas.vm_medias TO geonatatlas;


-- Faut faire des GRAND SELECT sur les 3 VM créées ?
-- Voir https://github.com/PnX-SI/GeoNature-atlas/pull/629/files#diff-e53167aeace735e10049b339b3f045aa65f7f994bfd6f0d6143861d4110ec186R39
-- Mais on ne connait pas le nom de l'utilisateur qui n'est pas forcément geonatatlas ?
-- Dans les précédentes UPDATE, on le mettait quand même en dur car quasiment tout le monde utilise ce nom... https://github.com/PnX-SI/GeoNature-atlas/blob/develop/data/update/update_1.5.2to1.6.0.sql#L85
-- Donc on peut faire ça je pense

