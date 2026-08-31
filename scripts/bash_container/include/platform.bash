#!/usr/bin/bash

# Host platform checks for Distrobox (native Linux only).

_is_windows_host() {
    case "$(uname -s 2>/dev/null)" in
        MINGW*|MSYS*|CYGWIN*) return 0 ;;
    esac
    return 1
}

_is_wsl() {
    grep -qiE 'microsoft|wsl' /proc/version 2>/dev/null
}

_require_native_linux_for_distrobox() {
    if _is_windows_host; then
        echo "Error: Distrobox (humble/jazzy) is not supported on Windows/Git Bash." >&2
        echo "Use: ./scripts/setup.bash macros" >&2
        echo "Run humble/jazzy from native Linux." >&2
        return 1
    fi
    if _is_wsl; then
        echo "Error: Distrobox is not supported under WSL." >&2
        echo "Use native Linux for ROS containers, or ./scripts/setup.bash macros on Windows." >&2
        return 1
    fi
    return 0
}
