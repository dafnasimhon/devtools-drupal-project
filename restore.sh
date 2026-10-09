#!/bin/bash

BACKUP_FILE="my-drupal.backup.sql.gz"

echo "Starting Drupal database restore..."

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^drupal-db$'; then
    echo "MySQL container drupal-db is not running."
    exit 1
fi

echo "Waiting for MySQL to be ready..."
until docker exec drupal-db mysqladmin ping -uroot -pmy-secret-pw --silent >/dev/null 2>&1; do
    sleep 2
done

echo "Restoring database..."

gunzip -c "$BACKUP_FILE" | \
docker exec -i drupal-db mysql -uroot -pmy-secret-pw

if [ $? -eq 0 ]; then
    echo "Database restored successfully."
    docker restart drupal-app >/dev/null
    echo "Drupal restarted."
    echo "Open: http://localhost:8080"
else
    echo "Restore failed."
    exit 1
fi
