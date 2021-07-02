# pylint: disable=redefined-outer-name
import pytest

from atlas.app import create_app

@pytest.fixture(scope='session')
def app():
    app = create_app()
    app.testing = True
    app.config['SERVER_NAME'] = 'test.atlas.local'  # required by url_for
    with app.app_context():
        yield app

@pytest.fixture
def client(app):
    return app.test_client()
