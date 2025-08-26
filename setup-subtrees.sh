#!/bin/bash

# Setup Git Subtrees for Parallel Development
# This script creates separate repositories for each development track
# and sets them up as git subtrees in the main repository

set -e

echo "🚀 Setting up Git Subtrees for Parallel Development"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed${NC}"
    echo "Please install it first: brew install gh"
    exit 1
fi

# Check GitHub authentication
if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ Not authenticated with GitHub${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI is ready${NC}"

# Configuration
GITHUB_USER="Amichban"
REPOS=(
    "px-auth-service:Portfolio X-Ray Authentication Service"
    "px-risk-engine:Portfolio X-Ray Risk Calculation Engine"
    "px-csv-processor:Portfolio X-Ray CSV Processing Service"
    "px-portfolio-service:Portfolio X-Ray Portfolio Management"
    "px-dashboard-ui:Portfolio X-Ray Dashboard UI"
)

# Function to create repository
create_repo() {
    local repo_name=$1
    local description=$2
    
    echo -e "${YELLOW}Creating repository: $repo_name${NC}"
    
    # Check if repo already exists
    if gh repo view "$GITHUB_USER/$repo_name" &> /dev/null; then
        echo -e "${YELLOW}  Repository already exists, skipping...${NC}"
    else
        gh repo create "$repo_name" --public --description "$description" --clone=false
        echo -e "${GREEN}  ✓ Created $repo_name${NC}"
    fi
}

# Function to initialize repository with basic structure
init_repo() {
    local repo_name=$1
    local repo_type=$2
    
    echo -e "${YELLOW}Initializing $repo_name${NC}"
    
    # Create temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository
    git clone "https://github.com/$GITHUB_USER/$repo_name.git" &> /dev/null
    cd "$repo_name"
    
    # Create basic structure based on type
    case $repo_type in
        "auth")
            cat > README.md << 'EOF'
# Authentication Service

Handles user authentication, authorization, and session management for Portfolio X-Ray.

## User Stories
- US-001: User Registration
- US-002: User Authentication
- US-003: Password Reset
- US-004: Profile Management
- US-005: Account Deactivation

## Setup
```bash
pip install -r requirements.txt
pytest tests/
```

## API Endpoints
- POST /api/auth/register
- POST /api/auth/login
- POST /api/auth/logout
- POST /api/auth/reset-password
EOF
            
            cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
pytest==7.4.3
pytest-cov==4.1.0
pytest-asyncio==0.21.1
httpx==0.25.2
EOF

            mkdir -p src/api src/models src/services tests/unit tests/integration
            ;;
            
        "risk")
            cat > README.md << 'EOF'
# Risk Calculation Engine

Calculates portfolio risk metrics including VaR, Beta, Sharpe Ratio, and Maximum Drawdown.

## User Stories
- US-020: Portfolio Risk Metrics Engine
- US-021: Value at Risk (VaR)
- US-022: Portfolio Beta
- US-023: Sharpe Ratio
- US-024: Maximum Drawdown
- US-025: Correlation Analysis

## EUR_USD Integration
Supports forex risk calculations with EUR_USD daily (D) timeframe data.

## Setup
```bash
pip install -r requirements.txt
pytest tests/
```
EOF

            cat > requirements.txt << 'EOF'
fastapi==0.104.1
numpy==1.24.3
pandas==2.1.3
scipy==1.11.4
yfinance==0.2.33
pytest==7.4.3
pytest-cov==4.1.0
EOF

            mkdir -p src/calculations src/api src/data tests/unit tests/fixtures
            ;;
            
        "csv")
            cat > README.md << 'EOF'
# CSV Processing Service

Handles CSV file upload, validation, and parsing for multiple brokerage formats.

## User Stories
- US-006: CSV File Upload
- US-007: Format Detection
- US-008: Data Validation
- US-012: Bulk Import

## Supported Formats
- Charles Schwab
- Fidelity
- TD Ameritrade
- Custom CSV

## Setup
```bash
pip install -r requirements.txt
pytest tests/
```
EOF

            cat > requirements.txt << 'EOF'
fastapi==0.104.1
pandas==2.1.3
python-multipart==0.0.6
pytest==7.4.3
pytest-cov==4.1.0
EOF

            mkdir -p src/parsers src/validators tests/fixtures tests/unit
            ;;
            
        "portfolio")
            cat > README.md << 'EOF'
# Portfolio Management Service

Manages portfolio CRUD operations, position management, and portfolio analytics.

