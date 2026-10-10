#!/usr/bin/env bash
set -Eeuo pipefail

DB_CONTAINER="${DB_CONTAINER:-drupal-db}"
DRUPAL_CONTAINER="${DRUPAL_CONTAINER:-drupal-app}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-my-secret-pw}"
MYSQL_DATABASE="${MYSQL_DATABASE:-drupal}"
MYSQL_USER="${MYSQL_USER:-drupaluser}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-drupalpass}"
BACKUP_FILE="${BACKUP_FILE:-my-drupal.backup.sql.gz}"
FILES_BACKUP="${FILES_BACKUP:-drupal-files.backup.tar.gz}"

echo "Starting Drupal restore..."

if [ ! -f "$BACKUP_FILE" ]; then
  echo "Backup file not found: $BACKUP_FILE"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -qx "$DB_CONTAINER"; then
  echo "MySQL container '$DB_CONTAINER' is not running."
  echo "Run ./setup.sh first, wait for the containers to start, and then run ./restore.sh."
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -qx "$DRUPAL_CONTAINER"; then
  echo "Drupal container '$DRUPAL_CONTAINER' is not running."
  echo "Run ./setup.sh first, wait for the containers to start, and then run ./restore.sh."
  exit 1
fi

echo "Waiting for MySQL to be ready..."
until docker exec "$DB_CONTAINER" mysqladmin ping -uroot -p"$MYSQL_ROOT_PASSWORD" --silent >/dev/null 2>&1; do
  sleep 2
done

echo "Restoring MySQL backup from $BACKUP_FILE..."
gunzip -c "$BACKUP_FILE" | docker exec -i "$DB_CONTAINER" mysql -uroot -p"$MYSQL_ROOT_PASSWORD" --force

echo "Configuring Drupal database connection..."
docker exec "$DRUPAL_CONTAINER" sh -c '
set -eu
settings_file="/var/www/html/sites/default/settings.php"
default_settings="/var/www/html/sites/default/default.settings.php"

if [ ! -f "$settings_file" ]; then
  cp "$default_settings" "$settings_file"
fi

chmod u+w "$settings_file"

if grep -q "// DevTools project database settings" "$settings_file"; then
  sed -i "/\/\/ DevTools project database settings/,\$d" "$settings_file"
fi

mkdir -p /var/www/html/sites/default/files
chown -R www-data:www-data /var/www/html/sites/default/files
'

cat <<'PHP_SETTINGS' | docker exec -i "$DRUPAL_CONTAINER" sh -c 'cat >> /var/www/html/sites/default/settings.php'

// DevTools project database settings
$databases['default']['default'] = [
  'database' => 'drupal',
  'username' => 'drupaluser',
  'password' => 'drupalpass',
  'prefix' => '',
  'host' => 'drupal-db',
  'port' => '3306',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'driver' => 'mysql',
];

$settings['hash_salt'] = 'devtools-drupal-project-restore-hash-salt';
$settings['trusted_host_patterns'] = [
  '^localhost$',
  '^127\\.0\\.0\\.1$',
];
PHP_SETTINGS

docker exec "$DRUPAL_CONTAINER" sh -c '
set -eu
settings_file="/var/www/html/sites/default/settings.php"
chown www-data:www-data "$settings_file"
chmod 664 "$settings_file"
'

if [ -f "$FILES_BACKUP" ]; then
  echo "Restoring Drupal files from $FILES_BACKUP..."
  cat "$FILES_BACKUP" | docker exec -i "$DRUPAL_CONTAINER" tar -xzf - -C /var/www/html/sites/default
  docker exec "$DRUPAL_CONTAINER" chown -R www-data:www-data /var/www/html/sites/default/files
else
  echo "No Drupal files backup found; continuing with database restore only."
fi

echo "Restarting Drupal..."
docker restart "$DRUPAL_CONTAINER" >/dev/null

echo "Restore completed successfully."
echo "Open Drupal at: http://localhost:8080"
