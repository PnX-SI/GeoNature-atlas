# coding: utf-8
from sqlalchemy import Boolean, Column, ForeignKey, Index, Integer, String, Table, Text, text
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
metadata = Base.metadata

class BibAttribut(Base):
    __tablename__ = 'bib_attributs'
    __table_args__ = {u'schema': 'taxonomie'}

    id_attribut = Column(Integer, primary_key=True, server_default=text("nextval('taxonomie.bib_attributs_id_attribut_seq'::regclass)"))
    nom_attribut = Column(String(255), nullable=False)
    label_attribut = Column(String(50), nullable=False)
    liste_valeur_attribut = Column(Text, nullable=False)
    obligatoire = Column(Boolean, nullable=False)
    desc_attribut = Column(Text)
    type_attribut = Column(String(50))


class BibFiltre(Base):
    __tablename__ = 'bib_filtres'
    __table_args__ = {u'schema': 'taxonomie'}

    id_filtre = Column(Integer, primary_key=True)
    nom_filtre = Column(String(50))
    label1 = Column(String(50))
    label2 = Column(String(50))
    label3 = Column(String(50))
    descr_filtre = Column(String(500))
    img = Column(String(250))
    valeur_filtre = Column(String(1000))
    obligatoire = Column(Boolean, server_default=text("false"))


class BibListe(Base):
    __tablename__ = 'bib_listes'
    __table_args__ = {u'schema': 'taxonomie'}

    id_liste = Column(Integer, primary_key=True, server_default=text("nextval('taxonomie.bib_listes_id_liste_seq'::regclass)"))
    nom_liste = Column(String(255), nullable=False)
    desc_liste = Column(Text)
    picto = Column(String(50))

    bib_taxons = relationship(u'BibTaxon', secondary='cor_taxon_liste')


class BibTaxon(Base):
    __tablename__ = 'bib_taxons'
    __table_args__ = {u'schema': 'taxonomie'}

    id_taxon = Column(Integer, primary_key=True)
    cd_nom = Column(ForeignKey(u'taxonomie.taxref.cd_nom'), unique=True)
    nom_latin = Column(String(100))
    nom_francais = Column(String(255))
    auteur = Column(String(200))
    filtre1 = Column(String(255), server_default=text("'oui'::character varying"))
    filtre2 = Column(String(255), server_default=text("'non'::character varying"))
    filtre3 = Column(String(255), server_default=text("'non'::character varying"))
    filtre4 = Column(String(255))
    filtre5 = Column(String(255), server_default=text("'indéterminée'::character varying"))
    filtre6 = Column(String(255), server_default=text("'inconnu'::character varying"))
    filtre7 = Column(String(255), server_default=text("'inconnue'::character varying"))
    filtre8 = Column(String(255), server_default=text("'non'::character varying"))
    filtre9 = Column(String(255))
    filtre10 = Column(String(255))

    taxref = relationship(u'Taxref', uselist=False)


class BibTaxrefHabitat(Base):
    __tablename__ = 'bib_taxref_habitats'
    __table_args__ = {u'schema': 'taxonomie'}

    id_habitat = Column(Integer, primary_key=True)
    nom_habitat = Column(String(50), nullable=False)


class BibTaxrefRang(Base):
    __tablename__ = 'bib_taxref_rangs'
    __table_args__ = {u'schema': 'taxonomie'}

    id_rang = Column(String(4), primary_key=True)
    nom_rang = Column(String(20), nullable=False)


class BibTaxrefStatut(Base):
    __tablename__ = 'bib_taxref_statuts'
    __table_args__ = {u'schema': 'taxonomie'}

    id_statut = Column(String(1), primary_key=True)
    nom_statut = Column(String(50), nullable=False)


class CdNomDisparu(Base):
    __tablename__ = 'cd_nom_disparus'
    __table_args__ = {u'schema': 'taxonomie'}

    cd_nom = Column(Integer, primary_key=True, nullable=False)
    plus_recente_diffusion = Column(String(5), primary_key=True, nullable=False)
    cd_nom_remplacement = Column(Integer)
    cd_raison_suppression = Column(Integer)
    raison_suppression = Column(Text)


class CorTaxonAttribut(Base):
    __tablename__ = 'cor_taxon_attribut'
    __table_args__ = {u'schema': 'taxonomie'}

    id_taxon = Column(ForeignKey(u'taxonomie.bib_taxons.id_taxon', onupdate=u'CASCADE'), primary_key=True, nullable=False)
    id_attribut = Column(ForeignKey(u'taxonomie.bib_attributs.id_attribut'), primary_key=True, nullable=False)
    valeur_attribut = Column(String(50), nullable=False, index=True)

    bib_attribut = relationship(u'BibAttribut')
    bib_taxon = relationship(u'BibTaxon')


t_cor_taxon_liste = Table(
    'cor_taxon_liste', metadata,
    Column('id_liste', ForeignKey(u'taxonomie.bib_listes.id_liste', ondelete=u'CASCADE', onupdate=u'CASCADE'), primary_key=True, nullable=False),
    Column('id_taxon', ForeignKey(u'taxonomie.bib_taxons.id_taxon', ondelete=u'CASCADE', onupdate=u'CASCADE'), primary_key=True, nullable=False),
    schema='taxonomie'
)


