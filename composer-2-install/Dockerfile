FROM composer:2

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Composer v2 Install"

COPY composer-install.sh /opt/composer-install.sh
RUN chmod +x /opt/composer-install.sh

ENV COMPOSER_HOME ~/.composer