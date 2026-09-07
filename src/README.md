# src/

Cloned subprojects live here (each is its own git repository).

Everything under `src/` except this `README.md` is gitignored by the workspace root. Clone via `importer <name>` ([`scripts/bash_macros/config/importer.repos`](../scripts/bash_macros/config/importer.repos)) or manually.

Each subproject may provide its own `scripts/bash_macros/`, `README.md`, and optional `.cursor/` / `AGENTS.md`. Macros are discovered by `load_macros` and listed by `diag` — the parent workspace does not hardcode them.
