#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose exec barman sh -c "su barman"
