import pytest

from atlas.modeles.repositories import vmAreasRepository
from atlas.tests.fixtures.main_fixtures import vm_areas_with_obs_data  # noqa: F401


@pytest.mark.usefixtures("vm_areas_with_obs_data")
def test_search_areas_basic(app):
    # Test exact search.
    res = vmAreasRepository.searchAreas("Commune de test")
    assert any(r["label"] == "Commune de test" and r["type_name"] == "Communes" for r in res)

    # Test case-insensitive partial search.
    res2 = vmAreasRepository.searchAreas("COMMUNE DE")
    assert any(r["label"] == "Commune de test" for r in res2)

    # Test a type not included in TYPE_TERRITOIRE_SHEET.
    res3 = vmAreasRepository.searchAreas("autre")
    assert res3 == []

    # Test no results.
    res4 = vmAreasRepository.searchAreas("inexistant")
    assert res4 == []

    # Test result limit.
    res5 = vmAreasRepository.searchAreas("", limit=1)
    assert len(res5) == 1
