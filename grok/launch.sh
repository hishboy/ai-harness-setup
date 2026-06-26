#!/bin/sh
# grok harness — launch (runs on EVERY launch, as root, cwd /workspace, under sh).
# Rewrites the SEED config's theme from the create-time TRIBES_THEME, exports the
# ENV-based proxy config (GROK_*), waits (bounded) for egress, then execs grok.

# --- theme (per-launch FILE config) -----------------------------------------
# Grok (xAI, ratatui) has NO OSC/auto theme detection — it hard-defaults to dark
# (GrokNight) and only reads its theme from .grok/config.toml [ui] theme. The file
# is committed as a SEED with theme = "__TRIBES_THEME__"; we sed the live theme
# line in place on every launch so a theme toggle takes effect on relaunch. The
# regex matches the `theme = "..."` line generically, so it works on both the
# original placeholder (first launch) and a previously-substituted value
# (relaunches). We do NOT touch the tty: an OSC-11 probe right before exec wedged
# grok's pager so it never painted its first frame.
theme=$([ "$TRIBES_THEME" = light ] && echo light || echo dark)
mkdir -p /workspace/.grok
[ -e /workspace/.grok/config.toml ] || printf '[ui]\ntheme = "__TRIBES_THEME__"\n' > /workspace/.grok/config.toml
sed -i "s|theme = \"[^\"]*\"|theme = \"$theme\"|" /workspace/.grok/config.toml

# --- proxy (ENV-only for grok) ----------------------------------------------
# grok CLI → OpenAI chat surface via its base-url override. An existing session
# beats the key, so log out first. Under `setsid -w` (own session, no controlling
# tty) so the grok binary can't grab/leave the pty's foreground group
# backgrounded; -w waits so creds are cleared before grok starts.
if [ -n "$TRIBES_LLM_MODEL" ] && [ -n "$API_BASE_URL" ] && [ -n "$TRIBES_API_KEY" ]; then
  export GROK_MODELS_BASE_URL="${API_BASE_URL}/llm/proxy"
  export GROK_CODE_XAI_API_KEY="$TRIBES_API_KEY"
  setsid -w grok logout </dev/null >/dev/null 2>&1 || true
fi

# --- bounded egress wait ----------------------------------------------------
# grok's startup BLOCKS its first paint on a model-catalog fetch to api.x.ai over
# IPv6, fired ~3s after boot. On a COLD boot, egress (host ND/routing for the
# routed prefix) can lag the eager-spawn, so that SYN is silently dropped and
# connect() hangs on SYN-retransmit for minutes — grok sits at "Starting grok..."
# forever. Wait — bounded — for egress to api.x.ai before launching, so the fetch
# returns fast (RST/HTTP) instead of hanging. curl returning at all proves the TCP
# path is alive; 30s cap so a truly offline VM still launches.
for _ in $(seq 1 30); do
  curl -s -o /dev/null --max-time 2 https://api.x.ai/ 2>/dev/null && break
  sleep 1
done

# --- launch -----------------------------------------------------------------
# --always-approve disables per-tool approval prompts (no trust gate exists in
# the official xAI CLI) — the microVM is the security boundary.
exec grok --always-approve
