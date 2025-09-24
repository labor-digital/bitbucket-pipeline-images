import common from './playwright.config.common';
import { defineConfig } from '@playwright/test';
export default defineConfig({
  ...common,
  
  workers: 1,
  reporter: [
    ...common['reporter'],
    ['./pipes-reporter.ts'],
  ],
});
