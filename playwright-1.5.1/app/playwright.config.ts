import common from './playwright.config.common';
import { defineConfig } from '@playwright/test';
export default defineConfig({
  ...common,
  
  workers: 1
});
