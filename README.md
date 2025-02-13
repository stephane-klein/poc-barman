# POC barman

## Prerequisites

- [mise](https://mise.jdx.dev/()
- [Docker Engine](https://docs.docker.com/engine/) (tested with `24.0.6`)
- [pgcli](https://www.pgcli.com/)
- `psql` (More info about `psql` [brew package](https://stackoverflow.com/a/49689589/261061))

## Services versions

- PostgreSQL 17
- [barman 3.12.1](https://github.com/EnterpriseDB/barman/releases/tag/release/3.12.1)

## Environment preparation

```sh
$ mise install
$ docker compose build
```

## Start or restart the playground test scenario

You can execute this test scenario manually or automatically by executing `./scripts/reset.sh`:

```sh
$ docker compose down -v
$ docker compose up -d postgres1 barman --wait
```

```sh
$ ./scripts/seed.sh
$ ./scripts/generate_dummy_rows.sh
```

Direct *barman* interaction:

```sh
$ ./scripts/enter-in-barman.sh
barman@5482aa5f8420:/$ barman switch-wal
barman@5482aa5f8420:/$ barman cron
barman@eaba483d9b3b:/$ barman check streaming-server
Server streaming-server:
        PostgreSQL: OK
        superuser or standard user with backup privileges: OK
        PostgreSQL streaming: OK
        wal_level: OK
        replication slot: OK
        directories: OK
        retention policy settings: OK
        backup maximum age: OK (no last_backup_maximum_age provided)
        backup minimum size: OK (0 B)
        wal maximum age: OK (no last_wal_maximum_age provided)
        wal size: OK (0 B)
        compression settings: OK
        failed backups: OK (there are 0 failed backups)
        minimum redundancy requirements: OK (have 0 backups, expected at least 0)
        pg_basebackup: OK
        pg_basebackup compatible: OK
        pg_basebackup supports tablespaces mapping: OK
        systemid coherence: OK (no system Id stored on disk)
        pg_receivexlog: OK
        pg_receivexlog compatible: OK
        receive-wal running: OK
        archiver errors: OK
barman@5482aa5f8420:/$ ls /var/lib/barman/streaming-server/streaming/
000000010000000000000001.partial

barman@5482aa5f8420:/$ barman backup streaming-server --immediate-checkpoint
barman@e54940fb8371:/$ ls /var/lib/barman/streaming-server//base/ -lha
total 8.0K
drwxr-xr-x 1 barman barman 60 Feb 13 10:00 .
drwxr-xr-x 1 barman barman 88 Feb 13 09:59 ..
drwxr-xr-x 1 barman barman 30 Feb 13 09:59 20250213T095917

```

## Teardown

```sh
$ docker compose down -v
```
