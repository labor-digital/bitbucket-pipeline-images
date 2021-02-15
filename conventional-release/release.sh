#!/bin/bash

# Prepare environment variables
echo "Checking environment variables..."
RELEASE_DIR=${RELEASE_DIR:-$BITBUCKET_CLONE_DIR}
GIT_PUSH_BACK_OAUTH_ID=${GIT_PUSH_BACK_OAUTH_ID:-$BITBUCKET_DEFAULT_OAUTH_ID}
GIT_PUSH_BACK_OAUTH_SECRET=${GIT_PUSH_BACK_OAUTH_SECRET:-$BITBUCKET_DEFAULT_OAUTH_SECRET}
GIT_PUSH_BACK_REPO_OWNER=${GIT_PUSH_BACK_REPO_OWNER:-$BITBUCKET_REPO_OWNER}
GIT_PUSH_BACK_REPO_SLUG=${GIT_PUSH_BACK_REPO_SLUG:-$BITBUCKET_REPO_SLUG}

# Configure git to push back to the repository
echo "Requesting oAuth token..."
export access_token=$(curl -s -X POST -u "${GIT_PUSH_BACK_OAUTH_ID}:${GIT_PUSH_BACK_OAUTH_SECRET}" \
	https://bitbucket.org/site/oauth2/access_token \
	-d grant_type=client_credentials -d scopes="repository"| jq --raw-output '.access_token')

# Configure git to use the oauth token.
git remote set-url origin "https://x-token-auth:${access_token}@bitbucket.org/${GIT_PUSH_BACK_REPO_OWNER}/${GIT_PUSH_BACK_REPO_SLUG}"

# Switch directory
cd $RELEASE_DIR

# This command can fail with "fatal: --unshallow on a complete repository does not make sense"
# if there are not enough commits in the Git repository.
# For this reason errors are ignored with "|| git fetch --tags --force"
git fetch --unshallow --tags --force || git fetch --tags --force

# Call the release script
echo "Starting release command..."
lcar release "$@"
if [ $? -eq 0 ]; then
    echo OK
else
    exit 1
fi
