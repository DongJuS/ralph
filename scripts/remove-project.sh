#!/bin/bash
# Remove a project from registry (optionally delete directory)
# Usage: ./scripts/remove-project.sh <name> [--delete]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_MD="$ROOT_DIR/PROJECTS.md"
MARKER_FILE=".git/ralph-managed"

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

PROJECT_PATH=$(
  awk -F'|' -v name="$NAME" '
    $2 ~ /^[[:space:]]*[^[:space:]].*$/ {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2)
      if ($2 == name) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3)
        print $3
        exit
      }
    }
  ' "$PROJECTS_MD"
)

if [ -z "$PROJECT_PATH" ]; then
  echo "Error: project path for '$NAME' could not be resolved"
  exit 1
fi

sed -i '' "/| $NAME |/d" "$PROJECTS_MD"
echo "Removed '$NAME' from PROJECTS.md"

if [ "$DELETE_FLAG" = "--delete" ]; then
  TARGET="$ROOT_DIR/$PROJECT_PATH"
  if [ -d "$TARGET" ]; then
    if [ ! -f "$TARGET/$MARKER_FILE" ]; then
      echo "Refusing to delete $PROJECT_PATH because it is not marked as Ralph-managed."
      exit 1
    fi
    echo "Deleting directory: $PROJECT_PATH"
    rm -rf "$TARGET"
    echo "Directory deleted."
  else
    echo "Directory $PROJECT_PATH does not exist, skipping."
  fi
else
  echo "Directory $PROJECT_PATH was NOT deleted. Use --delete to remove it."
fi
