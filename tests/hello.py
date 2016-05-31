#! /usr/bin/python
# -*- coding:utf-8 -*-

from flask import Flask, request
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)


@app.route('/')
def index():
    return "Hello Flask marche très bien !!!"


if __name__ == '__main__':
    app.debug= True


    
    





