#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

SITE_URL="${SITE_URL:-https://quinten.com.au}"

export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"

if ! command -v pdflatex >/dev/null || ! command -v lwarpmk >/dev/null; then
    echo "installing TinyTeX..."

    curl -fsSL https://yihui.org/tinytex/install-unx.sh | sh

    export PATH="$HOME/.TinyTeX/bin/x86_64-linux:$PATH"

    tlmgr install \
      scheme-medium \
      lwarp \
      ifptex \
      upquote \
      verifycommand \
      comment \
      catchfile \
      newunicodechar \
      xpatch \
      xstring \
      environ \
      cm-super
fi

rm -rf .build
mkdir -p .build public

find src -type f -name '*.tex' | sort | while read -r file; do
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
        pdflatex -interaction=nonstopmode -halt-on-error "$name.tex"
        lwarpmk html
    )

    cp "$work/$name.html" "$out/$name.html"

    if [[ -f "$work/lwarp.css" ]]; then
        cp "$work/lwarp.css" public/lwarp.css
    fi
done

{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    find src -type f -name '*.tex' | sort | while read -r file; do
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