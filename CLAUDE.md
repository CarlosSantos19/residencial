# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

- **Install dependencies**: `npm install`
- **Start development server**: `npm run dev` (uses nodemon for auto-reload)
- **Start production server**: `npm start`
- **Access application**: http://localhost:3000

## Authentication

The application includes a complete authentication system:
- **Demo user**: car-cbs@hotmail.com / password1
- Users are stored in-memory (server.js data.usuarios array)
- Login/register forms with validation
- Session management with localStorage
- Protected routes and auto-logout functionality

## Project Architecture

This is a residential complex management web application built with Node.js/Express backend and vanilla JavaScript frontend.

### Backend Structure (server.js)
- **Express server** running on port 3000
- **In-memory data storage** using JavaScript objects (data variable)
- **REST API endpoints** for all modules:
  - `/api/reservas` - Space reservations (GET, POST)
  - `/api/pagos` - Payment management (GET, PUT)
  - `/api/mensajes` - Community chat (GET, POST)
  - `/api/emprendimientos` - Resident businesses (GET)
  - `/api/pqrs` - Complaints/requests (GET, POST)
  - `/api/permisos` - Entry/exit permissions (GET, POST)
- **Auto-save mechanism**: Data is saved to `data.json` every 5 minutes

### Frontend Structure
- **frontend.html**: Complete single-page application with embedded CSS/JS
- **app.js**: Main application class (`ConjuntoApp`) with:
  - Authentication system (token-based)
  - WebSocket integration for real-time updates
  - PWA capabilities with service worker
  - Caching system and offline support
- **public/sw.js**: Service worker for PWA functionality

### Data Models
The application manages six main data types:
- **reservas**: Space reservations with user, date, time
- **pagos**: Payment records with status tracking
- **mensajes**: Community chat messages
- **emprendimientos**: Resident businesses directory
- **pqrs**: Petitions, complaints, claims, suggestions
- **permisos**: Entry/exit authorization system

### Key Patterns
- **Single-page application**: All functionality contained in one HTML file
- **RESTful API design**: Standard HTTP methods for CRUD operations
- **In-memory persistence**: Data stored in server memory with periodic file backup
- **Progressive Web App**: Service worker enables offline functionality
- **Real-time updates**: WebSocket integration for live chat and notifications

## File Organization
```
├── server.js          # Main Express server and API routes
├── app.js            # Frontend application logic
├── frontend.html     # Complete SPA with embedded styles
├── package.json      # Dependencies and scripts
└── public/
    └── sw.js         # Service worker for PWA
```