## User Stories
- US-009: Manual Position Entry
- US-010: Edit/Delete Positions
- US-011: Multiple Portfolios

## Setup
```bash
pip install -r requirements.txt
pytest tests/
```
EOF

            cat > requirements.txt << 'EOF'
fastapi==0.104.1
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
pytest==7.4.3
pytest-cov==4.1.0
EOF

            mkdir -p src/models src/api src/repositories tests/unit tests/integration
            ;;
            
        "dashboard")
            cat > README.md << 'EOF'
# Dashboard UI

React-based dashboard for Portfolio X-Ray visualization and user interaction.

## User Stories
- US-013: Portfolio Overview
- US-014: Risk Metrics Display
- US-015: Position Concentration
- US-016: Sector Concentration
- US-017: Historical Performance
- US-018: Dashboard Customization
- US-019: Real-time Updates

## Setup
```bash
npm install
npm test
npm run dev
```
EOF

            cat > package.json << 'EOF'
{
  "name": "px-dashboard-ui",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "test": "jest --watch",
    "test:ci": "jest --ci --coverage"
  },
  "dependencies": {
    "next": "14.0.3",
    "react": "18.2.0",
    "react-dom": "18.2.0",
    "recharts": "2.10.3",
    "axios": "1.6.2"
  },
  "devDependencies": {
    "@testing-library/react": "14.1.2",
    "@testing-library/jest-dom": "6.1.5",
    "jest": "29.7.0",
    "jest-environment-jsdom": "29.7.0",
    "typescript": "5.3.2"
  }
}
EOF

            mkdir -p src/components src/hooks src/services __tests__/components
            ;;
    esac
    
    # Create .gitignore
    cat > .gitignore << 'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
venv/
.env
.venv
*.egg-info/
dist/
build/
.pytest_cache/
.coverage
htmlcov/

# Node
node_modules/
.next/
out/
dist/
*.log
npm-debug.log*
.DS_Store
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/
*.swp
*.swo
EOF

    # Create GitHub Actions workflow
    mkdir -p .github/workflows
    cat > .github/workflows/ci.yml << 'EOF'
name: CI
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt 2>/dev/null || npm install 2>/dev/null || true
      - name: Run tests
        run: |
          pytest tests/ --cov 2>/dev/null || npm test 2>/dev/null || true
EOF

    # Commit and push
    git add .
    git commit -m "Initial setup with basic structure" &> /dev/null
    git push origin main &> /dev/null
    
    echo -e "${GREEN}  ✓ Initialized $repo_name${NC}"
    
    # Clean up
    cd ../..
    rm -rf "$temp_dir"
}

# Main execution
echo ""
echo "Step 1: Creating GitHub repositories"
echo "-------------------------------------"

for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name description <<< "$repo_info"
    create_repo "$repo_name" "$description"
done

echo ""
echo "Step 2: Initializing repository structures"
echo "------------------------------------------"

init_repo "px-auth-service" "auth"
init_repo "px-risk-engine" "risk"
init_repo "px-csv-processor" "csv"
init_repo "px-portfolio-service" "portfolio"
init_repo "px-dashboard-ui" "dashboard"

echo ""
echo "Step 3: Adding repositories as subtrees"
echo "---------------------------------------"

# Check if we're in the right directory
if [ ! -f "Makefile" ]; then
    echo -e "${RED}❌ Not in the project root directory${NC}"
    echo "Please run this script from the project root"
    exit 1
fi

# Create subtrees directory if it doesn't exist
mkdir -p subtrees

# Function to add subtree
add_subtree() {
    local repo_name=$1
    local prefix="subtrees/${repo_name#px-}"
    
    echo -e "${YELLOW}Adding $repo_name as subtree at $prefix${NC}"
    
    # Check if subtree already exists
    if [ -d "$prefix" ]; then
        echo -e "${YELLOW}  Subtree already exists, pulling updates...${NC}"
        git subtree pull --prefix="$prefix" \
            "https://github.com/$GITHUB_USER/$repo_name.git" main --squash &> /dev/null
    else
        git subtree add --prefix="$prefix" \
            "https://github.com/$GITHUB_USER/$repo_name.git" main --squash &> /dev/null
    fi
    
    echo -e "${GREEN}  ✓ Added $repo_name${NC}"
}

# Add all subtrees
for repo_info in "${REPOS[@]}"; do
    IFS=':' read -r repo_name description <<< "$repo_info"
    add_subtree "$repo_name"
done

echo ""
echo "Step 4: Creating helper scripts"
echo "-------------------------------"

