Install GeoNature-atlas and its database
========================================

Download and unzip the source code from the actual dedicated branch:

.. code-block:: console

    cd /home/geonatureatlas
    wget https://github.com/PnX-SI/GeoNature-atlas/archive/multilingue.zip
    unzip multilingue.zip

Rename the application folder:

.. code-block:: console

    mv GeoNature-atlas-multilingue atlas

Launch the environment script that will install PostgreSQL, PostGIS 2, Apache 2 and Python 2.7.

.. code-block:: console

    cd /home/geonatureatlas/atlas
    ./install_env.sh

Install the database

.. code-block:: console

    # Copy the example setting file
    cp main/configuration/settings.ini.sample main/configuration/settings.ini

Edit database setting file ``main/configuration/settings.ini``.

You can change PostgreSQL database owner and user names and their passwords. They will be created by the database installation script.

- Upload your territory shapefile as ``data/ref/territoire.shp`` (or fill its path in ``limit_shp``)
- Upload your municipalities shapefile as ``data/ref/communes.shp`` (or fill its path in ``communes_shp``)
- Upload your grids shapefile as ``data/ref/custom_maille.shp`` (or fill its path in ``chemin_custom_maille``)
- ``geonature_source=false``
- ``metropole=false``
- ``install_taxonomie = true``

Once done, launch the database creation script:

.. code-block:: console

    sudo ./install_db.sh
