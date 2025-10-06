#!/bin/bash
set -e

echo "[Primary] Creating replication user..."
# Create replication user and configure replication settings
psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
  CREATE ROLE ${REPL_USER} WITH REPLICATION LOGIN PASSWORD '${REPL_PASSWORD}';
EOSQL

# Adjust PostgreSQL configuration for replication
# cat >> ${PGDATA}/postgresql.conf <<EOF
# # Replication settings
# wal_level = replica
# max_wal_senders = 10
# max_replication_slots = 10
# # hot_standby = on
# wal_keep_size = 256MB

# # Connection
# listen_addresses = '*'
# max_connections = 200
# max_prepared_transactions = 100


# # Memory
# shared_buffers = 1GB
# work_mem = 4MB
# maintenance_work_mem = 64MB

# # WAL / checkpoints
# wal_buffers = 16MB
# checkpoint_timeout = 10min
# max_wal_size = 1GB
# min_wal_size = 80MB

# # Autovacuum
# autovacuum = on
# autovacuum_naptime = 1min

# # Stats & extensions
# track_activity_query_size = 16384
# shared_preload_libraries = 'pg_stat_statements'

# # Logging
# logging_collector = on
# log_directory = '/var/log/postgresql'
# log_filename = 'postgresql-%Y-%m-%d.log'
# log_statement = none
# log_duration = off
# log_min_duration_statement = -1

# # Timezone
# timezone = 'Asia/Bangkok'

# EOF

# Allow replica connection
# cat >> ${PGDATA}/pg_hba.conf <<EOF
# host replication ${REPL_USER} 0.0.0.0/0 md5
# EOF

echo "[Primary] Replication setup complete."