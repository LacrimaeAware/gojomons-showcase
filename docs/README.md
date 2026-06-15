# Gojomons Showcase Docs

This folder is the public documentation home for the showcase repo. The root
README stays as the front page; longer design, roadmap, and maintenance notes
live here.

## Read First

- [Living Game Bible](game-bible/living-game-bible.html): interactive reference
  for the current game shape, pipeline, roster, types, bestiary, masters,
  economy, catalog, bosses, balance, and roadmap.
- [Generated Bible files](game-bible/README.md): the current public snapshot for
  roster, type, move, item, relic, and opponent data.
- [Current state](roadmap/current-state.md): dated handoff and next-work note,
  not the primary source for live counts.
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

1. The source game repo canon: `DOCUMENTATION/DOCS_CANON.md`,
   `DOCUMENTATION/data/game_manifest.json`, and
   `DOCUMENTATION/data/project_facts.json`.
2. The generated Living Game Bible snapshot in `docs/game-bible/`.
3. The playable game.
4. The current design-bible/roadmap decision.
5. Current balance or simulation findings.
6. Chronological notes and old idea banks.

Keep unfinished workbench material, unreviewed exports, and draft media out of
the published docs until they are ready.
