#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/manifest.json"
DIST_DIR="$ROOT_DIR/dist"
STAGE_DIR="$DIST_DIR/edge-package"

if ! command -v node >/dev/null 2>&1; then
  echo "Error: node is required to read manifest version." >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  echo "Error: zip is required to build the package archive." >&2
  exit 1
fi

VERSION="$(node -e "const fs=require('fs'); const p=process.argv[1]; const m=JSON.parse(fs.readFileSync(p,'utf8')); process.stdout.write(String(m.version||'0.0.0'));" "$MANIFEST_PATH")"
ARCHIVE_NAME="design-md-extractor-edge-v${VERSION}.zip"
ARCHIVE_PATH="$DIST_DIR/$ARCHIVE_NAME"

rm -rf "$STAGE_DIR"
mkdir -p "$STAGE_DIR" "$DIST_DIR"

cp "$ROOT_DIR/manifest.json" "$STAGE_DIR/"
cp "$ROOT_DIR/service-worker.js" "$STAGE_DIR/"
cp "$ROOT_DIR/content-script.js" "$STAGE_DIR/"
cp -R "$ROOT_DIR/assets" "$STAGE_DIR/assets"
cp -R "$ROOT_DIR/lib" "$STAGE_DIR/lib"
cp -R "$ROOT_DIR/popup" "$STAGE_DIR/popup"

rm -f "$ARCHIVE_PATH"
(
  cd "$STAGE_DIR"
  zip -qr "$ARCHIVE_PATH" .
)

echo "Created Edge package: $ARCHIVE_PATH"
