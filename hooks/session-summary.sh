#!/bin/bash

# Session summary hook - Generates summary report when session ends
# Exit codes: 0 = success

set -e

# Read the hook payload from stdin
PAYLOAD=$(cat)

# Load configuration
CONFIG_FILE="$(dirname "$0")/../.claude/settings.json"
LOG_DIR=".claude/logs"

# Generate session summary
generate_summary() {
    local summary_file="$LOG_DIR/session_summary_$(date +%Y%m%d_%H%M%S).md"
    mkdir -p "$LOG_DIR"
    
    cat > "$summary_file" <<EOF
# Session Summary Report
Generated: $(date '+%Y-%m-%d %H:%M:%S')

## Session Statistics

### Tool Usage
EOF
    
    # Add tool usage stats
    if [ -f ".claude/tool_stats.json" ]; then
        echo '```json' >> "$summary_file"
        jq '.' ".claude/tool_stats.json" >> "$summary_file"
        echo '```' >> "$summary_file"
    fi
    
    echo "" >> "$summary_file"
    echo "### File Operations" >> "$summary_file"
    
    # Count file operations
    local ops_count=$(cat ".claude/session_ops_count" 2>/dev/null || echo "0")
    echo "- Total file operations: $ops_count" >> "$summary_file"
    
    # List modified files from git
    echo "" >> "$summary_file"
    echo "### Modified Files" >> "$summary_file"
    git diff --name-only 2>/dev/null | while read -r file; do
        echo "- $file (uncommitted)" >> "$summary_file"
    done
    
    git diff --cached --name-only 2>/dev/null | while read -r file; do
        echo "- $file (staged)" >> "$summary_file"
    done
    
    # Add checkpoint information
    if [ -f ".claude/checkpoints.log" ]; then
        echo "" >> "$summary_file"
        echo "### Checkpoints Created" >> "$summary_file"
        local checkpoint_count=$(wc -l < ".claude/checkpoints.log" | tr -d ' ')
        echo "- Total checkpoints: $checkpoint_count" >> "$summary_file"
        echo "" >> "$summary_file"
        echo "To squash checkpoints into a single commit:" >> "$summary_file"
        echo '```bash' >> "$summary_file"
        echo "git rebase -i HEAD~$checkpoint_count" >> "$summary_file"
        echo '```' >> "$summary_file"
    fi
    
    # Add session intent
    if [ -f ".claude/session_intent.json" ]; then
        echo "" >> "$summary_file"
        echo "### Session Intent" >> "$summary_file"
        echo '```json' >> "$summary_file"
        jq '.' ".claude/session_intent.json" >> "$summary_file"
        echo '```' >> "$summary_file"
    fi
    
    # Add warnings and blocks
    echo "" >> "$summary_file"
    echo "### Security Events" >> "$summary_file"
    grep "BLOCKED\|WARNING" "$LOG_DIR/hooks.log" 2>/dev/null | tail -10 >> "$summary_file" || echo "No security events" >> "$summary_file"
    
    # Add recommendations
    echo "" >> "$summary_file"
    echo "## Recommendations" >> "$summary_file"
    
    if [ "$ops_count" -gt 20 ]; then
        echo "- High number of file operations. Consider breaking work into smaller tasks." >> "$summary_file"
    fi
    
    if git status --porcelain 2>/dev/null | grep -q .; then
        echo "- You have uncommitted changes. Remember to commit your work." >> "$summary_file"
    fi
    
    if [ -f ".claude/checkpoints.log" ] && [ "$(wc -l < ".claude/checkpoints.log" | tr -d ' ')" -gt 5 ]; then
        echo "- Multiple checkpoints created. Consider squashing commits for cleaner history." >> "$summary_file"
    fi
    
    echo "" >> "$summary_file"
    echo "---" >> "$summary_file"
    echo "Summary saved to: $summary_file" >> "$summary_file"
    
    # Output summary location to stderr for user
    echo "Session summary saved to: $summary_file" >&2
}

# Clean up session files
cleanup_session() {
    # Reset operation counter for next session
    rm -f ".claude/session_ops_count"
    
    # Archive checkpoints log
    if [ -f ".claude/checkpoints.log" ]; then
        mv ".claude/checkpoints.log" "$LOG_DIR/checkpoints_$(date +%Y%m%d_%H%M%S).log"
    fi
    
    # Archive session intent
    if [ -f ".claude/session_intent.json" ]; then
        mv ".claude/session_intent.json" "$LOG_DIR/intent_$(date +%Y%m%d_%H%M%S).json"
    fi
}

# Main execution
main() {
    generate_summary
    cleanup_session
    
    exit 0
}

main