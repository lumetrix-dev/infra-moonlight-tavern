# mt-skills — Agent Context

## What is this

A collection of agent skills implementing the Moonlight Tavern-driven Sprint development workflow. Every `.md` file (except `README.md`) is a skill. After being installed via `install.sh`, they are globally available in Claude Code, Gemini CLI, Copilot, Codex, and any other agent that reads from `~/.agents/skills/`.

## Project Structure

```
mt-skills/
├── install.sh                 Install script — symlinks (local) or downloads (remote) to ~/.agents/skills/ + ~/.claude/skills/
├── .mt-version                 Version file
├── README.md                  Project overview + full usage workflow
├── mt-roadmap.md              /mt-roadmap — Plan the roadmap (Moonlight Tavern side)
├── mt-plan.md                 /mt-plan — Plan a Sprint (Moonlight Tavern side)
├── mt-sp-close.md             /mt-sp-close — Sprint archival (Moonlight Tavern side)
├── mt-project-init.md         /mt-project-init — New project initialization (Work Repo side)
├── mt-ship.md                 /mt-ship — Open a draft PR to start tasks (Work Repo side)
├── mt-research.md             /mt-research — Guide no-code research/DevOps work, open doc PR (Work Repo side)
├── mt-update.md               /mt-update — Check for skill updates (Work Repo side)
├── mt-my-tasks.md             /mt-my-tasks — View task progress (Work Repo side)
└── mt-sprint-report.md        /mt-sprint-report — Sprint progress report (Work Repo side)
```

## Architecture Principles

- **Task status is derived in real time from the PR lifecycle** — no manual checkbox maintenance
- Moonlight Tavern (`infra-moonlight-tavern`) is the central PM repository; all Sprint planning files live there exclusively
- Work repos only contain a `CLAUDE.md` pointing to Moonlight Tavern — no task state is stored there
- The `owner` value must be registered in `repos.yml`, otherwise an error is raised

## Skill File Writing Conventions

- Filename = skill name (no leading slash), e.g. `mt-plan.md` → `/mt-plan`
- File content is the behavior spec Claude follows when the skill is invoked
- **Frontmatter description format**: `[Moonlight Tavern] {brief description}. [Moonlight Tavern side / Work Repo side]`
  - `[Moonlight Tavern]` prefix identifies the system this skill belongs to
  - `[Moonlight Tavern side]` suffix means the skill operates on the Moonlight Tavern PM repository (`/mt-roadmap` `/mt-plan` `/mt-sp-close`)
  - `[Work Repo side]` suffix means the skill runs in a development repository (`/mt-project-init` `/mt-ship` `/mt-research` `/mt-my-tasks` `/mt-sprint-report` `/mt-update`)
- Use `### N.` numbered steps to clearly guide the Agent's behavior path
- Concrete executable bash commands go in code blocks
- Show output format examples in code blocks
- Add "👉 Next steps" prompts to chain the full workflow together

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/lumetrix-dev/infra-moonlight-tavern/main/mt-skills/install.sh | bash
```

Takes effect after restarting your agent/IDE. To update, re-run install.sh.

**Local development (symlink mode):** If you run install.sh directly from the repo checkout, it creates symlinks instead of downloading. Edits to `mt-skills/*.md` take effect immediately — no reinstall needed.

