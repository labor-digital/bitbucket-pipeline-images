#!/bin/bash

echo "Prepare environment variables..."
BUILD_AND_PUSH_TAG_LATEST=${BUILD_AND_PUSH_TAG_LATEST:-"latest"}
BUILD_AND_PUSH_IMAGE=${BUILD_AND_PUSH_IMAGE:-"$AWS_ECR_DEFAULT_URL/$PROJECT_NAME:$AWS_ECR_DEFAULT_TAG_PREFIX$BITBUCKET_COMMIT"}
BUILD_AND_PUSH_REGION=${BUILD_AND_PUSH_REGION:-$AWS_ECR_DEFAULT_REGION}
BUILD_AND_PUSH_DOCKER_FILE=${BUILD_AND_PUSH_DOCKER_FILE:-"Dockerfile"}
BUILD_AND_PUSH_BUILD=${BUILD_AND_PUSH_BUILD:-"yes"}
BUILD_AND_PUSH_PUSH=${BUILD_AND_PUSH_PUSH:-"yes"}
BUILD_AND_PUSH_LOAD_PATH=${BUILD_AND_PUSH_LOAD_PATH:-""}
BUILD_AND_PUSH_SAVE_PATH=${BUILD_AND_PUSH_SAVE_PATH:-""}

# Extracts the base repository url from the image
EXTRACTED_DOCKER_URL=$(echo $BUILD_AND_PUSH_IMAGE| cut -d'/' -f 1)

echo "Performing AWS ECR login... ($BUILD_AND_PUSH_REGION)"
aws ecr get-login-password --region $BUILD_AND_PUSH_REGION | docker login --username AWS --password-stdin ${EXTRACTED_DOCKER_URL}

# Extracts the repository name from the image, so we can  push it with all tags
EXTRACTED_TAG=$(echo $BUILD_AND_PUSH_IMAGE| cut -d':' -f 2)

if [ "$BUILD_AND_PUSH_IMAGE" == "$EXTRACTED_TAG" ]; then
  EXTRACTED_TAG=
fi

BUILD_AND_PUSH_TAG=${TAG:-"${EXTRACTED_TAG:-"DEFAULT_TAG"}"}
BUILD_AND_PUSH_REPO=${BUILD_AND_PUSH_IMAGE%":$BUILD_AND_PUSH_TAG"}

if [ "$BUILD_AND_PUSH_LOAD_PATH" != "" ] && [ -f "$BUILD_AND_PUSH_LOAD_PATH" ]; then
  echo "Loading image from file..."
  docker load --input $BUILD_AND_PUSH_LOAD_PATH
fi

if [ "$BUILD_AND_PUSH_BUILD" == "yes" ]; then
  echo "Building docker build-args out of .env.template"
  out=""
  for i in `cat .env.template`
  do
    echo "ARG: $i"
      out="$out --build-arg $i"
  done

  echo "Start building of image ($BUILD_AND_PUSH_REPO:$BUILD_AND_PUSH_TAG)..."
  out=$(echo $out|tr -d '\n'|tr -d '\r')
  docker build -f $BUILD_AND_PUSH_DOCKER_FILE -t $BUILD_AND_PUSH_REPO:$BUILD_AND_PUSH_TAG -t $BUILD_AND_PUSH_REPO:$BUILD_AND_PUSH_TAG_LATEST $out .
fi

if [ "$BUILD_AND_PUSH_PUSH" == "yes" ]; then
  echo "Pushing image..."
  docker push $BUILD_AND_PUSH_REPO:$BUILD_AND_PUSH_TAG
  docker push $BUILD_AND_PUSH_REPO:$BUILD_AND_PUSH_TAG_LATEST
fi

if [ "$BUILD_AND_PUSH_SAVE_PATH" != "" ]; then
  echo "Saving image for later use..."
  rm -rf $BUILD_AND_PUSH_SAVE_PATH
  mkdir -p $(dirname $BUILD_AND_PUSH_SAVE_PATH)
  docker save --output $BUILD_AND_PUSH_SAVE_PATH $BUILD_AND_PUSH_REPO:$BUILD_AND_PUSH_TAG
fi