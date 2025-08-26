#!/bin/bash

# Pre-tool guardrail hook - Validates and blocks dangerous operations
# Exit codes: 0 = allow, 2 = block with feedback

set -e

# Read the hook payload from stdin
PAYLOAD=$(cat)

# Extract tool and parameters
TOOL=$(echo "$PAYLOAD" | jq -r '.tool // empty')
PARAMS=$(echo "$PAYLOAD" | jq -r '.params // {}')

# Load configuration
CONFIG_FILE="$(dirname "$0")/../.claude/settings.json"
PROTECTED_BRANCHES=$(jq -r '.guardrails.protected_branches[]' "$CONFIG_FILE" 2>/dev/null || echo "main master")
DANGEROUS_PATTERNS=$(jq -r '.guardrails.dangerous_commands[]' "$CONFIG_FILE" 2>/dev/null)
PROTECTED_FILES=$(jq -r '.guardrails.protected_files[]' "$CONFIG_FILE" 2>/dev/null)

# Logging function
log_event() {
    local level=$1
    local message=$2
    local log_dir=".claude/logs"
    mkdir -p "$log_dir"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$log_dir/hooks.log"
}

# Branch protection check
check_branch_protection() {
    local current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    if [ -z "$current_branch" ]; then
        return 0
    fi
    
    for protected in $PROTECTED_BRANCHES; do
        if [[ "$current_branch" == "$protected" ]] || [[ "$current_branch" == $protected ]]; then
            cat <<EOF >&2
{
  "decision": "block",
  "reason": "Protected branch detected",
  "message": "Cannot modify protected branch '$current_branch'. Please create a feature branch first:\n  git checkout -b feature/your-feature-name",
  "suggestions": [
    "Create a feature branch: git checkout -b feature/your-task",
    "Use the /parallel-strategy command to identify safe work areas",
    "Ensure you're working on the correct story branch"
  ]
}
EOF
            log_event "BLOCKED" "Attempted modification on protected branch: $current_branch"
            exit 2
        fi
    done
}

# Check for uncommitted changes
check_uncommitted_changes() {
    if [ "$TOOL" == "Write" ] || [ "$TOOL" == "Edit" ] || [ "$TOOL" == "MultiEdit" ]; then
        local git_status=$(git status --porcelain 2>/dev/null)
        if [ -n "$git_status" ]; then
            local changed_files=$(echo "$git_status" | wc -l | tr -d ' ')
            cat <<EOF >&2
{
  "decision": "warn",
  "reason": "Uncommitted changes detected",
  "message": "You have $changed_files uncommitted changes. AI modifications may conflict with your manual edits.",
  "suggestions": [
    "Commit your changes: git add -A && git commit -m 'WIP: Manual changes'",
    "Stash your changes: git stash push -m 'Manual changes'",
    "Review changes: git diff"
  ]
}
EOF
            log_event "WARNING" "Uncommitted changes detected: $changed_files files"
        fi
    fi
}

# Check for dangerous bash commands
check_dangerous_commands() {
    if [ "$TOOL" == "Bash" ]; then
        local command=$(echo "$PARAMS" | jq -r '.command // ""')
        
        while IFS= read -r pattern; do
            if [ -n "$pattern" ] && echo "$command" | grep -qE "$pattern"; then
                cat <<EOF >&2
{
  "decision": "block",
  "reason": "Dangerous command pattern detected",
  "message": "Command contains dangerous pattern: '$pattern'",
  "command": "$command",
  "suggestions": [
    "Use safer alternatives",
    "Request user confirmation for destructive operations",
    "Break down the command into safer steps"
  ]
}
EOF
                log_event "BLOCKED" "Dangerous command blocked: $command"
                exit 2
            fi
        done <<< "$DANGEROUS_PATTERNS"
    fi
}

# Check for protected file modifications
check_protected_files() {
    if [ "$TOOL" == "Write" ] || [ "$TOOL" == "Edit" ] || [ "$TOOL" == "MultiEdit" ]; then
        local file_path=$(echo "$PARAMS" | jq -r '.file_path // ""')
        
        while IFS= read -r pattern; do
            if [ -n "$pattern" ] && [[ "$file_path" == $pattern ]]; then
                cat <<EOF >&2
{
  "decision": "block",
  "reason": "Protected file modification attempt",
  "message": "Cannot modify protected file: '$file_path'",
  "suggestions": [
    "Use environment variables instead of modifying .env files",
    "Request user permission for sensitive file changes",
    "Create a template file instead (e.g., .env.example)"
  ]
}
EOF
                log_event "BLOCKED" "Protected file modification blocked: $file_path"
                exit 2
            fi
        done <<< "$PROTECTED_FILES"
    fi
}

# Check file operation limits
check_operation_limits() {
    local session_ops_file=".claude/session_ops_count"
    local max_ops=$(jq -r '.guardrails.quality_thresholds.max_operations_per_session' "$CONFIG_FILE" 2>/dev/null || echo "50")
    
    if [ "$TOOL" == "Write" ] || [ "$TOOL" == "Edit" ] || [ "$TOOL" == "MultiEdit" ]; then
        mkdir -p .claude
        local current_ops=$(cat "$session_ops_file" 2>/dev/null || echo "0")
        current_ops=$((current_ops + 1))
        echo "$current_ops" > "$session_ops_file"
        
        if [ "$current_ops" -gt "$max_ops" ]; then
            cat <<EOF >&2
{
  "decision": "warn",
  "reason": "High operation count",
  "message": "You've performed $current_ops file operations this session (limit: $max_ops)",
  "suggestions": [
    "Consider breaking work into smaller sessions",
    "Review and commit current changes",
    "Use /parallel-strategy to distribute work"
  ]
}
EOF
            log_event "WARNING" "High operation count: $current_ops"
        fi
    fi
}

# Main execution
main() {
    log_event "INFO" "Pre-tool hook triggered for tool: $TOOL"
    
    # Run all checks
    check_branch_protection
    check_uncommitted_changes
    check_dangerous_commands
    check_protected_files
    check_operation_limits
    
    # If we get here, operation is allowed
    log_event "INFO" "Tool execution allowed: $TOOL"
    exit 0
}

main