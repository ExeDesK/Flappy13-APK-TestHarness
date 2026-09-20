import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const manifestPath = path.join(root, 'golden', 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
let failed = false;

for (const item of manifest.scenarios) {
  const file = path.join(root, 'golden', item.file);
  if (!fs.existsSync(file)) {
    console.error(`MISSING ${item.id}: ${file}`);
    failed = true;
    continue;
  }
  const data = fs.readFileSync(file);
  const actual = crypto.createHash('sha256').update(data).digest('hex');
  if (actual !== item.sha256.toLowerCase()) {
    console.error(`HASH FAIL ${item.id}: ${actual} != ${item.sha256}`);
    failed = true;
  } else {
    console.log(`HASH OK ${item.id}: ${actual}`);
  }
}

process.exit(failed ? 1 : 0);
