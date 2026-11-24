from datetime import datetime
from types import SimpleNamespace

import pytest
from sqlalchemy.dialects import postgresql

from atlas.modeles.repositories import vmObservationsMaillesRepository as repository


@pytest.fixture(autouse=True)
def db_session():
    yield


@pytest.fixture
def fake_session(mocker):
    session = mocker.Mock()
    session.scalars.return_value.all.return_value = []
    session.execute.return_value.all.return_value = []
    mocker.patch.object(repository, "db", SimpleNamespace(session=session))
    return session


def observation_row(**overrides):
    values = {
        "id_maille": 42,
        "area_geojson": '{"type": "Polygon", "coordinates": []}',
        "type_code": "M1",
        "cd_sensitivity": "2",
        "obs_nbr": 3,
        "last_obs_year": 2024,
        "ids_obs": [10, 11, 12],
    }
    values.update(overrides)
    return SimpleNamespace(**values)


def compiled_query(session):
    statement = session.execute.call_args.args[0]
    return statement.compile(dialect=postgresql.dialect())


def test_format_taxon_name_uses_first_vernacular_name():
    observation = SimpleNamespace(nom_vern="Nom commun, autre nom", lb_nom="Nom latin")

    assert repository.format_taxon_name(observation) == "Nom commun | <i>Nom latin</i>"


def test_format_taxon_name_falls_back_to_latin_name():
    observation = SimpleNamespace(nom_vern=None, lb_nom="Nom latin")

    assert repository.format_taxon_name(observation) == "<i>Nom latin</i>"


def test_get_observations_mailles_returns_geojson_features(fake_session):
    fake_session.execute.return_value.all.return_value = [observation_row()]

    result = repository.getObservationsMaillesChilds()

    assert result["type"] == "FeatureCollection"
    assert result["features"][0] == {
        "type": "Feature",
        "id": 42,
        "geometry": {"type": "Polygon", "coordinates": []},
        "properties": {
            "id_maille": 42,
            "type_code": "M1",
            "cd_sensitivity": "2",
            "nb_observations": 3,
            "last_observation": 2024,
            "ids_obs": None,
        },
    }


def test_get_observations_mailles_includes_ids_when_requested(fake_session):
    fake_session.execute.return_value.all.return_value = [observation_row()]

    result = repository.getObservationsMaillesChilds({"fields": "ids_obs"})

    assert result["features"][0]["properties"]["ids_obs"] == [10, 11, 12]
    assert "array_agg" in compiled_query(fake_session).string.lower()


def test_get_observations_mailles_filters_taxon_and_children(fake_session):
    fake_session.scalars.return_value.all.return_value = [100, 101]

    repository.getObservationsMaillesChilds({"cd_ref": "99"})

    fake_session.scalars.assert_called_once()
    compiled = compiled_query(fake_session)
    assert "any" in compiled.string.lower()
    assert [100, 101, 99] in compiled.params.values()


def test_get_observations_mailles_applies_year_filter_only_with_both_bounds(fake_session):
    repository.getObservationsMaillesChilds({"year_min": "2020"})
    assert not any(
        isinstance(value, datetime) for value in compiled_query(fake_session).params.values()
    )

    repository.getObservationsMaillesChilds({"year_min": "2020", "year_max": "2022"})
    params = compiled_query(fake_session).params.values()
    assert datetime(2020, 1, 1) in params
    assert datetime(2022, 12, 31) in params


def test_get_observations_mailles_filter_recent_observations(fake_session):
    repository.getObservationsMaillesChilds({"last_obs": "30 days"})

    compiled = compiled_query(fake_session)
    sql = compiled.string.lower()
    assert "current_timestamp" in sql
    assert "30 days" in compiled.params.values()


def test_get_observations_mailles_returns_empty_feature_collection(fake_session):
    result = repository.getObservationsMaillesChilds()

    assert result["type"] == "FeatureCollection"
    assert result["features"] == []
