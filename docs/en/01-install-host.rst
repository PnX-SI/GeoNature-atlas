Install host
============

You can install GeoNature-atlas locally to test it or on a remote host to make it available on internet.

The installation scripts are designed for Debian (8 or 9) and Ubuntu (18). Other linux distributions can work, but you will have to adapt 
installation scripts.

Login in SSH with ``root`` user to prepare host and launch these commands with a terminal.

.. code-block:: console

    # Install unzip and sudo
    apt-get install unzip
    apt-get install sudo
    # Create a linux user (geonatureatlas in our example) and add it to sudo group
    adduser geonatureatlas
    adduser geonatureatlas sudo

Logout from ``root`` user and we'll now work only with your dedicated user (``geonatureatlas`` in our example).
