#!/usr/bin/env bash
set -Eeuo pipefail

# Recreate my Pi setup.
#
# Override example:
#   PI_CODING_AGENT_DIR="$HOME/.pi/agent-work" bash pi/install-pi.sh

PI_CONFIG_DIR="${PI_CODING_AGENT_DIR:-${HOME}/.pi/agent}"

# Keep Pi startup quiet and avoid install/update telemetry while this setup runs.
export PI_CODING_AGENT_DIR="$PI_CONFIG_DIR"
export PI_SKIP_VERSION_CHECK="${PI_SKIP_VERSION_CHECK:-1}"
export PI_TELEMETRY="${PI_TELEMETRY:-0}"

PI_PACKAGES=(
  "npm:pi-mcp-adapter@2.8.0"
  "npm:pi-subagents@0.27.0"
  "npm:pi-lens@3.8.47"
  "npm:context-mode@1.0.161"
  "npm:@juicesharp/rpiv-ask-user-question@1.17.1"
  "npm:@plannotator/pi-extension@0.19.26"
  "npm:pi-web-access@0.10.7"
  "npm:@juicesharp/rpiv-advisor@1.17.1"
  "npm:@juicesharp/rpiv-btw@1.17.1"
  "npm:pi-powerline-footer@0.5.6"
  "npm:pi-intercom@0.6.0"
)

log() {
  printf '\n==> %s\n' "$*"
}

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$cmd" >&2
    exit 1
  fi
}

log "Checking prerequisites"
require_command node
require_command npm

log "Installing latest Pi CLI @earendil-works/pi-coding-agent"
npm install -g --ignore-scripts @earendil-works/pi-coding-agent

require_command pi
mkdir -p "$PI_CONFIG_DIR"

log "Installing Pi packages/extensions"
for package_source in "${PI_PACKAGES[@]}"; do
  # This is idempotent: Pi updates the existing settings entry for the same package identity.
  pi install "$package_source"
done

log "Normalizing Pi package settings"
PI_SETTINGS_FILE="${PI_CONFIG_DIR}/settings.json" node <<'NODE'
const fs = require('fs');
const path = require('path');

const settingsFile = process.env.PI_SETTINGS_FILE;
const desiredEntries = [
  'npm:pi-mcp-adapter@2.8.0',
  'npm:pi-subagents@0.27.0',
  'npm:pi-lens@3.8.47',
  'npm:context-mode@1.0.161',
  'npm:@juicesharp/rpiv-ask-user-question@1.17.1',
  { source: 'npm:@plannotator/pi-extension@0.19.26', skills: [] },
  'npm:pi-web-access@0.10.7',
  'npm:@juicesharp/rpiv-advisor@1.17.1',
  'npm:@juicesharp/rpiv-btw@1.17.1',
  'npm:pi-powerline-footer@0.5.6',
  'npm:pi-intercom@0.6.0',
];

function sourceOf(entry) {
  if (typeof entry === 'string') return entry;
  if (entry && typeof entry === 'object' && typeof entry.source === 'string') return entry.source;
  return '';
}

function npmIdentity(source) {
  if (!source.startsWith('npm:')) return null;
  const spec = source.slice('npm:'.length);

  // @scope/name@version -> @scope/name
  if (spec.startsWith('@')) {
    const match = spec.match(/^(@[^/]+\/[^@]+)(?:@.*)?$/);
    return match ? `npm:${match[1]}` : `npm:${spec}`;
  }

  // name@version -> name
  const match = spec.match(/^([^@]+)(?:@.*)?$/);
  return match ? `npm:${match[1]}` : `npm:${spec}`;
}

function identity(entry) {
  const source = sourceOf(entry);
  return npmIdentity(source) || source;
}

let settings = {};
if (fs.existsSync(settingsFile)) {
  settings = JSON.parse(fs.readFileSync(settingsFile, 'utf8'));
}

const desiredIds = new Set(desiredEntries.map(identity));
const existingPackages = Array.isArray(settings.packages) ? settings.packages : [];

settings.packages = [
  ...existingPackages.filter((entry) => sourceOf(entry).startsWith('npm:') && !desiredIds.has(identity(entry))),
  ...desiredEntries,
];

fs.mkdirSync(path.dirname(settingsFile), { recursive: true });
fs.writeFileSync(settingsFile, `${JSON.stringify(settings, null, 2)}\n`);
NODE

log "Validating installation"
pi --version
pi list

cat <<'EOF'

Pi setup complete.

Next steps:
- Auth is machine-local. Run `pi`, then `/login`, if this machine is not authenticated yet.
- Secrets/runtime files such as auth.json, OAuth tokens, mcp.json, models.json, caches, and sessions are not managed by this script.
EOF
