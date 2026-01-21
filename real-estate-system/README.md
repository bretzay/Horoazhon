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
symfony server:start
```

Web app will be available at: http://localhost:8000

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