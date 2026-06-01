# TAG: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools
# Build: docker build -t 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools .
# Push: docker push 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools

FROM ubuntu:latest

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Deployment Tools"

# Install open ssh
RUN apt-get update && apt-get install openssh-client -y

# Install curl
RUN apt-get update && apt-get install curl -y

# Install zip
RUN apt-get update && apt-get install zip -y

# Install doppler
RUN export HISTIGNORE='doppler*'
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates gnupg \
    && curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | gpg --dearmor -o /usr/share/keyrings/doppler-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/doppler-archive-keyring.gpg] https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list \
    && apt-get update \
    && apt-get install doppler -y