class ImportTaxref(Base):
    __tablename__ = 'import_taxref'
    __table_args__ = {u'schema': 'taxonomie'}

    regne = Column(String(20))
    phylum = Column(String(50))
    classe = Column(String(50))
    ordre = Column(String(50))
    famille = Column(String(50))
    group1_inpn = Column(String(50))
    group2_inpn = Column(String(50))
    cd_nom = Column(Integer, primary_key=True)
    cd_taxsup = Column(Integer)
    cd_sup = Column(Integer)
    cd_ref = Column(Integer)
    rang = Column(String(10))
    lb_nom = Column(String(100))
    lb_auteur = Column(String(250))
    nom_complet = Column(String(255))
    nom_complet_html = Column(String(255))
    nom_valide = Column(String(255))
    nom_vern = Column(String(1000))
    nom_vern_eng = Column(String(500))
    habitat = Column(String(10))
    fr = Column(String(10))
    gf = Column(String(10))
    mar = Column(String(10))
    gua = Column(String(10))
    sm = Column(String(10))
    sb = Column(String(10))
    spm = Column(String(10))
    may = Column(String(10))
    epa = Column(String(10))
    reu = Column(String(10))
    taaf = Column(String(10))
    pf = Column(String(10))
    nc = Column(String(10))
    wf = Column(String(10))
    cli = Column(String(10))
    url = Column(Text)


class Taxref(Base):
    __tablename__ = 'taxref'
    __table_args__ = (
        Index('i_taxref_hierarchy', 'regne', 'phylum', 'classe', 'ordre', 'famille'),
        {u'schema': 'taxonomie'}
    )

    cd_nom = Column(Integer, primary_key=True, index=True)
    id_statut = Column(ForeignKey(u'taxonomie.bib_taxref_statuts.id_statut', onupdate=u'CASCADE'), index=True)
    id_habitat = Column(ForeignKey(u'taxonomie.bib_taxref_habitats.id_habitat', onupdate=u'CASCADE'), index=True)
    id_rang = Column(ForeignKey(u'taxonomie.bib_taxref_rangs.id_rang', onupdate=u'CASCADE'), index=True)
    regne = Column(String(20), index=True)
    phylum = Column(String(50))
    classe = Column(String(50))
    ordre = Column(String(50))
    famille = Column(String(50))
    cd_taxsup = Column(Integer)
    cd_ref = Column(Integer, index=True)
    lb_nom = Column(String(100))
    lb_auteur = Column(String(150))
    nom_complet = Column(String(255))
    nom_valide = Column(String(255))
    nom_vern = Column(String(1000))
    nom_vern_eng = Column(String(255))
    group1_inpn = Column(String(255))
    group2_inpn = Column(String(255))
    nom_complet_html = Column(String(255))
    cd_sup = Column(Integer)

    bib_taxref_habitat = relationship(u'BibTaxrefHabitat')
    bib_taxref_rang = relationship(u'BibTaxrefRang')
    bib_taxref_statut = relationship(u'BibTaxrefStatut')


class TaxrefChange(Base):
    __tablename__ = 'taxref_changes'
    __table_args__ = {u'schema': 'taxonomie'}

    cd_nom = Column(Integer, primary_key=True, nullable=False)
    num_version_init = Column(String(5))
    num_version_final = Column(String(5))
    champ = Column(String(50), primary_key=True, nullable=False)
    valeur_init = Column(String(255))
    valeur_final = Column(String(255))
    type_change = Column(String(25))


class TaxrefProtectionArticle(Base):
    __tablename__ = 'taxref_protection_articles'
    __table_args__ = {u'schema': 'taxonomie'}

    cd_protection = Column(String(20), primary_key=True)
    article = Column(String(100))
    intitule = Column(Text)
    protection = Column(Text)
    arrete = Column(Text)
    fichier = Column(Text)
    fg_afprot = Column(Integer)
    niveau = Column(String(250))
    cd_arrete = Column(Integer)
    url = Column(String(250))
    date_arrete = Column(Integer)
    rang_niveau = Column(Integer)
    lb_article = Column(Text)
    type_protection = Column(String(250))
    concerne_mon_territoire = Column(Boolean)


class TaxrefProtectionEspece(Base):
    __tablename__ = 'taxref_protection_especes'
    __table_args__ = {u'schema': 'taxonomie'}

    cd_nom = Column(ForeignKey(u'taxonomie.taxref.cd_nom', onupdate=u'CASCADE'), primary_key=True, nullable=False, index=True)
    cd_protection = Column(ForeignKey(u'taxonomie.taxref_protection_articles.cd_protection'), primary_key=True, nullable=False)
    nom_cite = Column(String(200))
    syn_cite = Column(String(200))
    nom_francais_cite = Column(String(100))
    precisions = Column(Text)
    cd_nom_cite = Column(String(255), primary_key=True, nullable=False)

    taxref = relationship(u'Taxref')
    taxref_protection_article = relationship(u'TaxrefProtectionArticle')


t_v_nomade_classes = Table(
    'v_nomade_classes', metadata,
    Column('id_classe', Integer),
    Column('nom_classe_fr', String(255)),
    Column('desc_classe', Text),
    schema='taxonomie'
)
