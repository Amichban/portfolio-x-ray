/**
 * E2E smoke test example.
 * Copy to: apps/web/e2e/smoke.spec.ts
 */
import { test, expect } from '@playwright/test';

test.describe('Smoke Tests', () => {
  test('home page loads', async ({ page }) => {
    await page.goto('/');
    
    // Check page loaded
    await expect(page).toHaveTitle(/Home/);
    
    // Check main elements visible
    await expect(page.locator('nav')).toBeVisible();
    await expect(page.locator('main')).toBeVisible();
  });

  test('navigation works', async ({ page }) => {
    await page.goto('/');
    
    // Click login link
    await page.click('text=Login');
    await expect(page).toHaveURL(/.*login/);
    
    // Click signup link  
    await page.click('text=Sign Up');
    await expect(page).toHaveURL(/.*signup/);
  });
});

test.describe('Authentication Flow', () => {
  test('user can register and login', async ({ page }) => {
    // Go to signup
    await page.goto('/signup');
    
    // Fill registration form
    await page.fill('[name="email"]', `test${Date.now()}@example.com`);
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.fill('[name="confirmPassword"]', 'SecurePass123!');
    await page.fill('[name="name"]', 'Test User');
    
    // Submit
    await page.click('[type="submit"]');
    
    // Should redirect to dashboard
    await page.waitForURL('**/dashboard');
    await expect(page.locator('h1')).toContainText('Dashboard');
    
    // Logout
    await page.click('text=Logout');
    await expect(page).toHaveURL('/');
    
    // Login again
    await page.goto('/login');
    await page.fill('[name="email"]', `test${Date.now()}@example.com`);
    await page.fill('[name="password"]', 'SecurePass123!');
    await page.click('[type="submit"]');
    
    // Back to dashboard
    await page.waitForURL('**/dashboard');
  });
});

test.describe('Core Features', () => {
  // Add tests for your main features
  test.skip('create item', async ({ page }) => {
    // Login first
    // Navigate to create page
    // Fill form
    // Submit
    // Verify item created
  });
});