# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Conjunto Aralia de Castilla** is a comprehensive residential management system for apartment complexes in Colombia. The system combines a traditional Node.js/Express backend with Firebase integration, serving both a web application and supporting a Flutter mobile app (currently removed from repository but historically present).

### Key Technologies
- **Backend**: Node.js + Express (REST API)
- **Frontend**: Vanilla JavaScript with Tailwind CSS
- **Database**: Dual-mode - Firebase Firestore (production) and in-memory storage (development)
- **Authentication**: Firebase Authentication
- **Hosting**: Firebase Hosting + Render (for API fallback)

## Architecture

### Dual Storage System
The application uses a unique dual-storage architecture:
- **Development/Fallback**: In-memory storage in [server.js](server.js) with data persistence via [data.json](data.json)
- **Production**: Firebase Firestore with client-side integration through [firebase-adapter.js](public/firebase-adapter.js)

The [firebase-adapter.js](public/firebase-adapter.js) translates traditional REST API patterns to Firestore operations, allowing the frontend to work seamlessly with both modes.

### User Roles & Permissions
The system supports four distinct user roles with different capabilities:
- **Residente** (Resident): Make reservations, pay bills, submit PQRS, manage vehicles
- **Admin** (Administrator): Full system access, user management, billing, lottery system
- **Vigilante** (Security Guard): Vehicle control, package management, permit verification
- **Alcaldia** (Municipal Office): Incident reporting and tracking

Role-based access is enforced in both [server.js](server.js) middleware and [firestore.rules](firestore.rules).

### Main Modules

**Reservations System** (`/api/reservas`)
- Calendar-based booking for shared spaces (salon, gym, pool, BBQ area, sports court)
- Outlook-style interface with availability checking
- Admin can view/manage all reservations

**Payment Management** (`/api/pagos`)
- Monthly administration fee tracking
- PDF receipt uploads by admin
- Residents can view payment history and mark as paid
- Multi-concept billing support (admin fees, parking, utilities)

**PQRS System** (`/api/pqrs`)
- Petitions, Complaints, and Claims module
- Status tracking: pending, in_progress, resolved, closed
- Admin response system with timestamps

**Chat System** (`/api/chat`)
- General community chat (all residents)
- Admin-only channel
- Vigilante channel
- Private chat requests between residents (approval-based)
- Different chat channels stored separately in Firestore

**Vehicle Management**
- Visitor vehicle registration with automatic tariff calculation:
  - First 2 hours: FREE
  - Hour 3+: $1,000/hour
  - After 15 hours: $12,000 flat rate
- Receipt generation for parking fees
- Resident vehicle database with parking assignments

**Parking Lottery** (`/api/sorteo-parqueaderos`)
- Random assignment system for 100 parking spots (P-001 to P-100)
- Distribution across 3 basement levels
- CSV export of results
- Historical record keeping

**Incidents/Municipal Reports** (`/api/incidentes`)
- Community infrastructure issues
- Integration with municipal authorities (alcaldia role)
- Photo attachments, status tracking

**Entrepreneurship Directory** (`/api/emprendimientos`)
- Residents can promote their businesses
- Review and rating system
- Category filtering

**Permits & Packages** (`/api/permisos`, `/api/paquetes`)
- Pre-authorization for visitors
- QR code generation for entry
- Package tracking with vigilante management

## Development Commands

### Local Development
```bash
# Install dependencies
npm install

# Start development server with auto-reload
npm run dev

# Start production server
npm start

# Server runs on http://localhost:8081
```

### Firebase Operations
```bash
# Deploy to Firebase Hosting
firebase deploy --only hosting

# Deploy Firestore rules
firebase deploy --only firestore:rules

# View Firebase logs
firebase functions:log

# Test Firestore rules locally
firebase emulators:start
```

### Data Migration
```bash
# The repository contains several migration utilities in public/:
# - migrar-datos-completo.html - Full data migration to Firestore
# - crear-usuarios-firebase.html - Create Firebase Auth users
# - sincronizar-usuarios.html - Sync users between systems
# - reparar-usuarios.html - Fix user data inconsistencies
```

## Important File Locations

### Core Application Files
- [server.js](server.js) - Express API server with 50+ endpoints
- [public/index.html](public/index.html) - Main SPA with all UI components
- [public/firebase-adapter.js](public/firebase-adapter.js) - Firebase integration layer
- [data.json](data.json) - Development data store

