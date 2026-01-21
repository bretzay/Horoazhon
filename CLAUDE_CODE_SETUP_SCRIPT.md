# Claude Code Setup Script - Real Estate Management System

Copy and paste this entire script into Claude Code in VS Code to set up your complete project structure.

---

## PART 1: Initial Project Setup

```
I need you to create a complete full-stack real estate management system with the following architecture:

ARCHITECTURE:
- Backend: Java Spring Boot REST API with SQL Server Express (local for now)
- Frontend Web: Symfony (HTTP client to backend API)
- Frontend Mobile: Flutter app
- Database: SQL Server Express (local development, will migrate to remote server later)

PROJECT STRUCTURE:
Create this exact directory structure in the current workspace:

real-estate-system/
├── backend/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/realestate/api/
│   │   │   │   ├── config/
│   │   │   │   ├── entity/
│   │   │   │   ├── repository/
│   │   │   │   ├── service/
│   │   │   │   ├── controller/
│   │   │   │   ├── dto/
│   │   │   │   ├── exception/
│   │   │   │   └── security/
│   │   │   └── resources/
│   │   │       ├── db/migration/
│   │   │       └── application.properties
│   │   └── test/
│   ├── pom.xml
│   └── README.md
├── frontend-web/
│   ├── src/
│   │   ├── Controller/
│   │   ├── Service/
│   │   └── Security/
│   ├── templates/
│   │   ├── property/
│   │   ├── auth/
│   │   └── base.html.twig
│   ├── config/
│   ├── .env
│   ├── composer.json
│   └── README.md
├── frontend-mobile/
│   ├── lib/
│   │   ├── config/
│   │   ├── models/
│   │   ├── services/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── main.dart
│   ├── pubspec.yaml
│   └── README.md
├── docs/
│   ├── IMPLEMENTATION_GUIDE.md
│   ├── DATABASE_DEPLOYMENT.md
│   └── API_DOCUMENTATION.md
├── .gitignore
└── README.md

Please create this entire directory structure now, including all empty folders. After creating the structure, confirm completion and I'll provide the implementation files.
```

---

## PART 2: Backend - Flyway Migration Script

```
Now create the Flyway migration script that will create all database tables.

FILE: backend/src/main/resources/db/migration/V1__create_initial_schema.sql

CONTENT:
```

**Then paste the entire content of V1__create_initial_schema.sql**

---

## PART 3: Backend - Maven Configuration

```
Create the Spring Boot Maven configuration file.

FILE: backend/pom.xml

CONTENT:
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 
         https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.1</version>
        <relativePath/>
    </parent>
    
    <groupId>com.realestate</groupId>
    <artifactId>real-estate-api</artifactId>
    <version>1.0.0</version>
    <name>Real Estate API</name>
    <description>Real Estate Management System REST API</description>
    
    <properties>
        <java.version>17</java.version>
    </properties>
    
    <dependencies>
        <!-- Spring Boot Starters -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-validation</artifactId>
        </dependency>
        
        <!-- SQL Server Driver -->
        <dependency>
            <groupId>com.microsoft.sqlserver</groupId>
            <artifactId>mssql-jdbc</artifactId>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Flyway for Database Migrations -->
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-core</artifactId>
        </dependency>
        
        <dependency>
            <groupId>org.flywaydb</groupId>
            <artifactId>flyway-sqlserver</artifactId>
        </dependency>
        
        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.12.3</version>
        </dependency>
        
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.12.3</version>
            <scope>runtime</scope>
        </dependency>
        
        <!-- Lombok -->
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        
        <!-- DevTools -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        
        <!-- Testing -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>
```

---

## PART 4: Backend - Application Properties (Local Development)

