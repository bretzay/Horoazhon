#!/usr/bin/env bash
# =============================================================================
# Frontend Browser Test Runner (Puppeteer)
# =============================================================================
# Runs browser tests defined in docs/specs/frontend-web-tests.json using
# headless Puppeteer. Self-bootstrapping: installs puppeteer on first run.
#
# Usage:
#   ./tools/run-fe-tests.sh <featureId> [suiteId]
#   ./tools/run-fe-tests.sh fe-auth-login                  # all suites
#   ./tools/run-fe-tests.sh fe-auth-login fe-auth-login-page-loads  # one suite
#   ./tools/run-fe-tests.sh --list                          # list all features
#
# Prerequisites:
#   - Node.js >= 18 and npm
#   - Frontend running on http://127.0.0.1:8001
#   - Backend running on http://localhost:8080
#
# Output: JSON to stdout with pass/fail per suite and failure reasons.
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_FILE="$PROJECT_ROOT/docs/specs/frontend-web-tests.json"
RUNNER_DIR="/tmp/puppeteer-runner"

# --- Bootstrap: install puppeteer if not present ---
if [ ! -d "$RUNNER_DIR/node_modules/puppeteer" ]; then
  echo ">>> First run: installing puppeteer in $RUNNER_DIR ..." >&2
  mkdir -p "$RUNNER_DIR"
  (cd "$RUNNER_DIR" && npm init -y --silent >/dev/null 2>&1 && npm install puppeteer --silent 2>&1 | tail -1) >&2
  echo ">>> Puppeteer installed." >&2
fi

# --- Handle --list flag ---
if [ "${1:-}" = "--list" ]; then
  node -e "
    const data = require('$TESTS_FILE');
    for (const t of data.tests) {
      const total = t.suites.length;
      console.log(t.featureId.padEnd(35) + total + ' suite(s)');
    }
  "
  exit 0
fi

# --- Validate args ---
if [ -z "${1:-}" ]; then
  echo "Usage: $0 <featureId> [suiteId]" >&2
  echo "       $0 --list" >&2
  exit 1
fi

FEATURE_ID="$1"
SUITE_ID="${2:-}"

# --- Run the Node.js test runner ---
NODE_PATH="$RUNNER_DIR/node_modules" node -e "
const puppeteer = require('puppeteer');
const fs = require('fs');

const TESTS_FILE = '$TESTS_FILE';
const FEATURE_ID = '$FEATURE_ID';
const SUITE_ID = '$SUITE_ID' || null;
const TIMEOUT = 10000;

async function runAssertion(page, assertion) {
  switch (assertion.type) {
    case 'element_exists': {
      const el = await page.\$(assertion.selector);
      if (!el) return { pass: false, reason: 'Element not found: ' + assertion.selector };
      return { pass: true };
    }
    case 'page_contains': {
      const text = await page.evaluate(() => document.body.innerText);
      const normalize = s => s.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
      if (!normalize(text).includes(normalize(assertion.value))) {
        return { pass: false, reason: 'Page does not contain: \"' + assertion.value + '\"' };
      }
      return { pass: true };
    }
    case 'url_contains': {
      const url = page.url();
      if (!url.includes(assertion.value)) {
        return { pass: false, reason: 'URL \"' + url + '\" does not contain \"' + assertion.value + '\"' };
      }
      return { pass: true };
    }
    case 'element_text': {
      const el = await page.\$(assertion.selector);
      if (!el) return { pass: false, reason: 'Element not found for text check: ' + assertion.selector };
      const text = await page.evaluate(e => e.innerText, el);
      if (!text.includes(assertion.value)) {
        return { pass: false, reason: 'Element text does not contain: \"' + assertion.value + '\"' };
      }
      return { pass: true };
    }
    default:
      return { pass: false, reason: 'Unknown assertion type: ' + assertion.type };
  }
}

async function runStep(page, step) {
  switch (step.action) {
    case 'navigate':
      await page.goto(step.url, { waitUntil: 'networkidle2', timeout: TIMEOUT });
      break;
    case 'fill':
      await page.waitForSelector(step.selector, { timeout: TIMEOUT });
      await page.click(step.selector, { clickCount: 3 });
      await page.type(step.selector, step.value);
      break;
    case 'click':
      await page.waitForSelector(step.selector, { timeout: TIMEOUT });
      try {
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'networkidle2', timeout: 5000 }).catch(() => {}),
          page.click(step.selector)
        ]);
      } catch (e) { /* click may not trigger navigation */ }
      await new Promise(r => setTimeout(r, 500));
      break;
    case 'screenshot':
      break; // skip in headless CI mode
    case 'wait_for_selector':
      await page.waitForSelector(step.selector, { timeout: TIMEOUT });
      break;
    case 'wait_for_navigation':
      await new Promise(r => setTimeout(r, 2000));
      break;
  }
}

async function runSuite(browser, suite) {
  // Incognito context per suite: isolates cookies/session between tests
  const context = await browser.createBrowserContext();
  const page = await context.newPage();
  const result = { id: suite.id, title: suite.title, pass: true, failures: [] };
  try {
    for (const step of suite.steps) await runStep(page, step);
    for (const assertion of suite.assertions) {
      const r = await runAssertion(page, assertion);
      if (!r.pass) { result.pass = false; result.failures.push(r.reason); }
    }
  } catch (err) {
    result.pass = false;
    result.failures.push('Error: ' + err.message);
  } finally {
    await page.close();
    await context.close();
  }
  return result;
}

(async () => {
  const data = JSON.parse(fs.readFileSync(TESTS_FILE, 'utf8'));
  const featureTests = data.tests.find(t => t.featureId === FEATURE_ID);
  if (!featureTests) {
    console.log(JSON.stringify({ featureId: FEATURE_ID, error: 'No tests found' }));
    process.exit(0);
  }
  let suites = featureTests.suites;
  if (SUITE_ID) suites = suites.filter(s => s.id === SUITE_ID);

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });
  const results = [];
  for (const suite of suites) results.push(await runSuite(browser, suite));
  await browser.close();

  const allPass = results.every(r => r.pass);
  console.log(JSON.stringify({ featureId: FEATURE_ID, allPass, results }, null, 2));
  process.exit(0);
})().catch(err => { console.error('Fatal:', err.message); process.exit(1); });
"
