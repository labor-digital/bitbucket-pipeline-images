#!/bin/bash

# Perpare variables
NODE_WORKING_DIR=${NODE_WORKING_DIR:-$BITBUCKET_CLONE_DIR}

# Install the dependencies and call the action
cd $NODE_WORKING_DIR
echo "Running npm install in: $NODE_WORKING_DIR"
npm install --no-audit
if [ $? -eq 0 ]; then
    echo Install OK
else
    exit 1
fi

echo "Running npm script..."
npm run "$@"
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi