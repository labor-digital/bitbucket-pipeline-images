FROM python:2.7-alpine

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Deploy via an update of an Cloudformation Stack Parameter"

RUN pip install --upgrade pip awscli

COPY deploy-via-update-cloudformation-parameter.sh /opt/deploy-via-update-cloudformation-parameter.sh
RUN chmod +x /opt/deploy-via-update-cloudformation-parameter.sh