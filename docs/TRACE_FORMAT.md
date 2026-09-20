# Trace format

The harness writes a line-oriented CSV-like stream through the `Flappy13Trace` Android log tag.

## Records

```text
CONFIG,seed=<seed>,taps=<count>
H,tick,birdX,birdY,velY,rotation,rotVel,rotAccel,gravity,hit,idle,score,landX,p1x,p1y,p2x,p2y,p3x,p3y,speed,warmup,rngY,rngZ
START,seed=<seed>,rngY=<state>,rngZ=<state>
I,<tick>
S,<tick>,...
END,<tick>,score=<score>
```

`CONFIG` is the authoritative beginning of a run. Any tagged logcat lines before it are ignored.

## Tick convention

For tick `N`:

1. if `N` is present in the replay input list, the harness injects the input through the original in-game input handler;
2. the original game simulates tick `N`;
3. `S,N` records the state after that simulation tick.

In short: **input N before simulation N; `S,N` is state after simulation N**.

## State fields

- `birdX`, `birdY`: bird logical position.
- `velY`: vertical velocity.
- `rotation`, `rotVel`, `rotAccel`: bird rotation state.
- `gravity`: gravity value used by the game.
- `hit`: original instrumented boolean field.
- `idle`: bird idle/ready state.
- `score`: current score.
- `landX`: scrolling land offset.
- `p1x/p1y` ... `p3x/p3y`: three pipe slots.
- `speed`: world scroll speed.
- `warmup`: original hidden/warm-up state used by the game.
- `rngY`, `rngZ`: internal RNG state.

The comparator treats the five physics float fields (`velY`, `rotation`, `rotVel`, `rotAccel`, `gravity`) as IEEE-754 float32 values and compares their bit patterns, not approximate decimal values.
