# POC barman

## Prerequisites

- [mise]https://mise.jdx.dev/()
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

I start Minio service:

```sh
$ docker compose up -d minio --wait
```

I create the S3 bucket in Minio:

```sh
$ mc mb barman/barman
Bucket created successfully `barman/`.
$ mc ls barman/
[2023-12-31 15:19:25 CET]     0B barman/
```

I start PostgreSQL database service:

```sh
$ docker compose up -d postgres1 --wait
```

I check that the PostreSQL and Minio services are running correctly:

```sh
$ docker compose ps --services --status running
minio
postgres1
```

## Teardown

```sh
$ docker compose down -v
```
