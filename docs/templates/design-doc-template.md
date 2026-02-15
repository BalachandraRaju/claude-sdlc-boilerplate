# Design Document: [Feature Name]

**Author**: [Name]
**Date**: [Date]
**PRD Reference**: [Link to PRD]
**Status**: Draft | In Review | Approved

---

## 1. Overview

Brief summary of the technical approach.

## 2. Architecture

### 2.1 System Context
How this feature fits into the overall system.

### 2.2 Component Design

```
[ASCII diagram or description of component interactions]
```

### 2.3 Database Schema

```sql
-- New tables or modifications
CREATE TABLE ... (
);
```

### 2.4 API Design

```
GET  /api/v1/resource       → List resources
POST /api/v1/resource       → Create resource
GET  /api/v1/resource/{id}  → Get resource
PUT  /api/v1/resource/{id}  → Update resource
DELETE /api/v1/resource/{id} → Delete resource
```

**Request/Response Examples**:

```json
// POST /api/v1/resource
{
  "field": "value"
}

// Response 201
{
  "id": "uuid",
  "field": "value",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

## 3. Backend Implementation

### 3.1 Entities
- Entity classes and JPA mappings

### 3.2 Services
- Business logic and transaction boundaries

### 3.3 Controllers
- REST endpoints and validation

## 4. Frontend Implementation

### 4.1 Components
- Component tree and responsibilities

### 4.2 State Management
- How state flows through the UI

### 4.3 API Integration
- Service functions and error handling

## 5. Security Considerations

- Authentication and authorization requirements
- Input validation strategy
- Data protection measures

## 6. Testing Strategy

- Unit test scope
- Integration test scope
- E2E test scenarios

## 7. Migration Plan

- Database migration steps
- Data migration (if applicable)
- Rollback strategy

## 8. Alternatives Considered

| Option | Pros | Cons | Decision |
|--------|------|------|----------|
| A | | | Chosen / Rejected |
| B | | | Chosen / Rejected |
