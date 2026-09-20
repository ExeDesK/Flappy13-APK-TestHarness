import fs from 'node:fs';

const [apkPath, pwaPath] = process.argv.slice(2);
if (!apkPath || !pwaPath) {
  console.error('Usage: node compare-traces.mjs apk.csv pwa.csv');
  process.exit(2);
}

function parse(file) {
  const lines = fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, '').split(/\r?\n/).filter(Boolean);
  let header = [];
  let end = null;
  let activeRun = false;
  const taps = [];
  const states = [];
  for (const line of lines) {
    if (line.startsWith('CONFIG,')) {
      activeRun = true;
      header = [];
      end = null;
      taps.length = 0;
      states.length = 0;
      continue;
    }
    if (!activeRun) continue;
    if (line.startsWith('H,')) header = line.split(',').slice(1);
    else if (line.startsWith('I,')) taps.push(Number(line.split(',')[1]));
    else if (line.startsWith('S,')) {
      const parts = line.split(',').slice(1);
      const row = {};
      header.forEach((h, i) => row[h] = parts[i]);
      states.push(row);
    } else if (line.startsWith('END,')) {
      const p = line.split(',');
      end = { tick: Number(p[1]), score: Number(p[2].split('=')[1]) };
    }
  }
  return { header, taps, states, end };
}

const apk = parse(apkPath), pwa = parse(pwaPath);
const floatFields = new Set(['velY','rotation','rotVel','rotAccel','gravity']);
const boolFields = new Set(['hit','idle']);
const f32bits = n => {
  const b = new ArrayBuffer(4); const d = new DataView(b);
  d.setFloat32(0, Math.fround(n), true); return d.getUint32(0, true);
};
const diffs = [];
if (JSON.stringify(apk.taps) !== JSON.stringify(pwa.taps)) diffs.push({ field: 'inputs', apk: apk.taps, pwa: pwa.taps });
if (JSON.stringify(apk.end) !== JSON.stringify(pwa.end)) diffs.push({ field: 'end', apk: apk.end, pwa: pwa.end });
if (apk.states.length !== pwa.states.length) diffs.push({ field: 'rowCount', apk: apk.states.length, pwa: pwa.states.length });
const rows = Math.min(apk.states.length, pwa.states.length);
for (let i = 0; i < rows; i++) {
  for (const field of apk.header) {
    const a = apk.states[i][field], b = pwa.states[i][field];
    let same;
    if (floatFields.has(field)) same = f32bits(Number(a)) === f32bits(Number(b));
    else if (boolFields.has(field)) same = (a === 'true') === (b === 'true');
    else same = Number(a) === Number(b);
    if (!same) diffs.push({ tick: i, field, apk: a, pwa: b });
  }
}

if (diffs.length) {
  console.error(`DIFF: ${diffs.length} differences`);
  console.error(JSON.stringify(diffs.slice(0, 30), null, 2));
  process.exit(1);
}
console.log(`MATCH: ${rows} ticks, ${rows * apk.header.length} values, 0 differences`);
