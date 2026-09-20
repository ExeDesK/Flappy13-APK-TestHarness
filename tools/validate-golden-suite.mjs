import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const scenariosDir = path.join(root, 'scenarios');
let failed = 0;

for (const name of fs.readdirSync(scenariosDir).filter(x => x.endsWith('.json')).sort()) {
  const scenarioPath = path.join(scenariosDir, name);
  const scenario = JSON.parse(fs.readFileSync(scenarioPath, 'utf8'));
  const tracePath = path.join(root, 'golden', 'apk', `${scenario.id}.csv`);
  const r = spawnSync(process.execPath, [path.join(root, 'tools', 'validate-trace.mjs'), scenarioPath, tracePath], {
    stdio: 'inherit',
  });
  if (r.status !== 0) failed++;
}

if (failed) {
  console.error(`${failed} golden scenario(s) failed validation.`);
  process.exit(1);
}
