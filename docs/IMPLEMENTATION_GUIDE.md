# Real Estate Management System - Complete Implementation Guide

## Project Overview
Full-stack real estate application with:
- **Backend**: Java Spring Boot REST API
- **Database**: SQL Server Express
- **Frontend**: Symfony website + Flutter mobile app
- **Architecture**: Single API serving both platforms

---

## Phase 1: Java Spring Boot API Setup

### 1.1 Create Spring Boot Project

Use Spring Initializr (https://start.spring.io/) with:
- **Project**: Maven
- **Language**: Java 17 or 21
- **Spring Boot**: 3.2.x or latest
- **Dependencies**:
  - Spring Web
  - Spring Data JPA
  - Spring Security
  - Spring Validation
  - SQL Server Driver
  - Flyway Migration
  - Lombok
  - Spring Boot DevTools

### 1.2 Project Structure

```
real-estate-api/
├── src/
│   ├── main/
│   │   ├── java/com/realestate/api/
│   │   │   ├── config/          # Configuration classes
│   │   │   │   ├── SecurityConfig.java
│   │   │   │   ├── CorsConfig.java
│   │   │   │   └── FlywayConfig.java
│   │   │   ├── entity/          # JPA Entities
│   │   │   │   ├── Bien.java
│   │   │   │   ├── Contrat.java
│   │   │   │   ├── Cosigner.java
│   │   │   │   ├── Personne.java
│   │   │   │   ├── Utilisateur.java
│   │   │   │   ├── Agence.java
│   │   │   │   ├── Location.java
│   │   │   │   ├── Achat.java
│   │   │   │   └── ... (all entities)
│   │   │   ├── repository/      # Spring Data JPA repositories
│   │   │   │   ├── BienRepository.java
│   │   │   │   ├── ContratRepository.java
│   │   │   │   └── ...
│   │   │   ├── service/         # Business logic
│   │   │   │   ├── BienService.java
│   │   │   │   ├── ContratService.java
│   │   │   │   ├── AuthService.java
│   │   │   │   └── ...
│   │   │   ├── controller/      # REST Controllers
│   │   │   │   ├── BienController.java
│   │   │   │   ├── ContratController.java
│   │   │   │   ├── AuthController.java
│   │   │   │   └── ...
│   │   │   ├── dto/             # Data Transfer Objects
│   │   │   │   ├── BienDTO.java
│   │   │   │   ├── ContratDTO.java
│   │   │   │   ├── CreateBienRequest.java
│   │   │   │   └── ...
│   │   │   ├── exception/       # Custom exceptions
│   │   │   │   ├── ResourceNotFoundException.java
│   │   │   │   ├── BusinessException.java
│   │   │   │   └── GlobalExceptionHandler.java
│   │   │   ├── security/        # JWT & Security
│   │   │   │   ├── JwtTokenProvider.java
│   │   │   │   ├── JwtAuthenticationFilter.java
│   │   │   │   └── UserDetailsServiceImpl.java
│   │   │   └── util/            # Utility classes
│   │   │       └── Mapper.java
│   │   └── resources/
│   │       ├── db/migration/    # Flyway SQL scripts
│   │       │   └── V1__create_initial_schema.sql
│   │       └── application.properties
│   └── test/                    # Unit & Integration tests
├── pom.xml
└── README.md
```

### 1.3 Application Configuration

**application.properties:**
```properties
# Server Configuration
server.port=8080
spring.application.name=RealEstateAPI

# Database Configuration
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=true
spring.datasource.username=your_username
spring.datasource.password=your_password
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# JPA Configuration
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServerDialect

# Flyway Configuration
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:db/migration
spring.flyway.validate-on-migrate=true

# JWT Configuration
jwt.secret=your-secret-key-change-this-in-production-min-256-bits
jwt.expiration=86400000

# File Upload Configuration
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload-dir=./uploads/photos

# CORS Configuration
cors.allowed-origins=http://localhost:3000,http://localhost:4200,http://localhost:8000
```

---

## Phase 2: Database Setup with Flyway

### 2.1 Install SQL Server Express

1. Download SQL Server Express: https://www.microsoft.com/sql-server/sql-server-downloads
2. Install SQL Server Management Studio (SSMS): https://aka.ms/ssmsfullsetup
3. Create database: `CREATE DATABASE RealEstateDB;`

### 2.2 Place Flyway Migration Script

Copy the provided `V1__create_initial_schema.sql` to:
```
src/main/resources/db/migration/V1__create_initial_schema.sql
```

### 2.3 Run Application

When you start the Spring Boot application, Flyway will automatically:
1. Detect the migration script
2. Create all tables
3. Apply constraints and indexes

**Note:** DO NOT use Doctrine migrations. The database is managed by Spring Boot + Flyway only.

---

## Phase 3: Implement REST API

### 3.1 Example: BienController

```java
@RestController
@RequestMapping("/api/biens")
@RequiredArgsConstructor
public class BienController {
    
    private final BienService bienService;
    
    @GetMapping
    public ResponseEntity<Page<BienDTO>> getAllBiens(
        @RequestParam(required = false) String ville,
        @RequestParam(required = false) String type,
        @RequestParam(required = false) BigDecimal prixMin,
        @RequestParam(required = false) BigDecimal prixMax,
        @RequestParam(required = false) Boolean forSale,
        @RequestParam(required = false) Boolean forRent,
        @RequestParam(defaultValue = "0") int page,
        @RequestParam(defaultValue = "10") int size,
        @RequestParam(defaultValue = "dateCreation,desc") String[] sort
    ) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(/* parse sort */));
        Page<BienDTO> biens = bienService.findAll(ville, type, prixMin, prixMax, forSale, forRent, pageable);
        return ResponseEntity.ok(biens);
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<BienDetailDTO> getBienById(@PathVariable Long id) {
        BienDetailDTO bien = bienService.findById(id);
        return ResponseEntity.ok(bien);
    }
    
    @PostMapping
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    public ResponseEntity<BienDTO> createBien(@Valid @RequestBody CreateBienRequest request) {
        BienDTO created = bienService.create(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }
    
    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    public ResponseEntity<BienDTO> updateBien(
        @PathVariable Long id,
        @Valid @RequestBody UpdateBienRequest request
    ) {
        BienDTO updated = bienService.update(id, request);
        return ResponseEntity.ok(updated);
    }
    
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteBien(@PathVariable Long id) {
        bienService.delete(id);
        return ResponseEntity.noContent().build();
    }
    
    @PostMapping("/{id}/photos")
    @PreAuthorize("hasAnyRole('AGENT', 'ADMIN')")
    public ResponseEntity<PhotoDTO> uploadPhoto(
        @PathVariable Long id,
        @RequestParam("file") MultipartFile file,
        @RequestParam(defaultValue = "999") int ordre
    ) {
        PhotoDTO photo = bienService.uploadPhoto(id, file, ordre);
        return ResponseEntity.status(HttpStatus.CREATED).body(photo);
    }
}
```

### 3.2 Core API Endpoints

```
Authentication:
POST   /api/auth/register       - Register new user
POST   /api/auth/login          - Login (returns JWT)
POST   /api/auth/refresh        - Refresh token
GET    /api/auth/me             - Get current user

Properties (Bien):
GET    /api/biens               - List all properties (with filters)
GET    /api/biens/{id}          - Get property details
POST   /api/biens               - Create property (AGENT/ADMIN)
PUT    /api/biens/{id}          - Update property (AGENT/ADMIN)
DELETE /api/biens/{id}          - Delete property (ADMIN)
POST   /api/biens/{id}/photos   - Upload photo (AGENT/ADMIN)
DELETE /api/biens/{id}/photos/{photoId} - Delete photo

Rental/Purchase:
POST   /api/biens/{id}/location - Mark as available for rent
POST   /api/biens/{id}/achat    - Mark as available for sale
PUT    /api/biens/{id}/location - Update rental info
PUT    /api/biens/{id}/achat    - Update sale info

Contracts:
GET    /api/contrats            - List user's contracts
GET    /api/contrats/{id}       - Get contract details
POST   /api/contrats            - Create contract
PUT    /api/contrats/{id}       - Update contract
POST   /api/contrats/{id}/sign  - Sign contract

Users & Persons:
GET    /api/utilisateurs/profile - Get user profile
PUT    /api/utilisateurs/profile - Update profile
GET    /api/personnes/{id}       - Get person details
POST   /api/personnes            - Create person
PUT    /api/personnes/{id}       - Update person

Agencies:
GET    /api/agences              - List all agencies
GET    /api/agences/{id}         - Get agency details
POST   /api/agences              - Create agency (ADMIN)
```

---

## Phase 4: Flutter App

### 4.1 Project Structure

```
flutter_app/
├── lib/
│   ├── main.dart
│   ├── config/
│   │   └── api_config.dart
│   ├── models/
│   │   ├── bien.dart
│   │   ├── contrat.dart
│   │   ├── utilisateur.dart
│   │   └── ...
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── bien_service.dart
│   │   └── storage_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── bien_provider.dart
│   │   └── ...
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── property_list_screen.dart
│   │   ├── property_detail_screen.dart
│   │   ├── login_screen.dart
│   │   ├── profile_screen.dart
│   │   └── ...
│   ├── widgets/
│   │   ├── property_card.dart
│   │   ├── photo_carousel.dart
│   │   └── ...
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
└── pubspec.yaml
```

### 4.2 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.1
  # OR riverpod: ^2.4.9
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # Image Handling
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  
  # UI Components
  carousel_slider: ^4.2.1
  shimmer: ^3.0.0
  
  # Utilities
  intl: ^0.18.1
  url_launcher: ^6.2.4
```

### 4.3 API Service Example

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://your-api-url.com/api';
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = baseUrl;
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        return handler.next(error);
      },
    ));
  }

  Future<List<Bien>> getBiens({
    String? ville,
    String? type,
    double? prixMin,
    double? prixMax,
    bool? forSale,
    bool? forRent,
    int page = 0,
    int size = 10,
  }) async {
    final response = await _dio.get(
      '/biens',
      queryParameters: {
        if (ville != null) 'ville': ville,
        if (type != null) 'type': type,
        if (prixMin != null) 'prixMin': prixMin,
        if (prixMax != null) 'prixMax': prixMax,
        if (forSale != null) 'forSale': forSale,
        if (forRent != null) 'forRent': forRent,
        'page': page,
        'size': size,
      },
    );
    
    return (response.data['content'] as List)
        .map((json) => Bien.fromJson(json))
        .toList();
  }

  Future<Bien> getBienById(int id) async {
    final response = await _dio.get('/biens/$id');
    return Bien.fromJson(response.data);
  }

  Future<Bien> createBien(Map<String, dynamic> data) async {
    final response = await _dio.post('/biens', data: data);
    return Bien.fromJson(response.data);
  }
}
```

---

## Phase 5: Symfony Website

### 5.1 Project Structure

```
symfony_app/
├── config/
│   └── packages/
│       └── framework.yaml
├── src/
│   ├── Controller/
│   │   ├── PropertyController.php
│   │   ├── AuthController.php
│   │   ├── ProfileController.php
│   │   └── ...
│   ├── Service/
│   │   └── RealEstateApiClient.php
│   └── Security/
│       └── ApiAuthenticator.php
├── templates/
│   ├── property/
│   │   ├── list.html.twig
│   │   ├── detail.html.twig
│   │   └── create.html.twig
│   ├── auth/
│   │   ├── login.html.twig
│   │   └── register.html.twig
│   └── base.html.twig
└── .env
```

### 5.2 API Client Service

```php
<?php
// src/Service/RealEstateApiClient.php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\HttpFoundation\Session\SessionInterface;

class RealEstateApiClient
{
    private HttpClientInterface $client;
    private string $apiBaseUrl;
    private SessionInterface $session;

    public function __construct(
        HttpClientInterface $client,
        SessionInterface $session,
        string $apiBaseUrl
    ) {
        $this->client = $client;
        $this->session = $session;
        $this->apiBaseUrl = $apiBaseUrl;
    }

    private function getHeaders(): array
    {
        $headers = ['Content-Type' => 'application/json'];
        
        if ($token = $this->session->get('jwt_token')) {
            $headers['Authorization'] = 'Bearer ' . $token;
        }
        
        return $headers;
    }

    public function getBiens(array $filters = []): array
    {
        $response = $this->client->request(
            'GET',
            $this->apiBaseUrl . '/api/biens',
            [
                'query' => $filters,
                'headers' => $this->getHeaders(),
            ]
        );

        return $response->toArray();
    }

    public function getBienById(int $id): array
    {
        $response = $this->client->request(
            'GET',
            $this->apiBaseUrl . '/api/biens/' . $id,
            ['headers' => $this->getHeaders()]
        );

        return $response->toArray();
    }

    public function createBien(array $data): array
    {
        $response = $this->client->request(
            'POST',
            $this->apiBaseUrl . '/api/biens',
            [
                'json' => $data,
                'headers' => $this->getHeaders(),
            ]
        );

        return $response->toArray();
    }

    public function login(string $email, string $password): array
    {
        $response = $this->client->request(
            'POST',
            $this->apiBaseUrl . '/api/auth/login',
            [
                'json' => [
                    'email' => $email,
                    'password' => $password,
                ],
            ]
        );

        $data = $response->toArray();
        
        if (isset($data['token'])) {
            $this->session->set('jwt_token', $data['token']);
        }

        return $data;
    }

    public function logout(): void
    {
        $this->session->remove('jwt_token');
    }
}
```

### 5.3 Example Controller

```php
<?php
// src/Controller/PropertyController.php

namespace App\Controller;

use App\Service\RealEstateApiClient;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class PropertyController extends AbstractController
{
    private RealEstateApiClient $apiClient;

    public function __construct(RealEstateApiClient $apiClient)
    {
        $this->apiClient = $apiClient;
    }

    #[Route('/properties', name: 'properties_list')]
    public function list(Request $request): Response
    {
        $filters = [
            'ville' => $request->query->get('ville'),
            'type' => $request->query->get('type'),
            'forSale' => $request->query->get('forSale'),
            'forRent' => $request->query->get('forRent'),
            'page' => $request->query->getInt('page', 0),
        ];

        $properties = $this->apiClient->getBiens($filters);

        return $this->render('property/list.html.twig', [
            'properties' => $properties['content'],
            'totalPages' => $properties['totalPages'],
            'currentPage' => $properties['number'],
        ]);
    }

    #[Route('/properties/{id}', name: 'properties_detail')]
    public function detail(int $id): Response
    {
        $property = $this->apiClient->getBienById($id);

        return $this->render('property/detail.html.twig', [
            'property' => $property,
        ]);
    }

    #[Route('/properties/create', name: 'properties_create')]
    public function create(Request $request): Response
    {
        if ($request->isMethod('POST')) {
            $data = [
                'rue' => $request->request->get('rue'),
                'ville' => $request->request->get('ville'),
                'codePostal' => $request->request->get('codePostal'),
                'type' => $request->request->get('type'),
                'superficie' => $request->request->getInt('superficie'),
                'description' => $request->request->get('description'),
            ];

            $property = $this->apiClient->createBien($data);

            return $this->redirectToRoute('properties_detail', ['id' => $property['id']]);
        }

        return $this->render('property/create.html.twig');
    }
}
```

### 5.4 Environment Configuration

```env
# .env
API_BASE_URL=http://localhost:8080
```

---

## Phase 6: Testing & Deployment

### 6.1 Testing Strategy

**Backend (Spring Boot):**
- Unit tests for services
- Integration tests for repositories
- API tests for controllers
- Use @SpringBootTest, MockMvc, TestContainers

**Flutter:**
- Unit tests for models and services
- Widget tests for UI components
- Integration tests for user flows

**Symfony:**
- Functional tests for controllers
- Test API client with mocked responses

### 6.2 Deployment

**Java API:**
- Build JAR: `mvn clean package`
- Deploy to: AWS EC2, Azure App Service, or Heroku
- Use environment variables for sensitive config

**SQL Server:**
- Use Azure SQL Database or AWS RDS for SQL Server
- Configure firewall rules
- Backup strategy

**Flutter:**
- Android: Build APK/AAB for Google Play
- iOS: Build IPA for App Store
- Configure API URL for production

**Symfony:**
- Deploy to: AWS, DigitalOcean, or traditional hosting
- Configure production environment
- Set API_BASE_URL to production API

---

## Summary: Your Architecture

```
 ┌──────────────┐         ┌──────────────┐
 │ Flutter App  │────────▶│              │
 └──────────────┘  HTTP   │              │
                          │   Java API   │
 ┌──────────────┐  HTTP   │ (Spring Boot)│
 │   Symfony    │────────▶│              │
 │   Website    │         │  - REST API  │
 └──────────────┘         │  - JWT Auth  │
                          │  - Business  │
                          │    Logic     │
                          └──────┬───────┘
                                 │ JDBC
                                 ▼
                          ┌──────────────┐
                          │ SQL Server   │
                          │   Express    │
                          │              │
                          │  (Flyway     │
                          │   manages    │
                          │   schema)    │
                          └──────────────┘
```

**Key Points:**
✅ Single source of truth (Java API)
✅ Consistent business logic across platforms
✅ Flyway manages database migrations (NOT Doctrine)
✅ JWT authentication for security
✅ Both platforms stay perfectly in sync

---

## Next Steps

1. ✅ Use the provided migration script (V1__create_initial_schema.sql)
2. Create Spring Boot project with dependencies
3. Copy entity classes to your project
4. Implement repositories and services
5. Build REST controllers
6. Test API with Postman/Insomnia
7. Develop Flutter app
8. Develop Symfony website
9. Deploy!

Good luck with your project! 🚀
