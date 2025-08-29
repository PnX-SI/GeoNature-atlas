-- Copie du contenu de taxref (à partir du schéma taxonomie de TaxHub)

-- DROP MATERIALIZED VIEW IF EXISTS taxonomie.vm_taxref ;

CREATE MATERIALIZED VIEW atlas.vm_taxref AS
    SELECT * FROM taxonomie.taxref;

CREATE UNIQUE INDEX ON atlas.vm_taxref
    USING btree (cd_nom);

CREATE INDEX ON atlas.vm_taxref
    USING btree (cd_ref);

CREATE INDEX ON atlas.vm_taxref
    USING btree (cd_taxsup);

CREATE INDEX ON atlas.vm_taxref
    USING btree (lb_nom);

CREATE INDEX ON atlas.vm_taxref
    USING btree (nom_complet);

CREATE INDEX ON atlas.vm_taxref
    USING btree (nom_valide);

-- Rangs de taxref ordonnés

CREATE TABLE atlas.bib_taxref_rangs (
    id_rang character(4) NOT NULL,
    nom_rang character varying(20) NOT NULL,
    tri_rang integer
) ;

INSERT INTO atlas.bib_taxref_rangs (id_rang, nom_rang, tri_rang) VALUES
    ('Dumm', 'Domaine', 1),
    ('SPRG', 'Super-Règne', 2),
    ('KD  ', 'Règne', 3),
    ('SSRG', 'Sous-Règne', 4),
    ('IFRG', 'Infra-Règne', 5),
    ('PH  ', 'Embranchement', 6),
    ('SBPH', 'Sous-Phylum', 7),
    ('IFPH', 'Infra-Phylum', 8),
    ('DV  ', 'Division', 9),
    ('SBDV', 'Sous-division', 10),
    ('SPCL', 'Super-Classe', 11),
    ('CLAD', 'Cladus', 12),
    ('CL  ', 'Classe', 13),
    ('SBCL', 'Sous-Classe', 14),
    ('IFCL', 'Infra-classe', 15),
    ('LEG ', 'Legio', 16),
    ('SPOR', 'Super-Ordre', 17),
    ('COH ', 'Cohorte', 18),
    ('OR  ', 'Ordre', 19),
    ('SBOR', 'Sous-Ordre', 20),
    ('IFOR', 'Infra-Ordre', 21),
    ('SPFM', 'Super-Famille', 22),
    ('FM  ', 'Famille', 23),
    ('SBFM', 'Sous-Famille', 24),
    ('TR  ', 'Tribu', 26),
    ('SSTR', 'Sous-Tribu', 27),
    ('GN  ', 'Genre', 28),
    ('SSGN', 'Sous-Genre', 29),
    ('SC  ', 'Section', 30),
    ('SBSC', 'Sous-Section', 31),
    ('SER', 'Série', 32),
    ('SSER', 'Sous-Série', 33),
    ('AGES', 'Agrégat', 34),
    ('ES  ', 'Espèce', 35),
    ('SMES', 'Semi-espèce', 36),
    ('MES ', 'Micro-Espèce',37),
    ('SSES', 'Sous-espèce', 38),
    ('NAT ', 'Natio', 39),
    ('VAR ', 'Variété', 40),
    ('SVAR ', 'Sous-Variété', 41),
    ('FO  ', 'Forme', 42),
    ('SSFO', 'Sous-Forme', 43),
    ('FOES', 'Forma species', 44),
    ('LIN ', 'Linea', 45),
    ('CLO ', 'Clône', 46),
    ('RACE', 'Race', 47),
    ('CAR ', 'Cultivar', 48),
    ('MO  ', 'Morpha', 49),
    ('AB  ', 'Abberatio',50),
    --n'existe plus dans taxref V9
    ('CVAR', 'Convariété', NULL),
    ('HYB ', 'Hybride', NULL),
    --non documenté dans la doc taxref
    ('SPTR', 'Supra-Tribu', 25),
    ('SCO ', '?', NULL),
    ('PVOR', '?', NULL),
    ('SSCO', '?', NULL ) ;
