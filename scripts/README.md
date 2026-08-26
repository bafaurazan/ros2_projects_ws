# scripts/

Workspace entry, session bootstrap, and macros. CLI is always:

```bash
./scripts/setup.bash humble
./scripts/setup.bash jazzy
./scripts/setup.bash macros
./scripts/setup.bash jazzy prod   # reserved — not implemented yet
```

## Flow

| Command | What runs | Effect |
|---|---|---|
| `./scripts/setup.bash macros` | `session/macros/setup.bash` → `macros/api/load.bash` | Host shell (Git Bash); macros only, no ROS |
| `./scripts/setup.bash jazzy` | `session/container/runtime/setup.bash` → `runtime/distrobox/setup.bash` → (container) `session/container/setup.bash` → `load.bash` | Distrobox + ROS + macros |
| `./scripts/setup.bash jazzy prod` | `runtime/setup.bash` → `runtime/docker/setup.bash` | Stub until production runtime exists |

`source scripts/setup.bash macros` loads macros in the current shell instead of opening a new one.

## Layout

```text
setup.bash                         # CLI router only
session/
  macros/setup.bash                # host session → load_macros
  container/
    setup.bash                     # session inside runtime (hook from ~/.bashrc)
    modules/                       # ROS, display, CycloneDDS
    runtime/
      setup.bash                   # host: pick Distrobox vs Docker
      distrobox/                   # Distrobox create/enter + bashrc hook
      docker/                      # prod stub
macros/
  api/load.bash                    # find + source all scripts/macros/ (root only)
  api/build.bash                   # build, cbuild
  api/diag.bash                    # diag
```

Three `setup.bash` files under `session/container/` have different jobs:

- `runtime/setup.bash` — host dispatcher
- `runtime/distrobox/setup.bash` — Distrobox implementation
- `container/setup.bash` — ROS + macros **inside** the runtime (shared by Distrobox and future Docker)

Macros convention: [macros/README.md](macros/README.md)
