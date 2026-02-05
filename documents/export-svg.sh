#!/bin/bash

# Configuration
INKSCAPE_PATH="/Applications/Inkscape.app/Contents/MacOS/inkscape"
OUTPUT_DIR="../assets/sprites"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Export all SVG files to PNG using Inkscape
for svg in *.svg; do
    if [ -f "$svg" ]; then
        filename=$(basename "$svg" .svg)
        echo "Exporting: $svg -> ${OUTPUT_DIR}/${filename}.png"
        "$INKSCAPE_PATH" "$svg" --export-filename="${OUTPUT_DIR}/${filename}.png"
    fi
done

echo "Done!"
