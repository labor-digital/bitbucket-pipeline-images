#!/bin/bash

# Prepare environment variables
echo "Checking environment variables..."
RELEASE_DIR=${RELEASE_DIR:-$BITBUCKET_CLONE_DIR}
GIT_PUSH_BACK_OAUTH_ID=${GIT_PUSH_BACK_OAUTH_ID:-$BITBUCKET_DEFAULT_OAUTH_ID}
GIT_PUSH_BACK_OAUTH_SECRET=${GIT_PUSH_BACK_OAUTH_SECRET:-$BITBUCKET_DEFAULT_OAUTH_SECRET}
GIT_PUSH_BACK_USER=${GIT_PUSH_BACK_USER:-$BITBUCKET_DEFAULT_BOT_USER}
GIT_PUSH_BACK_PASS=${GIT_PUSH_BACK_PASS:-$BITBUCKET_DEFAULT_BOT_PASS}
GIT_PUSH_BACK_USER_NAME=${GIT_PUSH_BACK_USER_NAME:-$BITBUCKET_DEFAULT_BOT_USER_NAME}
GIT_PUSH_BACK_USER_EMAIL=${GIT_PUSH_BACK_USER_EMAIL:-$BITBUCKET_DEFAULT_BOT_USER_EMAIL}
GIT_PUSH_BACK_REPO_OWNER=${GIT_PUSH_BACK_REPO_OWNER:-$BITBUCKET_REPO_OWNER}
GIT_PUSH_BACK_REPO_SLUG=${GIT_PUSH_BACK_REPO_SLUG:-$BITBUCKET_REPO_SLUG}
NPM_REGISTRY_URL=${NPM_REGISTRY_URL:-$NPM_DEFAULT_REGISTRY_URL}
NPM_REGISTRY_USER=${NPM_REGISTRY_USER:-$NPM_DEFAULT_REGISTRY_USER}
NPM_REGISTRY_PW=${NPM_REGISTRY_PW:-$NPM_DEFAULT_REGISTRY_PW}
NPM_REGISTRY_EMAIL=${NPM_REGISTRY_EMAIL:-$NPM_DEFAULT_REGISTRY_EMAIL}

if [ "$NPM_REGISTRY_URL" != "" ]; then
  echo "Logging into registry..."
  npm set registry "https://$NPM_REGISTRY_URL"
  npm-cli-login -u "$NPM_REGISTRY_USER" -p "$NPM_REGISTRY_PW" -r "https://$NPM_REGISTRY_URL" -e "$NPM_REGISTRY_EMAIL" --quotes --config-path=/root/.npmrc
fi

if [ "$GIT_PUSH_BACK_PASS" == "" ]; then
  echo "Requesting oAuth token..."
  GIT_PUSH_BACK_USER="x-token-auth"
  GIT_PUSH_BACK_PASS=$(curl -s -X POST -u "${GIT_PUSH_BACK_OAUTH_ID}:${GIT_PUSH_BACK_OAUTH_SECRET}" \
    https://bitbucket.org/site/oauth2/access_token \
    -d grant_type=client_credentials -d scopes="repository"| jq --raw-output '.access_token')
fi
git remote set-url origin "https://${GIT_PUSH_BACK_USER}:${GIT_PUSH_BACK_PASS}@bitbucket.org/${GIT_PUSH_BACK_REPO_OWNER}/${GIT_PUSH_BACK_REPO_SLUG}"

if [ "$GIT_PUSH_BACK_USER_NAME" != "" ] && [ "$GIT_PUSH_BACK_USER_EMAIL" != "" ]; then
  git config user.name "$GIT_PUSH_BACK_USER_NAME"
  git config user.email "$GIT_PUSH_BACK_USER_EMAIL"
fi

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
