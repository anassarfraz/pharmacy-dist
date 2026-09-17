// PharmaCare POS Service Worker - Version 4
const CACHE_NAME = 'pharmacare-pos-v4';

// Only cache true static offline assets (NEVER dynamic HTML pages like /pos or /)
const STATIC_ASSETS = [
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/icons/icon.svg',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(STATIC_ASSETS).catch((err) => {
        console.warn('Cache addAll non-fatal error:', err);
      });
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Purge all legacy caches to guarantee fresh CSS and HTML
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            console.log('Purging legacy service worker cache:', key);
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);

  // 1. Completely bypass service worker for:
  // - Non-GET requests
  // - Next.js internal static assets & chunks (/_next/)
  // - API routes (/api/)
  // - Webpack HMR and hot updates
  if (
    request.method !== 'GET' ||
    url.pathname.startsWith('/_next/') ||
    url.pathname.startsWith('/api/') ||
    url.pathname.includes('webpack') ||
    url.pathname.includes('hot-update')
  ) {
    return; // Pass through to native browser network
  }

  // 2. Navigation / HTML requests - always fetch live from network
  if (request.mode === 'navigate' || request.headers.get('accept')?.includes('text/html')) {
    event.respondWith(
      fetch(request).catch(() => {
        // Only return cached offline fallback when network is completely down
        return caches.match('/manifest.json');
      })
    );
    return;
  }

  // 3. Cache-first ONLY for static icons & manifest
  if (url.pathname.startsWith('/icons/') || url.pathname.endsWith('manifest.json')) {
    event.respondWith(
      caches.match(request).then((cached) => {
        return (
          cached ||
          fetch(request).then((res) => {
            const clone = res.clone();
            caches.open(CACHE_NAME).then((cache) => cache.put(request, clone));
            return res;
          })
        );
      })
    );
    return;
  }

  // 4. Default network pass-through
  event.respondWith(fetch(request));
});
