#!/bin/sh
set -eu

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  chown -R postgres:postgres "$PGDATA"
  password_file=$(mktemp)
  printf '%s' "$POSTGRES_PASSWORD" > "$password_file"
  su postgres -s /bin/sh -c "initdb -D '$PGDATA' --username=db_user --pwfile='$password_file'"
  rm -f "$password_file"
  su postgres -s /bin/sh -c "pg_ctl -D '$PGDATA' -o '-c listen_addresses=localhost' -w start"
  su postgres -s /bin/sh -c "createdb -O db_user cs_db"
  su postgres -s /bin/sh -c "psql -d cs_db -c 'CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";'"
  su postgres -s /bin/sh -c "pg_ctl -D '$PGDATA' -m fast -w stop"
fi

exec su postgres -s /bin/sh -c "exec postgres -D '$PGDATA' -c listen_addresses='*'"
