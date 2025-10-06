#!/bin/bash
# Promote standby to primary

STANDBY_CONTAINER=${1:-postgres_replica_1}

echo "Promoting $STANDBY_CONTAINER to primary..."
docker exec $STANDBY_CONTAINER pg_ctl promote -D /var/lib/postgresql/data

echo "Waiting for promotion to complete..."
sleep 5

echo "Checking new primary status..."
docker exec $STANDBY_CONTAINER psql -U postgres -c "SELECT pg_is_in_recovery();"

echo "Promotion complete! Remember to reconfigure your application to point to the new primary."