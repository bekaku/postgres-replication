# PostgreSQL 18 Docker Replication Setup

This repository contains a **production-ready PostgreSQL 18 replication setup** using Docker Compose with **primary and replica nodes**. It includes:

- Streaming replication
- Separate configuration files for primary and replica
- Custom tuning for performance, WAL, autovacuum, logging, and memory
- Easy-to-use initialization scripts

---

## Prerequisites

- Docker >= 24.x  
- Docker Compose >= 2.x  
- At least 2GB RAM for the database (adjust `shared_buffers` in `postgresql.conf` if needed)  

## Setup and Usage

### 1. Clone repository

```bash
git clone https://github.com/bekaku/postgres-replication.git
cd postgres-replication
```

### 2. Start the containers
```bash
docker-compose up -d
```
This will:

1. Start the primary container with PostgreSQL 18.

2. Initialize the replication user using init-primary.sh.

3. Start the replica container, which will:

4. Wait for the primary to be ready

5. Initialize via pg_basebackup if the data directory is empty

6. Start PostgreSQL in hot-standby mode

### 3. Verify replication
```bash
docker logs -f pg_primary
docker logs -f pg_replica
```
- On the replica, you should see:
```bash
[Replica] Waiting for primary at...
[Replica] Empty data directory, running base backup...
[Replica] Starting PostgreSQL...
```

- Connect to the primary:
```bash
docker exec -it pg_primary psql -U postgres -d appdb
```
- Check replication status on the primary:
```bash
SELECT * FROM pg_stat_replication;
```

### 4. Tuning PostgreSQL
- Configuration files are mounted from `primary/postgresql.conf` and `replica/postgresql.conf`.
- To adjust memory, WAL, logging, or autovacuum:
1. Edit the respective `postgresql.conf` file.
2. Restart the container to apply settings:
```bash
docker-compose restart primary
docker-compose restart replica
```

- Some settings (like logging or autovacuum) can be reloaded without a full restart:
```bash
docker exec -it pg_primary pg_ctl reload
docker exec -it pg_replica pg_ctl reload
```

### 5. Logs
- Logs are written to `/var/log/postgresql` inside the container.
- You can mount this directory to the host in `docker-compose.yml` if needed:

```yaml
volumes:
  - pg_primary_logs:/var/log/postgresql
  - pg_replica_logs:/var/log/postgresql
```
### 6. Resetting the setup
To clean the environment and start fresh:
```bash
docker-compose down -v
docker-compose up -d
```
This removes named volumes and reinitializes the primary and replica.
### 7. Notes
- `hot_standby = on` is required only on the replica.

- Primary-only settings (`max_wal_senders`, `wal_keep_size`) can safely be copied to the replica; Postgres ignores them there.

- Ensure replication user credentials (`REPL_USER` and `REPL_PASSWORD`) are consistent between primary and replica.

- You can scale replicas by copying the replica service in `docker-compose.yml` and giving each a unique container name and port.

### 8. Recommended Improvements for Production
- Use Docker secrets for passwords instead of plain environment variables.
- Add health checks to monitor replication lag.
- Configure persistent host volumes for logs and data for better durability.
- Enable monitoring with pg_stat_statements or Prometheus exporters.