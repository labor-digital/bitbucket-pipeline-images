#!/bin/bash

echo "Prepare environment variables..."
BUILD_AND_PUSH_IMAGE=${BUILD_AND_PUSH_IMAGE:-"$AWS_ECR_DEFAULT_URL/$PROJECT_NAME:$AWS_ECR_DEFAULT_TAG_PREFIX$BITBUCKET_COMMIT"}
BUILD_AND_PUSH_REGION=${BUILD_AND_PUSH_REGION:-$AWS_ECR_DEFAULT_REGION}

# Extracts the base repository url from the image
EXTRACTED_DOCKER_URL=$(echo $BUILD_AND_PUSH_IMAGE| cut -d'/' -f 1)

echo "Performing AWS ECR login... ($BUILD_AND_PUSH_REGION)"
aws ecr get-login-password --region $BUILD_AND_PUSH_REGION | docker login --username AWS --password-stdin ${EXTRACTED_DOCKER_URL}

echo "Trying to pull image for this commit..."
docker pull ${BUILD_AND_PUSH_IMAGE}