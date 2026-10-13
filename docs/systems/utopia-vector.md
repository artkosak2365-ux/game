# Hidden utopia vector (draft)

Utopia is **possible, extremely hard, and not a win screen**. The engine may know a score. The player reads it from the settlement: stores, people who stay, quiet nights, no terror, no paper cage. If the vector ever crosses a secret threshold, **nothing banners**. The world simply holds. It can still fall.

There is **no fill bar** labeled Utopia, Harmony, or Victory.

## Axes (0.0–1.0, higher is closer)

Computed each sim tick from world state. Not shown in HUD.

1. **Needs** — fraction of regional agents whose hunger, rest, and shelter are above a humane floor (not maxed luxury).
2. **Freedom** — inverse of coerced labor, movement bans, and silenced dissent. A full granary with a closed gate scores low.
3. **Justice** — whether the levy and the law hit the same classes that eat the surplus. A tax that only the hungry pay scores low.
4. **Durability** — needs/freedom/justice held for a stretch of sim time, not a lucky hour.
5. **Voluntary union** — for the slice this is local: people *stay* without being fenced; later it becomes other peoples accepting a shared peace without conquest. Forced annexation **lowers** this axis.

## Combination (secret)

```
felt = min(needs, freedom, justice) * durability * voluntary_union
```

A single dump-stat cannot carry it. Min() is the point: a police granary is not utopia.

**Easter egg (not HUD):** if `felt` stays at or above `0.92` for a configured span (slice: 120 seconds of sim-time at 1×), the sim sets `utopia_held = true`. Gameplay continues. Debug/headless may print `UTOPIA_HELD` once. The player is not told why the town went still.

## Player-facing signals (allowed)

- People leave, idle, or refuse work.
- Construction stalls when the levy is cruel.
- Inspecting a named person shows hunger, rest, shelter, and whether they feel fenced.
- Chronicle lines (“three walked east at dusk”).

Forbidden: progress bar, percentage, “harmony +12”, victory toast.

## Slice scope

Vertical slice implements axes 1–4 on the home valley plus a local stand-in for 5 (retention vs fence). World unification waits for the state layer.
