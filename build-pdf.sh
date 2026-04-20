#!/usr/bin/env bash
set -euo pipefail

tmp="$(mktemp)"
chmod 600 "$tmp"

cleanup() {
	rm -f "$tmp"
}

trap cleanup EXIT INT TERM

target="${1:-main}"
target="${target%.tex}"

sops decrypt --output-type yaml secrets.enc.yaml >"$tmp"
RESUME_SECRETS_FILE="$tmp" latexmk -lualatex -interaction=nonstopmode -halt-on-error "${target}.tex"
