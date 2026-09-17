#!/usr/bin/env node
const { execSync } = require('child_process');
const path = require('path');

const rootDir = path.join(__dirname, '..');
const scriptPath = path.join(rootDir, 'erlik.sh');
const action = process.argv[2] || 'start';

try {
    execSync(`"${scriptPath}" ${action}`, { stdio: 'inherit' });
} catch (e) {
    process.exit(1);
}
