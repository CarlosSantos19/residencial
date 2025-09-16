// public/js/app.js - Aplicación JavaScript principal
class ConjuntoApp {
    constructor() {
        this.apiUrl = window.location.origin;
        this.token = localStorage.getItem('auth_token');
        this.user = JSON.parse(localStorage.getItem('user') || 'null');
        this.socket = null;
        this.currentSection = 'dashboard';
        this.cache = new Map();
        this.retryAttempts = 3;
        
        this.init();
    }

    // Inicializar aplicación
    async init() {
        this.showLoading(true);
        
        try {
            // Verificar autenticación
            if (!this.token) {
                this.redirectToLogin();
                return;
            }

            // Verificar token válido
            const isValid = await this.verifyToken();
            if (!isValid) {
                this.redirectToLogin();
                return;
            }

            // Inicializar componentes
            this.initializeEventListeners();
            this.initializeWebSocket();
            this.loadUserInfo();
            this.loadDashboard();
            this.registerServiceWorker();
            
            // Check for updates periodically
            setInterval(() => this.checkForUpdates(), 30000);
            
        } catch (error) {
            console.error('Error inicializando app:', error);
            this.showNotification('Error iniciando aplicación', 'error');
        } finally {
            this.showLoading(false);
        }
    }

    // Verificar token de autenticación
    async verifyToken() {
        try {
            const response = await this.apiCall('/api/auth/profile', 'GET');
            if (response.success) {
                this.user = response.data.user;
                localStorage.setItem('user', JSON.stringify(this.user));
                return true;
            }
            return false;
        } catch (error) {
            console.error('Token verification failed:', error);
            return false;
        }
    }

    // Realizar llamadas a la API con retry y manejo de errores
    async apiCall(endpoint, method = 'GET', data = null, retryCount = 0) {
        const url = `${this.apiUrl}${endpoint}`;
        const options = {
            method,
            headers: {
                'Content-Type': 'application/json',
                'Authorization': this.token ? `Bearer ${this.token}` : ''
            }
        };

        if (data && method !== 'GET') {
            options.body = JSON.stringify(data);
        }

        try {
            const response = await fetch(url, options);
            
            // Manejar diferentes códigos de estado
            if (response.status === 401) {
                this.handleUnauthorized();
                throw new Error('No autorizado');
            }

            if (response.status === 429) {
                // Rate limiting
                const retryAfter = response.headers.get('Retry-After') || 5;
                await this.sleep(retryAfter * 1000);
                if (retryCount < this.retryAttempts) {
                    return this.apiCall(endpoint, method, data, retryCount + 1);
                }
                throw new Error('Demasiadas solicitudes');
            }

            if (!response.ok) {
                const errorData = await response.json().catch(() => ({}));
                throw new Error(errorData.message || `HTTP ${response.status}`);
            }

            return await response.json();
        } catch (error) {
            if (retryCount < this.retryAttempts && this.shouldRetry(error)) {
                await this.sleep(Math.pow(2, retryCount) * 1000); // Exponential backoff
                return this.apiCall(endpoint, method, data, retryCount + 1);
            }
            throw error;
        }
    }

    // Determinar si se debe reintentar la solicitud
    shouldRetry(error) {
        return error.name === 'TypeError' || // Network error
               error.message.includes('fetch') ||
               error.message.includes('network');
    }

    // Utilidad para esperar
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    // Manejar no autorizado
    handleUnauthorized() {
        localStorage.removeItem('auth_token');
        localStorage.removeItem('user');
        this.redirectToLogin();
    }

    // Redireccionar a login
    redirectToLogin() {
        window.location.href = '/login.html';
    }

    // Inicializar WebSocket para tiempo real
    initializeWebSocket() {
        try {
            this.socket = io(this.apiUrl, {
                auth: {
                    token: this.token
                },
                transports: ['websocket', 'polling']
            });

            this.socket.on('connect', () => {
                console.log('✅ WebSocket conectado');
                this.socket.emit('join-room', 'general');
            });

            this.socket.on('disconnect', () => {
                console.log('❌ WebSocket desconectado');
                this.showNotification('Conexión perdida, reintentando...', 'warning');
            });

            this.socket.on('nuevo-mensaje', (mensaje) => {
                this.handleNewMessage(mensaje);
            });

            this.socket.on('notification', (notification) => {
                this.showNotification(notification.message, notification.type);
            });

            // Reconexión automática
            this.socket.on('connect_error', () => {
                setTimeout(() => {
                    this.socket.connect();
                }, 5000);
            });

        } catch (error) {
            console.error('Error inicializando WebSocket:', error);
        }
    }

