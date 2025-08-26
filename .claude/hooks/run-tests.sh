#!/bin/bash
# Simple test runner hook - runs after code changes

set -euo pipefail

# Create output directory
mkdir -p .claude/out

echo "🧪 Running quick tests..."

# Detect project type and run appropriate tests
if [ -f "apps/api/requirements.txt" ] || [ -f "requirements.txt" ]; then
    # Python project
    if command -v pytest &> /dev/null; then
        echo "Running Python unit tests..."
        pytest -q tests/unit 2>&1 | tee .claude/out/test-report.txt || true
    fi
fi

if [ -f "apps/web/package.json" ] || [ -f "package.json" ]; then
    # Node.js project
    if [ -f "package.json" ] && grep -q '"test"' package.json; then
        echo "Running JavaScript tests..."
        npm test 2>&1 | tee -a .claude/out/test-report.txt || true
    fi
fi

# Check if any tests failed
if [ -f ".claude/out/test-report.txt" ]; then
    if grep -q "FAILED\|FAIL\|Error" .claude/out/test-report.txt; then
        echo "⚠️  Some tests failed. Run /test-fixit to diagnose."
    else
        echo "✅ Tests passed!"
    fi
fi

echo "Test results saved to .claude/out/test-report.txt"