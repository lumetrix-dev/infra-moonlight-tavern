#!/bin/bash
set -e

REPO="lumetrix-dev/infra-moonlight-tavern"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH/lib-claude-command"
COMMANDS_DIR="$HOME/.claude/commands"
FILES=(mt-plan.md mt-ship.md mt-project-init.md mt-my-tasks.md mt-sprint-report.md mt-roadmap.md mt-sp-close.md mt-update.md .mt-version)

# Detect local vs remote mode
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
if [ -f "$SCRIPT_DIR/mt-plan.md" ]; then
  MODE="local"
else
  MODE="remote"
fi

echo "Installing Moonlight Tavern Claude commands ($MODE)..."
mkdir -p "$COMMANDS_DIR"

for f in "${FILES[@]}"; do
  if [ "$MODE" = "local" ]; then
    cp "$SCRIPT_DIR/$f" "$COMMANDS_DIR/$f"
  else
    curl -fsSL "$RAW_BASE/$f" -o "$COMMANDS_DIR/$f"
  fi
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
