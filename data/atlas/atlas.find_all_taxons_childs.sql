--Fonction qui permet de lister tous les taxons enfants d'un taxon

CREATE OR REPLACE FUNCTION atlas.find_all_taxons_childs(id integer)
  RETURNS SETOF integer AS
$BODY$
 --Param : cd_nom ou cd_ref d'un taxon quelque soit son rang
 --Retourne le cd_nom de tous les taxons enfants sous forme d'un jeu de données utilisable comme une table
 --Usage SELECT atlas.find_all_taxons_childs(197047);
 --ou SELECT * FROM atlas.vm_taxons WHERE cd_ref IN(SELECT * FROM atlas.find_all_taxons_childs(197047))
  DECLARE
    inf RECORD;
    c integer;
  BEGIN
    SELECT INTO c count(*) FROM atlas.vm_taxref WHERE cd_taxsup = id;
    IF c > 0 THEN
        FOR inf IN
      WITH RECURSIVE descendants AS (
        SELECT tx1.cd_nom FROM atlas.vm_taxref tx1 WHERE tx1.cd_taxsup = id
      UNION ALL
      SELECT tx2.cd_nom FROM descendants d JOIN atlas.vm_taxref tx2 ON tx2.cd_taxsup = d.cd_nom
      )
      SELECT cd_nom FROM descendants
  LOOP
      RETURN NEXT inf.cd_nom;
  END LOOP;
    END IF;
  END;
$BODY$
  LANGUAGE plpgsql IMMUTABLE
  COST 100
  ROWS 1000;
