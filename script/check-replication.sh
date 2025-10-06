#!/bin/bash
# Check replication status

echo "=== PRIMARY STATUS ==="
docker exec postgres_primary psql -U postgres -c "SELECT * FROM pg_stat_replication;"

echo -e "\n=== STANDBY-1 STATUS ==="
docker exec postgres_replica_1 psql -U postgres -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp();"

echo -e "\n=== STANDBY-2 STATUS ==="
docker exec postgres_replica_2 psql -U postgres -c "SELECT pg_is_in_recovery(), pg_last_wal_receive_lsn(), pg_last_wal_replay_lsn(), pg_last_xact_replay_timestamp();"

echo -e "\n=== REPLICATION LAG ==="
docker exec postgres_primary psql -U postgres -c "SELECT client_addr, state, sent_lsn, write_lsn, flush_lsn, replay_lsn, sync_state FROM pg_stat_replication;"


# sleep 100