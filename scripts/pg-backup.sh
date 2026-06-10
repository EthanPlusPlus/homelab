#!/usr/bin/env bash
# Nightly logical backup of the Prismo operational PostgreSQL instance.
# Decision 037 consequence — messages/sessions/canon-index are organizational
# memory; canon is in git, the operational DB needs its own dump.
#
# Cron: 17 2 * * *  (daily 02:17, off the :00 herd)
# Retention: 14 days. Restore: gunzip -c <file> | docker exec -i context-server-postgres-1 psql -U prismo prismo
set -euo pipefail

BACKUP_DIR="${PRISMO_BACKUP_DIR:-$HOME/backups/postgres}"
CONTAINER="context-server-postgres-1"
KEEP_DAYS=14

mkdir -p "$BACKUP_DIR"
STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$BACKUP_DIR/prismo-$STAMP.sql.gz"

docker exec "$CONTAINER" pg_dump -U prismo prismo | gzip > "$OUT"

# Sanity: a real dump is never tiny
if [ "$(stat -c%s "$OUT")" -lt 10000 ]; then
    echo "backup suspiciously small: $OUT" >&2
    exit 1
fi

find "$BACKUP_DIR" -name "prismo-*.sql.gz" -mtime +"$KEEP_DAYS" -delete
echo "ok: $OUT ($(du -h "$OUT" | cut -f1))"
