FROM atlassian/default-image:4

MAINTAINER LABOR digital <info@labor.digital>

LABEL description="Labor Digital Bitbucket Pipelines: Set up test environment via docker-compose to run tests as pipes against it"

COPY setup-test-env-and-start-compose.sh /opt/setup-test-env-and-start-compose.sh
RUN chmod +x /opt/setup-test-env-and-start-compose.sh