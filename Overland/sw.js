/* Overland service worker — lets the app cold-launch with no signal.
   The app shell (index.html + inlined Leaflet) is precached here.
   Map tiles are NOT handled here — the app caches those itself in IndexedDB. */
const CACHE = 'overland-shell-v1';
const SHELL = ['./', './index.html', './manifest.json', './icon.png'];

self.addEventListener('install', e => {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL).catch(() => {})));
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // Page loads / launches: serve the cached app shell so it opens offline.
  if (req.mode === 'navigate') {
    e.respondWith(
      caches.match('./index.html')
        .then(r => r || fetch(req).catch(() => caches.match('./')))
    );
    return;
  }

  // Map tiles: leave them to the app's own IndexedDB cache — just pass through.
  const isTile = /tile|arcgisonline|opentopomap|basemaps/i.test(url.host) || /\/tile\//i.test(url.pathname);
  if (isTile) return;

  // Everything else (the shell assets, fonts, etc.): cache-first, then network.
  e.respondWith(
    caches.match(req).then(cached =>
      cached || fetch(req).then(resp => {
        if (resp && resp.status === 200 && (url.origin === location.origin || /fonts\.(googleapis|gstatic)/.test(url.host))) {
          const copy = resp.clone();
          caches.open(CACHE).then(c => c.put(req, copy));
        }
        return resp;
      }).catch(() => cached)
    )
  );
});
