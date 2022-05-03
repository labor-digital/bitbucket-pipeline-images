#!/bin/bash

echo "[>] Starting deployment"

echo "  [+] Validating required environment variables"
if [[ -z "$DEPLOY_SSH_HOST" ]]; then
	echo "  [!] Missing the required $DEPLOY_SSH_HOST variable!"
	exit 1
fi

echo "  [+] Prepare environment variables..."
DEPLOY_DOCKER_DIR=${DEPLOY_DOCKER_DIR:-"/02_docker"}
DEPLOY_DOCKER_DIR=${DEPLOY_DOCKER_DIR%/}
DEPLOY_DOCKER_LOGIN_SCRIPT=${DEPLOY_DOCKER_LOGIN_SCRIPT:-"/opt/docker-login.sh"}
DEPLOY_PROJECT_ENV=${DEPLOY_PROJECT_ENV:-"prod"}
DEPLOY_PROJECT_NAME=${DEPLOY_PROJECT_NAME:-"$BITBUCKET_REPO_SLUG-$DEPLOY_PROJECT_ENV"}
DEPLOY_SSH_USER=${DEPLOY_SSH_USER:-"deployment"}
DEPLOY_SSH_PORT=${DEPLOY_SSH_PORT:-"22"}
DEPLOY_SSH_FINGERPRINT=${DEPLOY_SSH_FINGERPRINT:-""}
DEPLOY_SSH_KEY=${DEPLOY_SSH_KEY:-""}
DEPLOY_ADDITIONAL_FILES=${DEPLOY_ADDITIONAL_FILES:-""}
DEPLOY_AFTER_SCRIPT=${DEPLOY_AFTER_SCRIPT:-"echo ''"}
DEPLOY_ARCHIVE_NAME=${DEPLOY_ARCHIVE_NAME:-"deployment-$BITBUCKET_REPO_SLUG-$DEPLOY_PROJECT_NAME.zip"}
DEPLOY_SERVER_ENV_FILE=${DEPLOY_SERVER_ENV_FILE:-""}
DEPLOY_DOPPLER_ENV_TOKEN=${DEPLOY_DOPPLER_ENV_TOKEN:-""}
DEPLOY_DOPPLER_ENV_OPTIONS=${DEPLOY_DOPPLER_ENV_OPTIONS:-""}
DEPLOY_DOCKER_COMPOSE_OPTIONS=${DEPLOY_DOCKER_COMPOSE_OPTIONS:-""}

# Create the .env file
echo "  [+] Creating .env file"
/opt/makeProdEnv.sh $DEPLOY_PROJECT_ENV "$DEPLOY_DOPPLER_ENV_TOKEN" "$DEPLOY_DOPPLER_ENV_OPTIONS"

# Add required files to zip
echo "  [+] Packing zip"
zip "$DEPLOY_ARCHIVE_NAME" .env

if [ -f "docker-compose.$DEPLOY_PROJECT_ENV.yml" ]; then
  rm -rf docker-compose.yml
  cp "docker-compose.$DEPLOY_PROJECT_ENV.yml" docker-compose.yml
fi
if [ -f "docker-compose.yml" ]; then
  zip "$DEPLOY_ARCHIVE_NAME" docker-compose.yml
  else
    echo "  [!] Missing a docker-compose.yml file in the repository!"
    exit 1
fi

# Add additional files to the zip
if [ ! -z "$DEPLOY_ADDITIONAL_FILES" ]; then
  for i in ${DEPLOY_ADDITIONAL_FILES//,/ }
  do
      zip "$DEPLOY_ARCHIVE_NAME" "$i"
      echo "      -> $i"
  done
fi

if [ ! -z "$DEPLOY_SSH_FINGERPRINT" ]; then
  echo "  [+] Will use provided ssh fingerprint..."
  mkdir -p ~/.ssh
  echo $DEPLOY_SSH_FINGERPRINT >> ~/.ssh/known_hosts
fi

SSH_IDENTITY_FILE=""
if [ ! -z "$DEPLOY_SSH_KEY" ]; then
  echo "  [+] Will use provided ssh key (Note: The value MUST be base64 encoded!)..."
  mkdir -p ~/.ssh
  (umask 077 ; echo $DEPLOY_SSH_KEY | base64 --decode > ~/.ssh/id_rsa)
  SSH_IDENTITY_FILE=" -i ~/.ssh/id_rsa "
fi

echo "  [+] Preparing deployment folder ($DEPLOY_SSH_USER) on $DEPLOY_SSH_HOST:$DEPLOY_SSH_PORT"
ssh $SSH_IDENTITY_FILE $DEPLOY_SSH_USER@$DEPLOY_SSH_HOST -p $DEPLOY_SSH_PORT "
  mkdir -p $DEPLOY_DOCKER_DIR
  cd $DEPLOY_DOCKER_DIR
  rm -rf $DEPLOY_PROJECT_NAME
  mkdir -p $DEPLOY_PROJECT_NAME
"
if ! [ "$?" -eq "0" ]; then
	echo "  [!] Failed preparing deployment folder"
	exit 1
fi

echo "  [+] Copy archive to deployment folder"
scp $SSH_IDENTITY_FILE -P $DEPLOY_SSH_PORT "$DEPLOY_ARCHIVE_NAME" $DEPLOY_SSH_USER@$DEPLOY_SSH_HOST:"$DEPLOY_DOCKER_DIR/$DEPLOY_PROJECT_NAME"
if ! [ "$?" -eq "0" ]; then
	echo "  [!] Failed to copy the archive"
	exit 1
fi

DYN_SCRIPT="echo ''"
if [ ! -z "$DEPLOY_SERVER_ENV_FILE" ]; then
  echo "  [+] Will attach contents of $DEPLOY_SERVER_ENV_FILE to $DEPLOY_DOCKER_DIR/$DEPLOY_PROJECT_NAME/.env..."
  DYN_SCRIPT="
cat $DEPLOY_SERVER_ENV_FILE >> $DEPLOY_DOCKER_DIR/$DEPLOY_PROJECT_NAME/.env" || exit 1
fi

if [ ! -z "$DEPLOY_DOCKER_COMPOSE_OPTIONS" ]; then
  echo "  [+] Will use custom docker-compose options: $DEPLOY_DOCKER_COMPOSE_OPTIONS"
  $DEPLOY_DOCKER_COMPOSE_OPTIONS = " $DEPLOY_DOCKER_COMPOSE_OPTIONS"
fi

echo "  [+] Unpacking and pulling deployment"
ssh $SSH_IDENTITY_FILE $DEPLOY_SSH_USER@$DEPLOY_SSH_HOST -p $DEPLOY_SSH_PORT "
  cd $DEPLOY_DOCKER_DIR/$DEPLOY_PROJECT_NAME || exit 1
  unzip $DEPLOY_ARCHIVE_NAME || exit 1
  rm -rf $DEPLOY_ARCHIVE_NAME || exit 1
  ${DYN_SCRIPT}
  (test -x $DEPLOY_DOCKER_LOGIN_SCRIPT && $DEPLOY_DOCKER_LOGIN_SCRIPT)
  docker-compose${DEPLOY_DOCKER_COMPOSE_OPTIONS} pull || exit 1
  docker-compose${DEPLOY_DOCKER_COMPOSE_OPTIONS} up -d || exit 1
  $DEPLOY_AFTER_SCRIPT
"
ECD=$?
if ! [ "$ECD" -eq "0" ]; then
	echo "  [!] Failed to unpack, pull or deploy"
	exit 1
fi

echo "[>] Deployment done."
