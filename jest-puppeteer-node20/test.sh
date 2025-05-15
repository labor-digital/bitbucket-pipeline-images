#!/bin/bash

# Prepare variables
TEST_ROOT_DIR=${TEST_ROOT_DIR:-$BITBUCKET_CLONE_DIR}
TEST_BASE_URL=${TEST_BASE_URL:-"https://host.docker.internal"}

# Install hosts if requested
if [ "$TEST_HOST_IP" != "" ] && [ "$TEST_HOST_NAME" != "" ]; then
  echo "${TEST_HOST_IP} ${TEST_HOST_NAME}" >> /etc/hosts
fi
cat /etc/hosts

# Install the dependencies and call the action
cd /app
echo "Running test..."
npm run test
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi