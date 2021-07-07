#!/bin/bash

echo "Prepare environment variables..."
BUILD_AND_PUSH_TAG=${BUILD_AND_PUSH_TAG:"$AWS_ECR_DEFAULT_TAG_PREFIX$BITBUCKET_COMMIT"}
BUILD_AND_PUSH_TAG_LATEST=${BUILD_AND_PUSH_TAG_LATEST:"latest"}
BUILD_AND_PUSH_IMAGE=${BUILD_AND_PUSH_IMAGE:-"$AWS_ECR_DEFAULT_URL/$PROJECT_NAME:$BUILD_AND_PUSH_TAG"}
BUILD_AND_PUSH_IMAGE_LATEST=${BUILD_AND_PUSH_IMAGE_LATEST:-"$AWS_ECR_DEFAULT_URL/$PROJECT_NAME:$BUILD_AND_PUSH_TAG_LATEST"}
BUILD_AND_PUSH_REGION=${BUILD_AND_PUSH_REGION:-$AWS_ECR_DEFAULT_REGION}
DEFAULT_DOCKER_FILE="Dockerfile"
BUILD_AND_PUSH_DOCKER_FILE=${BUILD_AND_PUSH_DOCKER_FILE:-$DEFAULT_DOCKER_FILE}

echo "Performing AWS ECR login... ($BUILD_AND_PUSH_REGION)"
eval $(aws ecr get-login --region $BUILD_AND_PUSH_REGION --no-include-email)

echo "Building docker build-args out of .env.template"
out=""
for i in `cat .env.template`
do
	echo "ARG: $i"
    out="$out --build-arg $i"
done

echo "Start building of image ($BUILD_AND_PUSH_IMAGE)..."
out=$(echo $out|tr -d '\n'|tr -d '\r')
echo "Running command: build -f $BUILD_AND_PUSH_DOCKER_FILE -t $BUILD_AND_PUSH_IMAGE -t $BUILD_AND_PUSH_IMAGE_LATEST $out ."
docker build -f $BUILD_AND_PUSH_DOCKER_FILE -t $BUILD_AND_PUSH_IMAGE -t $BUILD_AND_PUSH_IMAGE_LATEST $out .

echo "Pushing image..."
docker push $BUILD_AND_PUSH_IMAGE