# bash_bringup

Workspace CLI router. Public entry remains `./scripts/setup.bash`. Helpers are `bringup::_name`.

| Path | Role |
|------|------|
| `launch/bringup.bash` | Wrapper: set root, source include + src, run `bringup::_dispatch` |
| `src/dispatch.bash` | Compose `humble` / `jazzy` / `macros` |
| `src/macros_session.bash` | Host session bootstrap (`bringup::_load_macros`) |
| `include/bringup_helpers.bash` | `bringup::_is_sourced`, `::_fail`, `::_print_usage`, `::_cleanup`, … |
| `include/macros_session_helpers.bash` | session load guards and workspace root |
