# POC barman

## Prerequisites

- [mise](https://mise.jdx.dev/()
- [Docker Engine](https://docs.docker.com/engine/) (tested with `24.0.6`)
- [pgcli](https://www.pgcli.com/)
- `psql` (More info about `psql` [brew package](https://stackoverflow.com/a/49689589/261061))

## Services versions

- PostgreSQL 17
- [barman 3.12.1](https://github.com/EnterpriseDB/barman/releases/tag/release/3.12.1)

## Getting start

```sh
$ mise install
```

I start PostgreSQL database and barman services:

```sh
$ docker compose up -d postgres1 barman --wait
```

```sh
$ ./scripts/seed.sh
$ ./scripts/generate_dummy_rows.sh
```

```sh
$ docker compose exec barman bash
root@5482aa5f8420:/# su barman
barman@5482aa5f8420:/$ barman check streaming-server
Server streaming-server:
        WAL archive: FAILED (please make sure WAL shipping is setup)
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
```

## Teardown

```sh
$ docker compose down -v
```
