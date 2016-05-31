##
## !/usr/bin/python
import sys
sys.path.insert(0, '/home/synthese/atlas')


from werkzeug.debug import DebuggedApplication
from main.atlasPNE import app as application
application = DebuggedApplication(application, evalex=True)
