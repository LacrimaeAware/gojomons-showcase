# Design Decision: Balancing by Simulation

*Instead of guessing at balance, I built a headless simulator that fights every
matchup thousands of times — and let the data tell me what was actually broken.*

## The idea

Manual playtesting is slow and biased — you can only feel a handful of matchups,
and you tend to confirm what you already believe. So I built a **headless battle
simulator** that reuses the *real* combat rules (the same
intent → resolve → apply pipeline the game uses) but strips out VFX, animation,
and the scene tree. A full fight resolves instantly.

This is only possible *because* of the event-driven architecture — the rules
layer emits events rather than driving the UI, so it can run with no renderer
attached (see [event-driven-combat-architecture.md](event-driven-combat-architecture.md)).

```
simulate(party, enemy, opts)        → one fight: victor, turns, damage dealt
simulate_many(party, enemy, runs)   → win rate + avg turn count over N seeded runs
```

Runs are **seeded and deterministic**, so any result is reproducible. The same
simulator does double duty: balance tooling *and* pre-fight turn-count prediction
the live game uses to pace its animation speed.

## What the data found

I built the report to be *fair* before trusting it — an early version used a wrong
stat-growth formula and a 2-move pool, which made it lie; the real version uses
the correct growth curve, the full leveled movepool, and **evolution cohorts**
(base/mid/final/legendary fight their own tier, not level-12-starter vs
level-12-legendary).

Then I decomposed the imbalance instead of chasing symptoms:

| Suspect | Verdict |
|---|---|
| The type chart | **Ruled out** — every type nets +0.00 |
| Per-type base stats | **Ruled out** — <3% spread across types |
| Move quality | Mostly even (one undertuned type) |
| **Single-type vs dual-type** | **The driver — a 20.8-point gap** |

```
1-type mons: 37.4% win rate
2-type mons: 58.2% win rate
```

The clincher that proved typing — not stats — was the cause: single and dual
mons had nearly identical base-stat totals (391 vs 400), so the entire 20-point
gap came from typing alone. The mechanism: a single-type can never get STAB on a
*second* element family.

## Pricing the fix

Rather than eyeball a buff, I ran a parameter sweep — multiplying single-type
stats and measuring where the win rates crossed:

| Single stat ×mult | Single WR | Dual WR |
|---|---|---|
| 1.00 (original) | 36.1% | 57.9% |
| 1.10 | 47.1% | 51.7% |
| **1.15 (parity)** | **51.3%** | **49.3%** |

Conclusion: **a second type is worth ≈ +50–60 BST of raw stats.** Now I could
make an *informed* design choice — close half the gap with a stat bump and leave
the other half as the reward budget for "honorary-type" graft items, so a grafted
single-type isn't double-buffed.

## Why this matters

This is the loop I wanted: **hypothesis → measure → decompose → price → decide**,
with the engine itself as the measuring instrument. It turns balance from an
argument into an experiment, and it catches regressions automatically — a content
or rules change that skews the numbers shows up the next time the report runs.

---

*Full living write-up with methodology and per-mon outliers lives in the
project's `BALANCE_FINDINGS.md`. This is the condensed version of the story.*
