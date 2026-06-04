# Gojomons

A turn-based creature-battler built in Godot 4.5 / GDScript. Original creatures,
a custom 9-element type chart, relics, masters, and a campaign loop that runs
overworld → towns → routes → battles.

This is a personal project in active development. This repo is a showcase of it:
the writing and media here are a record of what I'm building and how it works,
not a release.

<!-- MAIN MENU: upload media/MainMenuAnim.mp4 in the GitHub editor, paste the
     user-attachments URL on its own line below this comment. -->

*Main menu.*

I work on this solo: art, design, and code. I use AI to speed up art prototyping
and parts of development. I've been building creature-battler games for several
years across earlier prototypes; this repo is the current one, started in late
2025, so its commit history is much shorter than the actual time spent.

---

## What it is

A creature-collecting battler in the monster-tamer tradition, with a few of my
own systems:

- **Custom type system.** 9 elements (Fire, Water, Life, Machine, Storm, Mystic,
  Light, Dark, Alien) on a hand-built effectiveness chart, plus a neutral `Base`
  element that ignores STAB and the type chart.
- **Relics and items.** Run-modifying passives that hook into combat at set event
  points and adjust the damage/modifier pipeline.
- **Masters.** Element-themed mentors, each with their own specialization and
  starter creatures.
- **Campaign loop.** Overworld map → towns (with shops) → routes → encounters →
  battle, with run state (party, gold, location) saved between steps.

### Creatures

<!-- CATRA: upload media/CatraAnim.mp4, paste its user-attachments URL below. -->

*Catra, one of the more finished creatures.*

<!-- STYLE SHOWCASE: upload media/StyleExploration.png, use ![roster](URL). -->

*A wider look at the roster and art direction.*

---

## Scale

| | |
|---|---|
| Lines of GDScript | ~26,800 |
| Scripts (`.gd`) | 196 |
| Scenes (`.tscn`) | 71 |
| Creatures | 63 |
| Moves | 90 |
| Items | 47 |
| Relics | 28 |
| Elements | 9 + neutral `Base` |

*Snapshot: 2026-06-03.*

---

## How it's built

### Event-driven combat

Combat is wired through a central `EventDispatcher` (pub/sub) instead of direct
calls between subsystems.

```gdscript
EventDispatcher.register(GameEvents.SOME_EVENT, Callable(handler, "_method"))
EventDispatcher.emit(GameEvents.SOME_EVENT, context_dict)
```

Handlers get a single `Dictionary` context. Relics, items, and master passives
read that context and adjust it in place to inject their modifiers. Adding a new
relic means registering a handler, not editing the damage code. Background on why
I switched to this is in [design/event-driven-combat-architecture.md](design/event-driven-combat-architecture.md).

### Pure rules layer

Damage, type effectiveness, hit chance, and effect application are static
functions with no side effects beyond emitting events. Because they don't touch
the scene tree, the same logic runs headless, which is what the tests and the
balance simulator use.

### Tests and balance tooling

A headless runner (`godot --headless`) checks the combat rules, type chart, and
game state with roughly 1,500 assertions. A separate headless simulator replays
real fights to measure win rates. I use it to find balance outliers. See
[design/balance-by-simulation.md](design/balance-by-simulation.md) and
[design/symmetrical-type-chart.md](design/symmetrical-type-chart.md).

### Battle pipeline

```
BattleController
  build BattleState from run state
  loop until battle over:
    PreCombat    spawn battlers, load encounter, music/bg
    TurnManager  intents → move resolution → effects → VFX
    PostTurn     KO detection, switches, win/loss check
```

### UI

<!-- PARTY MENU: upload media/PartyMenuAnim.mp4, paste its URL below. -->

*Party menu.*

---

## Roadmap

[`roadmap/pipeline_view.html`](roadmap/pipeline_view.html) is an interactive,
color-coded view of the development pipeline across every system area, with
priorities and notes (including ideas that were considered and cut). Details in
[roadmap/README.md](roadmap/README.md).

---

## Project layout

```
DATA/        run-wide state, save system
SYSTEMS/
  battle/    combat pipeline (controller, turn manager, effects, UI)
  gojomons/  creature + move resources, species DB, rules layer
  moves/     move definitions
  items/  relics/  masters/   content databases
  map/  towns/  routes/  campaign/  encounters/   the world loop
  core/      event dispatcher, rates, config
UI/          menu/scene router
```

---

## Notes

- Media here is hosted on GitHub's CDN, not committed to the repo. To add a clip,
  drag the file from `media/` into the GitHub README editor and paste the
  generated URL where the placeholders are. See [media/README.md](media/README.md).
- Engine: Godot 4.5. Language: GDScript.
