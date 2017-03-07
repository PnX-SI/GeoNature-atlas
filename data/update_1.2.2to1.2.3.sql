--Release 1.2.3
--Cette modification ne doit être faite qu'après le passage à GeoNature 1.8.x ou supérieur
ALTER FOREIGN TABLE synthese.syntheseff ADD COLUMN diffusable boolean;
-- Vous devez maintenant mettre à jour la vue atlas.vm_observations
-- Voir le script data/update_vm_observations.sql