#!/bin/bash

echo "Processing Models..."

if ! command -v zip &> /dev/null; then
    echo "Error: 'zip' command not found, install zip before running the script"
    exit 1
fi

# Rename directories first, will only work where the lang codes are two-letter codes (the ISO ones)
for dir in */; do
    dir="${dir%/}"
    if [[ "$dir" =~ ^[a-z]{2}[a-z]{2}$ ]] && [[ ! "$dir" =~ - ]]; then
        new_name="${dir:0:2}-${dir:2:2}"
        echo "Renaming directory: $dir to $new_name"
        mv "$dir" "$new_name"
    fi
done

# handle file name operations
for dir in */; do
    dir="${dir%/}"
    echo "Processing directory: $dir"

    # Rename model files
    for file in "$dir"/*model*; do
        if [ -f "$file" ]; then
            decompressed_file="${file%.gz}"
            gzip -d "$file"
            mv "$decompressed_file" "$dir/model.bin"
            echo "  Renamed $(basename "$file") to model.bin"
        fi
    done

    # Rename vocab files
    for file in "$dir"/*vocab*; do
        if [ -f "$file" ]; then
            decompressed_file="${file%.gz}"
            gzip -d "$file"
            mv "$decompressed_file" "$dir/vocab.spm"
            echo "  Renamed $(basename "$file") to vocab.spm"
        fi
    done

    # Delete metadata.json and lex files
    [ -f "$dir/metadata.json" ] && rm "$dir/metadata.json" && echo "  Deleted metadata.json"
    for file in "$dir"/*lex*; do
        [ -f "$file" ] && rm "$file" && echo "  Deleted $(basename "$file")"
    done
done

# Compress all dirs to .zip & delete originals
for dir in */; do
    dir="${dir%/}"
    echo "Compressing $dir to $dir.zip"
    zip -r "$dir.zip" "$dir"
    rm -rf "$dir"
    echo "  Deleted original directory: $dir"
done

echo "model processing complete"