```
Create the application configuration for LOCAL development with SQL Server Express.

FILE: backend/src/main/resources/application.properties

CONTENT:
# ==============================================
# APPLICATION CONFIGURATION - LOCAL DEVELOPMENT
# ==============================================

# Server Configuration
server.port=8080
spring.application.name=RealEstateAPI

# ==============================================
# DATABASE CONFIGURATION - LOCAL SQL SERVER
# ==============================================
# Local SQL Server Express connection
# Make sure SQL Server Express is installed and running
spring.datasource.url=jdbc:sqlserver://localhost:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=true
spring.datasource.username=sa
spring.datasource.password=YourLocalPassword123!
spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Connection Pool
spring.datasource.hikari.maximum-pool-size=10
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000

# ==============================================
# JPA/HIBERNATE CONFIGURATION
# ==============================================
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServerDialect
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true

# ==============================================
# FLYWAY CONFIGURATION
# ==============================================
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:db/migration
spring.flyway.validate-on-migrate=true

# ==============================================
# JWT CONFIGURATION
# ==============================================
# IMPORTANT: Change this secret in production!
jwt.secret=your-secret-key-change-this-in-production-must-be-at-least-256-bits-long
jwt.expiration=86400000

# ==============================================
# FILE UPLOAD CONFIGURATION
# ==============================================
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload-dir=./uploads/photos

# ==============================================
# CORS CONFIGURATION - LOCAL DEVELOPMENT
# ==============================================
cors.allowed-origins=http://localhost:3000,http://localhost:4200,http://localhost:8000,http://localhost:8001

# ==============================================
# LOGGING CONFIGURATION
# ==============================================
logging.level.com.realestate.api=DEBUG
logging.level.org.springframework.web=INFO
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE

# ==============================================
# PROFILE
# ==============================================
spring.profiles.active=dev
```

---

Also create a production template:

FILE: backend/src/main/resources/application-prod.properties

CONTENT:
# ==============================================
# PRODUCTION CONFIGURATION - REMOTE DATABASE
# ==============================================
# See DATABASE_DEPLOYMENT.md for setup instructions

# Server Configuration
server.port=8080

# Database Configuration - REMOTE SERVER
# Replace these values with your remote server details
spring.datasource.url=jdbc:sqlserver://YOUR_REMOTE_SERVER_IP:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=false
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

# JPA Configuration - Production
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=false

# JWT Configuration - Use environment variable
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000

# File Upload - Production path
file.upload-dir=/var/app/uploads/photos

# CORS - Production domains
cors.allowed-origins=${CORS_ORIGINS}

# Logging - Production level
logging.level.com.realestate.api=INFO
logging.level.org.springframework.web=WARN
logging.level.org.hibernate.SQL=WARN
```

---

## PART 5: Backend - All Entity Classes

```
Now create ALL JPA entity classes. I'll provide them in groups.

FIRST, create the main entity: Bien (Property)

FILE: backend/src/main/java/com/realestate/api/entity/Bien.java
```

**Then paste the content of Bien.java**

```
Now create the Contrat entity with the exclusivity constraint:

FILE: backend/src/main/java/com/realestate/api/entity/Contrat.java
```

**Then paste the content of Contrat.java**

```
Create the Cosigner entity:

FILE: backend/src/main/java/com/realestate/api/entity/Cosigner.java
```

**Then paste the content of Cosigner.java**

```
Now create ALL remaining entities at once. Extract each class from the following file and create separate files:

1. Photo.java
2. Agence.java
3. Personne.java
4. Utilisateur.java
5. Ouvrir.java
6. Location.java
7. Achat.java
8. Caracteristiques.java
9. Contenir.java
10. Lieux.java
11. Deplacer.java
12. Posseder.java

All in: backend/src/main/java/com/realestate/api/entity/

Here's the content:
```

**Then paste the content of AllEntities.java**

---

## PART 6: Backend - All DTOs

```
Create all DTO (Data Transfer Object) classes for the REST API.

Extract each DTO class and create separate files in: backend/src/main/java/com/realestate/api/dto/

Create these files:
1. BienDTO.java
2. BienDetailDTO.java
3. CreateBienRequest.java
4. UpdateBienRequest.java
5. PhotoDTO.java
6. CaracteristiqueDTO.java
7. CaracteristiqueValueDTO.java
8. LieuDTO.java
9. LieuProximiteDTO.java
10. AgenceDTO.java
11. LocationDTO.java
12. CreateLocationRequest.java
13. AchatDTO.java
14. CreateAchatRequest.java
15. ContratDTO.java
16. ContratDetailDTO.java
17. CreateContratRequest.java
18. CosignerDTO.java
19. CosignerRequest.java
20. PersonneDTO.java
21. ProprietaireDTO.java
22. CreatePersonneRequest.java
23. UtilisateurDTO.java
24. LoginRequest.java
25. LoginResponse.java
26. RegisterRequest.java
27. PageResponse.java
28. ErrorResponse.java

Here's the content:
```

**Then paste the content of AllDTOs.java**

---

## PART 7: Backend - All Repositories

```
Create all Spring Data JPA repository interfaces.

Extract each repository interface and create separate files in: backend/src/main/java/com/realestate/api/repository/

