# TAG: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:conventional-release
# Build: docker build -t 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:conventional-release .
# Push: docker push 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:conventional-release
FROM node:10-alpine

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Conventional Release"

RUN apk --update add curl jq git bash git-lfs

RUN rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apk/*

RUN npm config set unsafe-perm true \
	&& npm install -g npm-cli-login

COPY src /opt/conventional-release

RUN cd /opt/conventional-release \
	&& npm install

COPY release.sh /opt/release.sh
RUN chmod +x /opt/release.sh

COPY simple-release.sh /opt/simple-release.sh
RUN chmod +x /opt/simple-release.sh