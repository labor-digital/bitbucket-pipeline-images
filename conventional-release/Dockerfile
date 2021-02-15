# TAG: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools
# Build: docker build -t 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools .
# Push: docker push 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:deployment-tools
FROM node:10-alpine

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Conventional Release"

ARG NPM_REGISTRY_URL
ARG NPM_REGISTRY_PW
ARG NPM_REGISTRY_USER
ARG NPM_REGISTRY_EMAIL

ENV NPM_REGISTRY_URL=${NPM_REGISTRY_URL}
ENV NPM_REGISTRY_PW=${NPM_REGISTRY_PW}
ENV NPM_REGISTRY_USER=${NPM_REGISTRY_USER}
ENV NPM_REGISTRY_EMAIL=${NPM_REGISTRY_EMAIL}

RUN apk --update add curl
RUN apk --update add jq
RUN apk --update add git

RUN rm -rf /var/lib/apt/lists/* \
    && rm -rf /var/cache/apk/*

RUN npm config set unsafe-perm true \
	&& npm install -g npm-cli-login \
	&& npm set registry https://$NPM_REGISTRY_URL \
	&& npm-cli-login -u $NPM_REGISTRY_USER -p $NPM_REGISTRY_PW -r https://$NPM_REGISTRY_URL -e $NPM_REGISTRY_EMAIL --quotes --config-path=/root/.npmrc \
	&& npm remove -g npm-cli-login

RUN npm install -g @labor/commit-and-release

COPY release.sh /opt/release.sh
RUN chmod +x /opt/release.sh