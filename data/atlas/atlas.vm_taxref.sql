--Copie du contenu de taxref (à partir du schéma taxonomie de TaxHub)

--DROP materialized view taxonomie.vm_taxref;
CREATE materialized view atlas.vm_taxref AS
SELECT * FROM taxonomie.taxref;

CREATE UNIQUE INDEX ON atlas.vm_taxref (cd_nom);
CREATE INDEX ON atlas.vm_taxref (cd_ref);
CREATE INDEX ON atlas.vm_taxref (cd_taxsup);
CREATE INDEX ON atlas.vm_taxref (lb_nom);
CREATE INDEX ON atlas.vm_taxref (nom_complet);
CREATE INDEX ON atlas.vm_taxref (nom_valide);

-- Rangs de taxref ordonnés

CREATE TABLE atlas.bib_taxref_rangs (
    id_rang character(4) NOT NULL,
    nom_rang character varying(20) NOT NULL,
    tri_rang integer
);
INSERT INTO atlas.bib_taxref_rangs (id_rang, nom_rang, tri_rang) VALUES ('Dumm', 'Domaine', 1);
INSERT INTO atlas.bib_taxref_rangs (id_rang, nom_rang, tri_rang) VALUES ('SPRG', 'Super-Règne', 2);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('KD  ', 'Règne', 3);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSRG', 'Sous-Règne', 4);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFRG', 'Infra-Règne', 5);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('PH  ', 'Embranchement', 6);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBPH', 'Sous-Phylum', 7);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFPH', 'Infra-Phylum', 8);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('DV  ', 'Division', 9);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBDV', 'Sous-division', 10);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPCL', 'Super-Classe', 11);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CLAD', 'Cladus', 12);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CL  ', 'Classe', 13);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBCL', 'Sous-Classe', 14);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFCL', 'Infra-classe', 15);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('LEG ', 'Legio', 16);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPOR', 'Super-Ordre', 17);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('COH ', 'Cohorte', 18);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('OR  ', 'Ordre', 19);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBOR', 'Sous-Ordre', 20);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('IFOR', 'Infra-Ordre', 21);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPFM', 'Super-Famille', 22);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('FM  ', 'Famille', 23);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBFM', 'Sous-Famille', 24);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('TR  ', 'Tribu', 26);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSTR', 'Sous-Tribu', 27);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('GN  ', 'Genre', 28);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSGN', 'Sous-Genre', 29);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SC  ', 'Section', 30);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SBSC', 'Sous-Section', 31);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SER', 'Série', 32);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSER', 'Sous-Série', 33);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('AGES', 'Agrégat', 34);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('ES  ', 'Espèce', 35);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SMES', 'Semi-espèce', 36);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('MES ', 'Micro-Espèce',37);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSES', 'Sous-espèce', 38);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('NAT ', 'Natio', 39);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('VAR ', 'Variété', 40);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SVAR ', 'Sous-Variété', 41);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('FO  ', 'Forme', 42);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SSFO', 'Sous-Forme', 43);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('FOES', 'Forma species', 44);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('LIN ', 'Linea', 45);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CLO ', 'Clône', 46);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('RACE', 'Race', 47);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('CAR ', 'Cultivar', 48);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('MO  ', 'Morpha', 49);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('AB  ', 'Abberatio',50);
--n'existe plus dans taxref V9
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('CVAR', 'Convariété');
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('HYB ', 'Hybride');
--non documenté dans la doc taxref
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang, tri_rang) VALUES ('SPTR', 'Supra-Tribu', 25);
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('SCO ', '?');
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('PVOR', '?');
INSERT INTO atlas.bib_taxref_rangs  (id_rang, nom_rang) VALUES ('SSCO', '?');
