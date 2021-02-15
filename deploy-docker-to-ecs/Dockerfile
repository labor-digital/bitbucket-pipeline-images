FROM python:2.7-alpine

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Build docker image and push to AWS ECR"

RUN pip install --upgrade pip awscli

COPY deploy-docker-to-ecs.sh /opt/deploy-docker-to-ecs.sh
RUN chmod +x /opt/deploy-docker-to-ecs.sh