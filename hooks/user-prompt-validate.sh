#!/bin/bash

# User prompt validation hook - Enforces quality standards and validates requests
# Exit codes: 0 = allow, 2 = block with feedback

set -e

# Read the hook payload from stdin
PAYLOAD=$(cat)
PROMPT=$(echo "$PAYLOAD" | jq -r '.prompt // ""')

# Load configuration
CONFIG_FILE="$(dirname "$0")/../.claude/settings.json"
MIN_SPEC_SCORE=$(jq -r '.guardrails.quality_thresholds.spec_score_minimum' "$CONFIG_FILE" 2>/dev/null || echo "7.0")

# Logging function
log_event() {
    local level=$1
    local message=$2
    local log_dir=".claude/logs"
    mkdir -p "$log_dir"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] PROMPT: $message" >> "$log_dir/hooks.log"
}

# Check if prompt is about implementing a feature
is_implementation_request() {
    local keywords="implement|build|create|develop|code|add feature|write"
    echo "$PROMPT" | grep -iE "($keywords)" > /dev/null 2>&1
    return $?
}

# Check for existing spec score
check_spec_score() {
    local spec_file=""
    
    # Try to find the most recent spec file
    if [ -d "user-stories" ]; then
        spec_file=$(find user-stories -name "*.md" -type f -exec grep -l "Quality Score:" {} \; | head -1)
    fi
    
    if [ -n "$spec_file" ]; then
        local score=$(grep "Quality Score:" "$spec_file" | grep -oE '[0-9]+\.?[0-9]*' | head -1)
        
        if [ -n "$score" ]; then
            # Use bc for floating point comparison
            if (( $(echo "$score < $MIN_SPEC_SCORE" | bc -l) )); then
                cat <<EOF >&2
{
  "decision": "warn",
  "reason": "Low specification quality score",
  "message": "Current spec score ($score) is below minimum ($MIN_SPEC_SCORE)",
  "suggestions": [
    "Run /spec-score to check specification quality",
    "Use /spec-enhance to improve the specification",
    "Ensure acceptance criteria are clear and measurable",
    "Add edge cases and error handling requirements"
  ]
}
EOF
                log_event "WARNING" "Low spec score detected: $score"
            fi
        fi
    fi
}

# Check for proper story context
check_story_context() {
    if is_implementation_request; then
        if ! echo "$PROMPT" | grep -iE "(US-[0-9]+|story|requirement|spec)" > /dev/null 2>&1; then
            cat <<EOF >&2
{
  "decision": "info",
  "reason": "No story reference detected",
  "message": "Implementation request without story reference",
  "suggestions": [
    "Reference a specific user story (e.g., 'Implement US-001')",
    "Use /user-story to create a new story first",
    "Use /spec-to-stories to generate multiple stories",
    "Include acceptance criteria in your request"
  ]
}
EOF
            log_event "INFO" "Implementation without story reference"
        fi
    fi
}

# Check for parallel work opportunities
suggest_parallel_work() {
    if echo "$PROMPT" | grep -iE "(multiple|several|list of|and also|additionally)" > /dev/null 2>&1; then
        cat <<EOF >&2
{
  "decision": "info",
  "reason": "Multiple tasks detected",
  "message": "Your request contains multiple tasks that might benefit from parallel execution",
  "suggestions": [
    "Use /parallel-strategy to identify parallel work opportunities",
    "Break down into separate user stories",
    "Use /spawn-expert for specialized domain tasks",
    "Consider using TodoWrite to track multiple tasks"
  ]
}
EOF
        log_event "INFO" "Multiple tasks detected in prompt"
    fi
}

# Validate testing requirements
check_testing_requirements() {
    if is_implementation_request; then
        if ! echo "$PROMPT" | grep -iE "(test|testing|coverage|tdd)" > /dev/null 2>&1; then
            cat <<EOF >&2
{
  "decision": "info",
  "reason": "No testing mentioned",
  "message": "Consider test-driven development for better quality",
  "suggestions": [
    "Use /gen-tests to generate comprehensive tests",
    "Use /test-plan to create a testing strategy",
    "Include testing requirements in your specification",
    "Consider TDD approach: write tests first"
  ]
}
EOF
            log_event "INFO" "No testing requirements in implementation request"
        fi
    fi
}

# Check for security considerations
check_security_mentions() {
    if echo "$PROMPT" | grep -iE "(auth|login|password|token|api|user data|database)" > /dev/null 2>&1; then
        if ! echo "$PROMPT" | grep -iE "(secure|security|encrypt|hash|validate|sanitize)" > /dev/null 2>&1; then
            cat <<EOF >&2
{
  "decision": "warn",
  "reason": "Security-sensitive operation without security mentions",
  "message": "Your request involves security-sensitive operations",
  "suggestions": [
    "Consider security implications",
    "Use /spawn-expert security for security review",
    "Include input validation requirements",
    "Specify authentication and authorization needs"
  ]
}
EOF
            log_event "WARNING" "Security-sensitive request without security considerations"
        fi
    fi
}

# Track session intent
track_session_intent() {
    local intent_file=".claude/session_intent.json"
    mkdir -p .claude
    
    local intent="general"
    if is_implementation_request; then
        intent="implementation"
    elif echo "$PROMPT" | grep -iE "(fix|debug|error|bug)" > /dev/null 2>&1; then
        intent="debugging"
    elif echo "$PROMPT" | grep -iE "(test|testing)" > /dev/null 2>&1; then
        intent="testing"
    elif echo "$PROMPT" | grep -iE "(refactor|improve|optimize)" > /dev/null 2>&1; then
        intent="refactoring"
    fi
    
    cat > "$intent_file" <<EOF
{
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "intent": "$intent",
  "prompt_length": ${#PROMPT},
  "has_story_ref": $(echo "$PROMPT" | grep -qE "US-[0-9]+" && echo "true" || echo "false")
}
EOF
    
    log_event "INFO" "Session intent: $intent"
}

# Main execution
main() {
    log_event "INFO" "User prompt validation started"
    
    # Run all checks
    check_spec_score
    check_story_context
    suggest_parallel_work
    check_testing_requirements
    check_security_mentions
    track_session_intent
    
    # Log prompt for audit
    echo "$PROMPT" | head -c 200 >> ".claude/logs/prompts.log"
    echo "..." >> ".claude/logs/prompts.log"
    
    log_event "INFO" "User prompt validation completed"
    exit 0
}

main