#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T postgres1 sh -c "cat << EOF | psql -U postgres
CREATE USER barman WITH SUPERUSER PASSWORD 'barman';
CREATE USER streaming_barman WITH REPLICATION PASSWORD 'streaming_barman';
\q
EOF"
