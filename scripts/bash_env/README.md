# bash_env

Workspace runtimes: host macros, Distrobox, and Docker/Podman (`prod` stub). Distrobox (`humble` / `jazzy`) is **native Linux only** — blocked on Windows/Git Bash and WSL. Helpers are `env::_name`.

| Path | Role |
|------|------|
| `launch/runtime_dispatch.bash` | Main host entry: macros vs Distrobox vs Docker |
| `launch/backends/run_macros.bash` | Host macros (exec → interactive; sourced → load macros) |
| `launch/backends/run_distrobox.bash` | Host create/enter; sourced in-container → ROS/display/macros |
| `launch/backends/run_docker.bash` | Host prod stub; sourced in-image → session template |
| `src/impl_distrobox.bash` | Distrobox functions + `env::_run_distrobox` |
| `src/impl_docker.bash` | Production stub (`env::_run_docker`) |
| `include/` | ROS 2, display, platform, macros session helpers |
| `config/` | CycloneDDS XML, Distrobox/Docker constants (`*_SESSION_SETUP` → backends) |
