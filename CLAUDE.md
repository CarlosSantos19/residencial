# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Install dependencies**: `npm install`
- **Start development server**: `npm run dev` (uses nodemon for auto-reload)
- **Start production server**: `npm start`
- **Access application**: http://localhost:8081

## Role-Based Authentication System

The application has four distinct user roles with visual differentiation:

**Demo Users:**
- **Residente**: `car-cbs@hotmail.com` / `password1` (Blue interface - #2563EB)
- **Administrador**: `shayoja@hotmail.com` / `password2` (Green interface - #16A34A)
- **Vigilante**: `car02cbs@gmail.com` / `password3` (Orange interface - #EA580C)
- **Alcaldía**: `alcaldia@conjunto.com` / `alcaldia123` (Special role for municipal coordination)

Each role has completely different UI colors, navigation tabs, and available functionalities.

## Project Architecture

This is a comprehensive residential complex management system with role-based access control built using Node.js/Express backend and vanilla JavaScript frontend.

### Backend Architecture (server.js)
- **Express server** running on port 8081
- **In-memory data storage** with auto-backup to `data.json` every 5 minutes (server.js:3206-3209)
- **Role-based middleware**:
  - `verificarAdmin(req, res, next)`: Ensures user has 'admin' role (server.js:1860-1873)
  - `verificarVigilante(req, res, next)`: Allows 'vigilante' or 'admin' roles (server.js:2064-2077)
  - Uses token-based authentication via Authorization header: `Bearer <token>`
  - Extracts user from token using `obtenerUsuarioPorToken(token)` helper (server.js:2049-2057)
  - Returns 403 for unauthorized access
- **~100+ API endpoints** organized by modules:
  - Authentication: `/api/auth/*` (login, register, verify)
  - Chat system: `/api/chat/*` (general, admin, vigilantes, private chats)
  - Admin endpoints: `/api/admin/*` (residentes, parqueaderos, noticias, pagos, usuarios, camaras, pqrs, etc.)
  - Resident services: `/api/residente/*` (emprendimientos, arriendos, parqueadero, reservas, solicitudes)
  - Vigilante operations: `/api/vigilante/*` (solicitudes)
  - General endpoints: `/api/reservas`, `/api/pagos`, `/api/mensajes`, `/api/emprendimientos`, `/api/pqrs`, `/api/encuestas`, `/api/incidentes`, `/api/vehiculos-visitantes`

### Frontend Architecture
- **Main application**: [public/conjunto-aralia-completo.html](public/conjunto-aralia-completo.html) - Complete SPA with embedded CSS/JS (single file architecture)
- **Role-based UI system**: Dynamic interface changes based on user role via `setupUserInterface()` (line ~614)
- **Tab-based navigation**: Different tab configurations per role using `tabConfigs` object (line ~449)
  - Residente: 15 modules (Dashboard, Reservas, Pagos, Emprendimientos, etc.)
  - Admin: 12 modules (Panel Admin, Sorteo, Noticias, Usuarios, etc.)
  - Vigilante: 6 security modules (Panel Seguridad, Control Vehículos, Permisos, etc.)
- **Tailwind CSS**: Custom color schemes per role configured via tailwind.config (line ~11)
- **Real-time features**: Notification system, live chat, dynamic updates

### Key Data Models
The `data` object in server.js (starts at line 15) contains:
- **usuarios**: User accounts with roles (residente, admin, vigilante, alcaldia) and permissions
- **chats**: Structured chat system with channels: `general`, `admin`, `vigilantes`, `privados` (object with chat IDs as keys)
- **emprendimientos**: Resident businesses with review system
- **resenas**: Rating and review system for businesses
- **noticias**: News management system with categories (Administrativo, Social, Mantenimiento, Seguridad)
- **reservas**: Space reservation system (Salón Social, BBQ, Piscina, etc.)
- **pagos**: Payment tracking and management
- **pqrs**: Complaints and request system with states (Pendiente, En proceso, Resuelto, Rechazado)
- **vehiculosVisitantes**: Vehicle access control with time-based fee calculation
- **solicitudesChat**: Private chat request system (accept/reject flow)
- **permisos**: Permission requests (visitantes, objetos, salidas, trasteos)
- **paquetes**: Package delivery notifications
- **encuestas**: Surveys and voting system
- **incidentes**: Municipal incident reporting (for Alcaldía role)
- **parqueaderos**: Parking spot assignments (100 spots with lottery system)
- **sorteoParqueaderos**: Parking lottery results
- **apartamentosArriendo**: Rental listings for apartments
- **recibosParqueadero**: Parking fee receipts

### Visual Differentiation System
The application implements complete visual differentiation by role via `setupUserInterface()`:
- **Dynamic header colors**: Gradient backgrounds change based on role (blue-600 to blue-700 for residente, green-600 to green-700 for admin, orange-600 to orange-700 for vigilante)
- **Navigation bar colors**: Full navigation bar adopts role colors (bg-blue-500, bg-green-500, bg-orange-500)
- **Tab styling**: Active and hover states use role-specific colors
- **UI elements**: Buttons, icons, and interactive elements match role theme
- **Color configuration**: Tailwind CSS custom colors defined in tailwind.config: `residente-azul: #2563EB`, `admin-verde: #16A34A`, `vigilante-naranja: #EA580C`

### Key Frontend Functions and Patterns
- **setupUserInterface()**: Dynamically applies role-based styling to header, navigation, and tabs (line ~614)
- **switchTab(tabId)**: Handles tab navigation with role-appropriate styling
- **tabConfigs**: Object defining available tabs per role (line ~449)
- **apiCall(endpoint, method, body)**: Centralized API communication helper with token management
- **Token-based authentication**: Simple token system using base64 encoding (userId:timestamp)
- **4-tier chat system**: general (all), admin (admin only), vigilantes (vigilantes + admin), privados (peer-to-peer)

## Data Persistence

- **Primary storage**: In-memory JavaScript objects in `data` variable (server.js:34)
- **Automatic backup**: `setInterval()` writes to data.json every 5 minutes (server.js:3206-3209)
- **Manual save**: `guardarDatos()` called after each data modification - currently a console.log stub (server.js:1851-1853)
- **No external database**: All data persists via JSON file for development/demo purposes
- **Important**: Changes are only persisted to disk every 5 minutes or when server shuts down gracefully

## Key Implementation Details

### Authentication Flow
1. Login via `/api/auth/login` returns token (base64 encoded `userId:timestamp`)
2. Token sent in Authorization header: `Bearer <token>`
3. Server decodes token via `obtenerUsuarioPorToken()` to identify user (server.js:2049-2057)
4. Middleware functions check user role and return 403 if unauthorized
5. Frontend stores token in localStorage as 'authToken'

### Vehicle Parking Fee Calculation
Time-based fee structure for visitor vehicles:
- **First 2 hours**: Free
- **Hours 3-10**: $1,000 COP per hour
- **After 10 hours or multiple days**: $12,000 COP flat rate per day
- **Receipt generation**: Automatic detailed breakdown with entry/exit times, calculation explanation
- **Endpoints**: `/api/vehiculos-visitantes/ingreso` (POST), `/api/vehiculos-visitantes/salida` (POST), `/api/vehiculos-visitantes/salida-calculada` (POST)

### Chat System Structure
- **General Chat**: All users can view and send messages (`/api/chat/general`)
- **Admin Chat**: Only admin can view and send (`/api/chat/admin`)
- **Vigilantes Chat**: Only vigilantes and admin can view (`/api/chat/vigilantes`)
- **Private Chats**: Between individual residents, requires acceptance of solicitud via `/api/chat/solicitar` and `/api/chat/responder`
- **Chat ID format**: Private chats use format `{userId1}-{userId2}` where lower ID comes first

### Parking Lottery System
- 100 parking spots managed via `/api/admin/sorteo-parqueaderos` (POST)
- Admin initiates lottery, system randomly assigns spots to residents
- Results stored in `sorteoParqueaderos` and reflected in resident's "Mi Parqueadero" tab
- Endpoint: `/api/residente/mi-parqueadero` (GET) returns assigned parking for logged-in user

### Important Helper Functions
- **obtenerUsuarioPorToken(token)**: Decodes base64 token and returns user object from data.usuarios (server.js:2049-2057)
- **verificarAdmin(req, res, next)**: Middleware to restrict endpoints to admin role (server.js:1860-1873)
- **verificarVigilante(req, res, next)**: Middleware to restrict endpoints to vigilante or admin roles (server.js:2064-2077)
- **guardarDatos()**: Stub function for manual data persistence - currently just logs to console (server.js:1851-1853)

## File Organization
```
├── server.js                           # Main Express server with all API endpoints (3208 lines)
├── public/
│   ├── conjunto-aralia-completo.html   # Main SPA application (9834 lines - all-in-one file)
│   ├── conjunto-aralia-firebase.html   # Firebase-integrated version
│   ├── app-residencial-completa.html   # Alternative frontend version
│   └── index.html                      # Legacy/alternative landing page
├── conjunto_residencial_flutter/       # Flutter mobile app (95% parity with web)
│   ├── lib/
│   │   ├── models/                    # Data models (User, Pago, Reserva, PQRS, Encuesta, etc.)
│   │   ├── screens/                   # UI screens by role (residente, admin, vigilante, alcaldia)
│   │   ├── services/                  # Core services (API, Auth, Notifications, PDF, Payments)
│   │   └── widgets/                   # Reusable UI components
│   ├── pubspec.yaml                   # Flutter dependencies
│   ├── CONFIGURACION_FIREBASE.md      # Step-by-step Firebase setup guide
│   └── RESUMEN_IMPLEMENTACION_COMPLETA.md  # Implementation summary
├── package.json                        # Node.js dependencies and scripts
├── data.json                          # Auto-generated data backup (created at runtime)
├── README_SISTEMA_COMPLETO.md         # Comprehensive system documentation
├── RESUMEN_PARIDAD_FLUTTER_WEB.md     # Flutter ↔ Web parity report
└── CLAUDE.md                          # This file
```

## Flutter Mobile App

The project includes a **complete Flutter mobile application** with 95% feature parity to the web version.

### Run Flutter App
```bash
cd conjunto_residencial_flutter
flutter pub get
flutter run
```

### Build for Production
```bash
# Android APK
flutter build apk --release

# iOS (requires Mac + Xcode)
flutter build ios --release
```

### Key Flutter Features
- **36+ screens** organized by role (residente, admin, vigilante, alcaldía)
- **3 core services** implemented:
  - `NotificationService`: Firebase Cloud Messaging with 5 notification channels
  - `PdfService`: Professional PDF generation (receipts, reports, summaries)
  - `PaymentService`: 5 payment methods (Efectivo, Nequi, Daviplata, PSE, Transferencia)
- **Real-time features**:
  - Vehicle control with live timer (updates every second)
  - Dashboard with live statistics
  - Auto-refresh for surveys (every 10 seconds)
- **Advanced UI**:
  - 4 chart types using `fl_chart` (bar, pie, line, progress)
  - Visual calendar for reservations (`table_calendar`)
  - Image gallery swipers with `PageView`
  - Confetti animations for parking lottery
- **Native integrations**:
  - Direct phone calls via `url_launcher`
  - WhatsApp deep linking
  - Camera/gallery for attachments (`image_picker`)
  - QR code generation and scanning

### Flutter Dependencies
See `conjunto_residencial_flutter/pubspec.yaml` for complete list:
- Firebase: `firebase_core`, `firebase_messaging`, `flutter_local_notifications`
- PDF: `pdf`, `printing`, `path_provider`, `open_file`
- Charts: `fl_chart`
- UI: `table_calendar`, `confetti`, `lottie`
- Utils: `url_launcher`, `image_picker`, `qr_flutter`, `mobile_scanner`

### Firebase Configuration
For push notifications to work, you must:
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Download `google-services.json` (Android) and place in `android/app/`
3. Download `GoogleService-Info.plist` (iOS) and add to Xcode project
4. See detailed guide: `conjunto_residencial_flutter/CONFIGURACION_FIREBASE.md`

## Important Implementation Notes

- **Single-file architecture (Web)**: All frontend functionality (HTML, CSS, JS) is in one file for easy deployment
- **Flutter architecture**: Clean separation with models, services, screens, and widgets
- **In-memory storage**: Server restarts will lose data unless backed up to data.json
- **Role-based access**: Implemented both client-side (UI visibility) and server-side (API authorization)
- **No build step (Web)**: Direct HTML/CSS/JS with CDN dependencies (Tailwind, Font Awesome, Chart.js)
- **Flutter build**: Requires `flutter build` for production APK/IPA
- **Token security**: Simple base64 encoding (not encrypted) - suitable for demo/development only
- **PWA capabilities**: Web version designed for offline support and mobile installation
- **Native capabilities (Flutter)**: Push notifications, PDF generation, payment integrations exceed web version
