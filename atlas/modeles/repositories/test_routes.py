from atlas.app import create_app

if __name__ == "__main__":
    app = create_app()
    with app.app_context():
        from atlas.modeles.repositories.vmTaxonsRepository import getListTaxon, getGroupINPNarea
        with app.test_request_context():
            # res = getListTaxon(34814, params = {"page" : -1})
            res = getGroupINPNarea(12849)
            print(res)