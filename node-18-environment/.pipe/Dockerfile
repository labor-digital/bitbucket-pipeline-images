FROM labordigital/bitbucket-pipeline-images:node-18-environment

LABEL description="Labor Digital Bitbucket Pipes: Node 18 Environment"

# Use bash as our default shell
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/opt/npm-run-script-without-login.sh", "build"]