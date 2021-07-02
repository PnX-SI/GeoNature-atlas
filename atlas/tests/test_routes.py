### Test if routes are not 404 ###

def test_index(app, client):
    del app
    res = client.get('/')
    assert res.status_code == 200

def test_atlas(app, client):
    del app
    res = client.get('/atlas/')
    assert res.status_code == 200
    assert b'Bienvenue' in res.data

def test_presentation(app, client):
    del app
    res = client.get('/atlas/presentation')
    assert res.status_code == 200

def test_photos(app, client):
    del app
    res = client.get('/atlas/photos')
    assert res.status_code == 200