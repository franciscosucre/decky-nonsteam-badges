#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLUGIN_NAME="decky-nonsteam-badges"
PLUGIN_ROOT="${DECKY_PLUGIN_ROOT:-$HOME/homebrew/plugins}"
INSTALL_DIR="$PLUGIN_ROOT/$PLUGIN_NAME"
SUDO="${SUDO:-sudo}"
SYSTEMCTL="${SYSTEMCTL:-systemctl}"

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
	echo "Error: run this script as the Deck user, not as root." >&2
	exit 1
fi
if [[ -z "$PLUGIN_ROOT" || "$PLUGIN_ROOT" == "/" ]]; then
	echo "Error: invalid Decky plugin root: $PLUGIN_ROOT" >&2
	exit 1
fi
if ! command -v "$SUDO" >/dev/null 2>&1; then
	echo "Error: sudo is required to install the plugin and restart plugin_loader." >&2
	exit 1
fi
if ! command -v "$SYSTEMCTL" >/dev/null 2>&1; then
	echo "Error: systemctl is required to restart plugin_loader." >&2
	exit 1
fi

cd "$REPO_ROOT"
echo "Building plugin..."
pnpm run build

if [[ ! -f dist/index.js ]]; then
	echo "Error: build did not produce dist/index.js." >&2
	exit 1
fi

STAGING_DIR="$(mktemp -d)"
LOADER_STOPPED=0
cleanup() {
	local exit_code=$?
	trap - EXIT
	if [[ "$LOADER_STOPPED" == "1" ]]; then
		"$SUDO" "$SYSTEMCTL" start plugin_loader || echo "Warning: could not restart plugin_loader." >&2
	fi
	rm -rf "$STAGING_DIR"
	exit "$exit_code"
}
trap cleanup EXIT

PLUGIN_DIR="$STAGING_DIR/$PLUGIN_NAME"
mkdir -p "$PLUGIN_DIR/dist"
cp README.md LICENSE plugin.json package.json main.py store_mappings.json "$PLUGIN_DIR/"
cp -R py_modules "$PLUGIN_DIR/"
find "$PLUGIN_DIR/py_modules" -type d -name __pycache__ -prune -exec rm -rf {} +
find "$PLUGIN_DIR/py_modules" -type f \( -name '*.pyc' -o -name '*.pyo' \) -delete
cp dist/index.js "$PLUGIN_DIR/dist/"

echo "Stopping plugin_loader..."
"$SUDO" "$SYSTEMCTL" stop plugin_loader
LOADER_STOPPED=1
"$SUDO" rm -rf -- "$INSTALL_DIR"
"$SUDO" install -d -o "$(id -u)" -g "$(id -g)" "$INSTALL_DIR"
cp -R "$PLUGIN_DIR/." "$INSTALL_DIR/"
"$SUDO" "$SYSTEMCTL" start plugin_loader
LOADER_STOPPED=0

echo "Installed $PLUGIN_NAME to $INSTALL_DIR and restarted plugin_loader."