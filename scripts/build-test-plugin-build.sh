#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${1:-.}"
mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR="$(cd "$OUTPUT_DIR" && pwd)"

if ! command -v zip >/dev/null 2>&1; then
	echo "Error: zip is required to create the Decky Loader archive." >&2
	exit 1
fi

cd "$SCRIPT_DIR/.."
echo "Building plugin..."
pnpm run build

if [[ ! -f dist/index.js ]]; then
	echo "Error: build did not produce dist/index.js." >&2
	exit 1
fi

STAGING_DIR="$(mktemp -d)"
trap 'rm -rf "$STAGING_DIR"' EXIT
PLUGIN_DIR="$STAGING_DIR/decky-nonsteam-badges"
mkdir -p "$PLUGIN_DIR/dist"

cp README.md LICENSE plugin.json package.json main.py store_mappings.json "$PLUGIN_DIR/"
cp -R py_modules "$PLUGIN_DIR/"
find "$PLUGIN_DIR/py_modules" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$PLUGIN_DIR/py_modules" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
cp dist/index.js "$PLUGIN_DIR/dist/"

echo "Packaging Decky Loader plugin..."
(
	cd "$STAGING_DIR"
	zip -qr "$STAGING_DIR/decky-nonsteam-badges.zip" decky-nonsteam-badges
)
mv "$STAGING_DIR/decky-nonsteam-badges.zip" "$OUTPUT_DIR/decky-nonsteam-badges.zip"
echo "Created $OUTPUT_DIR/decky-nonsteam-badges.zip"