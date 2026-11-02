#!/bin/sh
# Installs the Datto RMM connector and skills for Claude Code. Run: sh install-claude-code.sh
set -e

fail() { printf '\nERROR: %s\n' "$1" >&2; exit 1; }
here=$(cd "$(dirname "$0")" && pwd)

# Accepts the versioned release name (datto-rmm-1.2.3.mcpb) or the plain one.
# Several matches in one folder (e.g. an old and a new release) is an error, not a guess.
find_file() {
  for d in "$here" "$PWD"; do
    n=0
    for f in "$d"/$1 "$d"/$2; do [ -f "$f" ] && { n=$((n + 1)); hit=$f; }; done
    [ "$n" -le 1 ] || fail "Found more than one $1 in $d. Keep only the release you want to install."
    [ "$n" -eq 1 ] && { echo "$hit"; return; }
  done
}
mcpb=$(find_file 'datto-rmm-[0-9]*.mcpb' datto-rmm.mcpb); [ -n "$mcpb" ] || fail "datto-rmm.mcpb not found. Put it in the same folder as this script."
zip=$(find_file 'Datto-RMM-plugin-[0-9]*.zip' Datto-RMM-plugin.zip); [ -n "$zip" ] || fail "Datto-RMM-plugin.zip not found. Put it in the same folder as this script."

command -v node >/dev/null || fail "Node.js is not installed. Install Node.js 22 or newer from https://nodejs.org, then run this again."
[ "$(node -p 'process.versions.node.split(".")[0]')" -ge 22 ] || fail "Node.js $(node -v) is too old. Install Node.js 22 or newer."
command -v claude >/dev/null || fail 'Claude Code (the "claude" command) is not installed or not on PATH.'
command -v unzip >/dev/null || fail "unzip is not installed."

echo "[1/3] Installing connector..."
dir="$HOME/.drmm-mcpb-client"
mkdir -p "$dir"
unzip -qo "$mcpb" -d "$dir"
[ -f "$dir/dist/bundle.cjs" ] || fail "Connector files missing after extract. Is datto-rmm.mcpb the right file?"

echo "[2/3] Enter your Datto RMM platform number, API key and API secret when asked."
node "$dir/dist/bundle.cjs" setup || fail "Credential setup failed. Run this script again."
claude mcp remove datto-rmm --scope user >/dev/null 2>&1 || true
claude mcp add --transport stdio --scope user datto-rmm -- node "$dir/dist/bundle.cjs" || fail "Could not register the connector with Claude Code."

echo "[3/3] Installing skills..."
rm -rf "$HOME/.claude/skills/datto-rmm"
mkdir -p "$HOME/.claude/skills/datto-rmm"
unzip -qo "$zip" -d "$HOME/.claude/skills/datto-rmm"

printf "\nDone. Start 'claude' and ask: List my Datto RMM sites.\n"
