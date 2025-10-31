#!/bin/bash

# =========================
# CONFIGURATION
# =========================

# Action: "generate" or "delete"
ACTION="generate"

# Base folder containing your photos
BASE_DIR="/Volumes/2T-Local/Photos/2020s/2025/photos"

# Thumbnail max size (only for generate)
THUMB_SIZE="300x300"
THUMB_QUALITY="85"

# =========================
# SCRIPT LOGIC
# =========================

find "$BASE_DIR" -type f \( -iname "*.heic" -o -iname "*.heif" \) | while read f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    ts_dir="$dir/.ts"

    # Ensure .ts exists
    mkdir -p "$ts_dir"

    thumb_file="$ts_dir/$base.jpg"

    if [ "$ACTION" == "generate" ]; then
        echo "Generating thumbnail for: $f"
        magick "$f" -resize "$THUMB_SIZE" -quality "$THUMB_QUALITY" "$thumb_file"
    elif [ "$ACTION" == "delete" ]; then
        if [ -f "$thumb_file" ]; then
            echo "Deleting thumbnail: $thumb_file"
            rm "$thumb_file"
        fi
    else
        echo "Unknown ACTION: $ACTION"
        exit 1
    fi
done

echo "Done."
