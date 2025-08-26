#!/bin/bash
# Simple pre-commit hook for security scanning only

echo "🔍 Scanning for secrets..."

# Check for common secret patterns
if git diff --cached --name-only | xargs grep -E "(api_key|apikey|secret|password|token|private_key|aws_access|PRIVATE)" 2>/dev/null | grep -v "example\|template\|mock\|test"; then
    echo "⚠️  Warning: Potential secrets detected in commit!"
    echo "Please review and remove any sensitive information."
    exit 1
fi

echo "✅ No secrets detected"
exit 0