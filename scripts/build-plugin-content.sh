#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"
PLUGIN_NAME="decky-nonsteam-badges"

# Directory that will contain the staged "decky-nonsteam-badges/" folder.
OUTPUT_DIR="${1:-.}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

cd "$REPO_ROOT"
echo "Building plugin..." >&2
pnpm run build >&2

if [[ ! -f dist/index.js ]]; then
	echo "Error: build did not produce dist/index.js." >&2
	exit 1
fi

PLUGIN_DIR="$OUTPUT_DIR/$PLUGIN_NAME"
rm -rf "$PLUGIN_DIR"
mkdir -p "$PLUGIN_DIR/dist"

cp README.md LICENSE plugin.json package.json main.py store_mappings.json "$PLUGIN_DIR/"
cp -R py_modules "$PLUGIN_DIR/"
find "$PLUGIN_DIR/py_modules" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$PLUGIN_DIR/py_modules" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
cp dist/index.js "$PLUGIN_DIR/dist/"

# Emit the staged plugin directory so callers can pass it to the packagers.
echo "$PLUGIN_DIR"
