# game

Godot 4.7 strategy game. Windows is the first ship target; macOS uses the same project later.

Game design details are still open. This repository currently holds the engine project, Cloud Agent toolchain, and agent skills.

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
