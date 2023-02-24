# TAG: 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:node-12-environment
# Build: docker build -t 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:node-12-environment .
# Push: docker push 848331400135.dkr.ecr.eu-central-1.amazonaws.com/labor-prod-pipelines:node-12-environment
FROM node:16

LABEL description="Labor Digital Bitbucket Pipelines: Node.js Environment (16)"

# Additional dependencies for our asset-builder
# See https://github.com/imagemin/mozjpeg-bin/issues/67#issuecomment-950043912

RUN apt-get update && apt-get install -y nasm zlib1g-dev

RUN npm install -g npm-cli-login

COPY npm-login.sh /opt/npm-login.sh
RUN chmod +x /opt/npm-login.sh

COPY npm-run-script.sh /opt/npm-run-script.sh
RUN chmod +x /opt/npm-run-script.sh

COPY npm-run-script-without-login.sh /opt/npm-run-script-without-login.sh
RUN chmod +x /opt/npm-run-script-without-login.sh