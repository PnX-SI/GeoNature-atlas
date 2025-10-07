# pylint: disable=redefined-outer-name
import pytest

from atlas.app import create_app


@pytest.fixture(scope="session")
def _app():
    app = create_app()
    app.testing = True
    app.config["SERVER_NAME"] = "test.atlas.local"  # required by url_for
    with app.app_context():
        yield app

# @pytest.fixture(scope="session")
# def app():
#     print("passe la ?????")
#     app = create_app()
#     app.testing = True
#     app.config["SERVER_NAME"] = "test.atlas.local"  # required by url_for
#     with app.app_context():
#         with db.engine.connect() as conn:
#             conn.execute(text("CREATE SCHEMA IF NOT EXISTS atlas"))
#             conn.commit()
#         db.create_all()



#         yield app
#         db.drop_all()


@pytest.fixture
def client(_app):
    return _app.test_client()
