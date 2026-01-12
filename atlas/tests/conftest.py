# pylint: disable=redefined-outer-name
from copy import deepcopy
from pathlib import Path

import pytest
from sqlalchemy import text

from atlas.app import create_app
from atlas.env import db, BASE_DIR


def with_config(**config_overrides):
    def decorator(func):

        func._config_overrides = config_overrides
        return func

    return decorator


@pytest.fixture(scope="session")
def _db_setup():
    # Crée une app temporaire juste pour initialiser la DB
    app = create_app()
    with app.app_context():
        with db.engine.connect() as conn:
            conn.execute(text("CREATE SCHEMA IF NOT EXISTS atlas"))
            conn.execute(text("CREATE SCHEMA IF NOT EXISTS gn_meta"))
            conn.execute(text("CREATE SCHEMA IF NOT EXISTS utilisateurs"))
            sql = Path(BASE_DIR / "data/atlas/7.1.psql_functions.sql").read_text()
            conn.execute(text(sql))
            conn.commit()
            db.create_all()

        yield app
        db.drop_all()


@pytest.fixture(autouse=True)
def db_session(app):
    with app.app_context():
        db.session.begin_nested()
        yield db.session
        db.session.rollback()


@pytest.fixture()
def app(request, _db_setup):
    overrides = getattr(request.function, "_config_overrides", {})
    app = create_app(config_overrides=overrides)
    app.testing = True
    app.config["SERVER_NAME"] = "test.atlas.local"  # required by url_for

    return app
