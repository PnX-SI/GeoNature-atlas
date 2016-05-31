# coding: utf-8
from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, String, Table, Text, text
from sqlalchemy.sql.sqltypes import NullType
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base


Base = declarative_base()
metadata = Base.metadata


class BibTypeszone(Base):
    __tablename__ = 'bib_typeszones'
    __table_args__ = {u'schema': 'layers'}

    id_type = Column(Integer, primary_key=True)
    typezone = Column(String(200))


class LZonesstatut(Base):
    __tablename__ = 'l_zonesstatut'
    __table_args__ = {u'schema': 'layers'}

    id_zone = Column(Integer, primary_key=True)
    id_type = Column(ForeignKey(u'layers.bib_typeszones.id_type', onupdate=u'CASCADE'), nullable=False)
    id_mnhn = Column(String(20))
    nomzone = Column(String(250))
    the_geom = Column(NullType)

    bib_typeszone = relationship(u'BibTypeszone')


class BibLot(Base):
    __tablename__ = 'bib_lots'
    __table_args__ = {u'schema': 'meta'}

    id_lot = Column(Integer, primary_key=True)
    nom_lot = Column(String(255))
    desc_lot = Column(Text)
    menu_cf = Column(Boolean, server_default=text("false"))
    pn = Column(Boolean, server_default=text("true"))
    menu_inv = Column(Boolean, server_default=text("false"))
    id_programme = Column(ForeignKey(u'meta.bib_programmes.id_programme', onupdate=u'CASCADE'), nullable=False)

    bib_programme = relationship(u'BibProgramme')


class BibProgramme(Base):
    __tablename__ = 'bib_programmes'
    __table_args__ = {u'schema': 'meta'}

    id_programme = Column(Integer, primary_key=True)
    nom_programme = Column(String(255))
    desc_programme = Column(Text)
    programme_public = Column(Boolean)
    desc_programme_public = Column(Text)
    actif = Column(Boolean)


class TPrecision(Base):
    __tablename__ = 't_precisions'
    __table_args__ = {u'schema': 'meta'}

    id_precision = Column(Integer, primary_key=True)
    nom_precision = Column(String(50))
    desc_precision = Column(Text)


class TProtocole(Base):
    __tablename__ = 't_protocoles'
    __table_args__ = {u'schema': 'meta'}

    id_protocole = Column(Integer, primary_key=True)
    nom_protocole = Column(String(250))
    question = Column(Text)
    objectifs = Column(Text)
    methode = Column(Text)
    avancement = Column(String(50))
    date_debut = Column(Date)
    date_fin = Column(Date)


class BibCriteresSynthese(Base):
    __tablename__ = 'bib_criteres_synthese'
    __table_args__ = {u'schema': 'synthese'}

    id_critere_synthese = Column(Integer, primary_key=True)
    code_critere_synthese = Column(String(3))
    nom_critere_synthese = Column(String(90))
    tri = Column(Integer)


class BibSource(Base):
    __tablename__ = 'bib_sources'
    __table_args__ = {u'schema': 'synthese'}

    id_source = Column(Integer, primary_key=True)
    nom_source = Column(String(255))
    desc_source = Column(Text)
    host = Column(String(100))
    port = Column(Integer)
    username = Column(String(50))
    _pass = Column('pass', String(50))
    db_name = Column(String(50))
    db_schema = Column(String(50))
    db_table = Column(String(50))
    db_field = Column(String(50))
    url = Column(String(255))
    target = Column(String(10))
    picto = Column(String(255))
    groupe = Column(String(50))
    actif = Column(Boolean)


class CorUniteSynthese(Base):
    __tablename__ = 'cor_unite_synthese'
    __table_args__ = {u'schema': 'synthese'}

    id_unite_geo = Column(Integer, primary_key=True, nullable=False, index=True)
    id_synthese = Column(ForeignKey(u'synthese.syntheseff.id_synthese', ondelete=u'CASCADE', onupdate=u'CASCADE'), primary_key=True, nullable=False, index=True)
    dateobs = Column(Date)
    cd_nom = Column(Integer)

    syntheseff = relationship(u'Syntheseff')


t_cor_zonesstatut_synthese = Table(
    'cor_zonesstatut_synthese', metadata,
    Column('id_zone', ForeignKey(u'layers.l_zonesstatut.id_zone', onupdate=u'CASCADE'), primary_key=True, nullable=False, index=True),
    Column('id_synthese', ForeignKey(u'synthese.syntheseff.id_synthese', ondelete=u'CASCADE', onupdate=u'CASCADE'), primary_key=True, nullable=False, index=True),
    schema='synthese'
)


