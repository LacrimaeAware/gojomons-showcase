# Gojomons — Project Showcase

> A turn-based creature-battler built in **Godot 4.5 / GDScript**.
> Original creatures, a custom 9-element type chart, relics, masters, and a
> full campaign loop (overworld → towns → routes → battles).

This folder is a **snapshot of an in-progress personal project** — a record of
what I'm building and how it's put together, not a polished product release.
The game is actively in development.

*Snapshot date: 2026-06-03*

---

## By the numbers

| | |
|---|---|
| Lines of GDScript | **~26,800** |
| Scripts (`.gd`) | **196** |
| Scenes (`.tscn`) | **71** |
| Commits | **169** in this repo (since Dec 2025) |
| Development time | **~6 months in this repo; the project predates it** |

> The current repository's history starts December 2025, but the project itself
> is older — it lived in earlier repos before this one. The numbers above reflect
> *this* repo's snapshot, not the full timeline of the work.

### Content authored

| | |
|---|---|
| Creatures (species) | **63** |
| Moves | **90** |
| Items | **47** |
| Relics | **28** |
| Masters (mentors) | one per element |
| Elemental types | **9** + a neutral `Base` |

---

## What it is

A creature-collecting battler in the lineage of monster-tamer RPGs, with my own
twists:

- **Custom type system** — 9 elements (Fire, Water, Life, Machine, Storm,
  Mystic, Light, Dark, Alien) on a hand-tuned effectiveness chart, plus a
  special neutral `Base` element that bypasses both STAB and the type chart.
- **Relics & items** — run-modifying passives that hook into combat at defined
  event points and mutate the damage/modifier pipeline.
- **Masters** — element-themed mentors with their own specializations and
  starter creatures.
- **Full campaign loop** — overworld map → towns (with shops) → routes →
  encounters → battle → back out, with run-wide state (party, gold, location)
  persisted through a save system.

---

## Architecture highlights

The thing I'm most proud of isn't any single feature — it's that the systems
stay decoupled as the project grows. A few decisions that paid off:

### Event-bus / signal architecture

Combat doesn't hard-wire its subsystems together. Instead, there's a central
**`EventDispatcher`** (pub/sub) that rules and effects publish to and subscribe
from:

```gdscript
EventDispatcher.register(GameEvents.SOME_EVENT, Callable(handler, "_method"))
EventDispatcher.emit(GameEvents.SOME_EVENT, context_dict)
```

Handlers receive a single `Dictionary` context. The pattern I lean on most:
**relics, items, and master passives mutate the context dict in-place** to inject
modifiers, rather than each combat step needing to know which passives exist.
Adding a new relic doesn't mean touching the damage code — it means registering a
callback. This kept the battle pipeline from turning into a tangle of special
cases.

(I also moved off Godot's older `emit_signal("name", args)` style to the
typed `signal_name.emit(args)` form project-wide — small thing, but it catches
mistakes at compile time.)

### Pure-static rules layer

Damage, type effectiveness, hit chance, and effect application live in
**pure-static calculation scripts** with no side effects beyond emitting events.
That makes them trivial to unit-test in isolation — which matters because…

### Headless smoke tests

There's a headless test runner (`godot --headless`) with **~1,500 assertions**
covering the combat rules, type chart, and game state. Exit code 0 = green.
Balance changes get caught before they ship.

### Clear ownership of global state

A small set of autoload singletons own distinct concerns — run state, the event
bus, species data, save/load, UI routing — rather than one god-object. Static
`class_name` databases (moves, items, relics, masters) are globally readable but
hold no mutable state.

### The battle pipeline

```
BattleController
  ├─ build BattleState from run state
  └─ loop until battle over:
       PreCombat   → spawn battlers, load encounter, music/bg
       TurnManager → intents → move resolution → effects → VFX
       PostTurn    → KO detection, switches, win/loss check
```

---

## Design deep-dives

Longer writeups on the decisions I'm most proud of — the engineering and
balance-design reasoning behind the systems above:

- **[Event-driven combat architecture](design/event-driven-combat-architecture.md)**
  — why I rewrote combat onto a central event bus, and what it bought.
- **[A symmetrical type chart](design/symmetrical-type-chart.md)** — making a
  9-element chart *provably* fair without making every type identical.
- **[Balancing by simulation](design/balance-by-simulation.md)** — using the
  engine itself as a measuring instrument to find what's actually broken.

## Roadmap

[`roadmap/pipeline_view.html`](roadmap/pipeline_view.html) is an interactive,
color-coded view of the full development pipeline across every system area, with
priorities and design notes (including ideas considered and cut). See
[roadmap/README.md](roadmap/README.md).

---

## System map

```
DATA/        run-wide state, save system
SYSTEMS/
  battle/    full combat pipeline (controller, turn manager, effects, UI)
  gojomons/  creature + move resources, species DB, pure rules layer
  moves/     move definitions
  items/  relics/  masters/   content databases
  map/  towns/  routes/  campaign/  encounters/   the world loop
  core/      event dispatcher, rates, config
UI/          central menu/scene router
```

---

## Tech

- **Engine:** Godot 4.5
- **Language:** GDScript
- **Testing:** custom headless assertion runner
- **Scope:** solo project, ~6 months and counting

---

## Media

> Clips are hosted on GitHub's CDN, not stored in the repo. To fill these in:
> drag the file from `media/` into the GitHub README editor, then paste the
> generated `user-attachments` URL over the placeholder. See
> [media/README.md](media/README.md).

### Main menu
<!-- Upload media/MainMenuAnim.mp4 and paste its user-attachments URL below. -->
<!-- https://github.com/user-attachments/assets/REPLACE_ME -->
*Main menu animation.*

### Creatures
<!-- Upload media/CatraAnim.mp4 and media/StyleExploration.png; paste URLs below. -->
<!-- https://github.com/user-attachments/assets/REPLACE_ME -->
*Catra, a flagship creature — plus a wider look at the roster.*

### UI
<!-- Upload media/PartyMenuAnim.mp4 and paste its user-attachments URL below. -->
<!-- https://github.com/user-attachments/assets/REPLACE_ME -->
*Party menu — UI design.*

### Combat
*A representative battle clip is coming once it's visually ready.*
