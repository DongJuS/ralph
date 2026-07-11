#!/bin/bash
# Ralph Constellation Orchestrator - Perpetual Research & Evolution Loop

PROJECTS=("personal-finance-manager" "personal-data-agent" "career-tracker" "publishing-manager" "certification-scheduler" "life-schedule-ai")
BASE_DIR="/Users/ddj/Documents/00_code/05_Project"

echo "=== Starting Ralph Constellation Orchestrator ==="

while true; do
    for PROJ in "${PROJECTS[@]}"; do
        echo "---------------------------------------------------------------"
        echo "  Now evolving project: $PROJ"
        echo "---------------------------------------------------------------"
        
        PROJ_PATH="$BASE_DIR/$PROJ"
        if [ -d "$PROJ_PATH" ]; then
            cd "$PROJ_PATH"
            if [ -f "./scripts/ralph/ralph.sh" ]; then
                echo "Running Ralph with Gemini..."
                ./scripts/ralph/ralph.sh --tool gemini 2
                
                if [ $? -ne 0 ]; then
                    echo "Gemini failed or quota exhausted. Trying Ollama (Qwen 2.5)..."
                    ./scripts/ralph/ralph.sh --tool ollama 2
                fi
            else
                echo "ralph.sh not found in $PROJ/scripts/ralph/, skipping."
            fi
        else
            echo "Directory $PROJ_PATH not found, skipping."
        fi
        
        sleep 10
    done
    
    echo "==============================================================="
    echo "  Full constellation cycle complete. Cooling down for 30s..."
    echo "==============================================================="
    sleep 30
done
