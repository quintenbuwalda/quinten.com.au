import json
from html import escape
from pathlib import Path
from urllib.parse import quote
from xml.etree import ElementTree as ET

SITE_URL = 'https://quinten.com.au/'
sitemap = ET.Element('urlset', xmlns='http://www.sitemaps.org/schemas/sitemap/0.9')

for source in sorted(Path('src').rglob('*.tex')):
    page = source.relative_to('src').with_suffix('')
    path = page.as_posix()
    if page.name == 'index':
        path = path[:-5]
    url = SITE_URL + quote(path, safe='/')
    output = Path('public') / f'{page}.html'
    metadata = Path('metadata') / f'{page}.json'

    tags = f'<link rel="canonical" href="{url}" />\n'
    if metadata.exists():
        data = json.loads(metadata.read_text(encoding='utf-8'))
        for tag, entries in [('meta', data.get('meta', [])), ('link', data.get('links', []))]:
            for attributes in entries:
                attrs = ' '.join(f'{key}="{escape(str(value), quote=True)}"' for key, value in attributes.items())
                tags += f'<{tag} {attrs} />\n'
        if 'jsonld' in data:
            payload = json.dumps(data['jsonld'], ensure_ascii=False, indent=2).replace('<', '\\u003c')
            tags += f'<script type="application/ld+json">\n{payload}\n</script>\n'
    html = output.read_text(encoding='utf-8')
    output.write_text(html.replace('</head>', tags + '</head>'), encoding='utf-8')
    ET.SubElement(ET.SubElement(sitemap, 'url'), 'loc').text = url

ET.indent(sitemap)
ET.ElementTree(sitemap).write('public/sitemap.xml', encoding='utf-8', xml_declaration=True)
