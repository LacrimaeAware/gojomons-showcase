# Return Handoff - 2026-06-12

This is the re-entry point after the June documentation cleanup. It records what
the showcase repo was doing, what changed, and what should happen next.

## Current Operation

The showcase is being shaped into a public development record for Gojomons:
README, design notes, roadmap notes, media, and eventually a polished Living Game
Bible. The current work is not to publish every private design note. It is to
turn the stronger game bible and roadmap material into a coherent public-facing
view of the project.

The current product read:

- Gojomons is a run-based creature auto-battler.
- The player drafts, catches, equips, shops, routes, and prepares.
- The team handles the fight.
- The core skill is before the fight: party order, type coverage, route risk,
  relics, items, capture calls, town services, and knowing when not to push.
- Creature identity and capture matter, but the game should read as a roguelike
  build game first.

## What Changed In This Pass

- README framing moved away from named-inspiration shorthand and stale roadmap
  claims.
- The type-chart public note no longer leans on protected-series comparison.
- Media notes were simplified so they describe published media without process
  language.
- The old pipeline page had obvious protected-name and stale target language
  removed.
- A new public planning document was added:
  `roadmap/showcase-documentation-plan.md`.
- A local ignored Pages-style preview was built at:
  `pages-preview/living-game-bible.html`.
- Private working notes were kept in ignored `SHOWCASE_NOTES.md`.

## Current Source Stack

Use these in this order when updating public docs:

1. What the playable game actually does.
2. Current Gojomons design-bible decisions and roadmap.
3. Current balance and simulation findings.
4. Current content changelog.
5. Older idea banks and source notes.

Older notes can still be valuable, but they should not override the current
spine unless a newer source confirms them.

## Settled Or Strongly Leaning

- **2v2:** keep as a recurring minority format, roughly 25-33% of fights, not the
  dominant format.
- **Map travel:** intended for the future because it adds major flavor, but
  deferred until the art and scope cost makes sense.
- **Capture:** fewer total captures is the likely direction. Mix free random
  finds with targeted access through region, shop, trade, event, or travel.
- **PC pressure:** test paid PC unlocks, restricted-party Masters or modes,
  daycare targeting, trades, and sacrifice-style offers.
- **Rewards:** move toward a tiered power-object table across relics, items,
  gear, and other prizes. Regular elites should not always drop relics.
- **Battle control:** full manual trainer control is out of scope. Limited battle
  inputs remain an experiment: switching, a Master ultimate, or a special-form
  trigger.

## Next Work

1. Decide whether `pages-preview/living-game-bible.html` should stay local or be
   promoted into a real GitHub Pages page.
2. If promoting it, do one more public-readiness pass and keep the page focused
   on the game rather than the writing process.
3. Draft a route-preview section with examples: next-three-town boss previews,
   route elite/boss preview timing, room icons, reward tier, and danger.
4. Draft a roster-pressure section: capture scarcity, targeted access, paid PC
   unlocks, daycare, trade, and restricted-party Master.
5. Draft a reward-tier table by encounter type: wild, trainer, elite, gym, boss,
   event, shop.
6. Decide whether limited battle inputs belong in near-term testing or remain a
   banked experiment.
7. Pick the next public devlog topic from something visible: route telegraphs,
   battle readability, reward tiers, type services, or original audio/media.

## Public Readiness Gates

Before publishing a page, clip, or README update:

- Use edited project copy, not unreviewed exports or local-only scratch material.
- Keep account names, local paths, credentials, and unreleased working notes out.
- Use original or licensed media for public clips and images.
- Keep protected-series names out of in-world labels and project identity.
- If AI use is mentioned, keep it short and quality-centered.
- The page should talk about the game, not the writing process behind the page.

## Repo State Notes

- `SHOWCASE_NOTES.md` is ignored and should stay private.
- `pages-preview/` is ignored and should stay local until deliberately promoted.
- Local `.mp4` files in `media/` are ignored; README clips use GitHub attachment
  URLs.
- `StyleExploration.png` is the only committed media still.
- Remote `origin/main` had no extra branch or incoming commit when this handoff
  was written.
