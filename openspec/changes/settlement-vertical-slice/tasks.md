## 1. Simulation core

- [x] 1.1 Add `scripts/simulation/game_clock.gd` with speed 0/1/2, accumulated sim time, and `step_delta(wall_delta)`; verify with a headless script that pause freezes time and 2× doubles it
- [x] 1.2 Add `ValleySim` with named agents (hunger, rest, shelter), grain store, levy 0–1, optional fence, timed dwelling jobs, leaving/idle, chronicle; verify needs decay only while unpaused
- [x] 1.3 Implement levy coupling (high levy fills store and hurts hunger/rest; zero levy extracts nothing) and verify both cases in the headless test
- [x] 1.4 Implement `UtopiaVector` per `docs/systems/utopia-vector.md` (min of needs/freedom/justice × durability × retention); verify police-granary scores lower than a mild open valley and that `UTOPIA_HELD` prints once without quitting

## 2. Valley presentation

- [x] 2.1 Replace the sandbox main scene with a 2D valley: Camera2D, placeholder people/houses, levy control, build dwelling, pause/speed, chronicle, inspect panel; verify HUD has no opinion/utopia/harmony fill bar
- [x] 2.2 Add optional pitched/ortho camera toggle and Space to pause the clock (UI stays live); verify inspect still works while paused
- [x] 2.3 Rename the Godot project to Dystopia and point README at `docs/`

## 3. Verification harness

- [x] 3.1 Add `tools/test_settlement_slice.gd` covering clock, construction-vs-pause, levy, walk-out, hidden vector, and no-quit on hold; wire it into `scripts/smoke-test.sh` and confirm `./scripts/smoke-test.sh` passes
