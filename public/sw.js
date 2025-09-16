// public/sw.js - Service Worker para PWA
const CACHE_NAME = 'conjunto-residencial-v1.0.0';
const API_CACHE_NAME = 'conjunto-api-v1.0.0';

// Archivos a cachear para funcionamiento offline
const STATIC_CACHE_URLS = [
  '/',
  '/index.html',
  '/login.html',
  '/js/app.js',
  '/css/styles.css',
  '/icons/icon-192x192.png',
  '/icons/icon-512x512.png',
  'https://cdn.tailwindcss.com',
  'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css',
  'https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap'
];

// URLs de API que se pueden cachear
const API_CACHE_URLS = [
  '/api/auth/profile',
  '/api/emprendimientos',
  '/api/reservas/disponibilidad'
];

// Instalar Service Worker
self.addEventListener('install', (event) => {
  console.log('SW: Installing Service Worker');
  
  event.waitUntil(
    Promise.all([
      // Cache de archivos estáticos
      caches.open(CACHE_NAME).then((cache) => {
        console.log('SW: Caching static files');
        return cache.addAll(STATIC_CACHE_URLS);
      }),
      // Cache de API
      caches.open(API_CACHE_NAME).then((cache) => {
        console.log('SW: Preparing API cache');
        return Promise.resolve();
      })
    ]).then(() => {
      console.log('SW: Installation complete');
      // Forzar activación inmediata
      return self.skipWaiting();
    })
  );
});

