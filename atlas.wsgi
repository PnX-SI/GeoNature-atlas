#!/usr/bin/python
# -*- coding: utf-8 -*-

import os, sys

# Activate your virtual env
activate_env=os.path.expanduser(os.path.join(os.path.dirname(__file__), 'venv/bin/activate_this.py'))
execfile(activate_env, dict(__file__=activate_env))

APP_DIR = os.path.abspath(os.path.dirname(__file__))
sys.path.insert(0, APP_DIR)

from main.modeles import *
from main.configuration import config

from werkzeug.debug import DebuggedApplication
from initAtlas import app
application = DebuggedApplication(app, evalex=True)
