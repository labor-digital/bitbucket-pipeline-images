FROM labordigital/bitbucket-pipeline-images:node-16-environment

LABEL description="Labor Digital Bitbucket Pipes: Node 16 Environment"

# Use bash as our default shell
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/bin/bash", "/opt/npm-run-script.sh", "build"]
