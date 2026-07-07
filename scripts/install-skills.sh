#!/usr/bin/env bash
# Optional — NOT run during Codespace create (npx can hang for a long time).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v npx >/dev/null 2>&1; then
  echo "Node/npx not installed. Skipping skills install."
  exit 0
fi

mkdir -p "${HOME}/.cursor/skills"
npx skills@latest add taubyte/skills --agent cursor --global --copy --yes
npx skills@latest add taubyte/skills -g --all
echo "Taubyte skills installed."
