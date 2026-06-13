# Event-driven combat

## The problem

Combat started as direct calls and conditional checks. Every cross-cutting effect
(a relic that boosts Fire damage, an item that heals on KO, a master passive that
changes turn order) meant editing the combat code everywhere that effect could
matter. Adding the 20th relic meant touching the damage step, the KO step, the
targeting step, and so on. The work grew with every new effect times every place
it could fire.

Ordering was the other problem. When several effects all modify the same attack,
the order they apply in was whatever the call sequence happened to be. It wasn't
written down anywhere and was hard to change.

## The change

I moved combat onto a central `EventDispatcher` (publish/subscribe). It splits
four things that used to be mixed together:

1. **Events** are facts: "damage was dealt", "HP hit zero", "shop opened". They
   carry a context payload and don't change the world themselves.
2. **The dispatcher** maps `event_name -> list of handlers` and calls them. No game
   logic, no state.
3. **Handlers** (relics, items, master passives) read the event context and add
   their modifiers by editing that context. They don't assume an order and don't
   finalize anything.
4. **The resolver** applies the collected changes in a fixed order and is the only
   place world state actually changes.

```gdscript
EventDispatcher.register(GameEvents.SOME_EVENT, Callable(handler, "_method"))
EventDispatcher.emit(GameEvents.SOME_EVENT, context_dict)
```

Passives edit the `action_ctx.modifiers` dictionary that flows through the turn
pipeline, so a combat step doesn't need to know which passives exist.

## What it changed

- Adding a relic means registering a handler. The damage code never references it.
- Ordering is set in one place (the resolver) instead of being a side effect of
  call order, so it can be read and adjusted.
- The rules layer emits events instead of driving VFX/UI, so the same logic runs
  headless. That's what makes the simulator and tests possible (see
  [balance-by-simulation.md](balance-by-simulation.md)).
- Effects can be added or removed without editing the core steps.

## Invariants

- Events are explicit; handlers don't assume order.
- State changes only in the resolver.
- Flags and queued intent have a defined lifetime and are cleared in one place.
- No per-frame polling. Dispatch runs only when an event is emitted.
