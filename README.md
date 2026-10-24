<!--
SPDX-FileCopyrightText: 2026 e-editiones
SPDX-License-Identifier: CC0-1.0
-->

# TEI Guidelines

A static website of the [TEI P5 Guidelines](https://tei-c.org/guidelines/p5/), generated with
[opm](https://github.com/eeditiones/open-processing-model). Every chapter is a page, and every
element, class, macro and datatype has its own reference page. The site has a sidebar, search for
element and class names, a light/dark theme and works offline as an installable app.

The site is published to GitHub Pages by the workflow in `.github/workflows/pages.yml` on every push
to `master`.

## Building

```bash
opm odd document --force --preview
```

writes the site to `site/` and opens it in a browser. The latest TEI P5 source is downloaded on first
use and cached.

The same project also produces other formats:

```bash
opm odd document -t typst      # PDF
opm odd document -t markdown   # Markdown
opm odd document -t epub       # EPUB
```

To get the pages as data for another static site generator:

```bash
opm odd prepare -o schema.xml
opm chunk schema.xml --format json
```

## What is where

| file | what it decides |
| --- | --- |
| `opm.toml` | what to document, and the three runs that make the site: the chapters, the home page, then one reference page per spec |
| `odd/tagdocs.odd`, `odd/tagdocs.css` | how every page is rendered |
| `templates/page.html.j2` | the page around each chunk: header, sidebar, right-hand rail |
| `templates/document.css`, `search.js`, `theme.js` | the site's look, search box, light/dark switch and the catalogs' A–Z / by module switch |
| `templates/nav.xml` | the sidebar list |
| `templates/logo.svg` | the logo in the header and browser tab |
| `templates/tagdocs.typ.j2`, `epub.css` | the PDF and EPUB output |
| `pwa/` | web app manifest, service worker and icons that make the site installable |
| `data/tei_psalmy.odd` | a sample customisation, for testing the build on something smaller than the full Guidelines |

`templates/page.html.j2` and `templates/tagdocs.typ.j2` must stay, because `opm.toml` points to them.
For any other file in `templates/`, opm falls back to its own copy if you delete it.

## Installable app

`pwa/sw.js` caches the page shell and every page the reader opens, so visited pages work offline.
opm does not copy these files, so the workflow copies them into the site root after the build:

```bash
cp pwa/app.webmanifest pwa/sw.js pwa/icon-*.png site/
```

Do this after a local build too if you want to try the installed app. When the site changes, bump
`VERSION` in `pwa/sw.js` so readers' old caches are dropped.

## Documenting a customisation

To document your own ODD instead of the full Guidelines, pass it on the command line or set `source`
under `[document]` in `opm.toml`:

```bash
opm odd document data/tei_psalmy.odd --force --preview
```

`data/tei_psalmy.odd` is the schema of a didactic edition of Polish Psalters, made for the
[Jagiellonian Digital Platform](https://labedyt.dhlab.uj.edu.pl/index.html) by Magdalena Turska and
Helena Bermúdez Sabel. It is distributed under the Creative Commons Attribution-ShareAlike 4.0
International licence; see its `teiHeader`.
