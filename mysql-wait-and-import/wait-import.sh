#!/bin/bash

# Perpare variables
MYSQL_HOST=${MYSQL_HOST:-"localhost"}
MYSQL_DATABASE=${MYSQL_DATABASE:-"test"}
MYSQL_USER=${MYSQL_USER:-"test"}
MYSQL_PASS=${MYSQL_PASS:-"test"}
MYSQL_IMPORT_FILE_PATH=${MYSQL_IMPORT_FILE_PATH:-"./tests/test-data/dump.sql"}

echo ">> Waiting for mysql to start"
while ! nc -z $MYSQL_HOST 3306; do
  sleep 3
done

mysql --host="${MYSQL_HOST}" --user="${MYSQL_USER}" --password="${MYSQL_PASS}" -f "${MYSQL_DATABASE}" < ${MYSQL_IMPORT_FILE_PATH}