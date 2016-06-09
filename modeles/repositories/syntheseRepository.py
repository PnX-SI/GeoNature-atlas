# #! /usr/bin/python
# # -*- coding:utf-8 -*-
# from atlas import APP_DIR, BASE_DIR, manage
# import sys
# sys.path.insert(0, APP_DIR + '/modeles/entities')
# sys.path.insert(0, BASE_DIR)
# from synthese import Syntheseff
# from sqlalchemy import distinct, func
# from sqlalchemy.orm import sessionmaker




# session = manage.loadSession()

# #retourne le geojson des obs avec
# def observations(taxon):
# 	return session.query(Syntheseff.st_asgeojson).filter(Syntheseff.nom_vern.ilike('%'+taxon)).all()
    
