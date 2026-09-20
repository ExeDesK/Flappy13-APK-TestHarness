import fs from 'node:fs';

const [scenarioPath, tracePath] = process.argv.slice(2);
if (!scenarioPath || !tracePath) {
  console.error('Usage: node validate-trace.mjs scenario.json trace.csv');
  process.exit(2);
}

const scenario = JSON.parse(fs.readFileSync(scenarioPath, 'utf8'));
const lines = fs.readFileSync(tracePath, 'utf8').replace(/^\uFEFF/, '').split(/\r?\n/).filter(Boolean);
let header = [];
let configSeed = null;
let configTapCount = null;
let endTick = null;
let endScore = null;
const taps = [];
const states = [];

let activeRun = false;

for (const line of lines) {
  // logcat can occasionally emit a few stale Flappy13Trace lines before the
  // fresh CONFIG record even after `logcat -c`. CONFIG is therefore the
  // authoritative start-of-run marker. Ignore everything before it.
  if (line.startsWith('CONFIG,')) {
    activeRun = true;
    header = [];
    configSeed = null;
    configTapCount = null;
    endTick = null;
    endScore = null;
    taps.length = 0;
    states.length = 0;
    for (const part of line.split(',').slice(1)) {
      const [k, v] = part.split('=');
      if (k === 'seed') configSeed = Number(v);
      if (k === 'taps') configTapCount = Number(v);
    }
    continue;
  }

  if (!activeRun) continue;

  if (line.startsWith('H,')) {
    header = line.split(',').slice(1);
  } else if (line.startsWith('I,')) {
    taps.push(Number(line.split(',')[1]));
  } else if (line.startsWith('S,')) {
    const parts = line.split(',').slice(1);
    const row = {};
    header.forEach((h, i) => row[h] = parts[i]);
    states.push(row);
  } else if (line.startsWith('END,')) {
    const parts = line.split(',');
    endTick = Number(parts[1]);
    endScore = Number(parts[2].split('=')[1]);
  }
}

function deathReason(row) {
  if (!row) return 'unknown';
  const bx = Number(row.birdX), by = Number(row.birdY);
  if (by >= 380) return 'ground';
  for (const [pxKey, pyKey] of [['p1x','p1y'], ['p2x','p2y'], ['p3x','p3y']]) {
    const px = Number(row[pxKey]), py = Number(row[pyKey]);
    const xOverlap = bx <= px + 52 && bx + 20 >= px;
    if (!xOverlap) continue;
    if (by + 20 >= py - 416 && by <= py - 96) return 'upper-pipe';
    if (by + 20 >= py && by <= py + 320) return 'lower-pipe';
  }
  return 'unknown';
}

const errors = [];
if (configSeed !== scenario.seed) errors.push(`seed ${configSeed} != ${scenario.seed}`);
if (configTapCount !== scenario.taps.length) errors.push(`tap count ${configTapCount} != ${scenario.taps.length}`);
if (JSON.stringify(taps) !== JSON.stringify(scenario.taps)) errors.push('input ticks differ');
if (endTick !== scenario.expected.endTick) errors.push(`end tick ${endTick} != ${scenario.expected.endTick}`);
if (endScore !== scenario.expected.score) errors.push(`score ${endScore} != ${scenario.expected.score}`);
const reason = deathReason(states.at(-1));
if (reason !== scenario.expected.death) errors.push(`death ${reason} != ${scenario.expected.death}`);
if (states.length !== endTick + 1) errors.push(`state rows ${states.length} != ${endTick + 1}`);

if (errors.length) {
  console.error(`FAIL ${scenario.id}`);
  for (const error of errors) console.error(` - ${error}`);
  process.exit(1);
}
console.log(`OK ${scenario.id}: ${states.length} ticks, score ${endScore}, death ${reason}`);
