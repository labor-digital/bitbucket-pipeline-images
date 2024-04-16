FROM python:3-alpine

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Deploy docker image on AWS ECS"

RUN pip install --upgrade pip awscli

COPY deploy-docker-to-ecs.sh /opt/deploy-docker-to-ecs.sh
RUN chmod +x /opt/deploy-docker-to-ecs.sh