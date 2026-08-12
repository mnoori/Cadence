#!/usr/bin/env bash
# Cadence installer: symlinks the three skills into ~/.claude/skills/.
#
# Idempotent: re-run safely to update.
#
# Customize via env vars:
#   CADENCE_DIR = where the Cadence repo lives (default: ~/.claude-cadence)
#   SKILLS_DIR  = your Claude skills dir        (default: ~/.claude/skills)
#   REPO_URL    = git remote                    (default: https://github.com/mnoori/Cadence.git)
#   BRANCH      = branch to track               (default: main)

set -euo pipefail

CADENCE_DIR="${CADENCE_DIR:-$HOME/.claude-cadence}"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
REPO_URL="${REPO_URL:-https://github.com/mnoori/Cadence.git}"
BRANCH="${BRANCH:-main}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [ -f "$SCRIPT_REPO_ROOT/.claude-plugin/plugin.json" ]; then
  CADENCE_DIR="$SCRIPT_REPO_ROOT"
  echo "Using existing clone at $CADENCE_DIR"
elif [ -d "$CADENCE_DIR/.git" ]; then
  echo "Updating existing Cadence install at $CADENCE_DIR"
  git -C "$CADENCE_DIR" pull --ff-only origin "$BRANCH"
else
  echo "Cloning Cadence to $CADENCE_DIR"
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$CADENCE_DIR"
fi

mkdir -p "$SKILLS_DIR"

LINKED=()
SKIPPED=()

for skill_path in "$CADENCE_DIR/skills"/*/; do
  skill_name="$(basename "$skill_path")"
  target="$SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    SKIPPED+=("$skill_name (target exists and is not a symlink; will not overwrite)")
    continue
  fi

  ln -s "$skill_path" "$target"
  LINKED+=("$skill_name")
done

echo ""
echo "Installed:"
for s in "${LINKED[@]}"; do
  echo "  + $s -> $SKILLS_DIR/$s"
done

if [ "${#SKIPPED[@]}" -gt 0 ]; then
  echo ""
  echo "Skipped:"
  for s in "${SKIPPED[@]}"; do
    echo "  ! $s"
  done
fi

echo ""
echo "Next:"
echo "  1. Restart Claude Code, or run /reload-plugins if available."
echo "  2. Confirm cadence-pr-review, cadence-research, and cadence-sweep appear."
echo "  3. Test cadence-pr-review on $CADENCE_DIR/skills/cadence-pr-review/evals/sample-pr/"
echo ""
echo "Uninstall:"
echo "  rm \"$SKILLS_DIR\"/cadence-pr-review \"$SKILLS_DIR\"/cadence-research \"$SKILLS_DIR\"/cadence-sweep"
echo "  rm -rf \"$CADENCE_DIR\"   # only if you do not want to keep the source"
