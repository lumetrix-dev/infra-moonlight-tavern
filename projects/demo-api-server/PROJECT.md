# Sprint 1 · Infrastructure — 2026-05-12 ～ 2026-05-25

## E1 · Project Setup ✅

### S1.1 Scaffolding (S) ✅

- [x] T1.1 Initialize Node.js + Express + TypeScript project `owner: demo-api-server` `PR: #1`
- [x] T1.2 Configure ESLint, Prettier, Husky `owner: demo-api-server` `PR: #2`
- [x] T1.3 Set up Jest + Supertest for integration tests `owner: demo-api-server` `PR: #3`

**Acceptance**: CI passes; linting and tests run in pre-commit hook

## E2 · Database Layer ✅

### S2.1 PostgreSQL + Prisma (M) ✅

- [x] T2.1 Prisma schema: User, Session, RefreshToken `owner: demo-api-server` `PR: #4`
- [x] T2.2 Database migrations and seed script `owner: demo-api-server` `PR: #5`
- [x] T2.3 Repository pattern wrapper over Prisma client `owner: demo-api-server` `PR: #6`

**Acceptance**: Migrations run cleanly; seed creates 10 test users; repository unit tests pass

## E3 · Health & Config ✅

### S3.1 Health Check & Config (S) ✅

- [x] T3.1 GET /health — liveness + readiness probe `owner: demo-api-server` `PR: #7`
- [x] T3.2 Environment config validation with Zod `owner: demo-api-server` `PR: #8`

**Acceptance**: /health returns 200 with DB connectivity status; missing env vars fail fast on startup
