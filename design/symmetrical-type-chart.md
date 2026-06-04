# Design Decision: A Symmetrical Type Chart

*How I made a 9-element type chart provably fair — without forcing every type to
have the same number of strengths and weaknesses.*

## The problem

Pokémon-style type charts are famously lopsided. Some types are simply better
than others because they have more resistances, fewer weaknesses, or hit more
things super-effectively. The naive fix — *"give every type the same count of
strengths and weaknesses"* — is rigid and produces bland, samey types. I wanted
types with **distinct personalities** (a glass-cannon attacker, a tanky
defender) that were nonetheless **fair**.

## The insight

Fairness isn't about *count*, it's about *net*. A type can have lots of offensive
advantages as long as it pays for them somewhere — in defensive fragility, in
fewer defensive resistances, whatever. The constraint I imposed:

> **Every type's total advantages must equal its total disadvantages — net zero —
> even if the distribution between offense and defense differs.**

That lets Dark be a strong-but-fragile attacker and Light be a weak-but-tanky
defender, while *neither is objectively better* than the other.

## The implementation

The chart is **additive** rather than multiplicative-lookup. Each relationship is
just `+1` (advantage) or `-1` (disadvantage), stored from both perspectives:

```gdscript
"Dark": {
    "offense": {"Mystic": +1, "Fire": +1, "Life": +1, "Light": -1, "Alien": -1},
    "defense": {"Mystic": +1}
},
"Light": {
    "offense": {"Mystic": -1, "Life": -1},
    "defense": {"Dark": -1, "Mystic": -1}
},
```

Damage multiplier starts at `1.0`; each `+1` adds `0.5`, each `-1` subtracts
`0.5`, clamped at `0`. Multi-element moves and dual-type defenders just sum their
relationships — the additive model composes cleanly where a lookup table would
need an entry for every combination.

## The proof

This is the part I'm proud of: I didn't just *assert* the chart was balanced — I
**measured it**. The headless balance report computes every type's pure
offensive + defensive multiplier profile across all 9 types. The result:

> **Every type nets +0.00.** The chart has *personalities* (Dark =
> 1.06/1.06 strong-attacker/fragile; Light = 0.89/0.89 weak-attacker/tanky) but
> every advantage is paid for by an equal disadvantage.

So the chart is *demonstrably* symmetric in net power while still being
asymmetric — and interesting — in flavor. (Balance work later confirmed the chart
itself was **not** a source of imbalance and could be ruled out entirely — see
[balance-by-simulation.md](balance-by-simulation.md).)

---

*It's not deep mathematics — it's an invariant (net-zero per type) plus the
discipline to verify it computationally instead of by intuition. But that's
exactly the mindset I wanted the system to reflect.*
