#!/bin/bash

# Perpare variables
TEST_ROOT_DIR=${TEST_ROOT_DIR:-$BITBUCKET_CLONE_DIR}

# Install the dependencies and call the action
cd /app
echo "Running test..."
npm run test
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi