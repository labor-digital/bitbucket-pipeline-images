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
DEPLOY_PROJECT_ENV=${DEPLOY_PROJECT_NAME:-"prod"}
DEPLOY_PROJECT_NAME=${DEPLOY_PROJECT_NAME:-"$BITBUCKET_REPO_SLUG-$DEPLOY_PROJECT_ENV"}
DEPLOY_SSH_USER=${DEPLOY_SSH_USER:-"deployment"}
DEPLOY_SSH_PORT=${DEPLOY_SSH_PORT:-"22"}
DEPLOY_ADDITIONAL_FILES=${DEPLOY_ADDITIONAL_FILES:-""}
DEPLOY_AFTER_SCRIPT=${DEPLOY_AFTER_SCRIPT:-"echo ''"}
DEPLOY_ARCHIVE_NAME=${DEPLOY_ARCHIVE_NAME:-"deployment-$BITBUCKET_REPO_SLUG-$DEPLOY_PROJECT_NAME.zip"}

# Create the .env file
echo "  [+] Creating .env file"
/opt/makeProdEnv.sh $DEPLOY_PROJECT_ENV

# Add required files to zip
echo "  [+] Packing zip"
zip "$DEPLOY_ARCHIVE_NAME" .env

if [ -f "docker-compose.$DEPLOY_PROJECT_ENV.yml" ]; then
  rm -rf docker-compose.yml
  cp "docker-compose.$DEPLOY_PROJECT_ENV.yml" docker-compose.yml

  if [ -f "docker-compose.yml" ]; then
    zip "$DEPLOY_ARCHIVE_NAME" docker-compose.yml
    else
      echo "  [!] Missing a docker-compose.yml file in the repository!"
      exit 1
  fi
fi

# Add additional files to the zip
if ! [ -z "$DEPLOY_ADDITIONAL_FILES" ]; then
  for i in ${DEPLOY_ADDITIONAL_FILES//,/ }
  do
      zip "$DEPLOY_ARCHIVE_NAME" "$i"
      echo "      -> $i"
  done
fi

echo "  [+] Preparing deployment folder ($DEPLOY_SSH_USER) on $DEPLOY_SSH_HOST:$DEPLOY_SSH_PORT"
ssh $DEPLOY_SSH_USER@$DEPLOY_SSH_HOST -p $DEPLOY_SSH_PORT "
  mkdir -p $DEPLOY_DOCKER_DIR
  cd $DEPLOY_DOCKER_DIR
  rm -rf $DEPLOY_PROJECT_NAME
  mkdir -p $DEPLOY_PROJECT_NAME
"
if [ "$?" = 255 ] ; then
	echo "  [!] Failed preparing deployment folder"
	exit 1
fi

echo "  [+] Copy archive to deployment folder"
scp -P $DEPLOY_SSH_PORT "$DEPLOY_ARCHIVE_NAME" $DEPLOY_SSH_USER@$DEPLOY_SSH_HOST:"$DEPLOY_DOCKER_DIR/$DEPLOY_PROJECT_NAME"
if ! [ "$?" -eq "0" ]; then
	echo "  [!] Failed to copy the archive"
	exit 1
fi

echo "  [+] Unpacking and pulling deployment"
ssh $DEPLOY_SSH_USER@$DEPLOY_SSH_HOST -p $DEPLOY_SSH_PORT "
  cd $DEPLOY_DOCKER_DIR/$DEPLOY_PROJECT_NAME
  unzip $DEPLOY_ARCHIVE_NAME
  rm -rf $DEPLOY_ARCHIVE_NAME
  (test -x $DEPLOY_DOCKER_LOGIN_SCRIPT && $DEPLOY_DOCKER_LOGIN_SCRIPT)
  docker-compose pull
  docker-compose up -d
  $DEPLOY_AFTER_SCRIPT
"
if [ "$?" = 255 ] ; then
	echo "  [!] Failed to unpack, pull or deploy"
	exit 1
fi

echo "[>] Deployment done."