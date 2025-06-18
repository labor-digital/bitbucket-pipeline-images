FROM labordigital/jest-puppeteer:node20

LABEL description="Labor Digital Bitbucket Pipelines: Jest Puppeteer Environment on Node (20)"

ADD app/jest.config.js /app

COPY test.sh /opt/test.sh
RUN chmod +x /opt/test.sh

COPY test.sh /opt/test-debug.sh
RUN chmod +x /opt/test-debug.sh

COPY test.sh /opt/test-runInBand.sh
RUN chmod +x /opt/test-runInBand.sh