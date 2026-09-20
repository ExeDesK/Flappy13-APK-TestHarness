import fs from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';

const root = process.argv[2];
const harnessRoot = process.argv[3] ?? path.resolve(path.dirname(new URL(import.meta.url).pathname), '..');
if (!root) {
  console.error('Usage: node generate-pwa-traces.mjs <PWA repo root> [harness root]');
  process.exit(2);
}
const gamePath = path.join(path.resolve(root), 'site', 'src', 'game.js');
const { Game } = await import(pathToFileURL(gamePath).href);

const scenarioDir = path.join(harnessRoot, 'scenarios');
const outDir = path.join(harnessRoot, 'traces', 'pwa');
fs.mkdirSync(outDir, { recursive: true });
const header = ['tick','birdX','birdY','velY','rotation','rotVel','rotAccel','gravity','hit','idle','score','landX','p1x','p1y','p2x','p2y','p3x','p3y','speed','warmup','rngY','rngZ'];

function readyGame(seed) {
  const g = new Game({ seed, best: 0 });
  let guard = 0;
  while (!(g.menu && g.play.active && g.fade.done && g.fade.value === 0)) {
    g.tick(); if (++guard > 1000) throw new Error('menu timeout');
  }
  g.tick({ touches: [{ x: 78, y: 375 }] });
  g.tick({ touches: [] });
  guard = 0;
  while (!(g.ready.active && g.ready.stage === 1 && g.bird.idle && !g.menu)) {
    g.tick(); if (++guard > 1000) throw new Error('ready timeout');
  }
  return g;
}

function row(g, tick) {
  return [tick,g.bird.x,g.bird.y,g.bird.velocity,g.bird.rotation,g.bird.rotationSpeed,g.bird.rotationAcceleration,g.bird.gravity,g.bird.dead,g.bird.idle,g.score,g.land,g.pipes[0].x,g.pipes[0].y,g.pipes[1].x,g.pipes[1].y,g.pipes[2].x,g.pipes[2].y,g.speed,g.hidden,g.random.y,g.random.z];
}

for (const file of fs.readdirSync(scenarioDir).filter(x => x.endsWith('.json')).sort()) {
  const scenario = JSON.parse(fs.readFileSync(path.join(scenarioDir, file), 'utf8'));
  const g = readyGame(scenario.seed);
  const taps = new Set(scenario.taps);
  const lines = [];
  lines.push(`CONFIG,seed=${scenario.seed},taps=${scenario.taps.length}`);
  lines.push(`H,${header.join(',')}`);
  lines.push(`START,seed=${scenario.seed},rngY=${g.random.y},rngZ=${g.random.z}`);
  let ended = false;
  for (let tick = 0; tick <= scenario.expected.endTick + 1000; tick++) {
    if (taps.has(tick)) lines.push(`I,${tick}`);
    g.tick(taps.has(tick) ? { tap: { x: 144, y: 256 } } : {});
    lines.push(`S,${row(g, tick).join(',')}`);
    if (g.speed === 0 && !g.bird.idle) {
      lines.push(`END,${tick},score=${g.score}`);
      ended = true;
      break;
    }
  }
  if (!ended) throw new Error(`${scenario.id}: no terminal state`);
  const out = path.join(outDir, `${scenario.id}.csv`);
  fs.writeFileSync(out, `${lines.join('\n')}\n`);
  console.log(`${scenario.id} -> ${out}`);
}
