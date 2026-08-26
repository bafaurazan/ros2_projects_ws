#!/usr/bin/env bash

set -euo pipefail

# Production runtime (Docker/Podman) is reserved; not implemented yet.

_mode="${1:-}"

echo "Error: production runtime ('${_mode} prod') is not implemented yet." >&2
echo "See README.md TODO for Docker/Podman production entry." >&2
echo "Usage: ./scripts/setup.bash [humble|jazzy [prod]|macros]" >&2
exit 1
