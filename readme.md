Hello!

This is the repo for my website, found at [quinten.com.au](https://quinten.com.au).

[![build, deploy](https://github.com/quintenbuwalda/quinten.com.au/actions/workflows/deploy.yml/badge.svg)](https://github.com/quintenbuwalda/quinten.com.au/actions/workflows/deploy.yml)



## info about metadata!

each `metadata/<page>.json` matches `src/<page>.tex`

eg.
```json
{
  "meta": [
    {"name": "description", "content": "My personal website."},
    {"property": "og:title", "content": "Quinten Buwalda"}
  ],
  "links": [
    {"rel": "me", "href": "https://github.com/quintenbuwalda"}
  ],
  "jsonld": {
    "@context": "https://schema.org",
    "@type": "WebPage",
    "name": "Quinten Buwalda"
  }
}
```