#!/usr/bin/env bash
set -euo pipefail

PANDOC_VERSION="3.8.2"

if ! command -v pandoc >/dev/null 2>&1; then
  echo "Installing Pandoc ${PANDOC_VERSION}..."

  wget -q \
    "https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux-amd64.tar.gz" \
    -O /tmp/pandoc.tar.gz

  mkdir -p /tmp/pandoc

  tar -xzf /tmp/pandoc.tar.gz \
    --strip-components=1 \
    -C /tmp/pandoc

  export PATH="/tmp/pandoc/bin:$PATH"
fi

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