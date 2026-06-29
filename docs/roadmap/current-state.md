# Current State - 2026-06-29

This is the dated re-entry handoff for the June 29 docs freshness pass. For
live public counts, roster/catalog detail, and the current generated snapshot,
start with `docs/game-bible/README.md` and
`docs/game-bible/living-game-bible.html`.

## What Changed This Pass

- Refreshed the private source repo canon and rebuilt the public Living Game
  Bible.
- Game-content counts stayed steady at 64 Gojomons, 90 moves, 64 items, 48
  relics, 10 Masters, and 28 specs.
- Source-repo metrics moved to 239 GDScript files, 46,225 lines, 114 scenes,
  and 871 commits.
- Orientation docs now point back to the generated bible for live counts
  instead of carrying stale June 22 numbers.

## Product Read

Gojomons should currently be described as a run-based creature auto-battler.

The player drafts, catches, equips, shops, routes, and prepares. The team handles
the fight. Skill lives before the fight: party order, type coverage, route risk,
relics, items, capture calls, town services, and knowing when not to push.

Creature identity and capture matter, but the game should read as a roguelike
build game first, not a full collection game.

## Current Repo Motion

- Current source-repo motion is town and route iteration: walkable town-template
  work, route-flow cleanup, and playthrough-driven UI fixes.
- Public-facing docs should still describe towns as prep hubs and routes as
  short readable chains. The newer walkable-town implementation work is motion
  inside that spine, not a reason to promise a free-roam campaign.
- The weekly docs audit now needs to account for a dirty main showcase checkout:
  use a clean worktree for reviewable docs changes and leave unrelated local
  bible previews or scratch edits alone.

## Recently Settled Or Strongly Leaning

- **2v2:** recurring minority format, roughly 25-33% of fights.
- **Map travel:** future intended, but art/scope gated.
- **Capture:** fewer total captures, with a mix of free random finds and
  targeted access through region, shop, trade, event, or future travel.
- **PC pressure:** test paid PC unlocks, restricted-party Masters or modes,
  daycare targeting, trades, and sacrifice-style offers.
- **Rewards:** move toward a tiered power-object table across relics, items,
  gear, and other prizes. Regular elites should not always drop relics.
- **Battle control:** full manual trainer control is out of scope. Limited
  battle inputs remain an experiment: switching, a Master ultimate, or a
  special-form trigger.

## Public Docs Shape

- `docs/README.md`: document index and freshness rules.
- `docs/design/`: evergreen design notes.
- `docs/game-bible/`: the tracked Living Game Bible plus generated markdown and
  JSON reference for current roster, types, moves, items, relics, and opponent
  builders.
- `docs/roadmap/`: the dated handoff, the evergreen documentation plan, and the
  older interactive pipeline checklist.
- `docs/operations/`: the maintenance and public-readiness checklist.
- `scripts/check-public-docs.ps1`: local public-readiness check.
- `.github/workflows/docs-freshness.yml`: CI check for public docs.

`scripts/build-game-bible.ps1` still builds the public game-bible snapshot from
the game repo data without copying creature art or local paths. The June 22
parser hardening for `AspectsDB.gd` still holds on the current branch, and this
pass also pulled the stale private `showcase/README.md` snapshot back into sync
with canon validation.

## Next Agenda

1. Playtest the tracked `docs/game-bible/living-game-bible.html` view and mark
   anything that feels stale, thin, or misclassified.
2. Draft a route-preview section with examples: next-three-town boss previews,
   route elite/boss preview timing, room icons, reward tier, and danger.
3. Draft a roster-pressure section: capture scarcity, targeted access, paid PC
   unlocks, daycare, trade, and restricted-party Master.
4. Draft a reward-tier table by encounter type: wild, trainer, elite, gym, boss,
   event, shop.
5. Decide whether limited battle inputs belong in near-term testing or remain a
   banked experiment.
6. Add a sprite/media pass only after deciding which art is original enough for
   public use; for now the bible tracks production status without copying assets.
7. Rename old capture/training item source keys toward the public language, then
   regenerate the bible.
8. Pick the next public devlog topic from something visible: route telegraphs,
   battle readability, reward tiers, type services, or original audio/media.

## Maintenance Loop

Use [Documentation maintenance](../operations/documentation-maintenance.md) as
the source checklist. The short version is: refresh the source canon when the
private data moved, rebuild the public bible, run
`scripts/check-public-docs.ps1`, run `git diff --check`, and keep local-only
material ignored. If the main showcase checkout is dirty, do the public audit in
a clean worktree instead of folding reviewable docs changes into local-only
preview output.

## Pages Status

The tracked Living Game Bible in `docs/game-bible/living-game-bible.html`
remains the public review surface. The ignored
`pages-preview/living-game-bible.html` copy stays a local-only workbench.
