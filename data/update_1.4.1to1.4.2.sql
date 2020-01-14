--index uniques manquants sur 2 vues matérialisées
CREATE UNIQUE INDEX t_layer_territoire_gid_idx
  ON atlas.t_layer_territoire
  USING btree (gid);

CREATE UNIQUE INDEX t_mailles_territoire_id_maille_idx
  ON atlas.t_mailles_territoire
  USING btree (id_maille);