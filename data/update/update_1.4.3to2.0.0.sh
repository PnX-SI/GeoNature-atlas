#!/bin/bash

. ../atlas/configuration/settings.ini

export PGPASSWORD=$owner_atlas_pass;psql -d $db_name -U $owner_atlas -h $db_host -p $db_port \
    -v my_reader_user=$user_pg
    -f ./update_1.4.3to2.0.0.sql 