# Current State - 2026-06-13

This is the re-entry point for the showcase repo after the June documentation
cleanup and freshness pass.

## Where We Are

The showcase repo is now organized around a public `docs/` folder:

- `docs/README.md`: document index and freshness rules.
- `docs/design/`: evergreen design notes.
- `docs/roadmap/`: current state, roadmap, public documentation plan, and the
  older interactive pipeline checklist.
- `docs/operations/`: maintenance process.
- `scripts/check-public-docs.ps1`: local public-readiness check.
- `.github/workflows/docs-freshness.yml`: CI check for public docs.
- A weekly Codex app automation now covers the private game repo plus this
  showcase repo for docs freshness audits.

The root README stays as the project front page. `media/` stays at the root
because README assets need stable, simple paths.

## Product Read

Gojomons should currently be described as a run-based creature auto-battler.

The player drafts, catches, equips, shops, routes, and prepares. The team handles
the fight. Skill lives before the fight: party order, type coverage, route risk,
relics, items, capture calls, town services, and knowing when not to push.

Creature identity and capture matter, but the game should read as a roguelike
build game first, not a full collection game.

## Recently Settled Or Strongly Leaning

- **2v2:** recurring minority format, roughly 25-33% of fights.
- **Map travel:** future intended, but art/scope gated.
- **Capture:** fewer total captures, with a mix of free random finds and targeted
  access through region, shop, trade, event, or future travel.
- **PC pressure:** test paid PC unlocks, restricted-party Masters or modes,
  daycare targeting, trades, and sacrifice-style offers.
- **Rewards:** move toward a tiered power-object table across relics, items,
  gear, and other prizes. Regular elites should not always drop relics.
- **Battle control:** full manual trainer control is out of scope. Limited battle
  inputs remain an experiment: switching, a Master ultimate, or a special-form
  trigger.

## What We Were Working On

The last active work was documentation freshness and public-facing organization:

- clean named-inspiration shorthand out of public docs,
- keep private/local notes out of the repo,
- consolidate public docs under `docs/`,
- clarify current vs roadmap vs historical material,
- create a repeatable public-doc audit,
- decide whether the local Living Game Bible preview should ever become a real
  public page.

## Next Agenda

1. Decide whether `pages-preview/living-game-bible.html` stays local or becomes a
   public GitHub Pages document.
2. Draft a route-preview section with examples: next-three-town boss previews,
   route elite/boss preview timing, room icons, reward tier, and danger.
3. Draft a roster-pressure section: capture scarcity, targeted access, paid PC
   unlocks, daycare, trade, and restricted-party Master.
4. Draft a reward-tier table by encounter type: wild, trainer, elite, gym, boss,
   event, shop.
5. Decide whether limited battle inputs belong in near-term testing or remain a
   banked experiment.
6. Pick the next public devlog topic from something visible: route telegraphs,
   battle readability, reward tiers, type services, or original audio/media.

## Maintenance Loop

Before committing public doc changes:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-public-docs.ps1
git diff --check
```

Then review the staged files and make sure local-only files remain ignored:

- `SHOWCASE_NOTES.md`
- `pages-preview/`
- local `.mp4` files under `media/`

## Pages Status

No public Pages deployment was promoted during this pass. The HTML Living Game
Bible preview remains local and ignored until a deliberate publish pass.
