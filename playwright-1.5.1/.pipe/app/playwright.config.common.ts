import base from './playwright.config.base';
import { defineConfig } from '@playwright/test';
export default defineConfig({
  ...base,
  
  workers: 1,
  reporter: [
    ...base['reporter'],
    ['/app/pipes-reporter.ts'],
  ],
});
