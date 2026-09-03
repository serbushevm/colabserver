FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PGDATA=/var/lib/postgresql/data \
    PATH=/usr/lib/postgresql/18/bin:$PATH

RUN apt-get update && apt-get install -y --no-install-recommends \
      bzip2 ca-certificates locales \
    && rm -rf /var/lib/apt/lists/*

# Use the PostgreSQL 18 build supplied with the project.
COPY dist/postgresql_18.tar.bz2 /tmp/postgresql.tar.bz2
RUN mkdir /tmp/postgresql \
    && tar -xjf /tmp/postgresql.tar.bz2 -C /tmp/postgresql \
    && apt-get update \
    && apt-get install -y /tmp/postgresql/*.deb \
    && rm -rf /tmp/postgresql /tmp/postgresql.tar.bz2 /var/lib/apt/lists/*

COPY pg/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh \
    && mkdir -p "$PGDATA" \
    && chown postgres:postgres "$PGDATA"

VOLUME ["/var/lib/postgresql/data"]
EXPOSE 5432
ENTRYPOINT ["docker-entrypoint.sh"]
