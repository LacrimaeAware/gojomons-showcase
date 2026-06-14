# Gojomons Showcase Docs

This folder is the public documentation home for the showcase repo. The root
README stays as the front page; longer design, roadmap, and maintenance notes
live here.

## Read First

- [Current state](roadmap/current-state.md): current state, what was
  happening, and what to do next.
- [Living Game Bible](game-bible/living-game-bible.html): interactive reference
  for the game shape, pipeline, roster, types, bestiary, masters, economy,
  catalog, bosses, balance, and roadmap.
- [Generated Bible files](game-bible/README.md): markdown and JSON roster,
  type, move, item, relic, and opponent reference.
- [Showcase documentation plan](roadmap/showcase-documentation-plan.md): current
  public framing, status labels, and open decisions.
- [Roadmap index](roadmap/README.md): roadmap document map.

## Design Notes

- [Event-driven combat](design/event-driven-combat-architecture.md)
- [Balancing by simulation](design/balance-by-simulation.md)
- [The type chart](design/symmetrical-type-chart.md)

## Operations

- [Documentation maintenance](operations/documentation-maintenance.md)

## Freshness Rules

Public docs should make their status clear:

- **Current:** describes the playable game or the latest accepted plan.
- **Roadmap:** chosen direction, but not fully built.
- **Historical:** useful chronology or old pipeline context.
- **Local only:** useful workbench material that should not be published yet.

When docs disagree, use this order:

1. The private game repo canon: `DOCUMENTATION/DOCS_CANON.md`,
   `DOCUMENTATION/data/game_manifest.json`, and
   `DOCUMENTATION/data/project_facts.json`.
2. The playable game.
3. The current design-bible/roadmap decision.
4. Current balance or simulation findings.
5. Chronological notes and old idea banks.

Do not publish raw working notes, local-only previews, unreviewed exports, or
media with placeholder commercial audio.
