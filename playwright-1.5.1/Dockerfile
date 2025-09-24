FROM labordigital/playwright:1.5.1

LABEL description="Labor Digital Bitbucket Pipelines: Playwright 1.5.1"

ADD app/playwright.config.ts /app

COPY test.sh /opt/test.sh
RUN chmod +x /opt/test.sh