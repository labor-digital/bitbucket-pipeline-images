FROM labordigital/bitbucket-pipeline-images:node-24-environment

LABEL description="Labor Digital Bitbucket Pipes: Node 24 Environment"

# Use bash as our default shell
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/bin/bash", "/opt/npm-run-script-without-login.sh", "build"]
