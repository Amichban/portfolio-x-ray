#!/bin/bash

# Post-tool hook - Logs operations, creates checkpoints, and backs up changes
# Exit codes: 0 = success

set -e

# Read the hook payload from stdin
PAYLOAD=$(cat)
TOOL=$(echo "$PAYLOAD" | jq -r '.tool // empty')
PARAMS=$(echo "$PAYLOAD" | jq -r '.params // {}')
RESULT=$(echo "$PAYLOAD" | jq -r '.result // {}')

# Load configuration
CONFIG_FILE="$(dirname "$0")/../.claude/settings.json"
BACKUP_ENABLED=$(jq -r '.guardrails.backup.enabled' "$CONFIG_FILE" 2>/dev/null || echo "true")
BACKUP_DIR=$(jq -r '.guardrails.backup.directory' "$CONFIG_FILE" 2>/dev/null || echo ".claude/backups")

# Logging function
log_event() {
    local level=$1
    local message=$2
    local log_dir=".claude/logs"
    mkdir -p "$log_dir"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] POST-TOOL: $message" >> "$log_dir/hooks.log"
}

# Create checkpoint commit for file changes
create_checkpoint() {
    if [ "$TOOL" == "Write" ] || [ "$TOOL" == "Edit" ] || [ "$TOOL" == "MultiEdit" ]; then
        local file_path=$(echo "$PARAMS" | jq -r '.file_path // ""')
        
        if [ -n "$file_path" ] && [ -f "$file_path" ]; then
            # Check if file is tracked by git
            if git ls-files --error-unmatch "$file_path" > /dev/null 2>&1 || [ ! -f "$file_path" ]; then
                # Stage only this specific file
                git add "$file_path" 2>/dev/null || true
                
                # Check if there are changes to commit
                if ! git diff --cached --quiet "$file_path" 2>/dev/null; then
                    # Extract story reference from current work
                    local story_ref=""
                    if [ -f ".claude/session_intent.json" ]; then
                        story_ref=$(grep -oE "US-[0-9]+" ".claude/session_intent.json" | head -1 || echo "")
                    fi
                    
                    # Create descriptive commit message
                    local action="Update"
                    [ "$TOOL" == "Write" ] && action="Create"
                    local filename=$(basename "$file_path")
                    local commit_msg="checkpoint: $action $filename"
                    [ -n "$story_ref" ] && commit_msg="$commit_msg ($story_ref)"
                    
                    # Commit only this file
                    git commit -m "$commit_msg" "$file_path" > /dev/null 2>&1 || true
                    
                    log_event "INFO" "Checkpoint created for $file_path"
                    
                    # Track checkpoint for potential squashing
                    echo "$(git rev-parse HEAD) $file_path" >> ".claude/checkpoints.log"
                fi
            fi
        fi
    fi
}

# Backup gitignored files before modification
backup_gitignored_files() {
    if [ "$BACKUP_ENABLED" != "true" ]; then
        return 0
    fi
    
    if [ "$TOOL" == "Write" ] || [ "$TOOL" == "Edit" ] || [ "$TOOL" == "MultiEdit" ]; then
        local file_path=$(echo "$PARAMS" | jq -r '.file_path // ""')
        
        if [ -n "$file_path" ] && [ -f "$file_path" ]; then
            # Check if file is gitignored
            if git check-ignore "$file_path" > /dev/null 2>&1; then
                # Create backup directory with timestamp
                local timestamp=$(date +"%Y%m%d_%H%M%S")
                local backup_path="$BACKUP_DIR/$timestamp"
                mkdir -p "$backup_path"
                
                # Preserve directory structure in backup
                local file_dir=$(dirname "$file_path")
                mkdir -p "$backup_path/$file_dir"
                
                # Copy file to backup
                cp "$file_path" "$backup_path/$file_path"
                
                log_event "INFO" "Backed up gitignored file: $file_path to $backup_path"
                
                # Create backup metadata
                cat > "$backup_path/metadata.json" <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "file": "$file_path",
  "tool": "$TOOL",
  "reason": "gitignored_file_modification"
}
EOF
            fi
        fi
    fi
}

# Track tool usage statistics
track_tool_usage() {
    local stats_file=".claude/tool_stats.json"
    mkdir -p .claude
    
    # Initialize or read existing stats
    if [ ! -f "$stats_file" ]; then
        echo '{}' > "$stats_file"
    fi
    
    # Update tool count
    local current_count=$(jq -r ".[\"$TOOL\"] // 0" "$stats_file")
    current_count=$((current_count + 1))
    
    # Update stats file
    jq ". + {\"$TOOL\": $current_count}" "$stats_file" > "$stats_file.tmp" && mv "$stats_file.tmp" "$stats_file"
    
    log_event "INFO" "Tool usage: $TOOL (total: $current_count)"
}

# Clean old backups based on retention policy
cleanup_old_backups() {
    if [ "$BACKUP_ENABLED" != "true" ]; then
        return 0
    fi
    
    local retention_days=$(jq -r '.guardrails.backup.retention_days' "$CONFIG_FILE" 2>/dev/null || echo "7")
    
    if [ -d "$BACKUP_DIR" ]; then
        # Find and remove backups older than retention period
        find "$BACKUP_DIR" -maxdepth 1 -type d -mtime +$retention_days -exec rm -rf {} \; 2>/dev/null || true
        log_event "INFO" "Cleaned backups older than $retention_days days"
    fi
}

# Monitor for potential issues
check_for_issues() {
    # Check if we're modifying test files without running tests
    if [ "$TOOL" == "Write" ] || [ "$TOOL" == "Edit" ] || [ "$TOOL" == "MultiEdit" ]; then
        local file_path=$(echo "$PARAMS" | jq -r '.file_path // ""')
        
        if echo "$file_path" | grep -E "(test|spec)\.(js|ts|py|rb)" > /dev/null 2>&1; then
            cat <<EOF >&2
{
  "decision": "info",
  "reason": "Test file modified",
  "message": "Test file modified: $file_path",
  "suggestions": [
    "Run tests to verify changes",
    "Use /gen-tests to ensure comprehensive coverage",
    "Consider running: npm test or pytest"
  ]
}
EOF
            log_event "INFO" "Test file modified without test run: $file_path"
        fi
    fi
}

# Main execution
main() {
    log_event "INFO" "Post-tool hook triggered for: $TOOL"
    
    # Run all post-processing
    create_checkpoint
    backup_gitignored_files
    track_tool_usage
    cleanup_old_backups
    check_for_issues
    
    log_event "INFO" "Post-tool processing completed for: $TOOL"
    exit 0
}

main