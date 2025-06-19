from marshmallow import fields, post_dump
from atlas.env import ma

from atlas.modeles import VmMedias, VmTaxons

class VmMediasSchema(ma.SQLAlchemyAutoSchema):
    class Meta:
        model = VmMedias


        

class VmTaxonSchema(ma.SQLAlchemyAutoSchema):
    medias = fields.Nested(VmMediasSchema, many=True)
    main_picture = fields.Nested(VmMediasSchema)

    class Meta:
        model = VmTaxons
