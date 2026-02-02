# -*- coding: utf-8 -*-
import pytest
from atlas.modeles.repositories import vmAreasRepository


@pytest.mark.usefixtures("vm_areas_with_obs_data")
def test_search_areas_basic(app):
    # Test recherche exacte
    res = vmAreasRepository.searchAreas("Test Area")
    assert any(r["label"] == "Test Area" and r["type_name"] == "COMMUNE" for r in res)

    # Test recherche partielle insensible à la casse
    res2 = vmAreasRepository.searchAreas("autre")
    assert any(r["label"] == "Autre Territoire" and r["type_name"] == "DEPARTEMENT" for r in res2)

    # Test aucun résultat
    res3 = vmAreasRepository.searchAreas("inexistant")
    assert res3 == []

    # Test limite
    res4 = vmAreasRepository.searchAreas("", limit=1)
    assert len(res4) == 1
