#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

export PGPASSWORD=password
psql -n -q -d postgres -h localhost -p 5432 -U postgres -c "select insert_dummy_records(10); select * from dummy order by id desc limit 1"
