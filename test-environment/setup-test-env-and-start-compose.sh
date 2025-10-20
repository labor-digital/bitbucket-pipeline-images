#!/bin/bash

echo "Prepare environment variables..."
TEST_ENV_IMAGE_LOAD_PATH=${TEST_ENV_IMAGE_LOAD_PATH:-""}
TEST_ENV_COMPOSE_FILE_PATH=${TEST_ENV_COMPOSE_FILE_PATH:-"./docker-compose.yml"}

if [ "$TEST_ENV_IMAGE_LOAD_PATH" != "" ] && [ -f "$TEST_ENV_IMAGE_LOAD_PATH" ]; then
  echo "Loading image from file..."
  docker load --input $TEST_ENV_IMAGE_LOAD_PATH
fi

echo "Starting the compose"
docker-compose -f "${TEST_ENV_COMPOSE_FILE_PATH}" up -d --wait
docker ps -a