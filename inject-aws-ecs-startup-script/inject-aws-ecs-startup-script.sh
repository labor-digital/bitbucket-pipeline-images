#!/bin/bash

# Set up git ssh key and known hosts
mkdir -p /root/.ssh
chmod 700 /root/.ssh
echo "$INJECT_AWS_ECS_STARTUP_SCRIPT_SSH_KEY" | sed 's/\\n/\n/g' | cat > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
echo "$INJECT_AWS_ECS_STARTUP_SCRIPT_KNOWN_HOSTS" | sed 's/\\n/\n/g' | cat > /root/.ssh/known_hosts

# Fetch the startup-script from the infrastructure git
cd src/
mkdir _git_infrastructure
cd _git_infrastructure/
git clone -v -q git@bitbucket.org:labor-digital/$INJECT_AWS_ECS_STARTUP_SCRIPT_GIT_INFRASTRUCTURE.git .
chmod +x aws_container_fetch_env.sh