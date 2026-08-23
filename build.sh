#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC="$ROOT/src"
PUBLIC="$ROOT/public"
BUILD="$ROOT/.build"

SITE_URL="${SITE_URL:-https://quinten.com.au}"

cd "$ROOT"

mkdir -p "$PUBLIC"


setup_tex() {
  if command -v pdflatex >/dev/null &&
     command -v lwarpmk >/dev/null; then
    return
  fi

  [[ "$(uname -s)" == "Linux" ]] || {
    echo "pls install tinytex"
    exit 1
  }

  echo "u dont have tinytex"

  curl -fsSL https://yihui.org/tinytex/install-unx.sh |
    sh -s -- --no-admin

  TEXBIN="$(find "$HOME/.TinyTeX/bin" -name pdflatex -print -quit)"
  export PATH="$(dirname "$TEXBIN"):$PATH"

  tlmgr install lwarp
}


setup_pdftotext() {
  command -v pdftotext >/dev/null && return

  command -v python3 >/dev/null || {
    echo "pdftotext or python 3 not here"
    exit 1
  }

  mkdir -p "$BUILD/bin" "$BUILD/python"

  python3 -m pip install \
    --quiet \
    --disable-pip-version-check \
    --target "$BUILD/python" \
    pypdf

  export PYTHONPATH="$BUILD/python"

  cat > "$BUILD/bin/pdftotext" <<'PY'
#!/usr/bin/env python3

import sys
from pypdf import PdfReader

source = sys.argv[-2]
output = sys.argv[-1]

with open(output, "w", encoding="utf-8") as f:
    for page in PdfReader(source).pages:
        text = page.extract_text(extraction_mode="layout") or ""
        f.write(text)
        if text and not text.endswith("\n"):
            f.write("\n")
PY

  chmod +x "$BUILD/bin/pdftotext"
  export PATH="$BUILD/bin:$PATH"
}


setup_tex
setup_pdftotext

rm -rf "$BUILD/pages"
mkdir -p "$BUILD/pages"

rm -f "$PUBLIC/lwarp.css" "$PUBLIC/sitemap.xml"


while IFS= read -r file; do
  relative="${file#$SRC/}"
  page="${relative%.tex}"

  name="$(basename "$page")"
  dir="$(dirname "$page")"

  [[ "$dir" == "." ]] && dir=""

  work="$BUILD/pages/$page"
  out="$PUBLIC/$dir"

  mkdir -p "$work" "$out"

  echo "Building $relative"

  cp "$file" "$work/$name.tex"
  cp "$ROOT/site.sty" "$work/site.sty"

  (
    cd "$work"

    pdflatex \
      -interaction=nonstopmode \
      -halt-on-error \
      "$name.tex" >/dev/null

    lwarpmk html >/dev/null
  )

  cp "$work/$name.html" "$out/$name.html"

  if [[ -f "$work/lwarp.css" ]]; then
    cp "$work/lwarp.css" "$PUBLIC/lwarp.css"
  fi

done < <(find "$SRC" -type f -name '*.tex' | sort)


{
  echo '<?xml version="1.0" encoding="UTF-8"?>'
  echo '<urlset xmlns="http://www.sitemaps.org/sitemap/0.9">'

  while IFS= read -r file; do
    page="${file#$SRC/}"
    page="${page%.tex}"

    if [[ "$page" == "index" ]]; then
      url="$SITE_URL/"
    else
      url="$SITE_URL/$page.html"
    fi

    echo '  <url>'
    echo "    <loc>$url</loc>"
    echo '  </url>'

  done < <(find "$SRC" -type f -name '*.tex' | sort)

  echo '</urlset>'

} > "$PUBLIC/sitemap.xml"


echo "Build complete."