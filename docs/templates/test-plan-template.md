# Test Plan: [Feature Name]

**Author**: [Name]
**Date**: [Date]
**PRD Reference**: [Link]
**Status**: Draft | In Review | Approved

---

## 1. Scope

What is being tested and what is excluded.

## 2. Test Strategy

| Layer | Tool | Scope |
|-------|------|-------|
| Unit (Backend) | JUnit 5 + Mockito | Services, utilities |
| Unit (Frontend) | Vitest + Testing Library | Components, hooks |
| Integration | SpringBootTest + Testcontainers | API endpoints |
| E2E | Playwright | Critical user flows |

## 3. Test Cases

### 3.1 Unit Tests — Backend

| ID | Test | Input | Expected | Priority |
|----|------|-------|----------|----------|
| UT-B-1 | | | | High |
| UT-B-2 | | | | Medium |

### 3.2 Unit Tests — Frontend

| ID | Test | Input | Expected | Priority |
|----|------|-------|----------|----------|
| UT-F-1 | | | | High |
| UT-F-2 | | | | Medium |

### 3.3 Integration Tests

| ID | Endpoint | Scenario | Expected Status | Expected Body |
|----|----------|----------|-----------------|---------------|
| IT-1 | POST /api/v1/... | Valid input | 201 | Created resource |
| IT-2 | POST /api/v1/... | Invalid input | 400 | Validation errors |
| IT-3 | GET /api/v1/... | Unauthorized | 401 | Error message |

### 3.4 E2E Tests

| ID | User Flow | Steps | Expected Outcome |
|----|-----------|-------|-----------------|
| E2E-1 | | 1. ... 2. ... | |

## 4. Edge Cases

| ID | Scenario | Expected Behavior |
|----|----------|-------------------|
| EC-1 | Null/empty input | |
| EC-2 | Max length input | |
| EC-3 | Concurrent requests | |
| EC-4 | Network failure | |

## 5. Non-Functional Tests

- **Performance**: Response time under X concurrent users
- **Security**: Auth bypass attempts, injection attacks
- **Accessibility**: Screen reader compatibility, keyboard navigation

## 6. Test Data

Describe test data setup and teardown strategy.

## 7. Exit Criteria

- [ ] All High priority tests pass
- [ ] Code coverage > 80% for new code
- [ ] No Critical/High security findings
- [ ] All E2E critical paths pass
