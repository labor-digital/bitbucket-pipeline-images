FROM composer:1.10.17

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Composer Install"

COPY composer-install.sh /opt/composer-install.sh
RUN chmod +x /opt/composer-install.sh

ENV COMPOSER_HOME ~/.composer
