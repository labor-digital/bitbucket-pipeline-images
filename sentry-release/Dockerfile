# TAG: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:sentry-release
# Build: docker build -t 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:sentry-release .
# Push: docker push 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:sentry-release
FROM node:10

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Sentry.io release and config injection"

# Install curl
RUN apt-get update && apt-get install curl -y

# Install sentry cli
RUN npm install -g @sentry/cli --unsafe-perm

# Copy sources
COPY js /opt/sentryjs
COPY sentry-prepare-release.sh /opt/sentry-prepare-release.sh
COPY sentry-release.sh /opt/sentry-release.sh
RUN chmod +x /opt/sentry-prepare-release.sh
RUN chmod +x /opt/sentry-release.sh