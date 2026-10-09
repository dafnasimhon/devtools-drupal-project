#!/bin/bash

echo "Creating Docker network..."
docker network create drupal-network 2>/dev/null || true

echo "Starting MySQL container..."
docker run -d \
  --name drupal-db \
  --network drupal-network \
  -e MYSQL_ROOT_PASSWORD=my-secret-pw \
  -e MYSQL_DATABASE=drupal \
  -e MYSQL_USER=drupaluser \
  -e MYSQL_PASSWORD=drupalpass \
  -p 3306:3306 \
  mysql:latest

echo "Starting Drupal container..."
docker run -d \
  --name drupal-app \
  --network drupal-network \
  -p 8080:80 \
  drupal:latest

echo "Setup complete."
echo "Open Drupal at: http://localhost:8080"

