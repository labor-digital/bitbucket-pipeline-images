FROM labordigital/playwright:1.55.1

LABEL description="Labor Digital Bitbucket Pipelines: Playwright 1.55.1"

ADD app/playwright.config.common.ts /app

COPY test.sh /opt/test.sh
RUN chmod +x /opt/test.sh