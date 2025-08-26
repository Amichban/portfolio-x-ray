#!/bin/bash

# Navigate to the project directory
cd /Users/aminechbani/Desktop/cursorProjects/quantx/retail_products/portfolio_x_ray/src

# Check if gh CLI is installed and authenticated
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it first:"
    echo "   brew install gh"
    exit 1
fi

# Check authentication
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI is not authenticated. Please run:"
    echo "   gh auth login"
    exit 1
fi

echo "✓ GitHub CLI is ready"
echo "✓ Running issue creation script..."

# Make script executable and run it
chmod +x create_github_issues.py
python3 create_github_issues.py

echo ""
echo "🎉 GitHub issues creation completed!"
echo ""
echo "Next steps:"
echo "1. Visit https://github.com/Amichban/portfolio-x-ray/issues to view all created issues"
echo "2. Visit the project board to organize and track progress"
echo "3. Start development by picking up issues in priority order"