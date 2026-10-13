## Purpose

Provides pausable real-time simulation time with discrete speed steps so construction, needs, and other valley systems share one clock.

## ADDED Requirements

### Requirement: Clock can pause and resume
The simulation clock SHALL support an explicit paused state. While paused, simulation time MUST NOT advance. The player MUST be able to pause and resume without resetting accumulated sim time.

#### Scenario: Pause stops time
- **WHEN** the player pauses while the clock is running
- **THEN** subsequent wall-clock time does not increase simulated seconds

#### Scenario: Resume continues the same clock
- **WHEN** the player resumes after a pause
- **THEN** simulated time continues from the value it had at pause, not from zero

### Requirement: Clock speed steps
The simulation clock SHALL expose at least speeds 0 (paused), 1×, and 2×. Needs decay and construction progress MUST scale with the active speed.

#### Scenario: Double speed
- **WHEN** speed is 2× and one wall-clock second elapses unpaused
- **THEN** simulated time advances by two seconds

#### Scenario: Speed zero is pause
- **WHEN** speed is set to 0
- **THEN** simulated time does not advance
