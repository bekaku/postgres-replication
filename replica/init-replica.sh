#!/bin/bash
set -e

PGDATA="/var/lib/postgresql/data"

# Ensure logging directory exists
mkdir -p /var/log/postgresql
chown -R postgres:postgres /var/log/postgresql

echo "[Replica] Waiting for primary at $PRIMARY_HOST:$PRIMARY_PORT..."

# Wait for primary
until pg_isready -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" -U "$REPL_USER" >/dev/null 2>&1; do
  echo "[Replica] Waiting for primary..."
  sleep 3
done

# Only initialize if directory is empty
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "[Replica] Empty data directory, running base backup..."
  rm -rf "$PGDATA"/*

  PGPASSWORD="$REPL_PASSWORD" pg_basebackup \
    -h "$PRIMARY_HOST" -p "$PRIMARY_PORT" \
    -D "$PGDATA" -U "$REPL_USER" -Fp -Xs -P -R

  # echo "hot_standby = on" >> "$PGDATA/postgresql.conf"
fi

echo "[Replica] Starting PostgreSQL..."
# exec docker-entrypoint.sh postgres -c config_file=/etc/postgresql/postgresql.conf
exec docker-entrypoint.sh postgres \
     -c config_file=/etc/postgresql/postgresql.conf \
     -c hba_file=/etc/postgresql/pg_hba.conf
