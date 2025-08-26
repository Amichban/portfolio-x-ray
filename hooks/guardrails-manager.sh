#!/bin/bash

# Guardrails Manager - Utility script for managing and testing hooks
# Usage: ./guardrails-manager.sh [command] [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../.claude/settings.json"
LOG_DIR=".claude/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_color() {
    local color=$1
    shift
    echo -e "${color}$*${NC}"
}

# Show help
show_help() {
    cat <<EOF
Guardrails Manager - Agent Control System

Usage: $0 [command] [options]

Commands:
    status      Show guardrails status and configuration
    test        Test all hooks with sample payloads
    enable      Enable guardrails system
    disable     Disable guardrails system
    logs        View recent hook logs
    stats       Show tool usage statistics
    reset       Reset session counters and logs
    backup      List and manage backups
    help        Show this help message

Examples:
    $0 status                    # Check system status
    $0 test pre_tool_use        # Test specific hook
    $0 logs --tail 20           # View last 20 log entries
    $0 backup --clean           # Clean old backups
    $0 reset --all              # Full reset

For more information, see hooks/README.md
EOF
}

# Check system status
check_status() {
    print_color "$BLUE" "=== Guardrails System Status ==="
    echo ""
    
    # Check if hooks are configured
    if [ -f "$CONFIG_FILE" ]; then
        print_color "$GREEN" "✓ Configuration file exists"
        
        # Show protected branches
        echo ""
        print_color "$YELLOW" "Protected Branches:"
        jq -r '.guardrails.protected_branches[]' "$CONFIG_FILE" 2>/dev/null | while read -r branch; do
            echo "  - $branch"
        done
        
        # Show quality thresholds
        echo ""
        print_color "$YELLOW" "Quality Thresholds:"
        echo "  - Min Spec Score: $(jq -r '.guardrails.quality_thresholds.spec_score_minimum' "$CONFIG_FILE")"
        echo "  - Max Operations: $(jq -r '.guardrails.quality_thresholds.max_operations_per_session' "$CONFIG_FILE")"
        echo "  - Max Files/Commit: $(jq -r '.guardrails.quality_thresholds.max_files_per_commit' "$CONFIG_FILE")"
    else
        print_color "$RED" "✗ Configuration file missing"
    fi
    
    # Check hook files
    echo ""
    print_color "$YELLOW" "Hook Files:"
    for hook in user-prompt-validate.sh pre-tool-guard.sh post-tool-log.sh session-summary.sh subagent-cleanup.sh; do
        if [ -f "$SCRIPT_DIR/$hook" ]; then
            print_color "$GREEN" "  ✓ $hook"
        else
            print_color "$RED" "  ✗ $hook (missing)"
        fi
    done
    
    # Check current session stats
    echo ""
    print_color "$YELLOW" "Current Session:"
    local ops_count=$(cat ".claude/session_ops_count" 2>/dev/null || echo "0")
    echo "  - Operations performed: $ops_count"
    
    if [ -f ".claude/tool_stats.json" ]; then
        echo "  - Most used tools:"
        jq -r 'to_entries | sort_by(.value) | reverse | .[0:3] | .[] | "    \(.key): \(.value)"' ".claude/tool_stats.json"
    fi
    
    # Check for active warnings
    echo ""
    if [ -f "$LOG_DIR/hooks.log" ]; then
        local warnings=$(grep -c "WARNING\|BLOCKED" "$LOG_DIR/hooks.log" 2>/dev/null || echo "0")
        if [ "$warnings" -gt 0 ]; then
            print_color "$YELLOW" "⚠ $warnings warnings/blocks in current session"
        else
            print_color "$GREEN" "✓ No warnings or blocks"
        fi
    fi
}

