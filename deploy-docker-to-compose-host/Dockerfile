FROM labordigital/bitbucket-pipeline-images:deployment-tools

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Deploy a docker image to a docker-compose host"

COPY deploy-docker-to-compose-host.sh /opt/deploy-docker-to-compose-host.sh
RUN chmod +x /opt/deploy-docker-to-compose-host.sh

COPY makeProdEnv.sh /opt/makeProdEnv.sh
RUN chmod +x /opt/makeProdEnv.sh