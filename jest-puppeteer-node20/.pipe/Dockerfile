FROM labordigital/bitbucket-pipeline-images:jest-puppeteer-node20

LABEL description="Labor Digital Bitbucket Pipes: Jest Puppeteer Environment on Node (20)"

ADD app/jest.config.js /app
ADD app/global-teardown.js /app

# Use bash as our default shell
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/opt/test.sh"]