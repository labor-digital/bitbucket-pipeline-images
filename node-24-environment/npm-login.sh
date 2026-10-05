#!/bin/bash

# Prepare environment variables
echo "Checking environment variables..."
NPM_REGISTRY_URL=${NPM_REGISTRY_URL:-$NPM_DEFAULT_REGISTRY_URL}
NPM_REGISTRY_EMAIL=${NPM_REGISTRY_EMAIL:-$NPM_DEFAULT_REGISTRY_EMAIL}
NPM_REGISTRY_USER=${NPM_REGISTRY_USER:-$NPM_DEFAULT_REGISTRY_USER}
NPM_REGISTRY_PW=${NPM_REGISTRY_PW:-$NPM_DEFAULT_REGISTRY_PW}

# Login to our npm repository
echo "Writing .npmrc file..."
npm logout
npm set registry https://$NPM_REGISTRY_URL
npm-cli-login -u $NPM_REGISTRY_USER -p $NPM_REGISTRY_PW -r https://$NPM_REGISTRY_URL -e $NPM_REGISTRY_EMAIL --quotes