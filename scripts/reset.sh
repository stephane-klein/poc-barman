#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose down -v
docker compose up -d postgres1 barman --wait

./scripts/seed.sh
./scripts/generate_dummy_rows_in_postgres1.sh

set +e
echo "Execute barman check until all checks pass..."

while true; do
    echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] Running barman checks..."
    docker compose exec barman gosu barman barman switch-wal postgres1
    docker compose exec barman gosu barman barman cron
    
    # Capture the output of barman check all
    if ! output=$(docker compose exec barman gosu barman barman check postgres1 2>&1); then
        echo "An error occurred during check"
    fi
    
    echo "$output"
    
    # Check if "FAILED" is present in the output
    if ! echo "$output" | grep -q "FAILED"; then
        echo -e "\n✅ All checks passed successfully!"
        break
    fi
    
    sleep 4
done

echo "Execute: ls -lha /var/lib/barman/postgres1/streaming/"
docker compose exec barman ls -lha /var/lib/barman/postgres1/streaming/

echo "Execute: barman backup postgres1 --immediate-checkpoint"
docker compose exec barman gosu barman barman backup postgres1 --immediate-checkpoint

echo "Execute: ls /var/lib/barman/postgres1/base/ -lha"
docker compose exec barman ls /var/lib/barman/postgres1/base/ -lha

echo "Execute: barman list-backups postgres1"
docker compose exec barman gosu barman barman list-backups postgres1

docker compose exec barman gosu barman barman show-backup postgres1 last

docker compose exec barman sh -c "chown -R barman:barman /var/lib/postgres2/data/; barman restore postgres1 last /var/lib/postgres2/data/; chown -R 999:999 /var/lib/postgres2/data/"

docker compose up postgres2 --wait

./scripts/postgres2-display-dummy-rows.sh

docker compose down postgres2

./scripts/generate_dummy_rows_in_postgres1.sh

sleep 2

docker compose exec barman gosu barman barman switch-wal postgres1
docker compose exec barman gosu barman barman cron
docker compose exec barman gosu barman barman backup postgres1 --immediate-checkpoint --incremental last

docker compose exec barman sh -c "rm -rf /var/lib/postgres2/data/*; rm -rf /var/lib/postgres2/data/.* 2>/dev/null; chown -R barman:barman /var/lib/postgres2/data/; barman restore postgres1 last /var/lib/postgres2/data/ --no-get-wal --recovery-staging-path=/var/lib/barman/tmp/; chown -R 999:999 /var/lib/postgres2/data/; ls -lha /var/lib/postgres2/data/"
#
docker compose up postgres2 # <== error here

# ./scripts/postgres2-display-dummy-rows.sh

