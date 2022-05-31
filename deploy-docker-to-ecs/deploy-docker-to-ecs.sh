#!/bin/bash

echo "Validating required environment variables..."
if [[ -z "$DEPLOY_TO_ECS_ECS_CLUSTER" ]]; then
	echo "Missing the required DEPLOY_TO_ECS_ECS_CLUSTER variable!"
	exit 1
fi
if [[ -z "$DEPLOY_TO_ECS_ECS_SERVICE" ]]; then
	echo "Missing the required DEPLOY_TO_ECS_ECS_SERVICE variable!"
	exit 1
fi
if [[ -z "$DEPLOY_TO_ECS_ECS_TASK" ]]; then
	echo "Missing the required DEPLOY_TO_ECS_ECS_TASK variable!"
	exit 1
fi

echo "Prepare environment variables..."
ECS_REGION=${DEPLOY_TO_ECS_ECS_REGION:-$AWS_ECS_DEFAULT_REGION}
ECR_REGION=${DEPLOY_TO_ECS_ECR_REGION:-$AWS_ECR_DEFAULT_REGION}
ECR_URL=${DEPLOY_TO_ECS_ECR_URL:-$AWS_ECR_DEFAULT_URL}
DOCKER_IMAGE=${DEPLOY_TO_ECS_ECR_IMAGE:-$PROJECT_NAME}
DOCKER_TAG=${DEPLOY_TO_ECS_ECR_TAG:-$AWS_ECR_DEFAULT_TAG_PREFIX$BITBUCKET_COMMIT}

#eval $(aws ecr get-login --region $ECR_REGION --no-include-email)
aws ecs describe-task-definition --region $ECS_REGION --task-definition $DEPLOY_TO_ECS_ECS_TASK --query 'taskDefinition.{networkMode:networkMode,family:family,volumes:volumes,taskRoleArn:taskRoleArn,executionRoleArn:executionRoleArn,containerDefinitions:containerDefinitions}' > task-definition.json
aws ecs describe-task-definition --region $ECS_REGION --task-definition $DEPLOY_TO_ECS_ECS_TASK --query 'taskDefinition.containerDefinitions[0].image' > task-definition-image.json
sed -i -- 's/'$ECR_URL'\/'$DOCKER_IMAGE'://g' task-definition-image.json
sed -i -- 's/"//g' task-definition-image.json
sed -i -- 's/'$ECR_URL'\/'$DOCKER_IMAGE':'$(cat task-definition-image.json)'/'$ECR_URL'\/'$DOCKER_IMAGE':'$DOCKER_TAG'/g' task-definition.json
aws ecs register-task-definition --region $ECS_REGION --cli-input-json file://task-definition.json
aws ecs update-service --region $ECS_REGION --cluster $DEPLOY_TO_ECS_ECS_CLUSTER --service $DEPLOY_TO_ECS_ECS_SERVICE --task-definition $DEPLOY_TO_ECS_ECS_TASK:$(aws ecs describe-task-definition --region $ECS_REGION --task-definition $DEPLOY_TO_ECS_ECS_TASK --query 'taskDefinition.revision')