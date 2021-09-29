def test_pytesempty_db(client):
    """Start with a blank database."""

    rv = client.get('/')
    assert b'No entries here so far' not in rv.data