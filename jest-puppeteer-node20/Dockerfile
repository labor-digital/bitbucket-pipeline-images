FROM labordigital/jest-puppeteer:node20

LABEL description="Labor Digital Bitbucket Pipelines: Jest Puppeteer Environment on Node (20)"

# Install mysql, in case we need to connect to a database for testing in
RUN apt-get update && apt-get install -y default-mysql-client

ADD app/jest.config.js /app

COPY test.sh /opt/test.sh
RUN chmod +x /opt/test.sh