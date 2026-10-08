FROM labordigital/playwright:1.57.0-chromium

LABEL description="Labor Digital Bitbucket Pipelines: Playwright 1.57.0 (Chromium only)"

ADD app/playwright.config.common.ts /app

COPY test.sh /opt/test.sh
RUN chmod +x /opt/test.sh