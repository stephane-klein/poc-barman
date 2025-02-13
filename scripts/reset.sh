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
    docker compose exec barman gosu barman barman switch-wal all
    docker compose exec barman gosu barman barman cron
    
    # Capture the output of barman check all
    if ! output=$(docker compose exec barman gosu barman barman check all 2>&1); then
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

docker compose exec barman ls -lha /var/lib/barman/streaming-server/streaming/
