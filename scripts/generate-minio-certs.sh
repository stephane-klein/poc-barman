#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

mkdir -p minio/certs/
openssl genrsa -out minio/certs/private.key 2048
openssl req -new -key minio/certs/private.key -out minio/certs/server.csr -subj "/C=FR/ST=Lorraine/L=Metz/O=StephaneKlein/CN=localhost"
openssl x509 -extfile <(printf "subjectAltName=DNS:localhost,DNS:minio") -req -days 365 -in minio/certs/server.csr -signkey minio/certs/private.key -out minio/certs/public.crt
