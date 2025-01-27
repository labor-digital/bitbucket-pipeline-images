#!/bin/bash

# Prepare environment variables
echo "Checking environment variables..."
RELEASE_DIR=${RELEASE_DIR:-$BITBUCKET_CLONE_DIR}
GIT_PUSH_BACK_REPO_OWNER=${GIT_PUSH_BACK_REPO_OWNER:-$BITBUCKET_REPO_OWNER}
GIT_PUSH_BACK_REPO_SLUG=${GIT_PUSH_BACK_REPO_SLUG:-$BITBUCKET_REPO_SLUG}

cd $RELEASE_DIR

# This command can fail with "fatal: --unshallow on a complete repository does not make sense"
# if there are not enough commits in the Git repository.
# For this reason errors are ignored with "|| git fetch --tags --force"
git fetch --unshallow --tags --force || git fetch --tags --force

echo "Starting release command..."
node /opt/conventional-release/index.js "$@"
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi
