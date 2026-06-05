#!/bin/bash
# SessionStart hook for Claude Code on the web.
# - Installs the OpenAI Codex CLI so `codex` is available in the session.
# - Installs project (Poetry) dependencies so tests and linters can run.
# Safe to run multiple times (idempotent) and never prompts for input.
set -euo pipefail

# Only run in the remote (Claude Code on the web) environment.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# --- OpenAI Codex CLI -------------------------------------------------------
# Install only if it is not already on PATH (keeps re-runs fast).
if ! command -v codex >/dev/null 2>&1; then
  echo "[session-start] Installing OpenAI Codex CLI (@openai/codex)..."
  npm install -g @openai/codex
else
  echo "[session-start] Codex CLI already installed: $(codex --version 2>/dev/null || echo unknown)"
fi

# NOTE: Codex still needs an OPENAI_API_KEY and outbound access to
# api.openai.com. Set OPENAI_API_KEY in the environment's variables and make
# sure the environment's network policy allows api.openai.com, otherwise
# `codex` will fail with auth / "host_not_allowed" errors.

# --- Project dependencies (Poetry) -----------------------------------------
if command -v poetry >/dev/null 2>&1; then
  echo "[session-start] Installing project dependencies with Poetry..."
  poetry install -n
else
  echo "[session-start] Poetry not found; skipping project dependency install." >&2
fi

echo "[session-start] Done."
