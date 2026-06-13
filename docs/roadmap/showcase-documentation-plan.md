# Showcase Documentation Plan

Gojomons should read as one game, not as a pile of promising prototypes. The
showcase can still be honest about motion and uncertainty, but every page should
name the current shape before it shows alternatives.

## Current Spine

Gojomons is a run-based creature auto-battler. The player drafts, catches,
equips, routes, shops, and prepares; the team handles the fight. Player skill
lives before the battle: party order, type coverage, route risk, relic and item
choices, capture calls, town services, and knowing when not to push. Creature
identity matters, but the project is a roguelike build game first.

The current run shape is:

- choose a Master and starter,
- clear a short opening trail,
- move through a sequence of type-themed towns,
- spend town days on routes, shops, rest, PC, events, or services,
- beat a gym to move onward,
- finish with a boss fight.

The next documentation pass should make that spine easy to understand, then
place every bigger idea around it.

## Status Labels

| Label | Meaning | Showcase treatment |
|---|---|---|
| Live | In the playable path now. | Can be described directly. |
| Lab | Implemented in the decision model or simulator, not fully surfaced in play. | Describe as an experiment or next integration target. |
| Planned | Chosen direction with a near-term implementation path. | Put in roadmap and future-facing bible sections. |
| Future intended | Intended for later, but not scheduled or fully costed. | Name the direction without making it sound near-term. |
| Future possible | Fits the game, but is not chosen yet. | Keep short; avoid making it sound promised. |
| Possible alternative | A real fork that still needs a call. | Put in questions or design notes, not as current truth. |
| Parked | Changed, delayed, or waiting on another system. | Mention only when the change itself is useful context. |
| Cut | Does not fit the current game. | Keep out of player-facing pages unless a devlog explains the pivot. |
| Needs call | Too unclear to classify. | Turn into a question. |

## Living Bible Checks

Before a bible section becomes a showcase page, check it against this order:

1. Current playable behavior.
2. Current design-bible decisions and roadmap.
3. Current balance and simulation findings.
4. Current content changelog.
5. Older idea banks and source notes.

If an older idea conflicts with the current spine, the current spine wins. If the
code and design notes disagree, the page should say what the player can actually
experience today and save the design target for the roadmap.

## Classification Snapshot

| Area | Current treatment |
|---|---|
| Auto-battler combat | Current identity. Keep the player out of direct move selection during battle. |
| 1v1 and 2v2 | Mixed format. Target roughly 25-33% 2v2 across encounter types, enough to affect team strategy without making every fight about it. |
| Town day loop | Current spine. Towns are prep hubs and decision menus before they are explorable spaces. |
| Routes | Current spine. Short, readable chains with calm/perilous risk, route-end pressure, and stronger previews. Bosses for the next three towns should be visible before commitment. |
| Capture | Current spine, still tuning. The likely target is less total capture access, with a mix of free random finds and targeted ways to seek a creature by region, shop, trade, travel, or event. |
| PC storage | Live, but its long-term purpose needs pressure. Test paid PC unlocks, at least one restricted-party Master, daycare targeting, trades, and sacrifice-style offers. |
| Relics and items | Current spine. Next pass is quality, upgrade paths, clearer build identity, and tiered power-object rewards rather than asking whether every prize is a relic. |
| Type verbs | Planned design language. Use as a guide, not a prison; types lean into verbs rather than owning them exclusively. |
| Elite skill checks | Planned. Elites should ask visible questions and reward prepared teams. Regular elites should not always drop relics; reward tier and object type need a clearer table. |
| Town services | Planned. Start broad for playtesting, then narrow into stronger type identities. |
| World map travel | Future intended. An actual traversable map is a major flavor goal, but the current UI-first loop remains the practical prototype path until the art and scope cost make sense. |
| Large ring map | Parked long-term fantasy. Do not present as near-term scope. |
| Full free-roam campaign | Possible alternative. Keep the current docs centered on town and route decisions. |
| Limited battle inputs | Possible alternative. Full manual control is not current, but one or two attention checks such as switching, a Master ultimate, or a special-form trigger remain worth testing. |
| Full manual trainer control | Cut for the current game. The strategy still belongs around the auto battle. |
| Stall fixes through move exhaustion | Cut as the main answer. Prefer AI fixes, stall detection, and a fatigue backstop if needed. |

## Showcase Page Roadmap

1. **Living Game Bible.** Now generated under `docs/game-bible/`: roster, type
   breakdown, moves, items, relics, opponent builders, and a public JSON snapshot.
   The next step is a richer page view if the markdown version feels too flat.
2. **Type Spine.** A public-friendly page for the nine types, verb pairs,
   service seeds, and creature motifs.
3. **Run Structure.** Town week, route choices, gyms, final boss, and how the
   player reads risk.
4. **Combat Identity.** Why fights are automatic, what the player controls, and
   how the shared resolver supports testing.
5. **Roster And Team Pressure.** Capture, party size, PC, evolution, daycare,
   trade, restricted-party runs, and targeted creature access.
6. **Development Chronicle.** Short posts that show one real change at a time:
   route telegraphs, elite rewards, service UI, audio replacement, art direction,
   or balance findings.

## Questions To Resolve

- What exact capture economy should be tested first: free random finds, paid
  targeted access, travel-based targeting, shop rolls, trade events, or a blend?
- What should paid PC unlocks cost, and which Master or mode should test a
  strict six-creature limit?
- Should route elite and route boss previews appear while choosing a route in
  town, or only after the player enters the route?
- What is the reward-tier table by encounter type: wild, trainer, elite, gym,
  boss, event, and shop?
- Do limited battle inputs improve attention without turning the game into manual
  combat?
- Which town service ships first as the canonical example?
- How much future map travel belongs in the first public bible?
- What is the exact role of breeding, daycare, and boxed creatures?
- Which old world and story material is stable enough to publish?

## Review Follow-Ups

- Rewrite public phrasing away from "creature collection" as the core genre.
  Capture and roster identity support the build; they are not the whole game.
- Add route-preview examples that show the next three town bosses before a town
  commitment and mark route elite/boss preview timing as a playtest question.
- Treat map travel as future-intended, art-cost-gated scope.
- Track 2v2 as a recurring minority format, roughly 25-33% of battles.
- Turn PC pressure into testable hooks: paid unlocks, restricted-party Master,
  daycare targeting, trades, and sacrifice-style offers.
- Turn rewards into a tiered power-object system across relics, items, and gear.
- Use the generated game bible as the current content reference before promoting
  any local Pages preview.
- Do not copy creature sprites into the public repo until each asset has passed
  an originality/licensing check; production status is enough for now.
