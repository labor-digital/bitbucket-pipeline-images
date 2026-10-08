FROM labordigital/playwright:1.64.0

LABEL description="Labor Digital Bitbucket Pipelines: Playwright 1.64.0"

ADD app/playwright.config.common.ts /app

COPY test.sh /opt/test.sh
RUN chmod +x /opt/test.sh