-- Table: atlas.t_cache
-- DROP TABLE IF EXISTS atlas.t_cache;
CREATE TABLE atlas.t_cache (
  label VARCHAR(250) NOT NULL PRIMARY KEY,
  cache TEXT NOT NULL,
  meta_create_date TIMESTAMP NOT NULL DEFAULT NOW()
);