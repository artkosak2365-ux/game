## Context

See proposal.md for why. The repo is a Godot 4.7.2 GDScript sandbox (`project.godot`, `scenes/screens/main.tscn`). Docs in `docs/systems/utopia-vector.md` define the hidden vector. Setting drafts live under `docs/setting/` and are not simulated yet.

## Goals / Non-Goals

**Goals:**

- One simulation object stepped with `delta * speed`, independent of nodes.
- Autoload clock so pause does not freeze the UI.
- Valley view: top-down, optional pitch, inspect panel, chronicle, levy control, build action.
- Headless tests that do not need the GUI.

**Non-Goals:**

- World generator, seven continents as maps, five-race mechanics, armies, state proclamation.
- GUT/gdUnit4 addons (use SceneTree scripts under `tools/`).
- C#, networking, save/load beyond in-memory.

## Decisions

1. **Sim vs view** — All rules live in `scripts/simulation/`. Scenes only call `step` and render.
2. **Pause** — `GameClock` with speed including 0. UI uses `PROCESS_MODE_ALWAYS`. Do not use `get_tree().paused` for the slice.
3. **Levy** — One float 0–1, extracted each sim-second into `store_grain`. High levy drains rest/hunger. Freedom drops if `fence_closed`.
4. **Opinion** — No aggregate widget. Chronicle lines, `Agent.left`, `Agent.idle`.
5. **Utopia** — `UtopiaVector` per `docs/systems/utopia-vector.md`. Debug print only.
6. **Camera** — `Camera2D` default; a toggle squashes `WorldRoot.scale.y` for a cheap ortho pitch. Placeholders: ColorRect/Polygon2D people and houses.
7. **Tests** — `tools/test_settlement_slice.gd` extends SceneTree. Wired from `scripts/smoke-test.sh`.

## Risks / Trade-offs

- [Need decay tuning feels wrong] → Rates are consts on `ValleySim`; tests use short spans.
- [Utopia 0.92/120s unreachable in play] → Tests pass a shorter `hold_required_seconds`.
- [Tree.paused muscle memory] → Space pauses the clock, not the scene tree.

## Migration Plan

Replace the sandbox label scene in place. Rollback is git revert of this change.

## Open Questions

- Exact pitch angle for the ortho toggle (art clip pending). Default: scale.y = 0.65.
- Pause key is Space.
