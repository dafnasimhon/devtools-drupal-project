#!/bin/bash

BACKUP_FILE="my-drupal.backup.sql.gz"

echo "Starting Drupal database backup..."

docker exec drupal-db sh -c \
'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' \
| gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup completed successfully."
    echo "Backup file created: $BACKUP_FILE"
else
    echo "Backup failed."
    exit 1
fi
