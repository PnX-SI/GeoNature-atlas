import pytest
from werkzeug.datastructures import MultiDict

from atlas.modeles.utils import is_true_param


@pytest.mark.parametrize("value", ["1", "true", "TRUE", "yes", "on", " true "])
def test_is_true_param_accepts_true_values(value):
    assert is_true_param(MultiDict({"enabled": value}), "enabled") is True


@pytest.mark.parametrize("value", [None, "", "0", "false", "no", "off", 1, True])
def test_is_true_param_rejects_other_values(value):
    params = MultiDict()
    if value is not None:
        params["enabled"] = value
    assert is_true_param(params, "enabled") is (value is True)
