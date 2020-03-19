# -*- coding:utf-8 -*-

from sqlalchemy import MetaData
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool

from atlas.configuration.config import database_connection, NOM_APPLICATION

engine = create_engine(
    database_connection,
    client_encoding="utf8",
    echo=False,
    poolclass=QueuePool,
    connect_args={"application_name": "GN-atlas_{}".format(NOM_APPLICATION)},
)


def loadSession():
    from sqlalchemy.orm import sessionmaker

    Session = sessionmaker(bind=engine)
    session = Session()
    return session


def format_number(val):
    """ Ajouter des espaces en séparateur de milliers """
    return "{:,}".format(val).replace(",", " ")


SERIALIZERS = {
    "date": lambda x: str(x) if x else None,
    "datetime": lambda x: str(x) if x else None,
    "time": lambda x: str(x) if x else None,
    "timestamp": lambda x: str(x) if x else None,
    "uuid": lambda x: str(x) if x else None,
    "numeric": lambda x: str(x) if x else None,
}


class GenericTable:
    """
        Classe permettant de créer à la volée un mapping
            d'une vue avec la base de données par rétroingénierie
    """

    def __init__(self, tableName, schemaName, engine, geometry_field=None, srid=None):
        meta = MetaData(schema=schemaName, bind=engine)
        meta.reflect(views=True)

        try:
            self.tableDef = meta.tables["{}.{}".format(schemaName, tableName)]
        except KeyError:
            raise KeyError("table {}.{} doesn't exists".format(schemaName, tableName))

        # Test geometry field
        if geometry_field:
            try:
                if (
                        not self.tableDef.columns[geometry_field].type.__class__.__name__
                            == "Geometry"
                ):
                    raise TypeError(
                        "field {} is not a geometry column".format(geometry_field)
                    )
            except KeyError:
                raise KeyError("field {} doesn't exists".format(geometry_field))

        self.geometry_field = geometry_field
        self.srid = srid

        # Mise en place d'un mapping des colonnes en vue d'une sérialisation
        self.serialize_columns, self.db_cols = self.get_serialized_columns()

    def get_serialized_columns(self, serializers=SERIALIZERS):
        """
            Return a tuple of serialize_columns, and db_cols
            from the generic table
        """
        regular_serialize = []
        db_cols = []
        for name, db_col in self.tableDef.columns.items():
            if not db_col.type.__class__.__name__ == "Geometry":
                serialize_attr = (
                    name,
                    serializers.get(
                        db_col.type.__class__.__name__.lower(), lambda x: x
                    ),
                )
                regular_serialize.append(serialize_attr)

            db_cols.append(db_col)
        return regular_serialize, db_cols

    def as_dict(self, data, columns=None):
        if columns:
            fprops = list(filter(lambda d: d[0] in columns, self.serialize_columns))
        else:
            fprops = self.serialize_columns

        return {item: _serializer(getattr(data, item)) for item, _serializer in fprops}
