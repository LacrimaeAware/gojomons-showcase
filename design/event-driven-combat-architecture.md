# Design Decision: Event-Driven Combat Architecture

*One of the larger architectural decisions in the project — replacing hard-wired
combat logic with a central event bus.*

## The problem

Early on, combat was a tangle of direct calls and conditional checks. Every
cross-cutting effect — a relic that boosts Fire damage, an item that heals on KO,
a master passive that changes turn order — meant editing the combat code *at
every place that effect could matter*. Adding the 20th relic meant touching the
damage step, the KO step, the targeting step… The complexity was growing
**combinatorially**: every new effect × every place it could fire.

The deeper problem was **ordering**. When five different effects all want to
modify the same attack, *what order do they apply in?* With direct calls, the
order was implicit — buried in whatever sequence the code happened to run. It was
impossible to inspect and painful to reason about.

## The decision

I rewrote combat around a central **`EventDispatcher`** (publish/subscribe). The
model separates four concerns that used to be tangled together:

1. **Events** are facts — *"damage was dealt"*, *"HP hit zero"*, *"shop opened"*.
   They carry a context payload and mutate nothing on their own.
2. **The dispatcher** routes `event_name → list of handlers`. It owns no game
   logic and no state; it just calls who's listening.
3. **Handlers** (relics, items, master passives) read the event context and
   *contribute modifiers* by mutating the context dictionary — they never assume
   ordering and never finalize outcomes.
4. **The resolver** processes the accumulated intent in a **known, deterministic
   order** and is the *only* place world state actually mutates.

```gdscript
EventDispatcher.register(GameEvents.SOME_EVENT, Callable(handler, "_method"))
EventDispatcher.emit(GameEvents.SOME_EVENT, context_dict)
```

The key pattern: passives **mutate the `action_ctx.modifiers` dictionary** that
flows through the turn pipeline, rather than each combat step having to know
which passives exist.

## Why it was worth it

- **Adding a relic no longer touches core combat.** You register a callback. The
  damage code never learns the relic exists. New effects compose instead of
  forking the codebase.
- **Ordering became explicit and inspectable** — the resolver enforces a defined
  priority, so "what happens first" is a property you can read and adjust, not an
  accident of call order.
- **It made the simulator possible.** Because the rules layer emits events
  instead of driving VFX/UI directly, the same logic can run headless with no
  scene tree — which is what powers the balance tooling (see
  [balance-by-simulation.md](balance-by-simulation.md)).
- **Complexity grows linearly, not combinatorially.** Systems can be removed
  without breaking others; debugging is log-friendly because every interaction is
  a named event.

## The design invariants I committed to

- Events are explicit; handlers never assume order.
- Mutation happens **only** in the resolver.
- Flags/intent have a defined lifetime and are cleared in one place.
- No per-frame polling — dispatch happens only when an event is emitted.

---

*This is the decision I'd point to first if someone asked what I learned building
this. It's the difference between a codebase that fights you as it grows and one
that absorbs new content gracefully.*
