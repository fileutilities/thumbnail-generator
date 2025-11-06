#!/bin/bash

# ========================================================
# HEIC Thumbnail Manager
# --------------------------------------------------------
# This script manages HEIC/HEIF → JPG thumbnail generation.
# It can:
#   - generate: create resized JPGs from HEIC/HEIF files
#   - delete: remove corresponding JPG thumbnails
#   - deleteorphans: remove JPGs whose originals no longer exist
#
# Requires: ImageMagick (with HEIC support)
# ========================================================

# =========================
# CONFIGURATION
# =========================

# Action: "generate", "delete", or "deleteorphans"
ACTION="generate"

# Base folder containing your photos
BASE_DIR="/Volumes/2T-Local/Photos/2020s/2024/photos"

# Maximum long-side size for generated images
MAX_SIZE="1200"      # Long side will be resized to this if larger

# Output JPG quality (0–100)
JPEG_QUALITY="85"

# =========================
# SCRIPT LOGIC
# =========================

if [ "$ACTION" == "generate" ]; then
    echo "Generating thumbnails..."
    find "$BASE_DIR" -type f \( -iname "*.heic" -o -iname "*.heif" \) | while read f; do
        dir=$(dirname "$f")
        base=$(basename "$f")
        ts_dir="$dir/.ts"

        # Ensure .ts directory exists
        mkdir -p "$ts_dir"

        output_file="$ts_dir/$base.jpg"

        echo "→ $f"

        # Get original image dimensions
        read width height < <(magick identify -format "%w %h" "$f")

        # Determine if resizing is needed
        if [ "$width" -gt "$height" ]; then
            if [ "$width" -gt "$MAX_SIZE" ]; then
                resize="${MAX_SIZE}x"
            else
                resize="${width}x"
            fi
        else
            if [ "$height" -gt "$MAX_SIZE" ]; then
                resize="x${MAX_SIZE}"
            else
                resize="x${height}"
            fi
        fi

        # Convert HEIC → JPG with resizing and stripping metadata
        magick "$f" -auto-orient -resize "$resize" -quality "$JPEG_QUALITY" -strip "$output_file"
    done

elif [ "$ACTION" == "delete" ]; then
    echo "Deleting generated thumbnails..."
    find "$BASE_DIR" -type f -path "*/.ts/*.jpg" | while read thumb; do
        echo "Deleting: $thumb"
        rm "$thumb"
    done

elif [ "$ACTION" == "deleteorphans" ]; then
    echo "Deleting orphaned thumbnails (no matching originals)..."
    find "$BASE_DIR" -type f -path "*/.ts/*.jpg" | while read thumb; do
        dir=$(dirname "$thumb")
        parent_dir=$(dirname "$dir")
        base_noext=$(basename "$thumb" .jpg)

        # Try matching both HEIC and HEIF originals
        heic_path="$parent_dir/$base_noext"
        if [ ! -f "${heic_path}" ] && [ ! -f "${heic_path%.heic}.heif" ]; then
            echo "Orphan found, deleting: $thumb"
            rm "$thumb"
        fi
    done

    # Optional: remove empty .ts directories
    find "$BASE_DIR" -type d -name ".ts" -empty -delete

else
    echo "Unknown ACTION: $ACTION"
    echo "Valid options: generate | delete | deleteorphans"
    exit 1
fi

echo "Done."
