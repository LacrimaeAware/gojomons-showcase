# Current State - 2026-06-22

This is the dated re-entry handoff for the showcase repo after the June 22
Living Game Bible refresh and docs-freshness pass. For live public counts and
content detail, start with `docs/game-bible/README.md` and
`docs/game-bible/living-game-bible.html`.

## Where We Are

The showcase repo is now organized around a public `docs/` folder:

- `docs/README.md`: document index and freshness rules.
- `docs/design/`: evergreen design notes.
- `docs/game-bible/`: interactive Living Game Bible plus generated markdown and
  JSON reference for current roster, types, moves, items, relics, and opponent
  builders.
- `docs/roadmap/`: current state, roadmap, public documentation plan, and the
  older interactive pipeline checklist.
- `docs/operations/`: maintenance process.
- `scripts/check-public-docs.ps1`: local public-readiness check.
- `.github/workflows/docs-freshness.yml`: CI check for public docs.
- A weekly Codex app automation now covers the source game repo plus this
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
- replace the local Living Game Bible preview with a maintainable generated
  reference under `docs/game-bible/`.

Since then, `scripts/build-game-bible.ps1` builds the public game-bible
snapshot from the game repo data. It does not copy creature art or local paths;
it records production status as sprite-backed or prototype marker, and the June
22 refresh also taught the parser to survive the current `AspectsDB.gd`
dictionary declaration format.

The June 22 refresh kept the roster at 64 Gojomons, 90 moves, 64 items, 48
relics, 10 Masters, and 28 specs. Repo metrics now read as 233 GDScript files,
45,308 lines, 111 scenes, and 838 commits in the source repo. The generated
bible files under `docs/game-bible/` remain the current source for live counts
and catalog detail; the root README now mirrors that snapshot again instead of
carrying stale repo metrics.

## Next Agenda

1. Playtest the tracked `docs/game-bible/living-game-bible.html` view and mark
   anything that feels stale, thin, or misclassified.
2. Add a sprite/media pass only after deciding which art is original enough for
   public use; for now the bible tracks production status without copying assets.
3. Rename old capture/training item source keys toward the public language, then
   regenerate the bible.
4. Draft a route-preview section with examples: next-three-town boss previews,
   route elite/boss preview timing, room icons, reward tier, and danger.
5. Draft a roster-pressure section: capture scarcity, targeted access, paid PC
   unlocks, daycare, trade, and restricted-party Master.
6. Draft a reward-tier table by encounter type: wild, trainer, elite, gym, boss,
   event, shop.
7. Decide whether limited battle inputs belong in near-term testing or remain a
   banked experiment.
8. Pick the next public devlog topic from something visible: route telegraphs,
   battle readability, reward tiers, type services, or original audio/media.

## Maintenance Loop

Use [Documentation maintenance](../operations/documentation-maintenance.md) as
the source checklist. The short version is: refresh the source canon when the
private data moved, rebuild the public bible, run
`scripts/check-public-docs.ps1`, run `git diff --check`, and keep local-only
material ignored.

## Pages Status

The interactive Living Game Bible was promoted into the tracked docs tree at
`docs/game-bible/living-game-bible.html`. The ignored
`pages-preview/living-game-bible.html` copy remains the hot-reload workbench.
