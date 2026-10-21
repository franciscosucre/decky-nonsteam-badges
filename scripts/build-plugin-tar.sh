#!/usr/bin/env bash
set -euo pipefail

# Packages a directory staged by build-plugin-content.sh into a Decky Loader TAR.
# Usage: build-plugin-tar.sh [CONTENT_DIR] [OUTPUT_FILE]
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd)"

CONTENT_DIR="${1:-$REPO_ROOT/decky-nonsteam-badges}"
OUTPUT_FILE="${2:-$REPO_ROOT/decky-nonsteam-badges.tar.gz}"

if ! command -v tar >/dev/null 2>&1; then
	echo "Error: tar is required to create the Decky Loader archive." >&2
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

echo "Packaging Decky Loader plugin TAR..." >&2
rm -f "$OUTPUT_FILE"
tar -czf "$OUTPUT_FILE" -C "$PARENT_DIR" "$PLUGIN_NAME"
echo "Created $OUTPUT_FILE"
