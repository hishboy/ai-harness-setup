#!/bin/sh
# claude harness — bootstrap (runs ONCE, as root, cwd /workspace, under sh).
# Installs the Claude Code binary and stamps the host into the primer. All
# FILE-based config (.claude.json trust file, .claude/settings.json) ships as
# committed real files in this harness dir, copied verbatim into /workspace by
# the dispatcher — there is nothing to generate here. The proxy is ENV-only for
# claude (ANTHROPIC_*), configured in launch.sh.

set -e

# --- install the harness binary ---------------------------------------------
npm install -g --no-fund --no-audit @anthropic-ai/claude-code@latest || true

# --- stamp the host into the primer -----------------------------------------
# AGENTS.md/CLAUDE.md ship with a __HOST__ placeholder; substitute the VM's
# public subdomain so the agent knows its live URL.
host="${HOSTNAME:-$(cat /etc/hostname 2>/dev/null)}"
if [ -n "$host" ]; then
  for file in /workspace/AGENTS.md /workspace/CLAUDE.md; do
    [ -e "$file" ] && sed -i "s|__HOST__|$host|g" "$file"
  done
fi
