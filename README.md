# Gojomons

A turn-based creature-battler built in Godot 4.5 / GDScript. Original creatures,
a custom 9-element type chart, relics, masters, and a campaign loop that runs
overworld → towns → routes → battles.

A personal project, in active development. This repo is a showcase of it, not a release.

### Main menu

https://github.com/user-attachments/assets/002a4908-96f4-4c86-a180-8253683c4f1a

I work on this solo: art, design, and code. AI has sped up prototyping art and
code and testing styles; figuring out how to balance that speed against quality
and coherence has been part of the work. I've been prototyping games in Godot for
about five years; this project started in summer 2025, so its commit history is
much shorter than the time I've spent in the engine. Most of the art is still at
the prototype stage.

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

https://github.com/user-attachments/assets/37fd310a-7f81-4918-bca0-5bf175075fe9

*Catra.*

![Roster and art direction](media/StyleExploration.png)

### Combat

https://github.com/user-attachments/assets/6949fa0d-eae7-488f-94ff-aa767a7bdbc2

An early combat showcase, here in 2v2. Both 1v1 and 2v2 formats exist. I'm still
working on how combat is presented: layout, pacing, animation, and how much
impact each hit reads with. Expect this to keep changing.

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
relic means registering a handler, not editing the damage code. Background is in
[design/event-driven-combat-architecture.md](design/event-driven-combat-architecture.md).

### Pure rules layer

Damage, type effectiveness, hit chance, and effect application are static
functions with no side effects beyond emitting events. Because they don't touch
the scene tree, the same logic runs headless, which is what the tests and the
balance simulator use.

### Tests and balance tooling

A headless runner (`godot --headless`) checks the combat rules, type chart, and
game state with roughly 1,500 assertions. A separate headless simulator replays
real fights to measure win rates, which I use to find balance outliers. See
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

https://github.com/user-attachments/assets/c3c74b29-404c-4d1b-a405-19657dc0aac6

*Party menu.*

---

## Roadmap

The full pipeline is in [`roadmap/pipeline_view.html`](roadmap/pipeline_view.html),
an interactive checklist grouped by system area. Open it in a browser; GitHub
shows it as source, not rendered. It's an early iteration that tried to capture
every feature that might make it in, so it's broader than what's actually scoped.
Rough state right now:

- **Working:** party and PC storage, shops, node map, town scenes, base trainer
  battles, and the core combat loop (moves, types, damage, single and 2v2).
- **In progress:** relics, move cooldowns and styles, position and party-wide
  effects.
- **Planned:** catching/recruitment, gyms and bosses, masters and rivals,
  economy and scaling, map events and fog of war, overworld exploration, unlocks
  and challenge runs.

It's early, and a lot of the design is still open.

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
