FROM labordigital/bitbucket-pipeline-images:playwright-1.55.1

LABEL description="Labor Digital Bitbucket Pipes: Playwright 1.55.1"

ADD app/playwright.config.common.ts /app
ADD app/pipes-reporter.ts /app

# Use bash as our default shell
SHELL ["/bin/bash", "-c"]

ENTRYPOINT ["/opt/test.sh"]