#!/usr/bin/env bash
set -Eeuo pipefail

DB_CONTAINER="${DB_CONTAINER:-drupal-db}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-my-secret-pw}"
BACKUP_FILE="${BACKUP_FILE:-my-drupal.backup.sql.gz}"
DRUPAL_CONTAINER="${DRUPAL_CONTAINER:-drupal-app}"
FILES_BACKUP="${FILES_BACKUP:-drupal-files.backup.tar.gz}"

echo "Starting Drupal database backup..."

if ! docker ps --format '{{.Names}}' | grep -qx "$DB_CONTAINER"; then
  echo "MySQL container '$DB_CONTAINER' is not running."
  echo "Run ./setup.sh first, or set DB_CONTAINER to the correct container name."
  exit 1
fi

echo "Waiting for MySQL to be ready..."
until docker exec "$DB_CONTAINER" mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 2
done

tmp_backup="${BACKUP_FILE}.tmp"
rm -f "$tmp_backup"

docker exec -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" "$DB_CONTAINER" sh -c 'exec mysqldump --all-databases --single-transaction --quick --add-drop-database -uroot -p"$MYSQL_ROOT_PASSWORD"' \
  | gzip -c > "$tmp_backup"

mv "$tmp_backup" "$BACKUP_FILE"

echo "Database backup completed successfully: $BACKUP_FILE"

if docker ps --format '{{.Names}}' | grep -qx "$DRUPAL_CONTAINER"; then
  echo "Backing up Drupal public files directory if it exists..."
  if docker exec "$DRUPAL_CONTAINER" test -d /var/www/html/sites/default/files; then
    docker exec "$DRUPAL_CONTAINER" tar -czf - -C /var/www/html/sites/default files > "$FILES_BACKUP"
    echo "Drupal files backup completed successfully: $FILES_BACKUP"
  else
    echo "Drupal files directory was not found; skipping files backup."
  fi
else
  echo "Drupal container '$DRUPAL_CONTAINER' is not running; skipping files backup."
fi

echo "Backup finished."
