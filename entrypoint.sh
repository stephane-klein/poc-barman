#!/bin/bash

set -e

BARMAN_POSTGRES_HOST=${BARMAN_POSTGRES_HOST:-postgres}
BARMAN_POSTGRES_PORT=${BARMAN_POSTGRES_PORT}
BARMAN_POSTGRES_DB=${BARMAN_POSTGRES_DB:-postgres}
BARMAN_POSTGRES_USER=${BARMAN_POSTGRES_USER:-barman}
BARMAN_POSTGRES_STREAMING_USER=${BARMAN_POSTGRES_STREAMING_USER:-streaming_barman}
BARMAN_POSTGRES_PASSWORD=${BARMAN_POSTGRES_PASSWORD:-password}

cat <<EOF > ~/.pgpass
${BARMAN_POSTGRES_HOST}:${BARMAN_POSTGRES_PORT}:${BARMAN_POSTGRES_DB}:${BARMAN_POSTGRES_USER}:${BARMAN_POSTGRES_PASSWORD}
EOF

# See https://docs.pgbarman.org/release/3.12.1/user_guide/quickstart.html#:~:text=4.-,now%20let%E2%80%99s%20configure%20your%20first%20backup%20server%20on%20barman,-.%20On%20barmanhost%2C%20create%20a%0Afile
cat <<EOF > /etc/barman.d/streaming-backup-server.conf
[streaming-server]
description =  "Postgres server using streaming replication"
streaming_archiver = on
backup_method = postgres
streaming_conninfo = host=${BARMAN_POSTGRES_HOST} user=${BARMAN_POSTGRES_STREAMING_USER}
slot_name = barman
create_slot = auto
conninfo = host=${BARMAN_POSTGRES_HOST} user=${BARMAN_POSTGRES_USER} dbname=${BARMAN_POSTGRES_DB}
EOF


if [ -n "$1" ]; then
    exec "$@"
    exit 0
fi

sleep infinity
