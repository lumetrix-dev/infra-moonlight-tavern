#!/bin/bash
set -e

REPO="lumetrix-dev/infra-moonlight-tavern"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH/mt-skills"
AGENTS_SKILLS_DIR="$HOME/.agents/skills"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
SKILLS=(mt-plan mt-ship mt-project-init mt-my-tasks mt-sprint-report mt-roadmap mt-sp-close mt-update)

# Detect local checkout: BASH_SOURCE[0] is set when run as a file (not piped)
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
LOCAL_SKILLS_DIR=""
if [ -n "$SCRIPT_PATH" ] && [ -f "$(dirname "$SCRIPT_PATH")/mt-plan.md" ]; then
  LOCAL_SKILLS_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
fi

# ── Version / confirmation prompt ───────────────────────────────────────────

if [ -n "$LOCAL_SKILLS_DIR" ]; then
  LOCAL_VERSION=$(cat "$LOCAL_SKILLS_DIR/.mt-version" 2>/dev/null || echo "unknown")
  echo "Local development mode — symlinks will point to: $LOCAL_SKILLS_DIR"
  echo "Version: v$LOCAL_VERSION"
  echo ""
  read -rp "Install symlinks for local mt-skills? [Y/n] " confirm </dev/tty
  [[ "$confirm" =~ ^[Nn]$ ]] && { echo "Aborted."; exit 0; }
else
  # Remote install: compare local vs remote version
  LOCAL_VERSION=""
  VERSION_FILE="$CLAUDE_SKILLS_DIR/.mt-version"
  [ -f "$VERSION_FILE" ] && LOCAL_VERSION=$(cat "$VERSION_FILE")

  REMOTE_VERSION=$(curl -fsSL "$RAW_BASE/.mt-version" 2>/dev/null)
  if [ -z "$REMOTE_VERSION" ]; then
    echo "❌ Could not reach GitHub. Check your network and try again."
    exit 1
  fi

  if [ -z "$LOCAL_VERSION" ]; then
    echo "Local:  (not installed)"
    echo "Remote: v$REMOTE_VERSION"
    echo ""
    read -rp "Proceed with fresh install? [Y/n] " confirm </dev/tty
    [[ "$confirm" =~ ^[Nn]$ ]] && { echo "Aborted."; exit 0; }
  elif [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
    echo "Local:  v$LOCAL_VERSION"
    echo "Remote: v$REMOTE_VERSION"
    echo ""
    read -rp "Already up to date. Reinstall anyway? [y/N] " confirm </dev/tty
    [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
  else
    echo "Local:  v$LOCAL_VERSION"
    echo "Remote: v$REMOTE_VERSION"
    echo ""
    read -rp "Update available. Upgrade? [Y/n] " confirm </dev/tty
    [[ "$confirm" =~ ^[Nn]$ ]] && { echo "Aborted."; exit 0; }
  fi
fi

echo "Installing Moonlight Tavern skills..."
mkdir -p "$AGENTS_SKILLS_DIR"
mkdir -p "$CLAUDE_SKILLS_DIR"

# ── Clean up legacy flat files ───────────────────────────────────────────────
LEGACY_COMMANDS="$HOME/.claude/commands"
for s in "${SKILLS[@]}"; do
  [ -f "$LEGACY_COMMANDS/$s.md" ]  && rm "$LEGACY_COMMANDS/$s.md"  && echo "  🗑 removed legacy $LEGACY_COMMANDS/$s.md"
  [ -f "$CLAUDE_SKILLS_DIR/$s.md" ] && rm "$CLAUDE_SKILLS_DIR/$s.md" && echo "  🗑 removed legacy flat $CLAUDE_SKILLS_DIR/$s.md"
done

# ── Install each skill ───────────────────────────────────────────────────────
for s in "${SKILLS[@]}"; do
  mkdir -p "$AGENTS_SKILLS_DIR/$s"
  mkdir -p "$CLAUDE_SKILLS_DIR/$s"

  if [ -n "$LOCAL_SKILLS_DIR" ]; then
    # Symlink mode: both dirs point to the same source file
    ln -sf "$LOCAL_SKILLS_DIR/$s.md" "$AGENTS_SKILLS_DIR/$s/SKILL.md"
    ln -sf "$LOCAL_SKILLS_DIR/$s.md" "$CLAUDE_SKILLS_DIR/$s/SKILL.md"
  else
    # Remote mode: download into both dirs
    curl -fsSL "$RAW_BASE/$s.md" -o "$AGENTS_SKILLS_DIR/$s/SKILL.md"
    curl -fsSL "$RAW_BASE/$s.md" -o "$CLAUDE_SKILLS_DIR/$s/SKILL.md"
  fi
  echo "  ✓ $s"
done

# ── Version file ─────────────────────────────────────────────────────────────
if [ -n "$LOCAL_SKILLS_DIR" ]; then
  INSTALLED_VERSION=$(cat "$LOCAL_SKILLS_DIR/.mt-version" 2>/dev/null || echo "unknown")
else
  curl -fsSL "$RAW_BASE/.mt-version" -o "$CLAUDE_SKILLS_DIR/.mt-version"
  INSTALLED_VERSION=$(cat "$CLAUDE_SKILLS_DIR/.mt-version")
fi

# ── Update ~/.agents/.skill-lock.json ────────────────────────────────────────
LOCK_FILE="$HOME/.agents/.skill-lock.json"
SOURCE_URL="https://github.com/$REPO.git"
INSTALLED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v python3 &>/dev/null; then
  python3 - "$LOCK_FILE" "$SOURCE_URL" "$INSTALLED_AT" "${SKILLS[@]}" <<'EOF'
import json, sys, os

lock_file = sys.argv[1]
source_url = sys.argv[2]
installed_at = sys.argv[3]
skills = sys.argv[4:]

data = {"version": 3, "skills": {}}
if os.path.exists(lock_file):
  try:
    with open(lock_file) as f:
      data = json.load(f)
  except Exception:
    pass

if "skills" not in data:
  data["skills"] = {}

for s in skills:
  existing = data["skills"].get(s, {})
  data["skills"][s] = {
    "source": "lumetrix-dev/infra-moonlight-tavern",
    "sourceType": "github",
    "sourceUrl": source_url,
    "skillPath": f"mt-skills/{s}.md",
    "skillFolderHash": existing.get("skillFolderHash", ""),
    "installedAt": existing.get("installedAt", installed_at),
    "updatedAt": installed_at,
  }

with open(lock_file, "w") as f:
  json.dump(data, f, indent=2)
  f.write("\n")
EOF
fi

echo ""
echo "✅ Done. Skills available in Claude Code, Gemini CLI, Copilot, and other agents:"
echo ""
echo "  Moonlight Tavern side:"
echo "    /mt-project-init  Initialize a new project"
echo "    /mt-plan          Plan the next Sprint"
echo "    /mt-roadmap       Plan or update ROADMAP.md"
echo "    /mt-sp-close      Aggregate PR statuses and archive at Sprint end"
echo ""
echo "  Work Repo side:"
echo "    /mt-my-tasks      View incomplete tasks + real-time PR status"
echo "    /mt-sprint-report Generate Sprint progress report"
echo "    /mt-ship          Create aggregated draft PR (title starts with [TXX.X])"
echo "    /mt-update        Check for command updates"
echo ""
if [ -n "$LOCAL_SKILLS_DIR" ]; then
  echo "  Symlink mode: edits to mt-skills/*.md take effect immediately."
  echo ""
fi
echo "  Restart your agent/IDE to activate the skills."
