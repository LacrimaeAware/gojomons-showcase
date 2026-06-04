# The type chart

Most type charts (Pokémon and its descendants) are lopsided: some types just end
up better because they have more resistances or fewer weaknesses. I wanted types
with distinct feels (a strong-but-fragile attacker, a weak-but-tanky defender)
that still came out even overall.

## How the chart is stored

Each relationship is `+1` or `-1`, written from both sides:

- **Offense:** `+1` means this type hits the other one hard, `-1` means it hits
  weakly.
- **Defense:** `+1` means this type is *weak* to the other (takes more), `-1`
  means it *resists* the other (takes less).

So a `-1` in the defense column is good for the defender. That sign flip is the
part that's easy to misread.

The multiplier is additive. It starts at 1.0, each `+1` adds 0.5, each `-1`
subtracts 0.5, clamped at 0. Multi-element moves and dual-type defenders sum all
the relationships, so the additive form composes without needing a lookup entry
for every combination.

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

Reading Light: it attacks Mystic and Life weakly (two offensive `-1`), and it
resists Dark and Mystic (two defensive `-1`, both resistances). So Light deals
less damage than average but also takes less.

## The rule I balanced around

For every type, **average damage dealt equals average damage taken**. A type that
hits hard gets hit equally hard; a type that hits softly is equally hard to hurt.
Offense and defense are tied together so neither side comes out ahead.

The balance report computes each type's average offensive and defensive
multiplier across all 9 types. The two numbers match for every type:

- Dark: 1.06 out / 1.06 in. Hits above average, takes above average.
- Light: 0.89 out / 0.89 in. Hits below average, takes below average.

Same idea, measured instead of assumed. Later balance work confirmed the chart
itself isn't a source of imbalance and ruled it out (see
[balance-by-simulation.md](balance-by-simulation.md)). The remaining problems
live in individual creatures, not the chart.
