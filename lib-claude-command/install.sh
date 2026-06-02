#!/bin/bash
set -e

REPO="lumetrix-dev/infra-moonlight-tavern"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH/lib-claude-command"
COMMANDS_DIR="$HOME/.claude/skills"
FILES=(mt-plan.md mt-ship.md mt-project-init.md mt-my-tasks.md mt-sprint-report.md mt-roadmap.md mt-sp-close.md mt-update.md .mt-version)

# Version check
LOCAL_VERSION=""
if [ -f "$COMMANDS_DIR/.mt-version" ]; then
  LOCAL_VERSION=$(cat "$COMMANDS_DIR/.mt-version")
fi

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

echo "Installing Moonlight Tavern Claude commands..."
mkdir -p "$COMMANDS_DIR"

for f in "${FILES[@]}"; do
  curl -fsSL "$RAW_BASE/$f" -o "$COMMANDS_DIR/$f"
  echo "  ✓ $f"
done

echo ""
echo "✅ Done. Commands available in any Claude Code session:"
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
echo "  Restart Claude Code to activate the commands."
