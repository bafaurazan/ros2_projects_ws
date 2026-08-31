---
name: workspace-macros
description: Add or change workspace shell macros under scripts/bash_macros/. Use when creating a new macro, a scripts/bash_macros bundle in a subrepo, or explaining load_macros and diag.
---

# Workspace macros

Read [scripts/bash_macros/README.md](../../../scripts/bash_macros/README.md) for bundle layout, registry, helpers, and `load_macros`. Namespace (do not duplicate the bundle name): [bash/macros.mdc](../../rules/bash/macros.mdc). Prefixes: [bash/naming.mdc](../../rules/bash/naming.mdc).

After adding or changing a macro file, run `load_macros` (or open a new `./scripts/setup.bash` shell), then `diag` to confirm the list.
