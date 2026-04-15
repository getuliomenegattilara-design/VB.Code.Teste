const CACHE = 'pessoas-v1';
const ASSETS = [
    'supabase.html',
    'manifest.json',
    'icon.svg'
];

// Instala e cacheia os arquivos do app
self.addEventListener('install', e => {
    e.waitUntil(
        caches.open(CACHE).then(cache => cache.addAll(ASSETS))
    );
    self.skipWaiting();
});

// Limpa caches antigos
self.addEventListener('activate', e => {
    e.waitUntil(
        caches.keys().then(keys =>
            Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
        )
    );
    self.clients.claim();
});

// Cache first para assets locais, network first para Supabase
self.addEventListener('fetch', e => {
    const url = new URL(e.request.url);

    // Requisicoes ao Supabase sempre vao para a rede
    if (url.hostname.includes('supabase.co')) {
        e.respondWith(fetch(e.request));
        return;
    }

    // Assets locais: cache first
    e.respondWith(
        caches.match(e.request).then(cached => cached || fetch(e.request))
    );
});
