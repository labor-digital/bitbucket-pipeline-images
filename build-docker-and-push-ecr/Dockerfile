FROM python:3-alpine

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Build docker image and push to AWS ECR"

RUN pip install --upgrade pip awscli

COPY build-docker-and-push-ecr.sh /opt/build-docker-and-push-ecr.sh
RUN chmod +x /opt/build-docker-and-push-ecr.sh

COPY pull-image.sh /opt/pull-image.sh
RUN chmod +x /opt/pull-image.sh

COPY build-docker-and-push-ecr-public.sh /opt/build-docker-and-push-ecr-public.sh
RUN chmod +x /opt/build-docker-and-push-ecr-public.sh