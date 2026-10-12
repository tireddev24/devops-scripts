#!/bin/bash
set -euo pipefail

SRC="${1:?usage: $0 <source_dir> [keep]}"
KEEP="${2:-3}"
DEST="${BACKUP_DIR:-$HOME/backups}"
STAMP=$(date +%Y%m%d-%H%M%S)
NAME=$(basename "$SRC")
ARCHIVE="$DEST/$NAME-$STAMP.tar.gz"

log() { echo "$(date '+%F %T') $*"; }

if [ ! -d "$SRC" ]; then
    log "ERROR: $SRC is not a directory" >&2
    exit 2
fi
mkdir -p "$DEST"

TMP=$(mktemp "$DEST/.partial.XXXXXX")
trap 'rm -f "$TMP"' EXIT

log "Backing up $SRC"
tar -czf "$TMP" -C "$(dirname "$SRC")" "$NAME"
mv "$TMP" "$ARCHIVE"
log "Created $ARCHIVE"

# Rotation: keep the newest $KEEP archives, delete the rest
ls -1t "$DEST/$NAME"-*.tar.gz | tail -n +$((KEEP + 1)) | xargs -r rm --
log "Kept at most $KEEP backups"
