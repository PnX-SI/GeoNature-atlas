# coding: utf-8
from flask import current_app
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import Integer
from atlas.env import db


def create_vm_altitudes_class():
    """
    Dynamically creates and returns the VmAltitudes model class
    based on the altitude ranges defined in the configuration.
    """
    altitude_ranges = current_app.config["ALTITUDE_RANGES"]

    class_attributes = {
        "__tablename__": "vm_altitudes",
        "__table_args__": {"schema": "atlas"},
        # Fixed column
        "cd_ref": mapped_column(Integer, primary_key=True),
    }

    for i in range(len(altitude_ranges) - 1):
        alt_min = altitude_ranges[i]
        alt_max = altitude_ranges[i + 1]
        # The '_' prefix is necessary because a variable name cannot start with a number.
        column_name = f"_{alt_min}_{alt_max}"
        class_attributes[column_name] = mapped_column(Integer)

    VmAltitudesClass = type("VmAltitudes", (db.Model,), class_attributes)
    return VmAltitudesClass


VmAltitudes = create_vm_altitudes_class()
