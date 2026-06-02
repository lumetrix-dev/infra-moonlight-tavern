# Moonlight Tavern · v2.0

Multi-repo project management + Sprint board, powered by Claude Code.  
Git as the database. PR lifecycle as task status. Zero backend, zero manual updates.

## How It Works

Task status is derived automatically from the PR lifecycle — no manual maintenance required:

| PR Status | Task Status | Icon |
|-----------|-------------|------|
| No PR opened | todo | ⚪ |
| PR is draft | wip | 🟡 |
| PR open + ready | review | 🔵 |
| PR merged | done | ✅ |
| PR closed without merge | error | 🟥 |

## Commands

### Moonlight Tavern side

Run inside the `infra-moonlight-tavern` repository.

| Command | Purpose |
|---------|---------|
| `/mt-roadmap` | Plan or update ROADMAP.md: brainstorm based on product docs and design files |
| `/mt-plan` | Plan the next Sprint: break down Epics/Stories/Tasks and write to SPRINT.md |
| `/mt-sp-close` | At Sprint end, aggregate all PR statuses and archive to PROJECT.md |

### Work Repo side

Run inside any development repository linked to Moonlight Tavern.

| Command | Purpose |
|---------|---------|
| `/mt-project-init` | Initialize a new project: create directory structure in Moonlight Tavern + generate CLAUDE.md |
| `/mt-my-tasks` | List incomplete tasks for the current repo + real-time PR status |
| `/mt-sprint-report` | Generate a Sprint progress summary with live PR data |
| `/mt-ship` | Create an aggregated draft PR for one or more tasks (title starts with `[TXX.X]`) |
| `/mt-update` | Check for command updates, compare local vs. remote version |

## Usage Workflow

### 1. Install commands

```bash
curl -fsSL https://raw.githubusercontent.com/lumetrix-dev/infra-moonlight-tavern/main/lib-claude-command/install.sh | bash
```

Restart Claude Code. Commands are immediately available across all projects.

### 2. Set up Moonlight Tavern

Clone this repository as your starting point:

```bash
git clone https://github.com/lumetrix-dev/infra-moonlight-tavern.git
cd infra-moonlight-tavern
```

Then point it to your own GitHub repository:

```bash
# Create a new empty repo on GitHub (e.g. your-org/infra-moonlight-tavern), then:
git remote set-url origin https://github.com/your-org/infra-moonlight-tavern.git
git push -u origin main
```

Then configure the repository:

1. **Create a PAT** — GitHub avatar → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)** → **Generate new token (classic)**, check the **`repo`** scope, copy the token (shown only once)
2. **Add it as a secret** — your repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**, name `GH_PAT`, paste the token
3. **Enable GitHub Pages** — your repo → **Settings** → **Pages** → set **Source** to **GitHub Actions**
4. Push any change to `main` — the workflow runs and your board will be live at:
   `https://your-org.github.io/infra-moonlight-tavern/`

> The workflow also runs every 5 minutes on a schedule to keep PR statuses up to date.

### 3. Initialize a project

**New project**: create a work repo, then run inside it:

```
/mt-project-init
```

The Agent will guide you through creating the project directory, `meta.yaml`, `ROADMAP.md`, `SPRINT.md`, `PROJECT.md` in Moonlight Tavern, registering `repos.yml`, and generating `CLAUDE.md` in the work repo.

**Existing project**: clone the work repo and proceed — no extra initialization needed.

### 4. Plan the roadmap

```
/mt-roadmap
```

Provide your PRD and design files. The Agent brainstorms and writes `ROADMAP.md`.

### 5. Plan the Sprint

```
/mt-plan
```

The Agent breaks down `ROADMAP.md` into Epics → Stories → Tasks and writes `SPRINT.md`.

### 6. Start development

```
/mt-ship
```

The Agent reads `SPRINT.md`, creates a branch, and opens a draft PR with `[TXX.X]` in the title. Run `/mt-ship` repeatedly as you complete batches of tasks.

### 7. Check progress

```
/mt-my-tasks
```

See current task status and live PR state at any time.

### 8. Close the Sprint

```
/mt-sp-close
```

The Agent aggregates all PR statuses, updates `SPRINT.md`, archives to `PROJECT.md`, and prompts you to run `/mt-plan` for the next cycle.

Repeat **steps 5 → 8** until `ROADMAP.md` is complete.

### Mid-sprint changes

Tell the Agent what changed and provide the updated PRD. It will sync `SPRINT.md` and `ROADMAP.md` accordingly.

## SPRINT Task Format

Tasks are structured in three levels: Epic → Story → sub-task. Each sub-task carries `owner:` and `PR:`:

```markdown
# Sprint 2 · Auth & Dashboard — 2026-05-26 ～ 2026-06-08

## E1 · User Authentication
> Goal: Complete login/register flow with JWT refresh

### S1.1 Auth Pages (M)
- [x] T1.1 Login page with form validation `owner: demo-web-app` `PR: #5`
- [ ] T1.2 Registration page with email verification `owner: demo-web-app` `PR: draft`

**Acceptance**: User can register and stay authenticated across page reloads
```

A single PR can cover multiple tasks — title format: `[T1.1][T1.2] description`.

## File Structure

**Moonlight Tavern (this repository)**

```
infra-moonlight-tavern/
├── repos.yml                    # work repo registry
├── projects/
│   └── {project-name}/
│       ├── meta.yaml            # project metadata (name, color, members)
│       ├── ROADMAP.md           # long-term roadmap
│       ├── SPRINT.md            # current Sprint (PR lifecycle driven)
│       └── PROJECT.md           # completed Sprint archive
├── frontend/
│   ├── index.html               # SPA dashboard (single-file vanilla JS)
│   ├── scripts/aggregate-data.mjs  # SPRINT.md → data.json
│   └── package.json
└── lib-claude-command/
    ├── install.sh               # command installer
    └── mt-*.md                  # Claude Code slash commands
```

**Work Repo**

```
your-work-repo/
└── CLAUDE.md                    # project context + pointer to Moonlight Tavern
```

## Registering a Work Repo

Add an entry to `repos.yml`. The `name` must match the folder under `projects/`:

```yaml
repos:
  - name: demo-web-app
    github: your-org/demo-web-app
    description: "React TypeScript dashboard frontend"
```

## Dashboard

**Local development:**

```bash
cd frontend
npm install
npm start        # builds data.json + serves at http://localhost:8080
```

**Deployment:**

Push to `main` — GitHub Actions builds `data.json` and deploys to Pages automatically (also runs every 5 minutes to refresh PR statuses):

```
https://<your-org>.github.io/infra-moonlight-tavern/
```