    // Inicializar event listeners
    initializeEventListeners() {
        // Navegación
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const section = item.getAttribute('data-section');
                this.navigateToSection(section);
            });
        });

        // Mobile menu
        document.getElementById('mobile-menu-btn')?.addEventListener('click', () => {
            document.getElementById('sidebar').classList.toggle('open');
        });

        // Logout
        document.getElementById('logout-btn')?.addEventListener('click', () => {
            this.logout();
        });

        // Online/Offline detection
        window.addEventListener('online', () => {
            this.showNotification('Conexión restaurada', 'success');
            this.syncOfflineData();
        });

        window.addEventListener('offline', () => {
            this.showNotification('Sin conexión a internet', 'warning');
        });

        // Keyboard shortcuts
        document.addEventListener('keydown', (e) => {
            if (e.ctrlKey || e.metaKey) {
                switch(e.key) {
                    case '1':
                        e.preventDefault();
                        this.navigateToSection('dashboard');
                        break;
                    case '2':
                        e.preventDefault();
                        this.navigateToSection('reservas');
                        break;
                    case '3':
                        e.preventDefault();
                        this.navigateToSection('pagos');
                        break;
                    // Agregar más shortcuts
                }
            }
        });
    }

    // Navegar a sección
    navigateToSection(section) {
        if (section === this.currentSection) return;

        // Actualizar navegación visual
        document.querySelectorAll('.nav-item').forEach(item => {
            item.classList.remove('active');
        });
        document.querySelector(`[data-section="${section}"]`)?.classList.add('active');

        // Ocultar secciones actuales
        document.querySelectorAll('.section').forEach(sec => {
            sec.classList.add('hidden');
        });

        // Mostrar nueva sección
        const sectionElement = document.getElementById(`${section}-section`);
        if (sectionElement) {
            sectionElement.classList.remove('hidden');
            sectionElement.classList.add('fade-in');
        }

        // Actualizar título
        document.getElementById('page-title').textContent = this.getSectionTitle(section);

        // Cargar datos de la sección
        this.loadSectionData(section);
        this.currentSection = section;

        // Actualizar URL (sin recargar)
        history.pushState({ section }, '', `#${section}`);
    }

    // Obtener título de sección
    getSectionTitle(section) {
        const titles = {
            dashboard: 'Dashboard',
            reservas: 'Reservas',
            pagos: 'Pagos',
            chat: 'Chat',
            emprendimientos: 'Emprendimientos',
            pqr: 'PQR',
            permisos: 'Permisos'
        };
        return titles[section] || 'Dashboard';
    }

    // Cargar información del usuario
    async loadUserInfo() {
        if (!this.user) return;

        document.getElementById('user-name').textContent = 
            `${this.user.nombres} ${this.user.apellidos}`;
        document.getElementById('user-apartment').textContent = 
            `Apto ${this.user.apartamento}${this.user.torre}`;
    }

    // Cargar dashboard
    async loadDashboard() {
        try {
            const [reservas, pagos, mensajes, pqrs] = await Promise.all([
                this.apiCall('/api/reservas?limit=5'),
                this.apiCall('/api/pagos?estado=pendiente'),
                this.apiCall('/api/mensajes?limit=10'),
                this.apiCall('/api/pqrs?estado=pendiente')
            ]);

            // Actualizar estadísticas
            document.getElementById('stat-reservas').textContent = 
                reservas.data.pagination.totalItems;
            
            const totalPendiente = pagos.data.pagos
                .reduce((sum, pago) => sum + parseFloat(pago.valor), 0);
            document.getElementById('stat-pagos').textContent = 
                `$${totalPendiente.toLocaleString()}`;
            
            document.getElementById('stat-mensajes').textContent = 
                mensajes.data.pagination.totalItems;
            
            document.getElementById('stat-pqrs').textContent = 
                pqrs.data.pagination.totalItems;

            // Cargar actividad reciente
            this.loadRecentActivity();
            this.loadUpcomingEvents();

        } catch (error) {
            console.error('Error cargando dashboard:', error);
            this.showNotification('Error cargando dashboard', 'error');
        }
    }

    // Cargar actividad reciente
    async loadRecentActivity() {
        const container = document.getElementById('recent-activity');
        container.innerHTML = '<div class="skeleton h-4 rounded mb-2"></div>'.repeat(3);

        try {
            // Simular actividad reciente
            const activities = [
                {
                    icon: 'fa-calendar',
                    text: 'Reserva creada para Salón Comunal',
                    time: '2 horas ago',
                    type: 'success'
                },
                {
                    icon: 'fa-credit-card',
                    text: 'Pago de administración procesado',
                    time: '1 día ago',
                    type: 'success'
                },
                {
                    icon: 'fa-comments',
                    text: '3 mensajes nuevos en chat general',
                    time: '3 horas ago',
                    type: 'info'
                }
            ];

            container.innerHTML = activities.map(activity => `
                <div class="flex items-center gap-3 p-3 hover:bg-gray-50 rounded-lg">
                    <div class="w-8 h-8 bg-${activity.type === 'success' ? 'green' : activity.type === 'info' ? 'blue' : 'gray'}-100 rounded-full flex items-center justify-center">
                        <i class="fas ${activity.icon} text-${activity.type === 'success' ? 'green' : activity.type === 'info' ? 'blue' : 'gray'}-600 text-sm"></i>
                    </div>
                    <div class="flex-1">
                        <p class="text-sm text-gray-800">${activity.text}</p>
                        <p class="text-xs text-gray-500">${activity.time}</p>
                    </div>
                </div>
            `).join('');

        } catch (error) {
            container.innerHTML = '<p class="text-red-500 text-sm">Error cargando actividad</p>';
        }
    }

    // Cargar próximos eventos
    async loadUpcomingEvents() {
        const container = document.getElementById('upcoming-events');
        container.innerHTML = '<div class="skeleton h-4 rounded mb-2"></div>'.repeat(3);

        try {
            const events = [
                {
                    title: 'Reunión de Copropietarios',
                    date: '2025-08-20',
                    time: '19:00',
                    location: 'Salón Comunal'
                },
                {
                    title: 'Mantenimiento Ascensores',
                    date: '2025-08-25',
                    time: '08:00',
                    location: 'Torre A y B'
                }
            ];

            container.innerHTML = events.map(event => `
                <div class="border-l-4 border-blue-500 pl-4 py-2">
                    <h4 class="font-medium text-gray-800">${event.title}</h4>
                    <p class="text-sm text-gray-600">${event.date} a las ${event.time}</p>
                    <p class="text-xs text-gray-500">${event.location}</p>
                </div>
            `).join('');

        } catch (error) {
            container.innerHTML = '<p class="text-red-500 text-sm">Error cargando eventos</p>';
        }
    }

    // Cargar datos de sección específica
    async loadSectionData(section) {
        const loaders = {
            reservas: () => this.loadReservas(),
            pagos: () => this.loadPagos(),
            chat: () => this.loadChat(),
            emprendimientos: () => this.loadEmprendimientos(),
            pqr: () => this.loadPQR(),
            permisos: () => this.loadPermisos()
        };

        const loader = loaders[section];
        if (loader) {
            try {
                await loader();
            } catch (error) {
                console.error(`Error cargando ${section}:`, error);
                this.showNotification(`Error cargando ${section}`, 'error');
            }
        }
    }

    // Cargar reservas
    async loadReservas() {
        const container = document.getElementById('reservas-content');
        container.innerHTML = '<div class="skeleton h-32 rounded"></div>';

        try {
            const response = await this.apiCall('/api/reservas');
            const reservas = response.data.reservas;

            container.innerHTML = `
                <div class="mb-6">
                    <button class="btn-primary" onclick="app.showReservaModal()">
                        <i class="fas fa-plus"></i>
                        Nueva Reserva
                    </button>
                </div>
                
                <div class="space-y-4">
                    ${reservas.map(reserva => `
                        <div class="card p-4 flex justify-between items-center">
                            <div>
                                <h4 class="font-semibold">${this.getEspacioName(reserva.espacio)}</h4>
                                <p class="text-sm text-gray-600">${reserva.fecha} • ${reserva.horaInicio} - ${reserva.horaFin}</p>
                                <p class="text-xs text-gray-500">${reserva.numeroPersonas} personas</p>
                            </div>
                            <div class="flex items-center gap-2">
                                <span class="status-badge ${this.getStatusClass(reserva.estado)}">${reserva.estado}</span>
                                ${reserva.estado === 'pendiente' ? `
                                    <button onclick="app.cancelReserva('${reserva.id}')" class="text-red-600 hover:bg-red-50 p-2 rounded">
                                        <i class="fas fa-times"></i>
                                    </button>
                                ` : ''}
                            </div>
                        </div>
                    `).join('')}
                </div>
            `;

        } catch (error) {
            container.innerHTML = '<p class="text-red-500">Error cargando reservas</p>';
        }
    }

    // Cargar pagos
    async loadPagos() {
        const container = document.getElementById('pagos-content');
        container.innerHTML = '<div class="skeleton h-32 rounded"></div>';

        try {
            const response = await this.apiCall('/api/pagos');
            const pagos = response.data.pagos;

            const pendientes = pagos.filter(p => p.estado === 'pendiente');
            const pagados = pagos.filter(p => p.estado === 'pagado');

            container.innerHTML = `
                <div class="grid md:grid-cols-2 gap-6">
                    <div>
                        <h4 class="font-semibold text-red-600 mb-4">Pagos Pendientes</h4>
                        <div class="space-y-3">
                            ${pendientes.map(pago => `
                                <div class="card p-4">
                                    <div class="flex justify-between items-start mb-2">
                                        <h5 class="font-medium">${pago.descripcion}</h5>
                                        <span class="text-lg font-bold text-red-600">$${parseFloat(pago.valor).toLocaleString()}</span>
                                    </div>
                                    <p class="text-sm text-gray-600">${pago.periodo}</p>
                                    <p class="text-sm text-red-500">Vence: ${new Date(pago.fechaVencimiento).toLocaleDateString()}</p>
                                    <button onclick="app.processPayment('${pago.id}')" class="btn-primary mt-3">
                                        <i class="fas fa-credit-card"></i>
                                        Pagar Ahora
                                    </button>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                    
                    <div>
                        <h4 class="font-semibold text-green-600 mb-4">Pagos Realizados</h4>
                        <div class="space-y-3">
                            ${pagados.slice(0, 5).map(pago => `
                                <div class="card p-4">
                                    <div class="flex justify-between items-start mb-2">
                                        <h5 class="font-medium">${pago.descripcion}</h5>
                                        <span class="text-lg font-bold text-green-600">$${parseFloat(pago.valor).toLocaleString()}</span>
                                    </div>
                                    <p class="text-sm text-gray-600">${pago.periodo}</p>
                                    <div class="flex items-center text-green-500 text-sm mt-1">
                                        <i class="fas fa-check-circle mr-1"></i>
                                        Pagado el ${new Date(pago.fechaPago).toLocaleDateString()}
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>
                </div>
            `;

        } catch (error) {
            container.innerHTML = '<p class="text-red-500">Error cargando pagos</p>';
        }
    }

    // Mostrar notificación
    showNotification(message, type = 'info', duration = 5000) {
        const container = document.getElementById('notification-container');
        const id = Date.now();
        
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <div class="flex items-start gap-3">
                <i class="fas fa-${this.getNotificationIcon(type)} text-lg mt-1"></i>
                <div class="flex-1">
                    <p class="font-medium">${message}</p>
                </div>
                <button onclick="this.parentElement.parentElement.remove()" class="text-gray-400 hover:text-gray-600">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        `;

        container.appendChild(notification);
        
        // Animar entrada
        setTimeout(() => notification.classList.add('show'), 100);
        
        // Auto-remover
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, duration);
    }

    // Obtener icono de notificación
    getNotificationIcon(type) {
        const icons = {
            success: 'check-circle',
            error: 'exclamation-circle',
            warning: 'exclamation-triangle',
            info: 'info-circle'
        };
        return icons[type] || 'info-circle';
    }

    // Mostrar/ocultar loading
    showLoading(show) {
        const overlay = document.getElementById('loading-overlay');
        if (show) {
            overlay.classList.remove('hidden');
        } else {
            overlay.classList.add('hidden');
        }
    }

    // Cerrar sesión
    async logout() {
        try {
            await this.apiCall('/api/auth/logout', 'POST');
        } catch (error) {
            console.error('Error durante logout:', error);
        } finally {
            localStorage.removeItem('auth_token');
            localStorage.removeItem('user');
            if (this.socket) {
                this.socket.disconnect();
            }
            window.location.href = '/login.html';
        }
    }

    // Registrar Service Worker
    async registerServiceWorker() {
        if ('serviceWorker' in navigator) {
            try {
                await navigator.serviceWorker.register('/sw.js');
                console.log('Service Worker registrado');
            } catch (error) {
                console.error('Error registrando Service Worker:', error);
            }
        }
    }

    // Verificar actualizaciones
    async checkForUpdates() {
        if ('serviceWorker' in navigator) {
            const registration = await navigator.serviceWorker.getRegistration();
            if (registration) {
                registration.update();
            }
        }
    }

    // Sincronizar datos offline
    async syncOfflineData() {
        // Implementar sincronización de datos offline
        console.log('Sincronizando datos offline...');
    }

    // Utilidades
    getEspacioName(espacio) {
        const nombres = {
            salon_comunal: 'Salón Comunal',
            gimnasio: 'Gimnasio',
            piscina: 'Piscina',
            juegos_star: 'Zona de Juegos',
            terraza: 'Terraza',
            bbq: 'Zona BBQ'
        };
        return nombres[espacio] || espacio;
    }

    getStatusClass(estado) {
        const classes = {
            pendiente: 'warning',
            confirmada: 'success',
            cancelada: 'error',
            completada: 'info'
        };
        return classes[estado] || 'info';
    }

    // Manejar nuevos mensajes de chat
    handleNewMessage(mensaje) {
        // Implementar manejo de mensajes en tiempo real
        const badge = document.getElementById('chat-badge');
        if (badge && this.currentSection !== 'chat') {
            const current = parseInt(badge.textContent) || 0;
            badge.textContent = current + 1;
            badge.classList.remove('hidden');
        }
    }

    // Procesar pago
    async processPayment(pagoId) {
        try {
            this.showLoading(true);
            
            // Simular modal de pago
            const metodoPago = await this.showPaymentModal();
            if (!metodoPago) return;

            const response = await this.apiCall(`/api/pagos/${pagoId}/procesar`, 'PATCH', {
                metodoPago: metodoPago.method,
                referenciaPago: metodoPago.reference
            });

            if (response.success) {
                this.showNotification('Pago procesado exitosamente', 'success');
                this.loadPagos(); // Recargar pagos
            }

        } catch (error) {
            this.showNotification('Error procesando pago: ' + error.message, 'error');
        } finally {
            this.showLoading(false);
        }
    }

    // Mostrar modal de pago (simulado)
    async showPaymentModal() {
        return new Promise((resolve) => {
            // Simular selección de método de pago
            const method = prompt('Método de pago (tarjeta/pse/transferencia):') || 'tarjeta';
            const reference = `REF_${Date.now()}`;
            
            if (method) {
                resolve({ method, reference });
            } else {
                resolve(null);
            }
        });
    }

    // Cancelar reserva
    async cancelReserva(reservaId) {
        if (!confirm('¿Estás seguro de cancelar esta reserva?')) return;

        try {
            const motivo = prompt('Motivo de cancelación (opcional):') || '';
            
            const response = await this.apiCall(`/api/reservas/${reservaId}/cancel`, 'PATCH', {
                motivo
            });

            if (response.success) {
                this.showNotification('Reserva cancelada exitosamente', 'success');
                this.loadReservas(); // Recargar reservas
            }

        } catch (error) {
            this.showNotification('Error cancelando reserva: ' + error.message, 'error');
        }
    }
}

// Inicializar aplicación cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.app = new ConjuntoApp();
});

// Manejar navegación del historial
window.addEventListener('popstate', (event) => {
    if (event.state && event.state.section) {
        window.app.navigateToSection(event.state.section);
    }
});

// Manejar errores globales
window.addEventListener('error', (event) => {
    console.error('Error global:', event.error);
    if (window.app) {
        window.app.showNotification('Ha ocurrido un error inesperado', 'error');
    }
});

// Manejar promesas rechazadas
window.addEventListener('unhandledrejection', (event) => {
    console.error('Promise rechazada:', event.reason);
    if (window.app) {
        window.app.showNotification('Error de conexión', 'error');
    }
});

// Exportar para uso global
window.ConjuntoApp = ConjuntoApp;