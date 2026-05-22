#!/bin/bash
set -e

REPO="523753042/lib-claude-command"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
COMMANDS_DIR="$HOME/.claude/commands"
FILES=(plan.md ship.md project-init.md my-tasks.md sprint-report.md roadmap.md sp-close.md)

# Detect local clone vs curl pipe
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
USE_LOCAL=false
[ -f "$SCRIPT_DIR/plan.md" ] && USE_LOCAL=true

echo "Installing Claude sprint workflow commands..."
mkdir -p "$COMMANDS_DIR"

for f in "${FILES[@]}"; do
  if $USE_LOCAL; then
    cp "$SCRIPT_DIR/$f" "$COMMANDS_DIR/$f"
  else
    curl -fsSL "$BASE_URL/$f" -o "$COMMANDS_DIR/$f"
  fi
  echo "  ✓ $f"
done

echo ""
echo "✅ Done. Commands available in any Claude Code session:"
echo ""
echo "  月光酒馆 — Sprint 工作流："
echo "    /project-init  新项目初始化（月光酒馆侧）"
echo "    /plan          规划下一个 Sprint（月光酒馆侧）"
echo "    /roadmap       规划或更新 ROADMAP.md"
echo "    /sp-close      Sprint 结束时聚合 PR 状态并归档"
echo ""
echo "  月光酒馆 — 状态查询："
echo "    /my-tasks      查看当前用户未完成任务 + 实时 PR 状态"
echo "    /sprint-report 生成 Sprint 进度报告"
echo ""
echo "  Work Repo 侧："
echo "    /ship          创建聚合 draft PR（title 以 [TXX.X] 开头）"
echo ""
echo "  提示：在 Claude 对话中直接使用 /{命令名} 即可调用。"
