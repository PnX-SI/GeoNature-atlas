# -*- coding:utf-8 -*-
from urllib.parse import urljoin
from flask import current_app, url_for
from sqlalchemy import String, Float, Text, ForeignKey, Boolean, and_
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy.orm import relationship
from atlas.env import db
from atlas.modeles.entities.vmMedias import VmMedias
from atlas.modeles import utils

from typing import List
import datetime


class VmTaxons(db.Model):
    __tablename__ = "vm_taxons"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    regne: Mapped[str] = mapped_column(String(20))
    phylum: Mapped[str] = mapped_column(String(50))
    classe: Mapped[str] = mapped_column(String(50))
    ordre: Mapped[str] = mapped_column(String(50))
    famille: Mapped[str] = mapped_column(String(50))
    cd_taxsup: Mapped[int] = mapped_column()
    lb_nom: Mapped[str] = mapped_column(String(100))
    lb_auteur: Mapped[str] = mapped_column(String(250))
    nom_complet: Mapped[str] = mapped_column(String(255))
    nom_valide: Mapped[str] = mapped_column(String(255))
    nom_vern: Mapped[str] = mapped_column(String(1000))
    nom_vern_eng: Mapped[str] = mapped_column(String(500))
    group1_inpn: Mapped[str] = mapped_column(String(50))
    group2_inpn: Mapped[str] = mapped_column(String(50))
    group3_inpn: Mapped[str] = mapped_column(String(50))
    nom_complet_html: Mapped[str] = mapped_column(String(500))
    id_rang: Mapped[str] = mapped_column(String(10))
    patrimonial: Mapped[str] = mapped_column(String(255))
    protection_stricte: Mapped[bool] = mapped_column()
    menace: Mapped[bool] = mapped_column()
    yearmin: Mapped[float] = mapped_column(Float(53))
    yearmax: Mapped[float] = mapped_column(Float(53))
    nb_obs: Mapped[int] = mapped_column()
    attributs: Mapped[List["VmCorTaxonAttribut"]] = relationship(
        "VmCorTaxonAttribut", back_populates="taxon"
    )
    main_media: Mapped[VmMedias] = relationship(
        VmMedias,
        primaryjoin=and_(
            VmMedias.cd_ref == cd_ref, 
            VmMedias.id_type == current_app.config["ATTR_MAIN_PHOTO"]
        ),
    )
    def as_dict(self, with_main_media=False):
        d = {
            "cd_ref": self.cd_ref,
            "lb_nom": self.lb_nom,
            "nom_complet_html": self.nom_complet_html,
            "nom_vern": self.nom_vern,
            "patrimonial": self.patrimonial,
            "menace": self.menace,
            "protection_stricte": self.protection_stricte,
            "yearmin": self.yearmin,
            "yearmax": self.yearmax,
            "nb_obs": self.nb_obs,
            "group2_inpn": utils.deleteAccent(self.group2_inpn),
            "group3_inpn": utils.deleteAccent(self.group3_inpn)
        }
        if with_main_media:
            d["media"] = self.get_main_media()
        return d

    def get_main_media(self, size=(80,80)):
        """Get main image of default logo

        Parameters
        ----------
        size : tuple, optional
            (height, width), by default (80,80)

        Returns
        -------
        str
            The path or url of the main image if exist, the logo of the group INPN if not
        """
        default_media = url_for(
            'static',
            filename=f"images/picto_{utils.deleteAccent(self.group2_inpn).replace(' ', '_') }.png"
        )
        if self.main_media:
            if current_app.config["REDIMENSIONNEMENT_IMAGE"]:
                height, width = size
                return urljoin(
                    current_app.config['TAXHUB_URL'],
                    f"api/tmedias/thumbnail/{self.main_media.id_media}?h={height}&width={width}",
                )
            else:
                if self.main_media.chemin:
                    return current_app.config["REMOTE_MEDIAS_URL"] + self.main_media.chemin
                elif self.main_media.url:
                    return self.main_media.url
                else:
                    return default_media
        else:
            return default_media


    def shorten_name(self):
        shorten_nom_vern = self.nom_vern.split(",")[0] if self.nom_vern else ""
        return shorten_nom_vern + " | <i>" + self.lb_nom + " </i>"


class VmCorTaxonAttribut(db.Model):
    __tablename__ = "vm_cor_taxon_attribut"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(ForeignKey("atlas.vm_taxons.cd_ref"), primary_key=True)
    code: Mapped[str] = mapped_column(String(255), primary_key=True)
    title: Mapped[str] = mapped_column(String(50))
    value: Mapped[str] = mapped_column(Text)
    taxon: Mapped["VmTaxons"] = relationship("VmTaxons", back_populates="attributs")


class VmTaxonsMostView(db.Model):
    __tablename__ = "vm_taxons_plus_observes"
    __table_args__ = {"schema": "atlas"}

    cd_ref: Mapped[int] = mapped_column(primary_key=True)
    nb_obs: Mapped[int] = mapped_column()
    lb_nom: Mapped[str] = mapped_column(String(250))
    group2_inpn: Mapped[str] = mapped_column(String(50))
    nom_vern: Mapped[str] = mapped_column(String(1000))
    id_media: Mapped[int] = mapped_column()
    url: Mapped[str] = mapped_column(String(255))
    chemin: Mapped[str] = mapped_column(String(255))
    id_type: Mapped[int] = mapped_column()
