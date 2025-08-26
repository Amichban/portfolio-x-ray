#!/bin/bash
# Script to create GitHub issues from user stories

echo "🚀 Creating GitHub issues from user stories..."
echo "================================================"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed."
    echo "   Please install it from: https://cli.github.com/"
    exit 1
fi

# Check if user is authenticated with GitHub
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub."
    echo "   Please run: gh auth login"
    exit 1
fi

# Make the Python script executable
chmod +x create_github_issues.py

# Run the Python script
python3 create_github_issues.py

echo ""
echo "✅ GitHub issues creation completed!"
echo "   Check the output above for details."
echo "   Results have been saved to github_issues_created.json"