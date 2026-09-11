# -*- coding: utf-8 -*-
import pytest

from fixtures.main_fixtures import vm_areas_with_obs_data
from atlas.modeles.repositories import vmAreasRepository


@pytest.mark.usefixtures("vm_areas_with_obs_data")
def test_search_areas_basic(app):
    # Test recherche exacte
    res = vmAreasRepository.searchAreas("Commune de test")
    assert any(r["label"] == "Commune de test" and r["type_name"] == "Communes" for r in res)

    # Test recherche partielle insensible à la casse
    res2 = vmAreasRepository.searchAreas("COMMUNE DE")
    assert any(r["label"] == "Commune de test" for r in res2)

    # Test type absent de TYPE_TERRITOIRE_SHEET
    res3 = vmAreasRepository.searchAreas("autre")
    assert res3 == []

    # Test aucun résultat
    res4 = vmAreasRepository.searchAreas("inexistant")
    assert res4 == []

    # Test limite
    res5 = vmAreasRepository.searchAreas("", limit=1)
    assert len(res5) == 1
