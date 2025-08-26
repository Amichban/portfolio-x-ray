#!/bin/bash

# Subagent cleanup hook - Validates parallel work and ensures proper boundaries
# Exit codes: 0 = success, 2 = block

set -e

# Read the hook payload from stdin
PAYLOAD=$(cat)
AGENT_TYPE=$(echo "$PAYLOAD" | jq -r '.agent_type // "unknown"')
AGENT_ID=$(echo "$PAYLOAD" | jq -r '.agent_id // ""')
FILES_MODIFIED=$(echo "$PAYLOAD" | jq -r '.files_modified[]? // empty' 2>/dev/null)

# Load configuration
CONFIG_FILE="$(dirname "$0")/../.claude/settings.json"
LOG_DIR=".claude/logs"

# Logging function
log_event() {
    local level=$1
    local message=$2
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] SUBAGENT[$AGENT_TYPE]: $message" >> "$LOG_DIR/hooks.log"
}

# Check for file conflicts with other agents
check_file_conflicts() {
    local conflict_log=".claude/agent_files.log"
    mkdir -p .claude
    
    # Touch the log file if it doesn't exist
    touch "$conflict_log"
    
    for file in $FILES_MODIFIED; do
        # Check if another agent is working on this file
        if grep -q "^ACTIVE:.*:$file$" "$conflict_log" 2>/dev/null; then
            local other_agent=$(grep "^ACTIVE:.*:$file$" "$conflict_log" | cut -d: -f2)
            
            if [ "$other_agent" != "$AGENT_ID" ]; then
                cat <<EOF >&2
{
  "decision": "warn",
  "reason": "File conflict detected",
  "message": "File '$file' is being modified by another agent: $other_agent",
  "suggestions": [
    "Coordinate with other agents",
    "Use file locking mechanisms",
    "Review /parallel-strategy output"
  ]
}
EOF
                log_event "WARNING" "File conflict on $file with agent $other_agent"
            fi
        fi
        
        # Mark file as no longer being worked on by this agent
        sed -i.bak "/^ACTIVE:$AGENT_ID:$file$/d" "$conflict_log" 2>/dev/null || true
    done
}

# Validate agent stayed within boundaries
validate_agent_boundaries() {
    local boundaries_file=".claude/agent_boundaries.json"
    
    if [ -f "$boundaries_file" ]; then
        local allowed_paths=$(jq -r ".agents[\"$AGENT_TYPE\"].allowed_paths[]?" "$boundaries_file" 2>/dev/null)
        local violations=0
        
        for file in $FILES_MODIFIED; do
            local file_allowed=false
            
            for path in $allowed_paths; do
                if [[ "$file" == $path* ]]; then
                    file_allowed=true
                    break
                fi
            done
            
            if [ "$file_allowed" = false ] && [ -n "$allowed_paths" ]; then
                violations=$((violations + 1))
                log_event "WARNING" "Agent $AGENT_TYPE modified file outside boundaries: $file"
            fi
        done
        
        if [ $violations -gt 0 ]; then
            cat <<EOF >&2
{
  "decision": "warn",
  "reason": "Agent boundary violations",
  "message": "Agent $AGENT_TYPE modified $violations files outside its boundaries",
  "suggestions": [
    "Review agent boundaries configuration",
    "Use proper agent types for different tasks",
    "Check /parallel-strategy assignments"
  ]
}
EOF
        fi
    fi
}

# Generate agent performance metrics
track_agent_performance() {
    local metrics_file=".claude/agent_metrics.json"
    mkdir -p .claude
    
    # Initialize metrics file if needed
    if [ ! -f "$metrics_file" ]; then
        echo '{}' > "$metrics_file"
    fi
    
    # Count files modified
    local file_count=0
    for file in $FILES_MODIFIED; do
        file_count=$((file_count + 1))
    done
    
    # Update metrics
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    jq ". + {
        \"$AGENT_ID\": {
            \"type\": \"$AGENT_TYPE\",
            \"completed_at\": \"$timestamp\",
            \"files_modified\": $file_count
        }
    }" "$metrics_file" > "$metrics_file.tmp" && mv "$metrics_file.tmp" "$metrics_file"
    
    log_event "INFO" "Agent $AGENT_TYPE completed with $file_count files modified"
}

# Check for incomplete work
check_incomplete_work() {
    # Check for TODO comments in modified files
    local todos_found=false
    
    for file in $FILES_MODIFIED; do
        if [ -f "$file" ]; then
            if grep -q "TODO\|FIXME\|XXX" "$file" 2>/dev/null; then
                todos_found=true
                log_event "INFO" "TODOs found in $file"
            fi
        fi
    done
    
    if [ "$todos_found" = true ]; then
        cat <<EOF >&2
{
  "decision": "info",
  "reason": "Incomplete work detected",
  "message": "TODO/FIXME comments found in modified files",
  "suggestions": [
    "Review and complete TODOs",
    "Create follow-up tasks",
    "Use TodoWrite to track remaining work"
  ]
}
EOF
    fi
}

# Suggest next steps based on agent type
suggest_next_steps() {
    case "$AGENT_TYPE" in
        "frontend")
            cat <<EOF >&2
{
  "decision": "info",
  "reason": "Frontend work completed",
  "suggestions": [
    "Run UI tests",
    "Check accessibility",
    "Verify responsive design",
    "Test in different browsers"
  ]
}
EOF
            ;;
        "backend")
            cat <<EOF >&2
{
  "decision": "info",
  "reason": "Backend work completed",
  "suggestions": [
    "Run API tests",
    "Check database migrations",
    "Verify API documentation",
    "Test error handling"
  ]
}
EOF
            ;;
        "qa")
            cat <<EOF >&2
{
  "decision": "info",
  "reason": "QA work completed",
  "suggestions": [
    "Run full test suite",
    "Check code coverage",
    "Review test reports",
    "Update test documentation"
  ]
}
EOF
            ;;
    esac
}

# Main execution
main() {
    log_event "INFO" "Subagent cleanup started for $AGENT_TYPE (ID: $AGENT_ID)"
    
    # Run all validations
    check_file_conflicts
    validate_agent_boundaries
    track_agent_performance
    check_incomplete_work
    suggest_next_steps
    
    log_event "INFO" "Subagent cleanup completed for $AGENT_TYPE"
    exit 0
}

main