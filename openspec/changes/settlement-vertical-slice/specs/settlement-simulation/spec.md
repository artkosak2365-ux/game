## Purpose

Runs a single home-valley settlement: named people with needs, timed building, one levy, and opinion shown as behavior rather than a meter.

## ADDED Requirements

### Requirement: Named valley agents with needs
The valley SHALL contain multiple named agents. Each agent SHALL track hunger, rest, and shelter on a 0–1 scale. While the clock runs, hunger and rest MUST decay. Shelter MUST improve when the agent has access to a completed dwelling.

#### Scenario: Needs decay while time runs
- **WHEN** an agent starts with hunger 1.0 and the clock runs unpaused at 1× for several simulated seconds
- **THEN** that agent's hunger is lower than it started

#### Scenario: Pause freezes needs
- **WHEN** the clock is paused
- **THEN** agent hunger and rest do not change

### Requirement: Timed construction
The player SHALL be able to start at least one dwelling construction. Completing it SHALL take a positive amount of simulated time. Construction MUST NOT complete while the clock is paused.

#### Scenario: House completes after sim time
- **WHEN** the player starts a dwelling and enough unpaused simulated time elapses
- **THEN** the dwelling is complete and can provide shelter

#### Scenario: Paused build does not finish
- **WHEN** a dwelling is under construction and the clock is paused for longer than the remaining build time
- **THEN** the dwelling is still incomplete

### Requirement: Single levy
The valley SHALL have exactly one player-controlled tax in this slice: a grain/labor levy rate. A high levy SHALL reduce agent rest or increase hunger (labor taken from living) and SHALL add to a shared store. A levy of zero SHALL not extract.

#### Scenario: High levy fills the store and hurts people
- **WHEN** the levy is set high and simulated time advances
- **THEN** the shared store increases and at least one agent's hunger or rest is worse than with levy zero over the same span

#### Scenario: Zero levy extracts nothing
- **WHEN** the levy is 0 and time advances
- **THEN** the shared store does not increase from the levy

### Requirement: Opinion is behavior not a bar
The valley MUST NOT display a numeric public-opinion, harmony, or utopia meter. Dissatisfaction SHALL appear as agents becoming idle, leaving the valley, or chronicle lines. The player SHALL be able to inspect a named agent and see need values.

#### Scenario: No opinion meter in the HUD
- **WHEN** the valley screen is shown
- **THEN** it contains no control whose label or purpose is a fill-bar for opinion, harmony, or utopia

#### Scenario: People walk out under cruelty
- **WHEN** hunger is severe or the levy stays high long enough
- **THEN** at least one agent leaves or is marked leaving, and a chronicle line is recorded

#### Scenario: Inspect a person
- **WHEN** the player inspects a named agent
- **THEN** the UI shows that agent's name, hunger, rest, and shelter
