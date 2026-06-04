# Gojomons

A roguelike auto-battler creature game built in Godot 4.5 / GDScript. You draft a
team of original creatures over a run, pick up relics and items along the way, and
watch fast auto battles decide whether the build holds. Inspired by Slay the
Spire, Super Auto Pets, Pokémon, and Hearthstone Battlegrounds.

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

The strategy lives in building the team, not in micromanaging each fight. Battles
resolve on their own, so you win or lose on drafting, routing, and synergies.

- **Roguelike runs.** Start a run, pick a master and a starter, then move through
  towns (shop, heal, choose where to go next) and routes (chains of rooms and
  events) toward a boss. Towns and routes are decision spaces, not a free-roam
  overworld.
- **Auto battles.** Combat plays out automatically, meant to be fast and readable.
  Low input, high strategy.
- **Relics and items.** Run-modifying pickups in the Slay the Spire vein that hook
  into combat and bend the math.
- **Custom type system.** 9 elements (Fire, Water, Life, Machine, Storm, Mystic,
  Light, Dark, Alien) on a hand-built chart, plus a neutral `Base` element that
  ignores STAB and the chart.
- **Masters.** Element-themed run identities, each with their own specialization
  and starter.
- **Creatures.** Surreal companions, closer to spirits and archetypes than
  ordinary critters. Each has a type, an aspect, and a combat style.

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
game state with roughly 1,500 assertions. Since battles auto-resolve, the same
rules also drive a headless simulator that replays fights to measure win rates,
which I use to find balance outliers. See
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

---

## Roadmap

The full interactive checklist is in [`roadmap/pipeline_view.html`](roadmap/pipeline_view.html),
grouped by system area. Rough state right now:

- **Working:** party and PC storage, shops, node map, town scenes, base trainer
  battles, and the core combat loop (moves, types, damage, single and 2v2).
- **In progress:** relics, move cooldowns and styles, position and party-wide
  effects.
- **Planned:** catching/recruitment, gyms and bosses, masters and rivals,
  economy and scaling, map events and fog of war, unlocks and challenge runs.

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
  map/  towns/  routes/  campaign/  encounters/   the run loop
  core/      event dispatcher, rates, config
UI/          menu/scene router
```

---

## Showcase

### Creatures

https://github.com/user-attachments/assets/37fd310a-7f81-4918-bca0-5bf175075fe9

*Catra.*

![Roster and art direction](media/StyleExploration.png)

### Combat

https://github.com/user-attachments/assets/6949fa0d-eae7-488f-94ff-aa767a7bdbc2

An early combat showcase, 2v2. Battles auto-resolve; I'm still working on how they
read: layout, pacing, animation, and impact. Both 1v1 and 2v2 formats exist.

### Party menu

https://github.com/user-attachments/assets/c3c74b29-404c-4d1b-a405-19657dc0aac6