# Test hooks with sample payloads
test_hooks() {
    local hook_name=${1:-all}
    
    print_color "$BLUE" "=== Testing Hooks ==="
    echo ""
    
    # Test pre-tool-guard hook
    if [ "$hook_name" = "all" ] || [ "$hook_name" = "pre_tool_use" ]; then
        print_color "$YELLOW" "Testing pre-tool-guard.sh..."
        
        # Test dangerous command blocking
        local test_payload='{"tool":"Bash","params":{"command":"rm -rf /"}}'
        echo "$test_payload" | "$SCRIPT_DIR/pre-tool-guard.sh" 2>&1 | grep -q "block" && \
            print_color "$GREEN" "  ✓ Blocks dangerous commands" || \
            print_color "$RED" "  ✗ Failed to block dangerous command"
        
        # Test protected file blocking
        test_payload='{"tool":"Edit","params":{"file_path":".env"}}'
        echo "$test_payload" | "$SCRIPT_DIR/pre-tool-guard.sh" 2>&1 | grep -q "block" && \
            print_color "$GREEN" "  ✓ Blocks protected files" || \
            print_color "$RED" "  ✗ Failed to block protected file"
    fi
    
    # Test user-prompt-validate hook
    if [ "$hook_name" = "all" ] || [ "$hook_name" = "user_prompt_submit" ]; then
        print_color "$YELLOW" "Testing user-prompt-validate.sh..."
        
        test_payload='{"prompt":"implement user authentication"}'
        echo "$test_payload" | "$SCRIPT_DIR/user-prompt-validate.sh" 2>&1
        print_color "$GREEN" "  ✓ Prompt validation working"
    fi
    
    # Test post-tool-log hook
    if [ "$hook_name" = "all" ] || [ "$hook_name" = "post_tool_use" ]; then
        print_color "$YELLOW" "Testing post-tool-log.sh..."
        
        test_payload='{"tool":"Write","params":{"file_path":"test.txt"},"result":{}}'
        echo "$test_payload" | "$SCRIPT_DIR/post-tool-log.sh" 2>&1
        print_color "$GREEN" "  ✓ Post-tool logging working"
    fi
    
    echo ""
    print_color "$GREEN" "Hook testing complete!"
}

# View logs
view_logs() {
    local tail_lines=${1:-50}
    
    if [ -f "$LOG_DIR/hooks.log" ]; then
        print_color "$BLUE" "=== Recent Hook Logs (last $tail_lines lines) ==="
        tail -n "$tail_lines" "$LOG_DIR/hooks.log"
    else
        print_color "$YELLOW" "No logs found"
    fi
}

# Show statistics
show_stats() {
    print_color "$BLUE" "=== Tool Usage Statistics ==="
    echo ""
    
    if [ -f ".claude/tool_stats.json" ]; then
        jq '.' ".claude/tool_stats.json"
    else
        print_color "$YELLOW" "No statistics available"
    fi
    
    echo ""
    print_color "$BLUE" "=== Agent Metrics ==="
    if [ -f ".claude/agent_metrics.json" ]; then
        jq '.' ".claude/agent_metrics.json"
    else
        print_color "$YELLOW" "No agent metrics available"
    fi
}

# Reset session data
reset_session() {
    local reset_all=${1:-false}
    
    print_color "$YELLOW" "Resetting session data..."
    
    # Reset counters
    rm -f ".claude/session_ops_count"
    rm -f ".claude/session_intent.json"
    rm -f ".claude/checkpoints.log"
    
    if [ "$reset_all" = "--all" ]; then
        print_color "$YELLOW" "Performing full reset..."
        rm -f ".claude/tool_stats.json"
        rm -f ".claude/agent_metrics.json"
        rm -f ".claude/agent_files.log"
        rm -f ".claude/agent_boundaries.json"
        
        # Archive logs
        if [ -d "$LOG_DIR" ]; then
            local archive_name="$LOG_DIR/archive_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$archive_name"
            mv "$LOG_DIR"/*.log "$archive_name/" 2>/dev/null || true
            print_color "$GREEN" "Logs archived to $archive_name"
        fi
    fi
    
    print_color "$GREEN" "Session reset complete!"
}

# Manage backups
manage_backups() {
    local action=${1:-list}
    local backup_dir=".claude/backups"
    
    case "$action" in
        --list|list)
            print_color "$BLUE" "=== Backups ==="
            if [ -d "$backup_dir" ]; then
                find "$backup_dir" -maxdepth 1 -type d -name "20*" | while read -r backup; do
                    local size=$(du -sh "$backup" | cut -f1)
                    local date=$(basename "$backup")
                    echo "  - $date (Size: $size)"
                done
            else
                print_color "$YELLOW" "No backups found"
            fi
            ;;
        --clean|clean)
            print_color "$YELLOW" "Cleaning old backups..."
            local retention_days=$(jq -r '.guardrails.backup.retention_days' "$CONFIG_FILE" 2>/dev/null || echo "7")
            find "$backup_dir" -maxdepth 1 -type d -mtime +$retention_days -exec rm -rf {} \; 2>/dev/null || true
            print_color "$GREEN" "Cleaned backups older than $retention_days days"
            ;;
    esac
}

# Main command handler
main() {
    local command=${1:-help}
    shift || true
    
    case "$command" in
        status)
            check_status
            ;;
        test)
            test_hooks "$@"
            ;;
        enable)
            print_color "$GREEN" "Guardrails enabled (hooks active via .claude/settings.json)"
            ;;
        disable)
            print_color "$YELLOW" "To disable, remove hook entries from .claude/settings.json"
            ;;
        logs)
            view_logs "$@"
            ;;
        stats)
            show_stats
            ;;
        reset)
            reset_session "$@"
            ;;
        backup)
            manage_backups "$@"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_color "$RED" "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"