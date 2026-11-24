def test_taxon_list_cache_key_uses_query_string(app):
    from atlas.atlasAPI import get_taxon_list_json

    def make_key(query):
        with app.test_request_context(f"/api/taxonListJson?{query}"):
            return get_taxon_list_json.make_cache_key(use_request=True)

    assert make_key("page=1") != make_key("page=2")
    assert make_key("page=1&limit=10") == make_key("limit=10&page=1")


def test_taxon_list_cache_reuses_response_for_same_query(app, client, monkeypatch):
    from atlas.env import cache

    calls = []
    cached_values = {}

    def get_list_taxon(**kwargs):
        page = kwargs["params"].get("page")
        calls.append(page)
        return {"page": page}

    def get_cached_value(key):
        return cached_values.get(key)

    def set_cached_value(key, value, timeout=None):
        cached_values[key] = value

    monkeypatch.setattr(
        "atlas.atlasAPI.vmTaxonsRepository.getListTaxon",
        get_list_taxon,
    )
    with app.app_context():
        backend = cache.cache
    monkeypatch.setattr(backend, "get", get_cached_value)
    monkeypatch.setattr(backend, "set", set_cached_value)

    page_one = client.get("/api/taxonListJson?page=1")
    page_two = client.get("/api/taxonListJson?page=2")
    page_one_again = client.get("/api/taxonListJson?page=1")

    assert page_one.json == {"page": "1"}
    assert page_two.json == {"page": "2"}
    assert page_one_again.json == {"page": "1"}
    assert calls == ["1", "2"]


def test_cache_init_uses_flask_caching_configuration():
    from atlas.app import create_app
    from atlas.env import cache

    configured_app = create_app(
        {
            "CACHE_TYPE": "NullCache",
            "CACHE_DEFAULT_TIMEOUT": 123,
        }
    )

    with configured_app.app_context():
        backend = cache.cache

    assert type(backend).__name__ == "NullCache"


def test_cache_init_preserves_atlas_timeout_and_simplecache_options():
    from atlas.app import create_app
    from atlas.env import cache

    configured_app = create_app(
        {
            "CACHE_TIMEOUT": 456,
            "CACHE_THRESHOLD": 17,
        }
    )

    with configured_app.app_context():
        backend = cache.cache

    assert type(backend).__name__ == "SimpleCache"
    assert backend.default_timeout == 456
    assert backend._threshold == 17


def test_cache_init_prefers_flask_timeout_over_legacy_atlas_timeout():
    from atlas.app import create_app
    from atlas.env import cache

    configured_app = create_app(
        {
            "CACHE_TIMEOUT": 456,
            "CACHE_DEFAULT_TIMEOUT": 123,
        }
    )

    with configured_app.app_context():
        backend = cache.cache

    assert backend.default_timeout == 123
