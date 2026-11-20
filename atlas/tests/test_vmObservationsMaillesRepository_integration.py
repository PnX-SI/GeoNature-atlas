import json
from datetime import date

import pytest
from geoalchemy2.elements import WKTElement

from atlas.modeles.entities.vmAreas import VmAreas, VmBibAreasTypes, VmCorAreaSynthese
from atlas.modeles.entities.vmObservations import VMCorMailleObservation, VmObservations
from atlas.modeles.repositories import vmObservationsMaillesRepository as repository

pytest_plugins = ("atlas.tests.fixtures.main_fixtures",)


@pytest.fixture
def municipality_and_mesh_observations(db_session, taxon):
    municipality_id = 98000001
    type_id = 98000001
    municipality_bounds = (0, 0, 2, 2)
    mesh_bounds = {
        98000002: (-1, -1, 3, 3),
        98000003: (1.5, 0.5, 2.5, 1.5),
        98000004: (0.25, 0.25, 0.75, 0.75),
        98000005: (3, 0, 4, 1),
    }

    def area(id_area, name, bounds):
        x_min, y_min, x_max, y_max = bounds
        ring = [
            [x_min, y_min],
            [x_max, y_min],
            [x_max, y_max],
            [x_min, y_max],
            [x_min, y_min],
        ]
        coordinates = ", ".join(f"{x} {y}" for x, y in ring)
        geometry = WKTElement(f"MULTIPOLYGON((({coordinates})))", srid=4326)
        return VmAreas(
            id_area=id_area,
            area_code=str(id_area),
            area_name=name,
            id_type=type_id,
            the_geom=geometry,
            area_geojson=json.dumps({"type": "Polygon", "coordinates": [ring]}),
            description=name,
        )

    db_session.add(
        VmBibAreasTypes(
            id_type=type_id,
            type_code="COM",
            type_name="Communes",
            type_desc="Type de territoire de test",
        )
    )
    db_session.add(area(municipality_id, "municipality test", municipality_bounds))
    db_session.add_all(
        area(id_area, f"mesh M5 {id_area}", bounds) for id_area, bounds in mesh_bounds.items()
    )

    id_observation = 98000101
    observation = VmObservations(
        id_observation=id_observation,
        dateobs=date(2024, 1, 1),
        observateurs="test",
        altitude_retenue=1,
        cd_ref=taxon.cd_ref,
        the_geom_point=WKTElement("POINT(1 1)", srid=4326),
        geojson_point="{}",
        cd_sensitivity="0",
        id_dataset=1,
    )
    mesh_links = [
        VMCorMailleObservation(
            id_maille=id_mesh,
            id_observation=id_observation,
            type_code="M5",
        )
        for id_mesh in mesh_bounds
    ]
    municipality_link = VmCorAreaSynthese(
        id_synthese=id_observation,
        id_area=municipality_id,
        id_type=type_id,
        type_code="municipality",
        is_valid_for_display=True,
    )
    db_session.add_all([observation, *mesh_links, municipality_link])

    db_session.flush()
    return municipality_id, set(mesh_bounds)


def test_get_observations_meshs_filter_area(municipality_and_mesh_observations):
    municipality_id, all_mesh_ids = municipality_and_mesh_observations
    expected_intersecting_ids = {98000002, 98000003, 98000004}

    result = repository.getObservationsMaillesChilds({"id_area": str(municipality_id)})

    result_ids = {feature["id"] for feature in result["features"]}
    assert result_ids == expected_intersecting_ids
    assert result_ids < all_mesh_ids
