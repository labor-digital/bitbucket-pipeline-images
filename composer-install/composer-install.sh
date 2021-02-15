#!/bin/bash

echo "Validating required environment variables..."
if [[ -z "$COMPOSER_INSTALL_SOURCE_DIR" ]]; then
	echo "Missing the required COMPOSER_INSTALL_SOURCE_DIR variable!"
	exit 1
fi
if [[ -z "$COMPOSER_INSTALL_WORKING_DIR" ]]; then
	echo "Missing the required COMPOSER_INSTALL_WORKING_DIR variable!"
	exit 1
fi

echo "Prepare environment variables..."
COMPOSER_INSTALL_SSH_KEY=${COMPOSER_INSTALL_SSH_KEY:-$BITBUCKET_DEFAULT_SSH_KEY}
COMPOSER_INSTALL_KNOWN_HOSTS=${COMPOSER_INSTALL_KNOWN_HOSTS:-$BITBUCKET_DEFAULT_KNOWN_HOSTS}
COMPOSER_INSTALL_DESTINATION_DIR=${COMPOSER_INSTALL_DESTINATION_DIR:-$COMPOSER_INSTALL_SOURCE_DIR}

# Set up composer
# @todo don't run a self-update to prevent composer from updating to v2 please test if this makes issues!
#composer self-update

# Set up git ssh key, known hosts and config
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "$COMPOSER_INSTALL_SSH_KEY" | sed 's/\\n/\n/g' | cat > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
echo "$COMPOSER_INSTALL_KNOWN_HOSTS" | sed 's/\\n/\n/g' | cat > /root/.ssh/known_hosts
echo "Host bitbucket.org" >> /root/.ssh/config
echo "	Port 22" >> /root/.ssh/config
echo "	HostName bitbucket.org" >> /root/.ssh/config
echo "	User git" >> /root/.ssh/config
echo "	IdentityFile \"/root/.ssh/id_rsa\"" >> /root/.ssh/config

# Prepare directory for install
rm -rf $COMPOSER_INSTALL_WORKING_DIR/
mkdir -p $COMPOSER_INSTALL_WORKING_DIR/
cp -R -p $COMPOSER_INSTALL_SOURCE_DIR/* $COMPOSER_INSTALL_WORKING_DIR/
rm -rf $COMPOSER_INSTALL_SOURCE_DIR/*
cd $COMPOSER_INSTALL_WORKING_DIR/

# Composer install
composer install --ignore-platform-reqs --no-progress --optimize-autoloader --no-interaction --verbose

# Copy back for artifacts
cp -R -p ./* $COMPOSER_INSTALL_DESTINATION_DIR/
