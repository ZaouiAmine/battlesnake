#!/usr/bin/env bash
# Single entry point — run this to fix missing tau/dream/npm in any Codespace.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "${ROOT}/scripts/lib/install-tooling.sh"
