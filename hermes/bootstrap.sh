#!/bin/sh
# Hermes harness bootstrap — runs ONCE on first boot, as root, cwd /workspace, sh.
# Installs the Hermes CLI, then fills the placeholders in the COMMITTED seed config
# /workspace/.hermes/config.yaml. Hermes is fully FILE-based: it reads
# model/provider/skin from that file, so there is NO env-based config to defer to
# launch.sh. launch.sh re-seds the display.skin line each launch so a theme toggle
# takes effect on relaunch.
set -e

# --- install ----------------------------------------------------------------
command -v hermes >/dev/null 2>&1 ||
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# --- AGENTS.md: substitute the VM's public host -----------------------------
# Hermes reads AGENTS.md; replace the __HOST__ placeholder with this VM's host.
[ -n "$HOSTNAME" ] && [ -e /workspace/AGENTS.md ] &&
  sed -i "s|__HOST__|$HOSTNAME|g" /workspace/AGENTS.md || true

# --- proxy-routed config ----------------------------------------------------
# Fill the seed config's placeholders. Hermes declares a user `tribes` provider in
# config.yaml's providers map and points model.provider at it (the built-in
# openai-api provider has a hardcoded Nous baseUrl, so an env override never takes
# effect — this MUST be a file). transport: chat_completions makes the OpenAI SDK
# append /chat/completions to `api`. We omit a provider `models` list so the picker
# discovers the full catalog from the proxy's GET /models; model.default preselects
# ours. Skip gracefully if the proxy env is absent (CLI falls back to user creds).
if [ -n "$TRIBES_LLM_MODEL" ] && [ -n "$API_BASE_URL" ] && [ -n "$TRIBES_API_KEY" ]; then
  sed -i "s|__TRIBES_PROXY__|${API_BASE_URL}/llm/proxy|g" /workspace/.hermes/config.yaml
  sed -i "s|__TRIBES_TOKEN__|$TRIBES_API_KEY|g" /workspace/.hermes/config.yaml
  sed -i "s|__TRIBES_MODEL__|$TRIBES_LLM_MODEL|g" /workspace/.hermes/config.yaml
fi
