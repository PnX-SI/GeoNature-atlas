CREATE MATERIALIZED VIEW atlas.vm_observations_mailles
AS SELECT tx.cd_ref,
s.id_synthese AS id_observation,
s.dateobs,
m.id_maille,
m.id_type,
m.the_geom,
m.geojson_maille,
date_part('year', dateobs) as annee
FROM synthese.syntheseff s
     LEFT JOIN atlas.vm_taxref tx ON tx.cd_nom = s.cd_nom
     JOIN atlas.t_mailles_territoire m ON
        CASE
            -- since s.the_geom_point can be either a point or a geometry
            -- corresponding to m.the_geom, we need to use a case
            -- Intersects the geom point with a 1km mesh cell if no sensibility 
             WHEN s.diffusion_level = 5 THEN st_intersects(s.the_geom_point, st_transform(m.the_geom, 3857)) AND m.id_type = (( SELECT la.id_type
               FROM ref_geo.l_areas la
              WHERE la.area_code::text ~~ '10km%'::text --mettre ça en paramètre ? TODO 
             LIMIT 1))
            -- We have no id from the syntheseff view so need to st_equals...
            ELSE st_equals(s.the_geom_point, st_transform(m.the_geom, 3857))
        END
WITH DATA;

create unique index on atlas.vm_observations_mailles (id_observation);
create unique index on atlas.vm_observations_mailles (id_maille);
create unique index on atlas.vm_observations_mailles (cd_ref);
create unique index on atlas.vm_observations_mailles (geojson_maille);
-- create index on atlas.vm_observations_mailles (geojson_maille);
-- This line produces this error :
-- SQL Error [54000]: ERROR: index row requires 8400 bytes, maximum size is 8191
-- ERROR: index row requires 8400 bytes, maximum size is 8191
-- ERROR: index row requires 8400 bytes, maximum size is 8191