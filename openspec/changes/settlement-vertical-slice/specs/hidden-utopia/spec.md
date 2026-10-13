## Purpose

Tracks how close the valley is to a felt utopia using a hidden vector. The player never gets a bar or a victory banner; the session continues if the secret hold is reached.

## ADDED Requirements

### Requirement: Hidden felt score
Each simulation tick the system SHALL compute a felt-utopia value in [0, 1] from needs, freedom (inverse of fencing/coercion), justice (levy not borne only by the hungry), durability over recent time, and voluntary retention (people staying without a fence). The HUD MUST NOT show this value or any labeled utopia/harmony percentage.

#### Scenario: Score exists in the engine
- **WHEN** the valley has been ticking
- **THEN** the simulation exposes a felt value in [0, 1] to tests and debug, not to a labeled HUD meter

#### Scenario: Police granary is not utopia
- **WHEN** stores are high but a movement fence is on or the levy starves workers
- **THEN** felt is lower than a run with similar stores, open movement, and a mild levy

### Requirement: Secret hold does not end the game
If felt stays at or above 0.92 for 120 seconds of simulated time at 1×-equivalent, the system SHALL set an internal `utopia_held` flag. It MUST NOT show a victory banner, end the session, or reset the world. Headless/debug MAY print `UTOPIA_HELD` once.

#### Scenario: Hold does not quit
- **WHEN** `utopia_held` becomes true
- **THEN** the valley is still playable and simulated time can continue

#### Scenario: One-shot debug mark
- **WHEN** `utopia_held` becomes true in a headless test harness
- **THEN** a single `UTOPIA_HELD` line is emitted and a second tick does not emit it again
