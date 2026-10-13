# Dystopia

Pausable real-time civilization sim in Godot 4.7. The world is a dystopia; the hidden goal is a felt utopia — no meter, no victory banner.

Windows is the first ship target; macOS uses the same project later.

Design notes live in [`docs/`](docs/README.md):

- [Five peoples](docs/setting/races.md) (provisional)
- [Seven continents](docs/setting/continents.md) (provisional)
- [Visual climate](docs/setting/visual-climate.md)
- [Hidden utopia vector](docs/systems/utopia-vector.md)

The playable slice is a home valley: named people, timed building, one levy, a chronicle instead of an opinion bar, and pause/speed on a simulation clock.

## Toolchain

| Tool | Role |
| --- | --- |
| Godot 4.7.2 | Editor, headless import, Windows/macOS export |
| `gdlint` / `gdformat` | GDScript lint and format |
| OpenSpec | Spec-driven changes (`/opsx-propose`) |
| Superpowers | Brainstorm → plan → TDD |
| GodotPrompter | Godot 4 domain skills |
| GSD Core | Longer milestone loop |
| Matt Pocock skills | Grilling, specs, tickets, TDD |
| Karpathy guidelines | Simplicity and surgical diffs |

## Commands

```bash
./scripts/smoke-test.sh
./scripts/export-windows.sh
./scripts/export-macos.sh
```

Cloud Agents refresh the toolchain with `./scripts/cloud-agent-install.sh`.
