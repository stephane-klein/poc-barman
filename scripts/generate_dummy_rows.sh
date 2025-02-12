#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec -T postgres1 sh -c "cat << EOF | psql -U postgres
select insert_dummy_records(10);
select * from dummy order by id desc limit 1
\q
EOF"
