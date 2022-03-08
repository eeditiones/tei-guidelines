const CACHE = "guidelines-resources";
const CACHE_STATIC = "guidelines-static-resources"

importScripts('https://storage.googleapis.com/workbox-cdn/releases/5.1.2/workbox-sw.js');

self.addEventListener("message", (event) => {
  if (event.data && event.data.type === "SKIP_WAITING") {
    self.skipWaiting();
  }
});

workbox.precaching.cleanupOutdatedCaches();

workbox.precaching.precacheAndRoute([
    
    {
        url: '/ref/tei.css',
        revision: null
    },
    
    {
        url: '/css/guidelines.css',
        revision: null
    },
    
    {
        url: '/css/theme.css',
        revision: null
    },
    
    {
        url: '/css/tei.css',
        revision: null
    },
    
    {
        url: '/index.html',
        revision: null
    },
    
    {
        url: '/index.json',
        revision: null
    },
    
    {
        url: '/search.html',
        revision: null
    },
    
    {
        url: '/index.jsonl',
        revision: null
    },
    
    {
        url: '/p5.xml/index.html',
        revision: null
    },
    
    {
        url: '/p5.xml/index.json',
        revision: null
    },
    
    {
        url: '/offline.html',
        revision: null
    },
    
    {
        url: '/offline.json',
        revision: null
    },
    
    {
        url: 'https://fonts.googleapis.com/css2?family=Londrina+Solid:wght@300&display=swap',
        revision: null
    },
    
    {
        url: 'https://unpkg.com/@teipublisher/pb-components/src/pb-components-bundle.js',
        revision: null
    },
    
    {
        url: 'https://unpkg.com/@teipublisher/pb-components@1.35.2/dist/pb-components-bundle.js',
        revision: null
    },
    
    {
        url: 'https://unpkg.com/@webcomponents/webcomponentsjs@2.4.3/webcomponents-loader.js',
        revision: null
    },
    
    {
        url: 'https://unpkg.com/web-animations-js@2.3.2/web-animations-next-lite.min.js',
        revision: null
    },
    
    {
        url: 'https://cdn.jsdelivr.net/gh/nextapps-de/flexsearch@0.7.2/dist/flexsearch.bundle.js',
        revision: null
    },
    
]);

workbox.routing.registerRoute(
    ({request}) => request.destination === 'image' ||
      request.destination === 'script' ||
      request.destination === 'style',
    new workbox.strategies.CacheFirst({
      cacheName: CACHE_STATIC,
      plugins: [
        new workbox.expiration.ExpirationPlugin({
          maxEntries: 60,
          maxAgeSeconds: 30 * 24 * 60 * 60, // 30 Days
        }),
      ],
    })
);

workbox.routing.setDefaultHandler(new workbox.strategies.StaleWhileRevalidate({
    cacheName: CACHE
}));

async function offlinePage(file) {
  const cached = await self.caches.match(file);
  if (!cached) {
      console.log('offline page not found in cache');
      return Response.error();
  }
  return cached;
}

const handler = async (event) => {
    console.log('Destination: %o', event.request.headers);
    if (event.request.headers.get('Accept').includes('application/json')) {
      return offlinePage('/offline.json');
    }
    switch (event.request.destination) {
        case 'document':
            return offlinePage('/offline.html');
        default:
            return Response.error();
    }
};

workbox.routing.setCatchHandler(handler);