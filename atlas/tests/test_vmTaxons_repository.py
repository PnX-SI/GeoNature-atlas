# -*- coding: utf-8 -*-
from werkzeug.datastructures import MultiDict

from atlas.modeles.repositories import vmTaxonsRepository
from atlas.tests.fixtures.main_fixtures import taxon, obs_with_area


def test_getListTaxon_protected_filter(app, taxon, obs_with_area):
    """Insert an observation for the fixture taxon and verify
    that getListTaxon filtered with `protected` returns only
    taxa with `protection_stricte` == True."""

    params = MultiDict({"protected": "true"})
    res = vmTaxonsRepository.getListTaxon(params=params)

    assert res, "Expected at least one taxon returned"
    assert all(r.get("protection_stricte") is True for r in res)


def test_getListTaxon_filter_id_area(app, taxon, obs_with_area):
    """Insert an observation for the fixture taxon and verify
    that getListTaxon filtered with `protected` returns only
    taxa with `protection_stricte` == True."""

    # id_area 5 has no observation
    res = vmTaxonsRepository.getListTaxon(id_area=5)

    assert len(res) == 0

    # 777777 5 has 1 observation
    res = vmTaxonsRepository.getListTaxon(id_area=777777)
    assert len(res) > 0
