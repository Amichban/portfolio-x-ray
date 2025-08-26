#!/bin/bash

# Solo Software Factory - New Project Setup Script
# This script safely converts the template into your own project

set -e

echo "🚀 Solo Software Factory - Project Setup"
echo "========================================"
echo ""

# Get project name
read -p "Enter your project name (e.g., my-awesome-app): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name is required!"
    exit 1
fi

echo ""
echo "📦 Setting up '$PROJECT_NAME'..."
echo ""

# Step 1: Remove template git history
echo "1️⃣ Removing template repository connection..."
if [ -d .git ]; then
    rm -rf .git
    echo "   ✅ Template git history removed"
else
    echo "   ℹ️ No git history found (already clean)"
fi

# Step 2: Remove template-specific files
echo ""
echo "2️⃣ Cleaning up template files..."
rm -f START_HERE.txt 2>/dev/null || true
rm -f AUDIT_REPORT.md 2>/dev/null || true
rm -f TROUBLESHOOTING.md 2>/dev/null || true
rm -rf docs/archive 2>/dev/null || true
echo "   ✅ Template files cleaned"

# Step 3: Initialize new git repository
echo ""
echo "3️⃣ Initializing your git repository..."
git init
echo "   ✅ Git initialized"

# Step 4: Update project files
echo ""
echo "4️⃣ Personalizing project files..."

# Update README.md
if [ -f README.md ]; then
    sed -i.bak "s/Solo Software Factory/$PROJECT_NAME/g" README.md && rm README.md.bak
    sed -i.bak "s/\[this-repo\]/[your-repo-url]/g" README.md && rm README.md.bak
    echo "   ✅ README.md updated"
fi

# Update package.json for web
if [ -f apps/web/package.json ]; then
    sed -i.bak "s/\"name\": \"web\"/\"name\": \"$PROJECT_NAME-web\"/g" apps/web/package.json && rm apps/web/package.json.bak
    echo "   ✅ Frontend package.json updated"
fi

# Update STATE.md
if [ -f .claude/STATE.md ]; then
    cat > .claude/STATE.md << EOF
# Project State - $PROJECT_NAME

## Current Sprint
- **Active Story**: None
- **Sprint Goal**: Initial setup
- **Progress**: 0%

## Completed Stories
- Project initialization

## Pending Stories
- First feature to be defined

## Blockers
- None

## Next Steps
1. Read README.md for complete guide
2. Create first user story with /user-story
3. Check quality with /spec-score
4. Find parallel work with /parallel-strategy
5. Start building!

---
*Created: $(date +%Y-%m-%d)*
EOF
    echo "   ✅ STATE.md initialized"
fi

# Step 5: Define Architecture
echo ""
echo "5️⃣ Defining project architecture..."
echo ""
echo "What type of project is this?"
echo "  1) Full-Stack Web App (API + UI)"
echo "  2) API Service Only"
echo "  3) Data Pipeline/Processing"
echo "  4) Static Website"
echo "  5) Custom (define in Claude)"
echo ""
read -p "Select architecture [1-5]: " ARCH_CHOICE

case $ARCH_CHOICE in
    1)
        ARCH_PRESET="full-stack"
        echo "   ✅ Full-Stack architecture selected"
        ;;
    2)
        ARCH_PRESET="api-only"
        echo "   ✅ API-only architecture selected"
        ;;
    3)
        ARCH_PRESET="data-pipeline"
        echo "   ✅ Data Pipeline architecture selected"
        ;;
    4)
        ARCH_PRESET="static-site"
        echo "   ✅ Static Site architecture selected"
        ;;
    5)
        echo "   ℹ️ You'll need to run '/define-architecture' in Claude"
        ARCH_PRESET="custom"
        ;;
    *)
        echo "   ⚠️ Invalid choice, defaulting to full-stack"
        ARCH_PRESET="full-stack"
        ;;
esac

# Step 6: Install based on architecture
echo ""
echo "6️⃣ Installing dependencies..."

if [ "$ARCH_PRESET" != "custom" ]; then
    echo "   Running adaptive installation..."
    ./adaptive-install.sh --preset $ARCH_PRESET
    echo "   ✅ Architecture-specific dependencies installed"
else
    echo "   ℹ️ Skipping installation - define architecture in Claude first"
    echo "   Run './adaptive-install.sh' after defining architecture"
fi

# Step 7: Initial commit
echo ""
echo "7️⃣ Creating initial commit..."
git add .
git commit -m "🎉 Initial commit - $PROJECT_NAME from Solo Software Factory template"
echo "   ✅ Initial commit created"

# Step 8: Add remote (optional)
echo ""
echo "8️⃣ GitHub repository..."
echo ""
echo "To connect to GitHub:"
echo "  1. Create a new repository on GitHub (without README)"
echo "  2. Run these commands:"
echo ""
echo "     git remote add origin https://github.com/YOUR_USERNAME/$PROJECT_NAME.git"
echo "     git branch -M main"
echo "     git push -u origin main"
echo ""

# Step 9: Final instructions
echo "========================================="
echo "✅ Project '$PROJECT_NAME' is ready!"
echo "========================================="
echo ""
echo "📖 Next steps:"
echo "   1. Read README.md for complete guide"
echo "   2. Start development server: make dev"
echo "   3. Open Claude Code and build your first feature"
echo ""
echo "🎯 Quick commands:"
echo "   make dev        - Start development server"
echo "   make test       - Run tests"
echo "   make build      - Build for production"
echo ""
echo "Happy building! 🚀"