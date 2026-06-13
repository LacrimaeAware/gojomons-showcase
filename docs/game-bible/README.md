# Living Game Bible

Generated from the current game data on 2026-06-13. This is the one-stop reference for the project spine, roster, types, moves, items, relics, masters, economy, and opponent structure.

## Interactive Bible

- [Living Game Bible](living-game-bible.html): searchable HTML view for the current game shape, pipeline, roster/capture policy, type ledger, bestiary, masters, economy, catalog, bosses, balance, and roadmap.

## Sections
- [Bestiary](bestiary.md): every current Gojomon, including type, style, stats, evolution notes, and production status.
- [Types](types.md): the nine-element model, type chart, service seeds, and roster balance.
- [Moves](moves.md): move catalog with element, category, power, accuracy, flags, and VFX status.
- [Items and relics](items-and-relics.md): current power objects and reward-building material.
- [Opponents](opponents.md): gyms, elites, legendary fights, wild waves, and what still needs wiring.
- [Public data snapshot](data/public-game-bible.json): generated data for future pages tooling.

## Current Scale
| Area | Count |
|---|---:|
| Gojomons | 63 |
| Moves | 90 |
| Items | 49 |
| Relics | 32 |
| Types | 9 |

## Production Status Words
| Label | Meaning |
|---|---|
| Sprite-backed | Uses a dedicated creature scene currently listed as art-backed in the game data. |
| Prototype marker | Data-ready creature using the shared type-color marker until final art is made. |
| Custom VFX | Move has an authored or shared VFX scene assigned. |
| Fallback VFX | Move currently relies on the generic element-colored fallback. |

## Maintenance
Regenerate after changing roster, moves, items, relics, or type-chart data:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build-game-bible.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-public-docs.ps1
```
