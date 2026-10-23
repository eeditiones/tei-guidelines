// SPDX-FileCopyrightText: 2026 e-editiones
// SPDX-License-Identifier: CC0-1.0

// Copied to the site root by the publish workflow. Bump VERSION to drop old caches.
const VERSION = 'v1';
const CACHE = 'tei-guidelines-' + VERSION;
const SHELL = [
  './',
  'index.html',
  'idents.json',
  'assets/document.css',
  'assets/fonts.css',
  'assets/search.js',
  'assets/theme.js',
  'assets/logo.svg',
  'icon-192.png',
  'icon-512.png',
  'css/opm-layout.css',
  'css/tagdocs.css'
];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(SHELL)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

// Pages and assets are cached as they are read and refreshed in the background.
self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== location.origin) return;
  event.respondWith(
    caches.open(CACHE).then((cache) =>
      cache.match(req).then((hit) => {
        const fresh = fetch(req).then((res) => {
          if (res.ok) cache.put(req, res.clone());
          return res;
        });
        return hit || fresh;
      })
    ).catch(() => fetch(req))
  );
});
