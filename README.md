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
barman@eaba483d9b3b:/$ barman check postgres1
Server postgres1:
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
barman@5482aa5f8420:/$ ls /var/lib/barman/postgres1/streaming/
000000010000000000000001.partial

barman@5482aa5f8420:/$ barman backup postgres1 --immediate-checkpoint
Starting backup using postgres method for server postgres1 in /var/lib/barman/postgres1/base/20250213T100353
Backup start at LSN: 0/4000000 (000000010000000000000004, 00000000)
Starting backup copy via pg_basebackup for 20250213T100353
Copy done (time: 1 second)
Finalising the backup.
This is the first backup for server postgres1
WAL segments preceding the current backup have been found:
        000000010000000000000002 from server postgres1 has been removed
Backup size: 22.3 MiB
Backup end at LSN: 0/6000000 (000000010000000000000006, 00000000)
Backup completed (start time: 2025-02-13 10:03:53.072228, elapsed time: 1 second)
Processing xlog segments from streaming for postgres1
        000000010000000000000003
        000000010000000000000004
WARNING: IMPORTANT: this backup is classified as WAITING_FOR_WALS, meaning that Barman has not received yet all the required WAL files for the backup consistency.
This is a common behaviour in concurrent backup scenarios, and Barman automatically set the backup as DONE once all the required WAL files have been archived.
Hint: execute the backup command with '--wait'
total 4.0K
barman@e54940fb8371:/$ ls /var/lib/barman/postgres1/base/ -lha
total 8.0K
drwxr-xr-x 1 barman barman 60 Feb 13 10:00 .
drwxr-xr-x 1 barman barman 88 Feb 13 09:59 ..
drwxr-xr-x 1 barman barman 30 Feb 13 09:59 20250213T095917

barman@5ca8384b0def:/$ barman list-backups postgres1
postgres1 20250213T103723 - F - Thu Feb 13 10:37:24 2025 - Size: 22.3 MiB - WAL Size: 0 B - WAITING_FOR_WALS

barman@5ca8384b0def:/$ barman show-backup postgres1 20250213T103723
Backup 20250213T103723:
  Server Name            : postgres1
  System Id              : 7470850836021661734
  Status                 : WAITING_FOR_WALS
  PostgreSQL Version     : 170002
  PGDATA directory       : /var/lib/postgresql/data
  Estimated Cluster Size : 22.3 MiB

  Server information:
    Checksums            : off
    WAL summarizer       : on

  Base backup information:
    Backup Method        : postgres
    Backup Type          : full
    Backup Size          : 22.3 MiB
    Timeline             : 1
    Begin WAL            : 000000010000000000000005
    End WAL              : 000000010000000000000006
    Begin time           : 2025-02-13 10:37:23.292254+00:00
    End time             : 2025-02-13 10:37:24.799652+00:00
    Copy time            : 1 second
    Estimated throughput : 14.9 MiB/s
    Begin Offset         : 216
    End Offset           : 0
    Begin LSN            : 0/50000D8
    End LSN              : 0/6000000

  WAL information:
    No of files          : 0
    Disk usage           : 0 B
    Last available       : None

  Catalog information:
    Retention Policy     : not enforced
    Previous Backup      : - (this is the oldest base backup)
    Next Backup          : - (this is the latest base backup)
```

## Teardown

```sh
$ docker compose down -v
```
