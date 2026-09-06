#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

for cmd in pdflatex lwarpmk pdftotext perl python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "error: required command not found: $cmd" >&2
        exit 1
    fi
done

rm -rf .build public
mkdir -p .build public
cp -R static/. public/

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

python3 scripts/metadata.py

echo "Build complete."
