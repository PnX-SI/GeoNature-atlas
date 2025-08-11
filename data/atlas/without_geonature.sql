CREATE TABLE synthese.syntheseff(
    id_synthese serial PRIMARY KEY,
    id_organism integer DEFAULT 2, 
    id_dataset integer,
    cd_nom integer,
    id_area integer,
    dateobs date NOT NULL DEFAULT now(),
    observateurs character varying(255),
    altitude_retenue integer,
    supprime boolean DEFAULT false,
    the_geom_point geometry('POINT',4326),
    effectif_total integer,
    cd_sensitivity integer
);

INSERT INTO synthese.syntheseff
(cd_nom, id_area, observateurs, altitude_retenue, the_geom_point, effectif_total, cd_sensitivity)
VALUES (67111, 1, 'Mon observateur', 1254, ST_SetSRID( ST_Point( 6, 42.315), 4326), 3, 5);
INSERT INTO synthese.syntheseff
(cd_nom, id_area, observateurs, altitude_retenue, the_geom_point, effectif_total, cd_sensitivity)
VALUES (67111, 2, 'Mon observateur 3', 940, ST_SetSRID( ST_Point( 6.1, 42.315), 4326), 2, 5);


CREATE TABLE gn_meta.cor_dataset_actor (
    id_cda int4 NULL, -- id cadre d'acquisition (inutilisé aujourd'huit)
    id_dataset int4 NOT NULL,
    id_role int4  NULL,
    id_organism int4 NULL
);