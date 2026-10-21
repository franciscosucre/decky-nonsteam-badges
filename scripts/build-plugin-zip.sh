#!/usr/bin/env bash
set -euo pipefail

# Packages a directory staged by build-plugin-content.sh into a Decky Loader ZIP.
# Usage: build-plugin-zip.sh [CONTENT_DIR] [OUTPUT_FILE]
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

CONTENT_DIR="${1:-$REPO_ROOT/decky-nonsteam-badges}"
OUTPUT_FILE="${2:-$REPO_ROOT/decky-nonsteam-badges.zip}"

if ! command -v zip >/dev/null 2>&1; then
	echo "Error: zip is required to create the Decky Loader archive." >&2
	exit 1
fi

if [[ ! -d "$CONTENT_DIR" ]]; then
	echo "Error: content directory '$CONTENT_DIR' not found." >&2
	echo "Run scripts/build-plugin-content.sh first to stage the plugin content." >&2
	exit 1
fi

CONTENT_DIR="$(cd "$CONTENT_DIR" && pwd)"
mkdir -p "$(dirname "$OUTPUT_FILE")"
OUTPUT_FILE="$(cd "$(dirname "$OUTPUT_FILE")" && pwd)/$(basename "$OUTPUT_FILE")"

PLUGIN_NAME="$(basename "$CONTENT_DIR")"
PARENT_DIR="$(dirname "$CONTENT_DIR")"

echo "Packaging Decky Loader plugin ZIP..." >&2
rm -f "$OUTPUT_FILE"
(
	cd "$PARENT_DIR"
	zip -qr "$OUTPUT_FILE" "$PLUGIN_NAME"
)
echo "Created $OUTPUT_FILE"
