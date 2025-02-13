#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

docker compose down -v
docker compose up -d postgres1 barman --wait

./scripts/seed.sh
./scripts/generate_dummy_rows.sh

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

BACKUP_ID=$(docker compose exec barman gosu barman barman list-backups postgres1 --minimal 2>/dev/null | head -n1)

docker compose exec barman gosu barman barman show-backup postgres1 $BACKUP_ID
