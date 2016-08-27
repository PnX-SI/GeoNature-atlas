#!/usr/bin/python
# -*- coding: utf-8 -*-

import os, sys
APP_DIR = os.path.abspath(os.path.dirname(__file__))
sys.path.insert(0, APP_DIR)

from main.modeles import *
from main.configuration import config

from werkzeug.debug import DebuggedApplication
from initAtlas import app
application = DebuggedApplication(app, evalex=True)
