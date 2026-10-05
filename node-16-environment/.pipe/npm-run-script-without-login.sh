#!/bin/bash

# Perpare variables
NODE_WORKING_DIR=${NODE_WORKING_DIR:-$BITBUCKET_CLONE_DIR}
# check if other package manager should be used (yarn)
PACKAGE_MANAGER=${PACKAGE_MANAGER:-npm}

# Install the dependencies and call the action
cd $NODE_WORKING_DIR
echo "Running $PACKAGE_MANAGER install in: $NODE_WORKING_DIR"
$PACKAGE_MANAGER install --no-audit
if [ $? -eq 0 ]; then
    echo Install OK
else
    exit 1
fi

echo "Running npm script..."
$PACKAGE_MANAGER run "$@"
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi