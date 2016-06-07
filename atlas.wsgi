#!/usr/bin/python
# -*- coding: utf-8 -*-

# Définition des chemins racines
import os
APP_DIR = os.path.abspath(os.path.dirname(__file__))
BASE_DIR = os.path.abspath(os.path.join(APP_DIR, os.pardir))

#insertion des chemins racines
import sys
sys.path.insert(0, BASE_DIR)
sys.path.insert(0, APP_DIR)

from werkzeug.debug import DebuggedApplication
from manage import app as application
application = DebuggedApplication(application, evalex=True)
