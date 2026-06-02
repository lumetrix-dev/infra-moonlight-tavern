# mt-skills — Agent Context

## What is this

A collection of Claude Code global commands implementing the Moonlight Tavern-driven Sprint development workflow. Every `.md` file (except `README.md`) is a Claude Code slash command. After being installed to `~/.claude/commands/` via `install.sh`, they are globally available.

## Project Structure

```
mt-skills/
├── install.sh                 Install script — copies command .md files to ~/.claude/commands/
├── .mt-version                 Version file
├── README.md                  Project overview + full usage workflow
├── mt-roadmap.md              /mt-roadmap — Plan the roadmap (Moonlight Tavern side)
├── mt-plan.md                 /mt-plan — Plan a Sprint (Moonlight Tavern side)
├── mt-sp-close.md             /mt-sp-close — Sprint archival (Moonlight Tavern side)
├── mt-project-init.md         /mt-project-init — New project initialization (Work Repo side)
├── mt-ship.md                 /mt-ship — Open a draft PR to start tasks (Work Repo side)
├── mt-update.md               /mt-update — Check for command updates (Work Repo side)
├── mt-my-tasks.md             /mt-my-tasks — View task progress (Work Repo side)
└── mt-sprint-report.md        /mt-sprint-report — Sprint progress report (Work Repo side)
```

## Architecture Principles

- **Task status is derived in real time from the PR lifecycle** — no manual checkbox maintenance
- Moonlight Tavern (`infra-moonlight-tavern`) is the central PM repository; all Sprint planning files live there exclusively
- Work repos only contain a `CLAUDE.md` pointing to Moonlight Tavern — no task state is stored there
- The `owner` value must be registered in `repos.yml`, otherwise an error is raised

## Command File Writing Conventions

- Filename = command name (no leading slash), e.g. `mt-plan.md` → `/mt-plan`
- File content is the system prompt Claude executes for that command
- **First-line description format**: `[Moonlight Tavern] {brief description}. [Moonlight Tavern side / Work Repo side]`
  - `[Moonlight Tavern]` prefix identifies the system this command belongs to
  - `[Moonlight Tavern side]` suffix means the command operates on the Moonlight Tavern PM repository (`/mt-roadmap` `/mt-plan` `/mt-sp-close`)
  - `[Work Repo side]` suffix means the command runs in a development repository (`/mt-project-init` `/mt-ship` `/mt-my-tasks` `/mt-sprint-report` `/mt-update`)
- Use `### N.` numbered steps to clearly guide the Agent's behavior path
- Concrete executable bash commands go in code blocks
- Show output format examples in code blocks
- Add "👉 Next steps" prompts to chain the full workflow together

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/lumetrix-dev/infra-moonlight-tavern/main/mt-skills/install.sh | bash
```

Takes effect after restarting Claude Code. To update, re-run install.sh to overwrite.

