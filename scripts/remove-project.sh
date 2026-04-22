#!/bin/bash
# Remove a project from registry (optionally delete directory)
# Usage: ./scripts/remove-project.sh <name> [--delete]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_DIR="$ROOT_DIR/projects"
PROJECTS_MD="$ROOT_DIR/PROJECTS.md"

NAME="$1"
DELETE_FLAG="$2"

if [ -z "$NAME" ]; then
  echo "Usage: $0 <name> [--delete]"
  echo "  --delete: also remove the project directory"
  exit 1
fi

if ! grep -q "| $NAME |" "$PROJECTS_MD"; then
  echo "Error: project '$NAME' not found in PROJECTS.md"
  exit 1
fi

sed -i '' "/| $NAME |/d" "$PROJECTS_MD"
echo "Removed '$NAME' from PROJECTS.md"

if [ "$DELETE_FLAG" = "--delete" ]; then
  if [ -d "$PROJECTS_DIR/$NAME" ]; then
    echo "Deleting directory: projects/$NAME"
    rm -rf "$PROJECTS_DIR/$NAME"
    echo "Directory deleted."
  else
    echo "Directory projects/$NAME does not exist, skipping."
  fi
else
  echo "Directory projects/$NAME was NOT deleted. Use --delete to remove it."
fi