class InvalidSynthese(Base):
    __tablename__ = 'invalid_synthese'
    __table_args__ = {u'schema': 'synthese'}

    id_synthese = Column(Integer, primary_key=True, server_default=text("nextval('synthese.invalid_synthese_id_synthese_seq'::regclass)"))
    id_source = Column(Integer)
    id_fiche_source = Column(String(25))
    code_fiche_source = Column(String(25))
    id_organisme = Column(Integer)
    id_protocole = Column(Integer)
    codeprotocole = Column(Integer)
    ids_protocoles = Column(String(255), nullable=False)
    id_precision = Column(Integer)
    cd_nom = Column(Integer)
    insee = Column(String(5))
    dateobs = Column(Date, nullable=False)
    observateurs = Column(String(255))
    altitude_retenue = Column(Integer)
    remarques = Column(Text)
    date_insert = Column(DateTime)
    date_update = Column(DateTime)
    derniere_action = Column(String(1))
    supprime = Column(Boolean)
    the_geom_27572 = Column(NullType)
    the_geom_2154 = Column(NullType)
    the_geom_point = Column(NullType)
    desc_probleme = Column(Text)
    id_taxon = Column(Integer)
    id_lot = Column(Integer)
    id_critere_synthese = Column(Integer)
    the_geom_3857 = Column(NullType)
    effectif_total = Column(Integer)


class Syntheseff(Base):
    __tablename__ = 'syntheseff'
    __table_args__ = {u'schema': 'synthese'}

    id_synthese = Column(Integer, primary_key=True, server_default=text("nextval('synthese.syntheseff_id_synthese_seq'::regclass)"))
    id_source = Column(ForeignKey(u'synthese.bib_sources.id_source', onupdate=u'CASCADE'), index=True)
    id_fiche_source = Column(String(50))
    code_fiche_source = Column(String(50))
    id_organisme = Column(ForeignKey(u'utilisateurs.bib_organismes.id_organisme', onupdate=u'CASCADE'), index=True)
    id_protocole = Column(ForeignKey(u'meta.t_protocoles.id_protocole', onupdate=u'CASCADE'), index=True)
    id_precision = Column(ForeignKey(u'meta.t_precisions.id_precision', onupdate=u'CASCADE'))
    cd_nom = Column(Integer, index=True)
    insee = Column(String(5), index=True)
    dateobs = Column(Date, nullable=False, index=True)
    observateurs = Column(String(255))
    determinateur = Column(String(255))
    altitude_retenue = Column(Integer)
    remarques = Column(Text)
    date_insert = Column(DateTime)
    date_update = Column(DateTime)
    derniere_action = Column(String(1))
    supprime = Column(Boolean)
    the_geom_point = Column(NullType, index=True)
    id_lot = Column(ForeignKey(u'meta.bib_lots.id_lot', onupdate=u'CASCADE'), index=True)
    id_critere_synthese = Column(ForeignKey(u'synthese.bib_criteres_synthese.id_critere_synthese', onupdate=u'CASCADE'))
    the_geom_3857 = Column(NullType)
    effectif_total = Column(Integer)
    the_geom_2154 = Column(NullType)

    bib_criteres_synthese = relationship(u'BibCriteresSynthese')
    bib_lot = relationship(u'BibLot')
    bib_organisme = relationship(u'BibOrganisme')
    t_precision = relationship(u'TPrecision')
    t_protocole = relationship(u'TProtocole')
    bib_source = relationship(u'BibSource')
    l_zonesstatut = relationship(u'LZonesstatut', secondary='cor_zonesstatut_synthese')


t_v_taxons_synthese = Table(
    'v_taxons_synthese', metadata,
    Column('nom_francais', String(255)),
    Column('nom_latin', String(100)),
    Column('patrimonial', Boolean),
    Column('protection_stricte', Boolean),
    Column('cd_ref', Integer),
    Column('cd_nom', Integer),
    Column('nom_valide', String(255)),
    Column('famille', String(50)),
    Column('ordre', String(50)),
    Column('classe', String(50)),
    Column('regne', String(20)),
    Column('protections', Text),
    Column('id_liste', Integer),
    Column('picto', String(50)),
    schema='synthese'
)


t_v_tree_taxons_synthese = Table(
    'v_tree_taxons_synthese', metadata,
    Column('id_taxon', Integer),
    Column('cd_ref', Integer),
    Column('nom_latin', String(100)),
    Column('nom_francais', String),
    Column('id_regne', Integer),
    Column('nom_regne', String(20)),
    Column('id_embranchement', Integer),
    Column('nom_embranchement', String),
    Column('id_classe', Integer),
    Column('nom_classe', String),
    Column('desc_classe', String),
    Column('id_ordre', Integer),
    Column('nom_ordre', String),
    Column('id_famille', Integer),
    Column('nom_famille', String),
    schema='synthese'
)


class BibOrganisme(Base):
    __tablename__ = 'bib_organismes'
    __table_args__ = {u'schema': 'utilisateurs'}

    nom_organisme = Column(String(100), nullable=False)
    adresse_organisme = Column(String(128))
    cp_organisme = Column(String(5))
    ville_organisme = Column(String(100))
    tel_organisme = Column(String(14))
    fax_organisme = Column(String(14))
    email_organisme = Column(String(100))
    id_organisme = Column(Integer, primary_key=True, server_default=text("nextval('utilisateurs.bib_organismes_id_seq'::regclass)"))
