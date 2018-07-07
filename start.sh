#!/bin/bash

set -ex

usage() {
   echo "Usage: start.sh -m (migrate) -c (collectstatic) -w (wait for db) -s (startup supervisor)"
   exit 0
}

while getopts "hwmsc?:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    w)  WAIT=true
        ;;
    m)  MIGRATE=true
        ;;
    c)  COLLECT=true
        ;;
    s)  STARTUP=true
        ;;
    esac
done

# Wait for the db service to be ready before continuing
if [ "$WAIT" = "true" ]; then
  echo "waiting for db..."

  while ! timeout 2 bash -c "</dev/tcp/db/5432" 2>/dev/null;
  do
    echo -n .
    sleep 1
  done
fi

echo "db ready"

if [ "$MIGRATE" = "true" ]; then
  venv/bin/python3 manage.py migrate --noinput
fi

if [ "$COLLECT" = "true" ]; then
  venv/bin/python3 manage.py collectstatic --noinput
fi

if [ "$STARTUP" = "true" ]; then
  /usr/bin/supervisord -n -c /etc/supervisord.conf
fi

exit 0
