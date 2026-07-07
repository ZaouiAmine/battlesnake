#!/usr/bin/env bash
# Workshops-style post-create is just: . post/init.sh
# This file is kept for manual use only. Do NOT wire it into devcontainer.json.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

chmod +x "${ROOT}"/post/*.sh "${ROOT}"/scripts/*.sh "${ROOT}"/scripts/lib/*.sh 2>/dev/null || true
. "${ROOT}/post/init.sh"

if [ -n "${GITHUB_TOKEN:-}" ] && command -v gh >/dev/null 2>&1; then
  echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null || true
  gh auth setup-git 2>/dev/null || true
fi

bash "${ROOT}/scripts/tau-login.sh" 2>/dev/null || true

echo ""
echo " Ready. Run: bash scripts/init.sh"
