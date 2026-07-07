#!/bin/sh
# Codespace post-create — delegates to install-tooling (all fallbacks).
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash "${ROOT}/scripts/lib/install-tooling.sh"