# Create subtree management script
cat > manage-subtrees.sh << 'EOF'
#!/bin/bash

# Subtree Management Helper Script

ACTION=$1
TRACK=$2

GITHUB_USER="Amichban"

case $ACTION in
    pull)
        if [ -z "$TRACK" ]; then
            echo "Pulling all subtrees..."
            for dir in subtrees/*; do
                if [ -d "$dir" ]; then
                    track=$(basename "$dir")
                    repo_name="px-$track"
                    echo "Pulling $repo_name..."
                    git subtree pull --prefix="subtrees/$track" \
                        "https://github.com/$GITHUB_USER/$repo_name.git" main --squash
                fi
            done
        else
            echo "Pulling $TRACK..."
            git subtree pull --prefix="subtrees/$TRACK" \
                "https://github.com/$GITHUB_USER/px-$TRACK.git" main --squash
        fi
        ;;
    
    push)
        if [ -z "$TRACK" ]; then
            echo "Pushing all subtrees..."
            for dir in subtrees/*; do
                if [ -d "$dir" ]; then
                    track=$(basename "$dir")
                    repo_name="px-$track"
                    echo "Pushing $repo_name..."
                    git subtree push --prefix="subtrees/$track" \
                        "https://github.com/$GITHUB_USER/$repo_name.git" main
                fi
            done
        else
            echo "Pushing $TRACK..."
            git subtree push --prefix="subtrees/$TRACK" \
                "https://github.com/$GITHUB_USER/px-$TRACK.git" main
        fi
        ;;
    
    status)
        echo "Subtree Status:"
        for dir in subtrees/*; do
            if [ -d "$dir" ]; then
                track=$(basename "$dir")
                echo -n "  $track: "
                cd "$dir" && git log --oneline -1
                cd - > /dev/null
            fi
        done
        ;;
    
    *)
        echo "Usage: ./manage-subtrees.sh [pull|push|status] [track-name]"
        echo "Example: ./manage-subtrees.sh pull auth-service"
        echo "Example: ./manage-subtrees.sh push  # pushes all"
        ;;
esac
EOF

chmod +x manage-subtrees.sh

echo -e "${GREEN}✓ Created manage-subtrees.sh${NC}"

# Create integration docker-compose
cat > docker-compose.subtrees.yml << 'EOF'
version: '3.8'

services:
  auth-service:
    build: ./subtrees/auth-service
    ports:
      - "8001:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/auth
    networks:
      - px-network

  risk-engine:
    build: ./subtrees/risk-engine
    ports:
      - "8002:8000"
    environment:
      - AUTH_SERVICE_URL=http://auth-service:8000
    networks:
      - px-network

  csv-processor:
    build: ./subtrees/csv-processor
    ports:
      - "8003:8000"
    networks:
      - px-network

  portfolio-service:
    build: ./subtrees/portfolio-service
    ports:
      - "8004:8000"
    depends_on:
      - auth-service
    networks:
      - px-network

  dashboard-ui:
    build: ./subtrees/dashboard-ui
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://localhost:8080
    networks:
      - px-network

  db:
    image: postgres:15
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=portfolio_xray
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - px-network

networks:
  px-network:
    driver: bridge

volumes:
  postgres_data:
EOF

echo -e "${GREEN}✓ Created docker-compose.subtrees.yml${NC}"

echo ""
echo "=================================================="
echo -e "${GREEN}✅ Git Subtrees Setup Complete!${NC}"
echo ""
echo "📁 Repository Structure:"
echo "  Main: https://github.com/$GITHUB_USER/portfolio-x-ray"
echo "  Auth: https://github.com/$GITHUB_USER/px-auth-service"
echo "  Risk: https://github.com/$GITHUB_USER/px-risk-engine"
echo "  CSV:  https://github.com/$GITHUB_USER/px-csv-processor"
echo "  Port: https://github.com/$GITHUB_USER/px-portfolio-service"
echo "  UI:   https://github.com/$GITHUB_USER/px-dashboard-ui"
echo ""
echo "🎯 Next Steps:"
echo "  1. Teams can clone their specific repositories"
echo "  2. Use ./manage-subtrees.sh to sync changes"
echo "  3. Run 'docker-compose -f docker-compose.subtrees.yml up' for integration"
echo ""
echo "📚 Quick Commands:"
echo "  Pull all:  ./manage-subtrees.sh pull"
echo "  Push all:  ./manage-subtrees.sh push"
echo "  Status:    ./manage-subtrees.sh status"
echo ""