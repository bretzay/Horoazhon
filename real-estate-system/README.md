# Real Estate Management System

Full-stack real estate management application for buying, renting, and managing properties.

## Architecture

- **Backend**: Java Spring Boot REST API
- **Frontend Web**: Symfony
- **Frontend Mobile**: Flutter
- **Database**: SQL Server Express (local) / SQL Server (production)

## Quick Start

### Prerequisites

- Java 17+
- Maven 3.6+
- SQL Server Express 2019+
- PHP 8.1+
- Composer
- Flutter 3.0+
- Node.js (optional, for frontend tooling)

### 1. Database Setup

```bash
# Install SQL Server Express
# Create database: RealEstateDB
# Update credentials in backend/src/main/resources/application.properties
```

### 2. Backend Setup

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

API will be available at: http://localhost:8080

### 3. Frontend Web Setup

```bash
cd frontend-web
composer install
symfony server:start --port=8001
```

Web app will be available at: https://127.0.0.1:8001

## LAN Access

To make the website accessible from other computers on the same local network:

### 1. Start the frontend with LAN access enabled

```bash
cd frontend-web
symfony server:start --allow-all-ip --port=8001
```

This binds the server to all network interfaces (`0.0.0.0`) instead of `127.0.0.1` only.

### 2. Open the firewall (Windows - run as Administrator)

```powershell
netsh advfirewall firewall add rule name="Symfony Dev Server" dir=in action=allow protocol=TCP localport=8001
```

### 3. Access from another computer

Find your LAN IP with `ipconfig`, then from the other computer navigate to:

```
https://<YOUR_LAN_IP>:8001
```

### 4. Close access when done (run as Administrator)

```powershell
netsh advfirewall firewall delete rule name="Symfony Dev Server"
```

> **Note:** The backend (port 8080) does not need to be exposed. The Symfony frontend calls the backend internally via `localhost`.

### 4. Frontend Mobile Setup

```bash
cd frontend-mobile
flutter pub get
flutter run
```

## Documentation

- [Implementation Guide](docs/IMPLEMENTATION_GUIDE.md) - Complete development guide
- [Database Deployment](docs/DATABASE_DEPLOYMENT.md) - Deploy database to remote server
- [API Documentation](docs/API_DOCUMENTATION.md) - REST API endpoints

## Project Structure

```
real-estate-system/
├── backend/          # Spring Boot REST API
├── frontend-web/     # Symfony web application
├── frontend-mobile/  # Flutter mobile app
└── docs/             # Documentation
```

## Features

- Property listing (buy/rent)
- User authentication (JWT)
- Property management (CRUD)
- Contract management
- Photo uploads
- Advanced search and filtering
- Responsive web interface
- Native mobile app (iOS/Android)

## License

Private project - All rights reserved