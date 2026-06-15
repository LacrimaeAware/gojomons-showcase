# Opponents And Bosses

The opponent model is built from the same creature database as the player roster. The current source has scalable builders for type gyms, mixed elites, single-mon mega fights, legendary showcases, and larger wild-wave rosters.

## Current Opponent Builders
| Builder | Purpose | Current shape |
|---|---|---|
| Type gym | Type-themed town or milestone fight | Tiered level band and team size; pulls from matching roster types and arms an ace with an AoE move. |
| Elite | Mid-route spike or filler boss | Mixed non-legendary team slightly above player level. |
| Mega | One large mid-game wall | Single non-legendary mon with level, HP, and offense boosts. |
| Legendary | Showcase boss | One high-level legendary matching the requested type when available. |
| Wild wave | Horde-style pressure | Larger mixed team until true wave refill exists. |

## Legendary Roster
| Legendary | Type(s) | Style | BST | Note |
|---|---|---|---:|---|
| Aethernox | Life, Mystic | balanced | 520 | A many-winged dragon of reincarnation; each scale holds a lifetime. A run-defining legend that bends growth and fate alike. |
| Infinarch | Storm, Machine | tank | 520 | A colossus of stormlight and machinery ascending an endless staircase. An unstoppable legend that only grows heavier with the climb. |
| Maelura | Water | tank | 520 | A leviathan of the deep tides whose presence calms or drowns. The Water realm's apex - an ocean that simply outlasts everything. |
| Omnindra | Light, Dark, Mystic | balanced | 520 | A three-faced deity of serenity, doubt, and clarity whose faces never align. A legend embodying the Wanderer realm - light, dark, and mind in one. |
| Pyrethon | Fire | sweeper | 520 | A sky-scorching wyrm wreathed in perpetual flame. The Fire realm's apex - relentless, blinding offense few can outlast. |
| Xenarch | Alien | disruptor | 520 | An extradimensional sovereign that warps space around its strikes. The Alien realm's apex - it rewrites the battle's rules as it fights. |

## Implementation Calls
- Wire type gyms into the town/gym buildings as the main typed milestone fights.
- Place legendary fights into finale or last-room route contexts instead of treating every boss as an elite variant.
- Add true wave refill behavior when the battle loop is ready; the current larger-team wave is a useful stand-in.
- Give major bosses one visible gimmick beyond stat scaling so the player can read what the fight is asking.
