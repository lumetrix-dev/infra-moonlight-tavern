# Sprint 2 · Auth & Dashboard — 2026-05-26 ～ 2026-06-08

## E1 · User Authentication
> Goal: Complete login/register flow with JWT refresh

### S1.1 Auth Pages (M) ✅

- [x] T1.1 Login page with form validation `owner: demo-web-app` `PR: #5`
- [x] T1.2 Registration page with email verification `owner: demo-web-app` `PR: #6`
- [x] T1.3 JWT token storage and silent refresh `owner: demo-web-app` `PR: #7`

**Acceptance**: User can register, verify email, log in, and stay authenticated across page reloads

## E2 · Dashboard Layout

### S2.1 Navigation & Shell (L)

- [x] T2.1 Sidebar navigation with route guards `owner: demo-web-app` `PR: #8`
- [ ] T2.2 Analytics overview cards (users, revenue, activity) `owner: demo-web-app` `PR: #9`
- [ ] T2.3 Responsive layout for mobile viewports `owner: demo-web-app` `PR: -`

**Acceptance**: Dashboard loads correct data; sidebar navigation works; layout adapts to mobile

### S2.2 Data Tables (M)

- [ ] T3.1 User management table with search and pagination `owner: demo-web-app` `PR: -`
- [ ] T3.2 Export to CSV feature `owner: demo-web-app` `PR: -`

**Acceptance**: Table renders 1000+ rows without lag; CSV export downloads correct data
