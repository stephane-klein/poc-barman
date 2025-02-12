#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

export PGPASSWORD=password
psql -n -q -d postgres -h localhost -p 5432 -U postgres -f sqls/seed.sql
