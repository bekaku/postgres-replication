#!/bin/bash
# PostgreSQL backup script

BACKUP_DIR="/backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql.gz"

mkdir -p $BACKUP_DIR

# Perform backup
docker exec postgres_primary pg_dumpall -U postgres | gzip > $BACKUP_FILE

# Remove old backups (older than 7 days)
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete

echo "Backup completed: $BACKUP_FILE"