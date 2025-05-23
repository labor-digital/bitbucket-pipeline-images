FROM node:22

LABEL description="Labor Digital Bitbucket Pipelines: Node.js Environment (20)"

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