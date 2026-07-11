#!/bin/bash

# Define the projects
PROJECTS=("personal-data-agent" "career-tracker" "publishing-manager" "certification-scheduler" "life-schedule-ai")
BASE_DIR="/Users/ddj/Documents/00_code/05_Project"
LLM_WIKI_DIR="$BASE_DIR/llm-wiki"

for PROJ in "${PROJECTS[@]}"; do
    echo "Processing $PROJ..."
    PROJ_DIR="$BASE_DIR/$PROJ"
    
    # 1. Ensure scripts/ralph exists for general projects
    if [ ! -d "$PROJ_DIR/scripts/ralph" ]; then
        echo "Copying ralph scripts to $PROJ..."
        mkdir -p "$PROJ_DIR/scripts"
        cp -r "$BASE_DIR/personal-data-agent/scripts/ralph" "$PROJ_DIR/scripts/"
    fi
    
    # 2. Generate prd.json
    cat << 'PRD_EOF' > "$PROJ_DIR/prd.json"
{
  "project": "Adopt LLM Wiki Pattern",
  "branchName": "ralph/adopt-llm-wiki",
  "description": "Integrate the LLM Wiki pattern into this project. Read from ../llm-wiki/ and apply its structure.",
  "userStories": [
    {
      "id": "US-001",
      "title": "Adopt LLM Wiki Structure",
      "description": "Apply the LLM Wiki structure (index.md, log.md, sources/, wiki/) to this project.",
      "acceptanceCriteria": [
        "Copy index.md and log.md from ../llm-wiki/ to the project root.",
        "Create sources/ and wiki/ directories at the project root.",
        "Append the content of ../llm-wiki/CLAUDE.md to this project's CLAUDE.md.",
        "Move existing appropriate files into sources/ or wiki/. If a file's role doesn't match either, leave it where it is.",
        "Update index.md and log.md to reflect the newly moved files and initialization."
      ],
      "priority": 1,
      "passes": false,
      "notes": ""
    }
  ]
}
PRD_EOF

    # Link prd.json in scripts/ralph if not exists
    if [ ! -f "$PROJ_DIR/scripts/ralph/prd.json" ]; then
        ln -sf ../../prd.json "$PROJ_DIR/scripts/ralph/prd.json"
    fi
    
    # 3. Run ralph.sh
    echo "Running ralph.sh for $PROJ..."
    cd "$PROJ_DIR"
    ./scripts/ralph/ralph.sh --tool gemini 2
done
