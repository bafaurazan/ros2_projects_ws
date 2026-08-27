# bash_container

Container runtime for the workspace (Distrobox today; Docker/Podman reserved via `prod`).

| Path | Role |
|------|------|
| `launch/runtime_dispatch.bash` | Host entry: Distrobox vs Docker |
| `src/container_session.bash` | In-container bootstrap (ROS, display, macros); hooked from `~/.bashrc` |
| `src/distrobox/distrobox_enter.bash` | Create/enter Distrobox + refresh bashrc hook |
| `src/docker/docker_enter.bash` | Production stub |
| `include/` | ROS 2 and display helpers |
| `config/` | CycloneDDS XML, Distrobox/Docker constants |
