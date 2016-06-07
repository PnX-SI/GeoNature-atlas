#!/usr/bin/python
# -*- coding: utf-8 -*-

# Définition des chemins racines
import os
appDir = os.path.abspath(os.path.dirname(__file__))
baseDir = os.path.abspath(os.path.join(appDir, os.pardir))

#insertion des chemins racines
import sys
sys.path.insert(0, baseDir)
sys.path.insert(0, appDir)

from werkzeug.debug import DebuggedApplication
from manage import app as application
application = DebuggedApplication(application, evalex=True)
