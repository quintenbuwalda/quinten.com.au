#!/usr/bin/env bash
set -euo pipefail

# INSTALL PANDOC
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

# COMPILE PAGES
find src -type f -name '*.tex' | while read -r file; do
  relative="${file#src/}"
  output="${relative%.tex}"

  mkdir -p "public/$(dirname "$output")"

  echo "Building $file"

  pandoc "$file" \
    --standalone \
    --to=html5 \
    --css="/style.css" \
    --output="public/$output.html"

  pandoc "$file" \
    --to=gfm \
    --output="public/$output.md"
done

# BUILD SITEMAP
SITE_URL="https://quinten.com.au"

{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

  find src -type f -name '*.tex' | sort | while read -r file; do
    relative="${file#src/}"
    page="${relative%.tex}"

    # index.tex is the site root
    if [[ "$page" == "index" ]]; then
      url="$SITE_URL/"
    else
      url="$SITE_URL/$page.html"
    fi

    echo '  <url>'
    echo "    <loc>$url</loc>"
    echo '  </url>'
  done

  echo '</urlset>'
} > public/sitemap.xml

echo "Generated public/sitemap.xml"