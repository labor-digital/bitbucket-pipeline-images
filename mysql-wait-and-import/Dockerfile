FROM alpine:3

LABEL description="Labor Digital Bitbucket Pipelines: MySQL wait and import"

# Install mysql
RUN apk add --no-cache mysql-client

COPY wait-import.sh /opt/wait-import.sh
RUN chmod +x /opt/wait-import.sh