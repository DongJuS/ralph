#!/bin/bash
# Ralph Constellation Dashboard - Real-time Ingestion Monitor

PROJECTS=("personal-finance-manager" "personal-data-agent" "career-tracker" "publishing-manager" "certification-scheduler" "life-schedule-ai")
BASE_DIR="/Users/ddj/Documents/00_code/05_Project"

echo "==============================================================="
echo "   RALPH CONSTELLATION DASHBOARD"
echo "==============================================================="
printf "%-25s | %-10s | %-10s | %-40s\n" "Project Name" "Sources" "Wiki Pages" "Last Ingest Action"
echo "---------------------------------------------------------------"

for PROJ in "${PROJECTS[@]}"; do
    WIKI_HEAD_DIR="$BASE_DIR/$PROJ/wiki-head"
    
    if [ -d "$WIKI_HEAD_DIR" ]; then
        SRC_COUNT=$(find "$WIKI_HEAD_DIR/sources" -maxdepth 1 -type f | wc -l | xargs)
        WIKI_COUNT=$(find "$WIKI_HEAD_DIR/wiki" -maxdepth 1 -type f | wc -l | xargs)
        LAST_LOG=$(grep "ingest" "$WIKI_HEAD_DIR/log.md" | tail -n 1 | sed 's/## //')
        
        if [ -z "$LAST_LOG" ]; then
            LAST_LOG="Initialized"
        fi
        
        printf "%-25s | %-10s | %-10s | %-40s\n" "$PROJ" "$SRC_COUNT" "$WIKI_COUNT" "${LAST_LOG:0:40}"
    else
        printf "%-25s | %-10s | %-10s | %-40s\n" "$PROJ" "N/A" "N/A" "Pending..."
    fi
done
echo "==============================================================="
