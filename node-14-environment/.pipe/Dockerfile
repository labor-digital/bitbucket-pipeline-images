FROM labordigital/bitbucket-pipeline-images:node-14-environment

LABEL description="Labor Digital Bitbucket Pipes: Node 14 Environment"

ADD ./npm-run-script.sh /opt/npm-run-script.sh
RUN chmod +x /opt/npm-run-script.sh

ADD ./npm-run-script-without-login.sh /opt/npm-run-script-without-login.sh
RUN chmod +x /opt/npm-run-script-without-login.sh

# Use bash as our default shell
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/opt/npm-run-script.sh", "build"]