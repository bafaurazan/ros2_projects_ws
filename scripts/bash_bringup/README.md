# bash_bringup

Workspace CLI router. Public entry remains `./scripts/setup.bash`. Helpers are `bringup::_name`. All modes hand off to `bash_env`.

| Path | Role |
|------|------|
| `launch/bringup.bash` | Main entry: set root, source include + src, run `bringup::_dispatch` |
| `src/dispatch.bash` | Hand-off to `bash_env/launch/runtime_dispatch.bash` |
| `include/bringup_helpers.bash` | `bringup::_is_sourced`, `::_fail`, `::_print_usage`, `::_cleanup` |
