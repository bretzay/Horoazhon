# Database Deployment Guide - Moving from Local to Remote SQL Server

This guide explains how to deploy your SQL Server database from local development (SQL Server Express) to a remote production server and update your application configuration.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Remote SQL Server Setup Options](#remote-sql-server-setup-options)
3. [Database Migration Process](#database-migration-process)
4. [Backend Configuration Changes](#backend-configuration-changes)
5. [Security Best Practices](#security-best-practices)
6. [Testing Remote Connection](#testing-remote-connection)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### What You Need

- ✅ Local SQL Server Express with RealEstateDB working
- ✅ Remote server access (Azure SQL, AWS RDS, or dedicated server)
- ✅ SQL Server Management Studio (SSMS) installed locally
- ✅ Network access to remote server (firewall rules configured)

---

## Remote SQL Server Setup Options

### Option 1: Azure SQL Database (Recommended for Production)

**Advantages:**
- Fully managed (no server maintenance)
- Automatic backups and high availability
- Easy scaling
- Pay-as-you-go pricing

**Setup Steps:**

1. **Create Azure SQL Database**
   ```bash
   # Using Azure Portal:
   # 1. Go to portal.azure.com
   # 2. Create Resource > SQL Database
   # 3. Database name: RealEstateDB
   # 4. Pricing tier: Choose based on needs (Basic/Standard/Premium)
   # 5. Server: Create new or use existing
   # 6. Authentication: SQL Authentication (username/password)
   ```

2. **Configure Firewall Rules**
   ```bash
   # In Azure Portal > SQL Server > Firewalls and virtual networks:
   # 1. Add your development machine IP
   # 2. Add your production server IP (where Spring Boot will run)
   # 3. Enable "Allow Azure services and resources to access this server" if deploying to Azure
   ```

3. **Connection String**
   ```
   Server: your-server-name.database.windows.net
   Port: 1433
   Database: RealEstateDB
   Username: your-admin-username
   Password: your-secure-password
   ```

### Option 2: AWS RDS for SQL Server

**Setup Steps:**

1. **Create RDS Instance**
   ```bash
   # Using AWS Console:
   # 1. Go to RDS Dashboard
   # 2. Create Database > SQL Server
   # 3. Choose SQL Server Express (free tier) or Standard/Enterprise
   # 4. DB instance identifier: realestate-db
   # 5. Master username and password
   # 6. VPC and security group configuration
   ```

2. **Configure Security Group**
   ```bash
   # In EC2 > Security Groups:
   # 1. Edit inbound rules
   # 2. Add rule: Type=MSSQL, Port=1433, Source=Your IP or CIDR
   # 3. Add your application server IP
   ```

3. **Connection String**
   ```
   Server: your-instance.region.rds.amazonaws.com
   Port: 1433
   Database: RealEstateDB
   Username: admin
   Password: your-secure-password
   ```

### Option 3: Self-Hosted SQL Server

**Setup Steps:**

1. **Install SQL Server on Remote Server**
   - Install SQL Server Standard/Enterprise on Windows Server
   - Or use SQL Server on Linux (Docker container)

2. **Configure SQL Server for Remote Access**
   ```sql
   -- Enable SQL Server Authentication
   -- In SSMS, right-click server > Properties > Security
   -- Select "SQL Server and Windows Authentication mode"
   
   -- Enable TCP/IP
   -- SQL Server Configuration Manager > SQL Server Network Configuration
   -- Protocols > TCP/IP > Enabled
   
   -- Configure Port (default 1433)
   -- TCP/IP Properties > IP Addresses > IPAll > TCP Port = 1433
   
   -- Restart SQL Server service
   ```

3. **Configure Windows Firewall**
   ```powershell
   # PowerShell (Run as Administrator)
   New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
   ```

4. **Create SQL Login**
   ```sql
   -- In SSMS, connect to remote server
   USE master;
   GO
   
   CREATE LOGIN realestate_api WITH PASSWORD = 'YourStrongPassword123!';
   GO
   
   USE RealEstateDB;
   GO
   
   CREATE USER realestate_api FOR LOGIN realestate_api;
   GO
   
   ALTER ROLE db_owner ADD MEMBER realestate_api;
   GO
   ```

---

## Database Migration Process

### Step 1: Backup Local Database

```sql
-- In SSMS, connected to local SQL Server Express
BACKUP DATABASE RealEstateDB
TO DISK = 'C:\Backup\RealEstateDB.bak'
WITH FORMAT, COMPRESSION;
```

### Step 2: Transfer Backup to Remote Server

**For Azure SQL Database:**
```bash
# Azure SQL doesn't support .bak restore directly
# Use one of these methods:

# Method A: Export to BACPAC
# 1. In SSMS: Right-click database > Tasks > Export Data-tier Application
# 2. Save as .bacpac file
# 3. In Azure Portal: Import database from .bacpac

# Method B: Use schema migration (Recommended)
# Let Flyway handle it (see Step 3)
```

**For AWS RDS or Self-Hosted:**
```bash
# Upload .bak file to remote server
# Then restore:

RESTORE DATABASE RealEstateDB
FROM DISK = '/path/to/RealEstateDB.bak'
WITH MOVE 'RealEstateDB' TO '/var/opt/mssql/data/RealEstateDB.mdf',
     MOVE 'RealEstateDB_log' TO '/var/opt/mssql/data/RealEstateDB_log.ldf';
```

### Step 3: Use Flyway to Create Schema (Recommended)

**This is the EASIEST method for initial deployment:**

1. **Create empty database on remote server**
   ```sql
   CREATE DATABASE RealEstateDB;
   ```

2. **Update application.properties with remote credentials**
3. **Run Spring Boot application**
   ```bash
   cd backend
   mvn spring-boot:run
   ```

Flyway will automatically:
- Detect the V1__create_initial_schema.sql migration
- Execute it on the remote database
- Create all tables, constraints, and indexes

---

## Backend Configuration Changes

### Update application.properties

**Create a production profile:**

**File:** `backend/src/main/resources/application-prod.properties`

```properties
# ==============================================
# PRODUCTION CONFIGURATION
# ==============================================

# Server Configuration
server.port=8080

# ==============================================
# DATABASE CONFIGURATION - REMOTE SERVER
# ==============================================

# OPTION 1: Azure SQL Database
spring.datasource.url=jdbc:sqlserver://your-server.database.windows.net:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

# OPTION 2: AWS RDS SQL Server
# spring.datasource.url=jdbc:sqlserver://your-instance.region.rds.amazonaws.com:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=true

# OPTION 3: Self-Hosted SQL Server
# spring.datasource.url=jdbc:sqlserver://YOUR_SERVER_IP:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=true

spring.datasource.driver-class-name=com.microsoft.sqlserver.jdbc.SQLServerDriver

# Connection Pool - Production Settings
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=30000
spring.datasource.hikari.idle-timeout=600000
spring.datasource.hikari.max-lifetime=1800000

# ==============================================
# JPA/HIBERNATE CONFIGURATION - PRODUCTION
# ==============================================
spring.jpa.show-sql=false
spring.jpa.properties.hibernate.format_sql=false
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.SQLServerDialect

# ==============================================
# FLYWAY CONFIGURATION - PRODUCTION
# ==============================================
spring.flyway.enabled=true
spring.flyway.baseline-on-migrate=true
spring.flyway.locations=classpath:db/migration
spring.flyway.validate-on-migrate=true

# ==============================================
# JWT CONFIGURATION - USE ENVIRONMENT VARIABLE
# ==============================================
jwt.secret=${JWT_SECRET}
jwt.expiration=86400000

# ==============================================
# FILE UPLOAD CONFIGURATION - PRODUCTION PATH
# ==============================================
spring.servlet.multipart.max-file-size=10MB
spring.servlet.multipart.max-request-size=10MB
file.upload-dir=/var/app/uploads/photos

# ==============================================
# CORS CONFIGURATION - PRODUCTION DOMAINS
# ==============================================
cors.allowed-origins=${CORS_ORIGINS}

# ==============================================
# LOGGING CONFIGURATION - PRODUCTION
# ==============================================
logging.level.com.realestate.api=INFO
logging.level.org.springframework.web=WARN
logging.level.org.hibernate.SQL=WARN
logging.level.org.flywaydb=INFO
```

### Set Environment Variables

**For Linux/Mac (production server):**

```bash
# Create environment file
sudo nano /etc/environment

# Add these lines:
export DB_USERNAME="your_database_username"
export DB_PASSWORD="your_secure_password"
export JWT_SECRET="your-super-secret-jwt-key-minimum-256-bits-long"
export CORS_ORIGINS="https://yourdomain.com,https://www.yourdomain.com"

# Reload environment
source /etc/environment
```

**For Windows Server:**

```powershell
# Set system environment variables
[Environment]::SetEnvironmentVariable("DB_USERNAME", "your_database_username", "Machine")
[Environment]::SetEnvironmentVariable("DB_PASSWORD", "your_secure_password", "Machine")
[Environment]::SetEnvironmentVariable("JWT_SECRET", "your-super-secret-jwt-key", "Machine")
[Environment]::SetEnvironmentVariable("CORS_ORIGINS", "https://yourdomain.com", "Machine")
```

**For Docker:**

```dockerfile
# docker-compose.yml
version: '3.8'
services:
  api:
    image: real-estate-api:latest
    environment:
      - SPRING_PROFILES_ACTIVE=prod
      - DB_USERNAME=your_database_username
      - DB_PASSWORD=your_secure_password
      - JWT_SECRET=your-super-secret-jwt-key
      - CORS_ORIGINS=https://yourdomain.com
    ports:
      - "8080:8080"
```

### Run with Production Profile

```bash
# Method 1: Command line
java -jar -Dspring.profiles.active=prod backend/target/real-estate-api-1.0.0.jar

# Method 2: Environment variable
export SPRING_PROFILES_ACTIVE=prod
java -jar backend/target/real-estate-api-1.0.0.jar

# Method 3: Maven
mvn spring-boot:run -Dspring-boot.run.profiles=prod
```

---

## Security Best Practices

### 1. Never Commit Credentials to Git

```bash
# Ensure these are in .gitignore:
*.env.local
application-prod.properties
**/secrets/
```

### 2. Use Strong Passwords

```
Minimum requirements:
- At least 16 characters
- Mix of uppercase, lowercase, numbers, symbols
- Not dictionary words
- Unique (not reused from other systems)

Example generator:
openssl rand -base64 32
```

### 3. Restrict Database Access

```sql
-- Create application-specific user (not admin)
CREATE LOGIN realestate_api WITH PASSWORD = 'StrongPassword123!';
CREATE USER realestate_api FOR LOGIN realestate_api;

-- Grant only necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON SCHEMA::dbo TO realestate_api;
-- Don't grant: DROP, ALTER, CREATE
```

### 4. Enable SSL/TLS

```properties
# Force encrypted connections
spring.datasource.url=jdbc:sqlserver://server:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=false
```

### 5. Configure Network Security

- ✅ Use VPN or private network when possible
- ✅ Whitelist only specific IP addresses
- ✅ Use Azure Private Link or AWS PrivateLink
- ✅ Enable SQL Server auditing

### 6. Regular Backups

**Azure SQL:**
```bash
# Automatic backups enabled by default
# Configure retention period in Azure Portal
# Point-in-time restore available
```

**Self-Hosted:**
```sql
-- Schedule daily backups
BACKUP DATABASE RealEstateDB
TO DISK = '/backup/RealEstateDB_$(date +%Y%m%d).bak'
WITH COMPRESSION, INIT;
```

---

## Testing Remote Connection

### Test from Local Machine

**Using SSMS:**
```
1. Open SQL Server Management Studio
2. Connect to server: your-server.database.windows.net
3. Authentication: SQL Server Authentication
4. Login: your_username
5. Password: your_password
6. Test connection
```

**Using Command Line:**
```bash
# Test with sqlcmd
sqlcmd -S your-server.database.windows.net -U your_username -P your_password -d RealEstateDB -Q "SELECT @@VERSION"
```

**Using Java:**
```java
// Test connection from your application
public static void main(String[] args) {
    String url = "jdbc:sqlserver://your-server.database.windows.net:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=false";
    String user = "your_username";
    String password = "your_password";
    
    try (Connection conn = DriverManager.getConnection(url, user, password)) {
        System.out.println("Connection successful!");
        System.out.println("Database: " + conn.getCatalog());
    } catch (SQLException e) {
        System.err.println("Connection failed: " + e.getMessage());
    }
}
```

### Test Spring Boot Application

```bash
# 1. Build the application
cd backend
mvn clean package

# 2. Run with production profile
export SPRING_PROFILES_ACTIVE=prod
export DB_USERNAME=your_username
export DB_PASSWORD=your_password
java -jar target/real-estate-api-1.0.0.jar

# 3. Test API endpoint
curl http://localhost:8080/api/biens

# 4. Check logs for successful connection
# Look for: "Flyway migration completed successfully"
```

---

## Update Frontend Applications

### Symfony Web App

**File:** `frontend-web/.env.prod`

```env
APP_ENV=prod
APP_SECRET=your-production-secret

# Point to production API server
API_BASE_URL=https://api.yourdomain.com
```

### Flutter Mobile App

**File:** `frontend-mobile/lib/config/api_config.dart`

```dart
class ApiConfig {
  // Development
  static const String devBaseUrl = 'http://localhost:8080/api';
  
  // Production
  static const String prodBaseUrl = 'https://api.yourdomain.com/api';
  
  // Current environment
  static const String baseUrl = prodBaseUrl; // Change for production build
  
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
```

Or use flavors:

```bash
# Build for production
flutter build apk --release --flavor production
flutter build ipa --release --flavor production
```

---

## Troubleshooting

### Connection Timeout

**Problem:** Application can't connect to remote database

**Solutions:**
```bash
# 1. Check firewall rules
# Ensure your application server IP is whitelisted

# 2. Verify SQL Server is listening on port 1433
netstat -an | grep 1433

# 3. Test connectivity
telnet your-server.database.windows.net 1433

# 4. Check SQL Server error logs
# In SSMS: Management > SQL Server Logs
```

### Authentication Failed

**Problem:** Login failed for user

**Solutions:**
```sql
-- 1. Verify user exists
SELECT name FROM sys.database_principals WHERE name = 'your_username';

-- 2. Reset password
ALTER LOGIN your_username WITH PASSWORD = 'NewPassword123!';

-- 3. Check permissions
SELECT dp.name, dp.type_desc, dp.default_schema_name
FROM sys.database_principals dp
WHERE dp.name = 'your_username';
```

### Flyway Migration Errors

**Problem:** Flyway fails to apply migrations

**Solutions:**
```bash
# 1. Check Flyway version compatibility
# Update Flyway if needed

# 2. Manually baseline if database already has schema
# In application.properties:
spring.flyway.baseline-on-migrate=true

# 3. Clean Flyway history (CAREFUL - development only!)
mvn flyway:clean
mvn flyway:migrate
```

### SSL/TLS Certificate Issues

**Problem:** Certificate validation errors

**Solutions:**
```properties
# For Azure SQL - use correct hostname in certificate
spring.datasource.url=jdbc:sqlserver://server.database.windows.net:1433;databaseName=RealEstateDB;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net

# For self-signed certificates (testing only)
spring.datasource.url=...;encrypt=true;trustServerCertificate=true
```

### Performance Issues

**Solutions:**
```properties
# Increase connection pool size
spring.datasource.hikari.maximum-pool-size=30

# Enable statement caching
spring.jpa.properties.hibernate.query.plan_cache_max_size=2048
spring.jpa.properties.hibernate.query.plan_parameter_metadata_max_size=128

# Add database indexes (if needed)
CREATE INDEX IDX_Bien_Ville_Type ON Bien(ville, type);
```

---

## Rollback Plan

If deployment fails, you can rollback:

1. **Switch back to local database:**
   ```bash
   export SPRING_PROFILES_ACTIVE=dev
   java -jar backend/target/real-estate-api-1.0.0.jar
   ```

2. **Restore from backup:**
   ```sql
   RESTORE DATABASE RealEstateDB
   FROM DISK = '/backup/RealEstateDB_backup.bak'
   WITH REPLACE;
   ```

3. **Check application logs:**
   ```bash
   tail -f /var/log/real-estate-api.log
   ```

---

## Deployment Checklist

- [ ] Remote SQL Server instance created
- [ ] Firewall rules configured
- [ ] Database user created with appropriate permissions
- [ ] Database created (empty or restored from backup)
- [ ] `application-prod.properties` configured
- [ ] Environment variables set on production server
- [ ] SSL/TLS enabled for database connection
- [ ] Connection tested from application server
- [ ] Flyway migrations tested
- [ ] API endpoints tested
- [ ] Frontend applications updated with production API URL
- [ ] Backup strategy implemented
- [ ] Monitoring and logging configured
- [ ] Security audit completed

---

## Additional Resources

- [Azure SQL Database Documentation](https://docs.microsoft.com/azure/sql-database/)
- [AWS RDS for SQL Server Documentation](https://docs.aws.amazon.com/rds/latest/userguide/CHAP_SQLServer.html)
- [Spring Boot Database Configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/data.html#data.sql.datasource)
- [Flyway Documentation](https://flywaydb.org/documentation/)

---

## Support

If you encounter issues not covered in this guide:

1. Check application logs: `tail -f logs/spring.log`
2. Check SQL Server error logs
3. Review Flyway migration history: `SELECT * FROM flyway_schema_history`
4. Test connection with sqlcmd or SSMS
5. Verify environment variables are set correctly

Remember: **NEVER commit passwords or secrets to version control!**
