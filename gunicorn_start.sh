#!/bin/bash

FLASKDIR=$(readlink -e "${0%/*}")


. "$FLASKDIR"/atlas/configuration/settings.ini

echo "Starting $app_name"
echo "$FLASKDIR"

# activate the virtualenv
cd $FLASKDIR/$venv_dir
source bin/activate

export PYTHONPATH=$FLASKDIR:$PYTHONPATH


# Start your unicorn
exec gunicorn initAtlas:app --error-log $FLASKDIR/log/errors_atlas.log \
    --pid="${app_name}.pid" \
    --timeout=${gun_timeout} \
    -w "${gun_num_workers}" \
    -b "${gun_host}:${gun_port}" \
    -n "${app_name}"
