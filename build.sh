#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SITE_URL="${SITE_URL:-https://quinten.com.au}"

for cmd in pdflatex lwarpmk pdftotext perl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "error: required command not found: $cmd" >&2
        exit 1
    fi
done

rm -rf .build
mkdir -p .build public

find src -type f -name '*.tex' -print0 |
    sort -z |
    while IFS= read -r -d '' file; do

        page="${file#src/}"
        page="${page%.tex}"

        name="$(basename "$page")"
        dir="$(dirname "$page")"
        [[ "$dir" == "." ]] && dir=""

        work=".build/$page"
        out="public/$dir"

        mkdir -p "$work" "$out"

        echo "building $file"

        cp "$file" "$work/$name.tex"
        cp site.sty "$work/site.sty"

        (
            cd "$work"

            pdflatex \
                -file-line-error \
                -interaction=nonstopmode \
                -halt-on-error \
                "$name.tex"

            lwarpmk html
        )

        cp "$work/$name.html" "$out/$name.html"

        # thank you claude for this blessing of a command
        perl -pi -e 's{(<a href="/[^"]*") target="_blank"}{$1}g' "$out/$name.html"
        
        if [[ -f "$work/lwarp.css" ]]; then
            cp "$work/lwarp.css" public/lwarp.css
        fi
    done

{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    find src -type f -name '*.tex' -print0 |
        sort -z |
        while IFS= read -r -d '' file; do

            page="${file#src/}"
            page="${page%.tex}"

            if [[ "$page" == "index" ]]; then
                url="$SITE_URL/"
            else
                url="$SITE_URL/$page.html"
            fi

            echo "  <url><loc>$url</loc></url>"
        done

    echo '</urlset>'
} > public/sitemap.xml

echo "Build complete."