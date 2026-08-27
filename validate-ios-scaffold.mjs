import assert from 'node:assert/strict';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(here, 'HermesRuns');
const testRoot = join(here, 'HermesRunsTests');
const projectFile = join(here, 'HermesRuns.xcodeproj', 'project.pbxproj');
const schemeFile = join(here, 'HermesRuns.xcodeproj', 'xcshareddata', 'xcschemes', 'HermesRuns.xcscheme');

const requiredFiles = [
  'HermesRunsApp.swift',
  'Models/HermesModels.swift',
  'Networking/HermesAPIClient.swift',
  'Storage/KeychainStore.swift',
  'Stores/SessionStore.swift',
  'Theme/HermesTheme.swift',
  'Views/RootView.swift',
  'Views/LoginView.swift',
  'Views/ForgotPasswordView.swift',
  'Views/MainTabView.swift',
  'Views/TodayView.swift',
  'Views/RunsView.swift',
  'Views/ShoesView.swift',
  'Views/MoreView.swift',
  'Views/AnalysisView.swift',
  'Views/RacesView.swift',
  'Views/ScheduleView.swift',
  'Views/RewardsView.swift',
  'Views/ProfileView.swift',
  'Views/WeatherView.swift',
  'Views/SettingsView.swift',
  'Resources/Info.plist',
];

assert.ok(existsSync(projectFile), 'The iOS Xcode project must exist.');
assert.ok(existsSync(schemeFile), 'The shared HermesRuns scheme must exist.');
assert.ok(existsSync(projectRoot), 'The HermesRuns app source directory must exist.');
assert.ok(existsSync(join(testRoot, 'HermesRunsTests.swift')), 'The XCTest source must exist.');

for (const relativePath of requiredFiles) {
  assert.ok(existsSync(join(projectRoot, relativePath)), `Missing iOS source: ${relativePath}`);
}

const project = readFileSync(projectFile, 'utf8');
const scheme = readFileSync(schemeFile, 'utf8');
assert.match(project, /PRODUCT_BUNDLE_IDENTIFIER = com\.hermesruns\.ios;/);
assert.match(project, /IPHONEOS_DEPLOYMENT_TARGET = 16\.0;/);
assert.match(project, /HermesRunsApp\.swift/);
assert.match(project, /Info\.plist/);
assert.match(scheme, /BlueprintName = "HermesRuns"/);
assert.match(scheme, /BlueprintName = "HermesRunsTests"/);
for (const relativePath of requiredFiles.filter((file) => file.endsWith('.swift'))) {
  assert.ok(project.includes(relativePath.split('/').at(-1)), `Xcode project does not reference ${relativePath}`);
}

const infoPlist = readFileSync(join(projectRoot, 'Resources/Info.plist'), 'utf8');
assert.match(infoPlist, /^<\?xml version="1\.0" encoding="UTF-8"\?>/);
assert.match(infoPlist, /<plist version="1\.0">[\s\S]*<\/plist>/);

const app = readFileSync(join(projectRoot, 'HermesRunsApp.swift'), 'utf8');
const client = readFileSync(join(projectRoot, 'Networking/HermesAPIClient.swift'), 'utf8');
const tabs = readFileSync(join(projectRoot, 'Views/MainTabView.swift'), 'utf8');
assert.match(app, /@main/);
assert.match(client, /\/api\/auth\/login/);
assert.match(client, /\/api\/auth\/password-reset\/request/);
assert.match(client, /\/api\/today\/dashboard/);
assert.match(client, /\/api\/coach\/schedule/);
assert.match(client, /\/api\/activities\/analysis/);
assert.match(tabs, /TodayView/);
assert.match(tabs, /RunsView/);
assert.match(tabs, /ShoesView/);
assert.match(tabs, /MoreView/);
assert.match(project, /HermesRunsTests\.swift/);

console.log('[PASS] HermesRuns iOS scaffold contract passed.');
