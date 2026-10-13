## Why

Dystopia needs a playable valley before races, continents, or world unification exist as systems. The sandbox scene does not pause time, house named people, or show opinion without a meter. This change lands the first slice so later layers hang off one simulation.

## What Changes

- Add a pausable real-time clock with speed steps. Construction and needs advance only while the clock runs.
- Simulate a home-valley settlement: named agents, two or three needs, timed building, one levy, and opinion as behavior (leaving, idling, chronicle) — not a harmony bar.
- Compute a hidden utopia vector from that state. Crossing a secret hold threshold may print a one-shot debug line and does not end the session.
- Present the valley in 2D from above with an optional pitched/ortho camera and inspect-a-person UI.
- Rename the project to Dystopia where the window title and README describe the game.

## Capabilities

### New Capabilities

- `game-clock`: Pausable sim time and speed multipliers used by construction and needs.
- `settlement-simulation`: Valley agents, needs, jobs, a single tax, and opinion symptoms.
- `hidden-utopia`: Secret felt-utopia vector with no HUD meter and no victory banner.

### Modified Capabilities

- (none)

## Impact

- `project.godot`, `scenes/screens/main.tscn`, autoloads, new `scripts/simulation/` logic, valley UI, `docs/`, `README.md`, `./scripts/smoke-test.sh`.
- No new engine, addons, or C#.
- Headless tests must cover clock, tax/needs coupling, and “no utopia HUD”.
