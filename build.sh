#!/usr/bin/env bash
set -euo pipefail

find src -type f -name '*.tex' | while read -r file; do
    relative="${file#src/}"
    output="${relative%.tex}"

    mkdir -p "public/$(dirname "$output")"

    echo "Building $file"

    pandoc "$file" \
        --standalone \
        --to=html5 \
        --output="public/$output.html"

    pandoc "$file" \
        --to=gfm \
        --output="public/$output.md"
done