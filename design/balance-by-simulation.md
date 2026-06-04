# Balancing by simulation

Manual playtesting only covers a handful of matchups and leans on whatever you
already expect to happen. To get past that, I built a headless simulator that
runs the real combat rules (the same intent → resolve → apply pipeline the game
uses) without VFX, animation, or a scene tree, so a full fight resolves
instantly. This works because the rules layer emits events instead of driving the
UI (see [event-driven-combat-architecture.md](event-driven-combat-architecture.md)).

```
simulate(party, enemy, opts)        one fight: victor, turns, damage dealt
simulate_many(party, enemy, runs)   win rate + avg turns over N seeded runs
```

Runs are seeded and deterministic, so results reproduce. The same simulator also
predicts a fight's turn count before it renders, which the game uses to pace
animation speed.

## Getting the measurement right

The first version of the report lied: it used a wrong stat-growth formula and only
the 2 default moves per creature, so it measured the wrong thing. The current
version uses the correct growth curve, each creature's full leveled movepool, and
evolution cohorts (base/mid/final fight their own tier instead of a level-12
starter facing a level-12 legendary).

## What it found

I split the imbalance into possible causes and checked each one:

| Suspect | Result |
|---|---|
| Type chart | Even. Every type nets +0.00. |
| Per-type base stats | Even. Under 3% spread across types. |
| Move quality | Mostly even, one undertuned type. |
| Single-type vs dual-type | The main gap, about 20 points. |

```
1-type creatures: 37.4% win rate
2-type creatures: 58.2% win rate
```

Single and dual creatures had nearly identical base-stat totals (391 vs 400), so
the gap came from typing, not stats. A single-type can't get STAB on a second
element family, which is the advantage it's missing.

## Pricing the fix

Instead of guessing at a buff, I swept a stat multiplier on single-types and
watched where the win rates crossed:

| Single stat ×mult | Single WR | Dual WR |
|---|---|---|
| 1.00 (original) | 36.1% | 57.9% |
| 1.10 | 47.1% | 51.7% |
| 1.15 (parity) | 51.3% | 49.3% |

So a second type is worth roughly +50–60 BST. I closed about half the gap with a
stat bump and left the rest as the reward budget for "graft" items that add a
second type, so a grafted single-type isn't buffed twice.

## Example output

The report prints a per-creature tier list and a per-type aggregate. The type
view, from one run (63 creatures, 8 runs each):

```
TYPE TIER LIST (aggregate 1v1 win rate)
  Water     61.3%   ████████████
  Machine   60.1%   ████████████
  Mystic    59.9%   ███████████
  Light     59.4%   ███████████
  Alien     50.8%   ██████████
  Storm     49.6%   █████████
  Fire      49.6%   █████████
  Life      45.5%   █████████
  Dark      41.0%   ████████
```

The per-creature spread is still wide (top creature ~97%, bottom ~12%), which is
the point: the chart and per-type stats are flat, but individual creatures still
need work, and the report flags exactly which ones each time it runs.

The full living writeup, with methodology and the per-creature outlier list,
stays in the project's `BALANCE_FINDINGS.md`.
