# Sprint 2 · Core API Endpoints — 2026-05-26 ～ 2026-06-08

## E1 · User Resource
> Goal: Complete CRUD endpoints for user management with input validation

### S1.1 User CRUD (M) ✅

- [x] T1.1 GET /users — paginated list with filters `owner: demo-api-server` `PR: #12`
- [x] T1.2 POST /users — create with Zod validation `owner: demo-api-server` `PR: #12`
- [x] T1.3 PATCH /users/:id — partial update `owner: demo-api-server` `PR: #13`
- [x] T1.4 DELETE /users/:id — soft delete `owner: demo-api-server` `PR: #13`

**Acceptance**: All endpoints return correct status codes; unit + integration tests pass

## E2 · Middleware

### S2.1 Auth Middleware (S) ✅

- [x] T2.1 JWT verification middleware `owner: demo-api-server` `PR: #14`
- [x] T2.2 Role-based access control (RBAC) `owner: demo-api-server` `PR: #14`

**Acceptance**: Protected routes reject invalid tokens with 401; RBAC returns 403 on insufficient role

### S2.2 Security & Observability (S)

- [ ] T3.1 Rate limiting on auth endpoints (100 req/min per IP) `owner: demo-api-server` `PR: #15`
- [ ] T3.2 Structured request logging (method, path, status, duration) `owner: demo-api-server` `PR: -`

**Acceptance**: 429 returned after threshold; logs include request ID for tracing