Create these files:
1. BienRepository.java
2. ContratRepository.java
3. PhotoRepository.java
4. AgenceRepository.java
5. PersonneRepository.java
6. UtilisateurRepository.java
7. LocationRepository.java
8. AchatRepository.java
9. CosignerRepository.java
10. CaracteristiquesRepository.java
11. ContenirRepository.java
12. LieuxRepository.java
13. DeplacerRepository.java
14. PossederRepository.java
15. OuvrirRepository.java

Here's the content:
```

**Then paste the content of AllRepositories.java**

---

## PART 8: Backend - Main Application Class

```
Create the main Spring Boot application class.

FILE: backend/src/main/java/com/realestate/api/RealEstateApiApplication.java

CONTENT:
package com.realestate.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class RealEstateApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(RealEstateApiApplication.class, args);
    }
}
```

---

## PART 9: Backend - Configuration Classes

```
Create the security configuration class.

FILE: backend/src/main/java/com/realestate/api/config/SecurityConfig.java

CONTENT:
package com.realestate.api.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(
            AuthenticationConfiguration authenticationConfiguration) throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/biens/**").permitAll() // Public property listing
                .anyRequest().authenticated()
            );

        return http.build();
    }
}
```

---

Create CORS configuration:

FILE: backend/src/main/java/com/realestate/api/config/CorsConfig.java

CONTENT:
package com.realestate.api.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
public class CorsConfig {

    @Value("${cors.allowed-origins}")
    private String[] allowedOrigins;

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList(allowedOrigins));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("*"));
        configuration.setAllowCredentials(true);
        configuration.setMaxAge(3600L);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", configuration);
        return source;
    }
}
```

---

## PART 10: Backend - Sample Service and Controller

```
Create a sample BienService to demonstrate the pattern:

FILE: backend/src/main/java/com/realestate/api/service/BienService.java

CONTENT:
package com.realestate.api.service;

import com.realestate.api.dto.*;
import com.realestate.api.entity.Bien;
import com.realestate.api.repository.BienRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
@RequiredArgsConstructor
@Transactional
public class BienService {

    private final BienRepository bienRepository;

    public Page<BienDTO> findAll(
            String ville,
            String type,
            BigDecimal prixMin,
            BigDecimal prixMax,
            Boolean forSale,
            Boolean forRent,
            Pageable pageable
    ) {
        return bienRepository.findByFilters(
            ville, type, forSale, forRent, prixMin, prixMax, pageable
        ).map(this::convertToDTO);
    }

    public BienDetailDTO findById(Long id) {
        Bien bien = bienRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Bien not found"));
        return convertToDetailDTO(bien);
    }

    public BienDTO create(CreateBienRequest request) {
        Bien bien = new Bien();
        bien.setRue(request.getRue());
        bien.setVille(request.getVille());
        bien.setCodePostal(request.getCodePostal());
        bien.setType(request.getType());
        bien.setSuperficie(request.getSuperficie());
        bien.setDescription(request.getDescription());
        // Set other fields...
        
        Bien saved = bienRepository.save(bien);
        return convertToDTO(saved);
    }

    private BienDTO convertToDTO(Bien bien) {
        BienDTO dto = new BienDTO();
        dto.setId(bien.getId());
        dto.setRue(bien.getRue());
        dto.setVille(bien.getVille());
        dto.setCodePostal(bien.getCodePostal());
        dto.setType(bien.getType());
        dto.setSuperficie(bien.getSuperficie());
        dto.setDescription(bien.getDescription());
        dto.setAvailableForSale(bien.isAvailableForSale());
        dto.setAvailableForRent(bien.isAvailableForRent());
        // Map other fields...
        return dto;
    }

    private BienDetailDTO convertToDetailDTO(Bien bien) {
        // Implement full mapping with relationships
        BienDetailDTO dto = new BienDetailDTO();
        // ... mapping logic
        return dto;
    }
}
```

---

Create a sample BienController:

FILE: backend/src/main/java/com/realestate/api/controller/BienController.java

CONTENT:
package com.realestate.api.controller;

import com.realestate.api.dto.*;
import com.realestate.api.service.BienService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.math.BigDecimal;

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
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "dateCreation"));
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
}
```

---

## PART 11: Frontend Web - Symfony Setup

```
Create Symfony configuration files.

FILE: frontend-web/.env

CONTENT:
# Symfony Application Configuration
APP_ENV=dev
APP_SECRET=change-this-secret-in-production

# API Configuration
API_BASE_URL=http://localhost:8080

# Database (not used - we use API)
# DATABASE_URL is left empty as Symfony doesn't connect to DB directly
```

---

Create the API client service:

FILE: frontend-web/src/Service/RealEstateApiClient.php

CONTENT:
<?php

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
}
```

---

## PART 12: Frontend Mobile - Flutter Setup

```
Create Flutter configuration files.

FILE: frontend-mobile/pubspec.yaml

CONTENT:
name: real_estate_app
description: Real Estate Management Mobile Application
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP & API
  dio: ^5.4.0
  
  # State Management
  provider: ^6.1.1
  
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

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

---

Create API configuration:

FILE: frontend-mobile/lib/config/api_config.dart

CONTENT:
class ApiConfig {
  // Change this to your computer's IP address for testing on physical devices
  // Use 'localhost' for emulator/simulator
  static const String baseUrl = 'http://localhost:8080/api';
  
  // For production, this will be replaced with remote server URL
  // static const String baseUrl = 'https://your-domain.com/api';
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

---

Create API service:

FILE: frontend-mobile/lib/services/api_service.dart

CONTENT:
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = ApiConfig.connectionTimeout;
    _dio.options.receiveTimeout = ApiConfig.receiveTimeout;
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        print('API Error: \${error.message}');
        return handler.next(error);
      },
    ));
  }

  Future<List<dynamic>> getBiens({
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
    
    return response.data['content'] as List;
  }

  Future<Map<String, dynamic>> getBienById(int id) async {
    final response = await _dio.get('/biens/\$id');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    
    if (response.data['token'] != null) {
      await _storage.write(key: 'jwt_token', value: response.data['token']);
    }
    
    return response.data as Map<String, dynamic>;
  }
}
```

---

## PART 13: Documentation Files

```
Create comprehensive documentation.

FILE: docs/IMPLEMENTATION_GUIDE.md
```

**Then paste the entire IMPLEMENTATION_GUIDE.md content**

---

## PART 14: Database Deployment Guide

```
Create the database deployment guide for moving to remote server.

FILE: docs/DATABASE_DEPLOYMENT.md
```

**I'll create this next - continue to PART 15**

---

## PART 15: Project README

```
Create the main project README.

FILE: README.md

CONTENT:
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
```

---

## PART 16: Git Configuration

```
Create .gitignore file.

FILE: .gitignore

CONTENT:
# Java/Maven
backend/target/
backend/*.jar
backend/*.war
backend/*.ear
backend/.mvn/
backend/mvnw
backend/mvnw.cmd

# Spring Boot
backend/HELP.md
backend/spring-boot-starter-parent/

# IDE
.idea/
*.iml
.vscode/
*.swp
*.swo
*~

# Symfony
frontend-web/var/
frontend-web/vendor/
frontend-web/.env.local
frontend-web/.env.*.local

# Flutter
frontend-mobile/.dart_tool/
frontend-mobile/.flutter-plugins
frontend-mobile/.flutter-plugins-dependencies
frontend-mobile/.packages
frontend-mobile/build/
frontend-mobile/ios/
frontend-mobile/android/

# OS
.DS_Store
Thumbs.db

# Uploads
uploads/
*.log

# Sensitive
*.key
*.pem
*.p12
.env.local
application-prod.properties
```

---

## COMPLETION CHECKLIST

After running all parts above, verify:

1. ✅ Directory structure created
2. ✅ Backend entities, DTOs, repositories created
3. ✅ Backend configuration files (pom.xml, application.properties)
4. ✅ Flyway migration script in place
5. ✅ Symfony API client service created
6. ✅ Flutter API service created
7. ✅ Documentation files created
8. ✅ Git configuration (.gitignore)

## Next Steps

1. Install SQL Server Express locally
2. Create database: `CREATE DATABASE RealEstateDB;`
3. Update credentials in `application.properties`
4. Run: `cd backend && mvn spring-boot:run`
5. Flyway will automatically create all tables
6. Test API: `curl http://localhost:8080/api/biens`
7. Start Symfony web app
8. Start Flutter mobile app

## For Remote Database Deployment

See `docs/DATABASE_DEPLOYMENT.md` for complete instructions on moving to a remote SQL Server.
```

---

# END OF SETUP SCRIPT

Copy each PART sequentially into Claude Code and wait for completion before moving to the next part. This ensures proper file creation and organization.
