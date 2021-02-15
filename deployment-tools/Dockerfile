# TAG: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools
# Build: docker build -t 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools .
# Push: docker push 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools

FROM ubuntu:latest

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="LABOR GmbH - Bitbucket Pipelines - Deployment Tools"

# Install open ssh
RUN apt-get update && apt-get install openssh-client -y

# Install curl
RUN apt-get update && apt-get install curl -y

# Install zip
RUN apt-get update && apt-get install zip -y