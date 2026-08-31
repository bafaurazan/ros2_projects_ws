# bash_bringup

Workspace CLI router. Public entry remains `./scripts/setup.bash`.

| Path | Role |
|------|------|
| `launch/bringup.bash` | Wrapper: set root, source include + src, run `_dispatch` |
| `src/dispatch.bash` | Compose `humble` / `jazzy` / `macros` |
| `src/macros_session.bash` | Host session bootstrap (`_load_macros`) |
| `include/bringup_helpers.bash` | `_is_sourced`, `_fail`, `_print_usage`, … |
| `include/macros_session_helpers.bash` | session load guards and workspace root |
