FROM debian:12.9

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates wget gnupg2 \
    && rm -rf /var/lib/apt/lists/*

RUN bash -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" >> /etc/apt/sources.list.d/pgdg.list' \
    && (wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -) \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        postgresql-client-17 \
        barman \
        barman-cli \
        barman-cli-cloud \
        gosu \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