### Configuration Files
- [firebase.json](firebase.json) - Firebase hosting and Firestore config
- [firestore.rules](firestore.rules) - Security rules for all collections
- [firestore.indexes.json](firestore.indexes.json) - Database indexes
- [render.yaml](render.yaml) - Render.com deployment config
- [.firebaserc](.firebaserc) - Firebase project ID

## API Endpoints Structure

All endpoints follow RESTful conventions under `/api/` prefix:

**Authentication**: `/api/auth/login`, `/api/auth/register`, `/api/auth/verify`

**Resources**: Standard CRUD operations
- GET `/api/{resource}` - List all (filtered by role)
- GET `/api/{resource}/:id` - Get single item
- POST `/api/{resource}` - Create new
- PUT `/api/{resource}/:id` - Update existing
- DELETE `/api/{resource}/:id` - Delete (admin only)

**Role-specific prefixes**:
- `/api/residente/*` - Resident-only endpoints
- `/api/admin/*` - Admin-only endpoints (uses `verificarAdmin` middleware)
- `/api/vigilante/*` - Security guard endpoints (uses `verificarVigilante` middleware)

## Firestore Collections

Primary collections (see [firestore.rules](firestore.rules) for complete list):
- `usuarios` - User profiles with role information
- `reservas` - Space reservations
- `pagos` - Payment records
- `pqrs` - Petitions, complaints, claims
- `noticias` - Community news/announcements
- `encuestas` - Surveys with nested `votos` subcollection
- `emprendimientos` - Business directory with `resenas` subcollection
- `chats/general/mensajes` - General chat messages
- `chats/privados/{chatId}/mensajes` - Private chats
- `vehiculosVisitantes` - Visitor vehicle logs
- `permisos` - Visitor permits
- `paquetes` - Package deliveries
- `parqueaderos` - Parking assignments
- `sorteos` - Parking lottery history
- `incidentes` - Municipal incident reports

## Authentication Flow

1. User submits email/password via login form
2. Firebase Authentication validates credentials
3. On success, retrieve user document from `usuarios` collection
4. Store user data in `localStorage` with role information
5. All API calls include user context from localStorage
6. Firestore rules verify permissions using `request.auth.uid`

## Testing Credentials

Demo users are defined in [server.js](server.js) and [data.json](data.json):
- **Resident**: car-cbs@hotmail.com / password1
- **Admin**: shayoja@hotmail.com / password2
- **Vigilante**: car02cbs@gmail.com / password3
- **Alcaldia**: alcaldia@conjunto.com / alcaldia123
- Additional demo residents: All use password `demo123`

## Special Considerations

### Firebase vs. Local Mode
The application auto-detects Firebase availability. If [firebase-adapter.js](public/firebase-adapter.js) is loaded and configured, it uses Firestore. Otherwise, it falls back to API calls against [server.js](server.js). When modifying data structures, update both:
1. In-memory data structures in [server.js](server.js)
2. Firebase adapter methods in [public/firebase-adapter.js](public/firebase-adapter.js)
3. Firestore security rules in [firestore.rules](firestore.rules)

### Spanish Language
All UI text, comments, and user-facing content are in Spanish. Variable names and code comments mix Spanish and English. Maintain this pattern when adding features.

### No Traditional Database
Despite being a full-featured application, there is NO PostgreSQL/MySQL database. Data persistence relies entirely on:
- Firestore in production
- In-memory + data.json file syncing in development

### Parking Lottery Algorithm
The parking lottery ([server.js](server.js) around line 1500+) uses a Fisher-Yates shuffle to randomly assign 100 parking spots. Results are distributed across 3 basement levels with specific spot ranges:
- Sótano 1: P-001 to P-033
- Sótano 2: P-034 to P-066
- Sótano 3: P-067 to P-100

### Vehicle Tariff Calculation
Visitor parking fees are calculated in real-time based on entry/exit timestamps. The logic in the `/api/vehiculos-visitantes/salida` endpoint implements the tiered pricing model. Do not modify this without updating printed receipts and admin documentation.

## Deployment

### Firebase Hosting (Primary)
```bash
firebase deploy
```
Frontend is served from Firebase CDN, API calls go to Firestore directly.

### Render.com (API Fallback)
Configured via [render.yaml](render.yaml). Used for scenarios where direct Firestore access isn't available or for backward compatibility with legacy API consumers.

## Flutter Integration (Historical)

The repository previously contained a complete Flutter application in `conjunto_residencial_flutter/` directory (now deleted per git status). If recreating mobile app:
- API base URL should point to Render deployment or local server
- All endpoints are CORS-enabled for mobile access
- Authentication tokens use email-based identification
- Reference deleted files in git history for previous implementation
