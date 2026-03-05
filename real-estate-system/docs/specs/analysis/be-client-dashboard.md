# be-client-dashboard — Client dashboard API

## Codebase Context
- **Controller**: `backend/src/main/java/com/realestate/api/controller/ClientDashboardController.java`
  - Class-level `@PreAuthorize("hasRole('CLIENT')")`
- **Service**: `backend/src/main/java/com/realestate/api/service/ClientDashboardService.java`
- **DTO**: `backend/src/main/java/com/realestate/api/dto/ClientDashboardDTO.java`

## Developer Notes
- **Status**: Fully implemented
- Class-level @PreAuthorize restricts all endpoints to CLIENT role only
- SUPER_ADMIN, ADMIN_AGENCY, AGENT all get 403
- Dashboard returns: personneId, totalProperties, totalContracts, activeContracts, totalRevenue, monthlyRevenue, revenueByMonth
- Revenue calculation from signed contracts
- All data scoped to client's linked Personne entity
- No gaps found

## QA Remarks
*(none yet)*

## Security Warnings
*(none yet)*

## Orchestrator Notes
*(none yet)*
