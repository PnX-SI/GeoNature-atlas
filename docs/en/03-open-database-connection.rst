Open database connection
========================

To access and manage GeoNature-atlas database we'll use pgAdmin software (https://www.pgadmin.org).

By default a PostgreSQL database only accept connections from its local host. 
To manage the database from your local computer we'll have to open database connections.

Edit ``postgresql.conf`` file so that PostgreSQL would listen from all IP :

.. code-block:: console

    sudo nano /etc/postgresql/*/main/postgresql.conf

Replace ``listen_adress = 'localhost'`` by ``listen_adress = '*'``. 
Don't forget to uncomment this line (with removing the ``#``).

To define IP that can connect to the database we'll edit ``pg_hba.conf`` file:

.. code-block:: console

    sudo nano /etc/postgresql/*/main/pg_hba.conf

To give access to the database from a specific IP (recommanded), add this line to the ``pg_hba.conf`` file:

.. code-block::

    host    all     all     MY_IP/0        md5  

Or if you want to give access to all IP, add this line to the ``pg_hba.conf`` file:

.. code-block::

    host    all     all     0.0.0.0/0        md5

Restart PostgreSQL to apply changes:

.. code-block:: console

    sudo /etc/init.d/postgresql restart
