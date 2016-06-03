##
## !/usr/bin/python
import sys
sys.path.insert(0, '/home/theo/atlas')
sys.path.insert(0, '/home/theo')


from werkzeug.debug import DebuggedApplication
from manage import app as application
application = DebuggedApplication(application, evalex=True)
