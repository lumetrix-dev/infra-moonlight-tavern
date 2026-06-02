# Moonlight Tavern · v2.0 Product Document

## Overview

Moonlight Tavern is a lightweight multi-repo project management system. It uses a Git repository as the single source of truth, drives task status through **SPRINT.md + PR lifecycle**, and visualizes progress through a single-file SPA dashboard.

**Design principles:**
- Git is the only database — task history is commit history
- Task status is derived from the PR lifecycle, no manual status fields
- `repos.yml` registers work repos; `owner:` in SPRINT references the registered name
- Zero backend, zero database, zero build steps

---

## v2.0 Changes

Upgraded from v1.x (React + Vite + individual task files) to v2.0:

| Dimension | v1.x | v2.0 |
|-----------|------|------|
| Frontend | React + Vite + TSX | Single-file vanilla JS SPA |
| Task definition | `tasks/{id}.md` individual files | `SPRINT.md` hierarchical structure |
| Status management | frontmatter `status:` field | Derived from PR lifecycle |
| Cross-repo | No native support | `repos.yml` + `owner:` tag |
| Build | `tsc + vite build` | `aggregate-data.mjs` → data.json |
| Board | 5-column kanban | Sprint view / Kanban view dual mode |

---

## System Architecture

```
projects/{repo}/SPRINT.md          repos.yml
        │                              │
        ▼                              ▼
  frontend/scripts/aggregate-data.mjs
        │
        ▼
  data.json ──→ index.html (SPA)
                  ├─ Sprint view — epic → story → task + PR status
                  └─ Kanban view — 5-column board (legacy task format)
```

---

## Core Concepts

### repos.yml — Work Repo Registry

Registers all code repositories. `name` maps to the folder name under `projects/`:

```yaml
repos:
  - name: demo-web-app
    github: your-org/demo-web-app
    description: "React TypeScript dashboard frontend"
  - name: demo-api-server
    github: your-org/demo-api-server
    description: "Node.js REST API server"
```

### SPRINT.md — Sprint Task Definition

Tasks are organized in a three-level hierarchy: epic → story → sub-task. Each sub-task carries `owner:` and `PR:`:

```markdown
# Sprint 2 · Auth & Dashboard — 2026-05-26 ～ 2026-06-08

## E1 · User Authentication
### S1.1 Auth Pages (M)
- [x] T1.1 Login page with form validation `owner: demo-web-app` `PR: #5`
- [ ] T1.2 Analytics API endpoint `owner: demo-api-server` `PR: draft`

**Acceptance**: User can log in and stay authenticated across page reloads
```

### PR Lifecycle → Status Mapping

```
No PR opened          →  todo   ⚪
PR is draft           →  wip    🟡
PR is open + ready    →  review 🔵
PR is merged          →  done   ✅
PR is closed unmerged →  error  🟥
```

Status is pre-computed by `aggregate-data.mjs` (using the `gh` CLI) and written into `data.json`. The SPA reads `data.json` statically — it makes no GitHub API calls.

---

## Data Flow

1. **Write**: Developer or PM updates `SPRINT.md` via Claude Code commands (`/mt-plan`, `/mt-ship`, etc.), commits and pushes
2. **Aggregate**: CI (or local `npm run build`) runs `aggregate-data.mjs`, parses `SPRINT.md` and `repos.yml`, outputs `data.json`
3. **Display**: SPA reads `data.json` and renders Sprint view or Kanban view per project
4. **Display**: SPA reads `data.json` and renders Sprint view or Kanban view per project

---

## Frontend

### Stack

- Single-file HTML + CSS + JavaScript (vanilla JS)
- No framework, no build step, no npm runtime dependencies
- Dark gothic theme

### View Modes

| Mode | Trigger | Content |
|------|---------|---------|
| Sprint view | Project has `SPRINT.md` | Collapsible epics, story progress bars, task PR status indicators |
| Kanban view | Project has legacy `tasks/*.md` only | 5-column board (Pending / In Progress / Testing / Done / Released) |

### Local Development

```bash
cd frontend
npm install
npm start        # build + http://localhost:8080
```

---

## Deployment

### Prerequisites

- GitHub repository with GitHub Pages enabled (Settings → Pages → Source: GitHub Actions)

### Deploy Flow

After merging to `main`, GitHub Actions automatically:

1. Runs `npm ci` + `aggregate-data.mjs` to generate `data.json`
2. Copies `index.html` + `data.json` to `frontend/dist/`
3. Uploads as Pages artifact and deploys

Board URL: `https://<your-org>.github.io/infra-moonlight-tavern/`

---

## Daily Workflow

### Plan a Sprint

```
/mt-plan
  → reads ROADMAP.md + repos.yml
  → proposes task breakdown (parent + sub-task structure, sub-tasks have owner)
  → writes SPRINT.md
  → commits + pushes
```

### Developer starts a task

```
/mt-ship
  → reads SPRINT.md, determines TXX.X
  → opens draft PR with title starting [TXX.X]
  → PR status automatically becomes wip 🟡
```

### Code merged

```
PR merged
  → status automatically becomes done ✅
  → /mt-sp-close  aggregates all repo PR statuses, updates SPRINT.md
```

### Check progress

```
Open the board
  → Sprint view: epic progress → story progress → sub-task PR status
  → Kanban view (legacy projects): 5-column board
```

---

## Extension Guide

- **Add a project**: Create a directory under `projects/`, add `meta.yaml` + `SPRINT.md`
- **Register a work repo**: Add an entry in `repos.yml`, name must match the `projects/` folder
- **New Sprint**: Update the project's `SPRINT.md`, add epics/stories/tasks following the format
- **Update roadmap**: Edit `ROADMAP.md` to describe long-term plans
- **Custom theme**: Modify CSS variables in `index.html`