// Activar Service Worker
self.addEventListener('activate', (event) => {
  console.log('SW: Activating Service Worker');
  
  event.waitUntil(
    Promise.all([
      // Limpiar caches viejos
      caches.keys().then((cacheNames) => {
        return Promise.all(
          cacheNames.map((cacheName) => {
            if (cacheName !== CACHE_NAME && cacheName !== API_CACHE_NAME) {
              console.log('SW: Deleting old cache:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      }),
      // Tomar control de todas las páginas
      self.clients.claim()
    ]).then(() => {
      console.log('SW: Activation complete');
    })
  );
});

// Interceptar requests
self.addEventListener('fetch', (event) => {
  const request = event.request;
  const url = new URL(request.url);

  // Solo manejar requests GET
  if (request.method !== 'GET') {
    return;
  }

  // Estrategia para archivos estáticos
  if (STATIC_CACHE_URLS.some(cacheUrl => request.url.includes(cacheUrl))) {
    event.respondWith(handleStaticRequest(request));
    return;
  }

  // Estrategia para API calls
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(handleApiRequest(request));
    return;
  }

  // Estrategia para otras páginas
  event.respondWith(handlePageRequest(request));
});

// Manejar requests de archivos estáticos (Cache First)
async function handleStaticRequest(request) {
  try {
    const cache = await caches.open(CACHE_NAME);
    const cachedResponse = await cache.match(request);

    if (cachedResponse) {
      console.log('SW: Serving from cache:', request.url);
      return cachedResponse;
    }

    console.log('SW: Fetching and caching:', request.url);
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      cache.put(request, networkResponse.clone());
    }

    return networkResponse;
  } catch (error) {
    console.error('SW: Error handling static request:', error);
    
    // Si es una página, devolver index.html desde cache
    if (request.destination === 'document') {
      const cache = await caches.open(CACHE_NAME);
      return cache.match('/index.html');
    }
    
    return new Response('Network error', { status: 408 });
  }
}

// Manejar requests de API (Network First con cache fallback)
async function handleApiRequest(request) {
  try {
    console.log('SW: API request:', request.url);
    
    // Intentar network primero
    const networkResponse = await fetch(request.clone());
    
    if (networkResponse.ok) {
      // Cachear solo requests específicos de solo lectura
      if (API_CACHE_URLS.some(url => request.url.includes(url))) {
        const cache = await caches.open(API_CACHE_NAME);
        cache.put(request, networkResponse.clone());
      }
      
      return networkResponse;
    }
    
    throw new Error('Network response not ok');
  } catch (error) {
    console.log('SW: Network failed, trying cache for:', request.url);
    
    // Intentar desde cache
    const cache = await caches.open(API_CACHE_NAME);
    const cachedResponse = await cache.match(request);
    
    if (cachedResponse) {
      // Agregar header para indicar que viene del cache
      const response = cachedResponse.clone();
      response.headers.set('X-Served-By', 'ServiceWorker');
      return response;
    }
    
    // Devolver respuesta de error personalizada
    return new Response(
      JSON.stringify({
        success: false,
        message: 'Sin conexión. Los datos mostrados pueden estar desactualizados.',
        code: 'OFFLINE_MODE'
      }),
      {
        status: 503,
        headers: { 'Content-Type': 'application/json' }
      }
    );
  }
}

// Manejar requests de páginas (Network First, Cache Fallback)
async function handlePageRequest(request) {
  try {
    const networkResponse = await fetch(request);
    
    if (networkResponse.ok) {
      return networkResponse;
    }
    
    throw new Error('Network response not ok');
  } catch (error) {
    console.log('SW: Page network failed, serving index.html from cache');
    
    const cache = await caches.open(CACHE_NAME);
    const cachedIndex = await cache.match('/index.html');
    
    if (cachedIndex) {
      return cachedIndex;
    }
    
    return new Response('Página no disponible offline', { 
      status: 503,
      headers: { 'Content-Type': 'text/html' }
    });
  }
}

// Manejar mensajes del cliente
self.addEventListener('message', (event) => {
  const { type, payload } = event.data;

  switch (type) {
    case 'SKIP_WAITING':
      self.skipWaiting();
      break;
      
    case 'GET_VERSION':
      event.ports[0].postMessage({ version: CACHE_NAME });
      break;
      
    case 'CLEAR_CACHE':
      clearAllCaches().then(() => {
        event.ports[0].postMessage({ success: true });
      });
      break;
      
    case 'CACHE_API_RESPONSE':
      cacheApiResponse(payload.url, payload.response);
      break;
  }
});

// Limpiar todos los caches
async function clearAllCaches() {
  const cacheNames = await caches.keys();
  await Promise.all(
    cacheNames.map(cacheName => caches.delete(cacheName))
  );
  console.log('SW: All caches cleared');
}

// Cachear respuesta de API manualmente
async function cacheApiResponse(url, responseData) {
  try {
    const cache = await caches.open(API_CACHE_NAME);
    const response = new Response(JSON.stringify(responseData), {
      headers: { 'Content-Type': 'application/json' }
    });
    await cache.put(url, response);
    console.log('SW: Cached API response for:', url);
  } catch (error) {
    console.error('SW: Error caching API response:', error);
  }
}

// Sincronización en background (cuando hay conexión)
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    event.waitUntil(handleBackgroundSync());
  }
});

// Manejar sincronización en background
async function handleBackgroundSync() {
  console.log('SW: Performing background sync');
  
  try {
    // Aquí podrías sincronizar datos offline con el servidor
    // Por ejemplo, enviar mensajes de chat que quedaron pendientes
    await syncOfflineData();
  } catch (error) {
    console.error('SW: Background sync failed:', error);
  }
}

// Sincronizar datos offline
async function syncOfflineData() {
  // Implementar lógica de sincronización
  console.log('SW: Syncing offline data...');
  
  // Por ejemplo, recuperar datos del IndexedDB y enviarlos al servidor
  // cuando hay conexión disponible
}

// Push notifications
self.addEventListener('push', (event) => {
  console.log('SW: Push message received');
  
  let options = {
    body: 'Tienes una nueva notificación',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/badge-72x72.png',
    tag: 'conjunto-notification',
    requireInteraction: false,
    actions: [
      {
        action: 'view',
        title: 'Ver',
        icon: '/icons/view-icon.png'
      },
      {
        action: 'dismiss',
        title: 'Descartar',
        icon: '/icons/dismiss-icon.png'
      }
    ]
  };

  if (event.data) {
    const data = event.data.json();
    options = { ...options, ...data };
  }

  event.waitUntil(
    self.registration.showNotification('Conjunto Villa Real', options)
  );
});

// Manejar clicks en notificaciones
self.addEventListener('notificationclick', (event) => {
  console.log('SW: Notification clicked');
  
  event.notification.close();

  if (event.action === 'view') {
    event.waitUntil(
      clients.openWindow('/') // Abrir la aplicación
    );
  }
});

// ============================================
// public/manifest.json - Manifest de PWA
// ============================================
{
  "name"; "Conjunto Villa Real",
  "short_name"; "Villa Real",
  "description"; "Sistema de gestión integral para conjunto residencial",
  "start_url"; "/",
  "scope"; "/",
  "display"; "standalone",
  "orientation"; "portrait-primary",
  "theme_color"; "#667eea",
  "background_color"; "#ffffff",
  "lang"; "es-CO",
  "dir"; "ltr",
  "categories"; ["productivity", "utilities"],
  "icons"; [
    {
      "src": "/icons/icon-72x72.png",
      "sizes": "72x72",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-96x96.png",
      "sizes": "96x96",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-128x128.png",
      "sizes": "128x128",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-144x144.png",
      "sizes": "144x144",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-152x152.png",
      "sizes": "152x152",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-384x384.png",
      "sizes": "384x384",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "shortcuts"; [
    {
      "name": "Nueva Reserva",
      "short_name": "Reservar",
      "description": "Crear una nueva reserva de espacio común",
      "url": "/#reservas",
      "icons": [
        {
          "src": "/icons/shortcut-reserva.png",
          "sizes": "96x96"
        }
      ]
    },
    {
      "name": "Pagos",
      "short_name": "Pagar",
      "description": "Ver y realizar pagos",
      "url": "/#pagos",
      "icons": [
        {
          "src": "/icons/shortcut-pagos.png",
          "sizes": "96x96"
        }
      ]
    },
    {
      "name": "Chat",
      "short_name": "Chat",
      "description": "Acceder al chat comunitario",
      "url": "/#chat",
      "icons": [
        {
          "src": "/icons/shortcut-chat.png",
          "sizes": "96x96"
        }
      ]
    }
  ],
  "screenshots"; [
    {
      "src": "/screenshots/desktop-dashboard.png",
      "sizes": "1280x720",
      "type": "image/png",
      "platform": "wide",
      "label": "Dashboard principal"
    },
    {
      "src": "/screenshots/mobile-reservas.png",
      "sizes": "375x812",
      "type": "image/png",
      "platform": "narrow",
      "label": "Sistema de reservas"
    }
  ],
  "related_applications"; [
    {
      "platform": "play",
      "url": "https://play.google.com/store/apps/details?id=com.villareal.conjunto",
      "id": "com.villareal.conjunto"
    }
  ],
  "prefer_related_applications"; false,
  "edge_side_panel"; {
    "preferred_width"; 400
  }
  "launch_handler"; {
    "client_mode"; "navigate-existing"
  }
  "handle_links"; "preferred",
  "protocol_handlers"; [
    {
      "protocol": "web+conjunto",
      "url": "/handle?type=%s"
    }
  ]
}

// ============================================
// public/js/pwa-manager.js - Gestor de PWA
// ============================================

class PWAManager {
  constructor() {
    this.swRegistration = null;
    this.deferredPrompt = null;
    this.isOnline = navigator.onLine;
    this.init();
  }

  async init() {
    // Registrar Service Worker
    await this.registerServiceWorker();
    
    // Configurar eventos
    this.setupEventListeners();
    
    // Check for updates
    this.checkForUpdates();
    
    // Setup install prompt
    this.setupInstallPrompt();
  }

  async registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      try {
        this.swRegistration = await navigator.serviceWorker.register('/sw.js');
        console.log('PWA: Service Worker registered successfully');
        
        // Configurar update listener
        this.swRegistration.addEventListener('updatefound', () => {
          this.handleUpdateFound();
        });

      } catch (error) {
        console.error('PWA: Service Worker registration failed:', error);
      }
    }
  }

  setupEventListeners() {
    // Online/Offline events
    window.addEventListener('online', () => {
      this.isOnline = true;
      this.handleOnline();
    });

    window.addEventListener('offline', () => {
      this.isOnline = false;
      this.handleOffline();
    });

    // PWA install prompt
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      this.deferredPrompt = e;
      this.showInstallBanner();
    });

    // PWA installed
    window.addEventListener('appinstalled', () => {
      console.log('PWA: App installed successfully');
      this.hideInstallBanner();
      this.deferredPrompt = null;
    });
  }

  handleUpdateFound() {
    const newWorker = this.swRegistration.installing;
    
    newWorker.addEventListener('statechange', () => {
      if (newWorker.state === 'installed') {
        if (navigator.serviceWorker.controller) {
          // Nueva versión disponible
          this.showUpdateAvailable();
        }
      }
    });
  }

  showUpdateAvailable() {
    const updateBanner = document.createElement('div');
    updateBanner.id = 'update-banner';
    updateBanner.className = 'fixed top-0 left-0 right-0 bg-blue-600 text-white p-4 z-50 text-center';
    updateBanner.innerHTML = `
      <div class="flex items-center justify-between max-w-4xl mx-auto">
        <span>🔄 Nueva versión disponible</span>
        <div>
          <button onclick="pwaManager.applyUpdate()" class="bg-white text-blue-600 px-4 py-2 rounded mr-2">
            Actualizar
          </button>
          <button onclick="this.parentElement.parentElement.parentElement.remove()" class="text-white">
            ✕
          </button>
        </div>
      </div>
    `;
    
    document.body.insertBefore(updateBanner, document.body.firstChild);
  }

  async applyUpdate() {
    if (this.swRegistration && this.swRegistration.waiting) {
      this.swRegistration.waiting.postMessage({ type: 'SKIP_WAITING' });
      window.location.reload();
    }
  }

  showInstallBanner() {
    // Solo mostrar si no está instalado y no se ha rechazado recientemente
    if (this.isInstalled() || localStorage.getItem('install-rejected')) {
      return;
    }

    const installBanner = document.createElement('div');
    installBanner.id = 'install-banner';
    installBanner.className = 'fixed bottom-4 left-4 right-4 bg-gradient-to-r from-blue-500 to-purple-600 text-white p-4 rounded-lg shadow-lg z-50';
    installBanner.innerHTML = `
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <div class="w-12 h-12 bg-white bg-opacity-20 rounded-lg flex items-center justify-center mr-3">
            <i class="fas fa-home text-xl"></i>
          </div>
          <div>
            <p class="font-semibold">Instalar Villa Real</p>
            <p class="text-sm opacity-90">Acceso rápido desde tu pantalla de inicio</p>
          </div>
        </div>
        <div class="flex gap-2">
          <button onclick="pwaManager.installApp()" class="bg-white text-blue-600 px-4 py-2 rounded font-medium">
            Instalar
          </button>
          <button onclick="pwaManager.dismissInstall()" class="text-white">
            ✕
          </button>
        </div>
      </div>
    `;
    
    document.body.appendChild(installBanner);
  }

  async installApp() {
    if (this.deferredPrompt) {
      this.deferredPrompt.prompt();
      const { outcome } = await this.deferredPrompt.userChoice;
      
      if (outcome === 'accepted') {
        console.log('PWA: Install prompt accepted');
      } else {
        console.log('PWA: Install prompt dismissed');
        localStorage.setItem('install-rejected', Date.now().toString());
      }
      
      this.deferredPrompt = null;
      this.hideInstallBanner();
    }
  }

  dismissInstall() {
    localStorage.setItem('install-rejected', Date.now().toString());
    this.hideInstallBanner();
  }

  hideInstallBanner() {
    const banner = document.getElementById('install-banner');
    if (banner) {
      banner.remove();
    }
  }

  isInstalled() {
    return window.matchMedia('(display-mode: standalone)').matches ||
           window.navigator.standalone === true;
  }

  handleOnline() {
    console.log('PWA: Back online');
    
    // Quitar banner de offline
    const offlineBanner = document.getElementById('offline-banner');
    if (offlineBanner) {
      offlineBanner.remove();
    }
    
    // Sincronizar datos pendientes
    this.syncOfflineData();
    
    // Mostrar notificación
    if (window.app) {
      window.app.showNotification('Conexión restaurada', 'success');
    }
  }

  handleOffline() {
    console.log('PWA: Gone offline');
    
    // Mostrar banner de offline
    this.showOfflineBanner();
    
    // Mostrar notificación
    if (window.app) {
      window.app.showNotification('Sin conexión - Modo offline activado', 'warning');
    }
  }

  showOfflineBanner() {
    const offlineBanner = document.createElement('div');
    offlineBanner.id = 'offline-banner';
    offlineBanner.className = 'fixed top-0 left-0 right-0 bg-orange-500 text-white p-2 z-50 text-center text-sm';
    offlineBanner.innerHTML = `
      <div class="flex items-center justify-center">
        <i class="fas fa-wifi-slash mr-2"></i>
        <span>Sin conexión - Trabajando en modo offline</span>
      </div>
    `;
    
    document.body.insertBefore(offlineBanner, document.body.firstChild);
  }

  async syncOfflineData() {
    if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
      try {
        await this.swRegistration.sync.register('background-sync');
        console.log('PWA: Background sync registered');
      } catch (error) {
        console.error('PWA: Background sync registration failed:', error);
      }
    }
  }

  async checkForUpdates() {
    if (this.swRegistration) {
      try {
        await this.swRegistration.update();
      } catch (error) {
        console.error('PWA: Update check failed:', error);
      }
    }
  }

  // Habilitar notificaciones push
  async enableNotifications() {
    if ('Notification' in window && 'serviceWorker' in navigator) {
      const permission = await Notification.requestPermission();
      
      if (permission === 'granted') {
        console.log('PWA: Notifications enabled');
        return true;
      }
    }
    
    return false;
  }

  // Obtener información de la app
  getAppInfo() {
    return {
      isInstalled: this.isInstalled(),
      isOnline: this.isOnline,
      hasServiceWorker: !!this.swRegistration,
      canInstall: !!this.deferredPrompt,
      notificationsEnabled: Notification.permission === 'granted'
    };
  }
}

// Inicializar PWA Manager
const pwaManager = new PWAManager();

// Exportar para uso global
window.pwaManager = pwaManager;