FROM composer:1.7

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Inject AWS ECS Startup Script"

COPY inject-aws-ecs-startup-script.sh /opt/inject-aws-ecs-startup-script.sh
RUN chmod +x /opt/inject-aws-ecs-startup-script.sh

ENV COMPOSER_HOME ~/.composer