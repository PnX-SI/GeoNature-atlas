
Ce script permet d'importer les médias Commons à partir des code_taxon GBIF présents dans Wikidata.

::

    virtualenv -p /usr/bin/python3 venv #Python 3 n'est pas requis
    source venv/bin/activate
    pip install lxml psycopg2 requests SPARQLWrapper xmltodict
    deactivate