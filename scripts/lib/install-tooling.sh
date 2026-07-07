#!/usr/bin/env bash
# Idempotent install for tau + dream. Handles missing npm, old Codespaces, PATH issues.
# Used by post-create, init, doctor, and manual repair.
set -euo pipefail

INSTALL_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TAU_BIN="${INSTALL_ROOT}/post/tau"
DREAM_NPM_PKG="${DREAM_NPM_PKG:-@taubyte/dream@latest}"

ilog() { echo "[install-tooling] $*"; }
iwarn() { echo "[install-tooling] WARN: $*" >&2; }

path_refresh() {
  local npm_bin=""
  npm_bin="$(npm bin -g 2>/dev/null || true)"
  export PATH="/usr/local/bin:/bin:/usr/bin:${npm_bin}:${HOME}/.npm-global/bin:${PATH}"
}

install_tau() {
  command -v tau >/dev/null 2>&1 && { ilog "tau ok: $(tau version 2>/dev/null | head -1 || echo ready)"; return 0; }
  [ -f "${TAU_BIN}" ] || { ilog "ERROR: missing ${TAU_BIN}"; return 1; }
  ilog "Installing vendored tau..."
  sudo cp "${TAU_BIN}" /usr/local/bin/tau
  sudo chmod 755 /usr/local/bin/tau
  sudo ln -sf /usr/local/bin/tau /bin/tau 2>/dev/null || true
  path_refresh
  command -v tau >/dev/null 2>&1
}

install_node_npm() {
  command -v npm >/dev/null 2>&1 && return 0

  ilog "npm missing — installing Node.js..."

  if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y -qq ca-certificates curl gnupg
    if ! sudo apt-get install -y -qq nodejs npm 2>/dev/null; then
      ilog "Trying NodeSource Node 20..."
      curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
      sudo apt-get install -y -qq nodejs
    fi
  fi

  path_refresh
  command -v npm >/dev/null 2>&1
}

dream_link_npm_global() {
  local root dream_js
  for root in "$(npm root -g 2>/dev/null)" "/usr/lib/node_modules" "/usr/local/lib/node_modules"; do
    dream_js="${root}/@taubyte/dream/index.js"
    if [ -f "${dream_js}" ]; then
      sudo ln -sf "${dream_js}" /usr/local/bin/dream
      sudo chmod 755 /usr/local/bin/dream 2>/dev/null || true
      return 0
    fi
  done
  return 1
}

install_dream_npm() {
  install_node_npm || return 1
  ilog "Installing ${DREAM_NPM_PKG} via npm..."
  if ! sudo npm install -g "${DREAM_NPM_PKG}"; then
    mkdir -p "${HOME}/.npm-global"
    npm config set prefix "${HOME}/.npm-global" 2>/dev/null || true
    npm install -g "${DREAM_NPM_PKG}"
  fi
  path_refresh
  dream_link_npm_global || true
  command -v dream >/dev/null 2>&1
}

install_dream_curl() {
  ilog "npm path failed — trying get.tau.link/dream..."
  curl -fsSL https://get.tau.link/dream | sudo sh
  path_refresh
  command -v dream >/dev/null 2>&1
}

install_dream() {
  if command -v dream >/dev/null 2>&1; then
    if dream --help 2>/dev/null | grep -qE '(^|[[:space:]])start([[:space:]]|$)'; then
      ilog "dream ok (npm CLI with start)"
      return 0
    fi
    iwarn "dream exists but looks legacy — reinstalling..."
  fi

  install_dream_npm && return 0
  install_dream_curl && return 0
  return 1
}

install_tooling_all() {
  path_refresh
  install_tau || return 1
  install_dream || return 1
  path_refresh

  grep -q 'tau autocomplete' "${HOME}/.bashrc" 2>/dev/null || \
    echo 'eval "$(tau autocomplete)"' >> "${HOME}/.bashrc" || true

  ilog "tau:  $(command -v tau) ($(tau version 2>/dev/null | head -1 || echo ok))"
  ilog "dream: $(command -v dream) ($(dream --version 2>/dev/null || dream --help 2>&1 | head -1 || echo ok))"
  ilog "npm:  $(command -v npm || echo missing)"
  ilog "Done."
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  install_tooling_all
fi
