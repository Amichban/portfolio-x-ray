# Git Subtree Strategy for Parallel Development

## Overview
Using Git subtrees allows each track to work in complete isolation with their own repositories, CI/CD pipelines, and release cycles while still enabling integration into the main monorepo.

## Architecture

```
portfolio-x-ray/ (Main Repository)
├── subtrees/
│   ├── auth-service/        → github.com/Amichban/px-auth-service
│   ├── risk-engine/         → github.com/Amichban/px-risk-engine
│   ├── csv-processor/       → github.com/Amichban/px-csv-processor
│   ├── portfolio-service/   → github.com/Amichban/px-portfolio-service
│   └── dashboard-ui/        → github.com/Amichban/px-dashboard-ui
├── integration/
│   ├── docker-compose.yml
│   ├── tests/
│   └── contracts/
└── .subtrees              (tracks subtree configs)
```

## Setting Up Git Subtrees

### Initial Setup Script
```bash
#!/bin/bash
# setup-subtrees.sh

# Create separate repositories for each track
gh repo create px-auth-service --public --description "Portfolio X-Ray Authentication Service"
gh repo create px-risk-engine --public --description "Portfolio X-Ray Risk Calculation Engine"
gh repo create px-csv-processor --public --description "Portfolio X-Ray CSV Processing Service"
gh repo create px-portfolio-service --public --description "Portfolio X-Ray Portfolio Management"
gh repo create px-dashboard-ui --public --description "Portfolio X-Ray Dashboard UI"

# Add subtrees to main repository
git subtree add --prefix=subtrees/auth-service \
  https://github.com/Amichban/px-auth-service.git main --squash

git subtree add --prefix=subtrees/risk-engine \
  https://github.com/Amichban/px-risk-engine.git main --squash

git subtree add --prefix=subtrees/csv-processor \
  https://github.com/Amichban/px-csv-processor.git main --squash

git subtree add --prefix=subtrees/portfolio-service \
  https://github.com/Amichban/px-portfolio-service.git main --squash

git subtree add --prefix=subtrees/dashboard-ui \
  https://github.com/Amichban/px-dashboard-ui.git main --squash
```

## Track Repository Structure

### Track 1: Authentication Service (px-auth-service)
```
px-auth-service/
├── src/
│   ├── api/
│   ├── models/
│   ├── services/
│   └── middleware/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── cd.yml
├── Dockerfile
├── requirements.txt
├── pytest.ini
└── README.md
```

### Track 2: Risk Engine (px-risk-engine)
```
px-risk-engine/
├── src/
│   ├── calculations/
│   │   ├── var.py
│   │   ├── beta.py
│   │   ├── sharpe.py
│   │   └── drawdown.py
│   ├── api/
│   └── data/
├── tests/
│   ├── test_var.py
│   ├── test_beta.py
│   └── fixtures/
├── .github/
│   └── workflows/
├── Dockerfile
└── requirements.txt
```

## Subtree Commands Reference

### For Developers

```bash
# Clone specific track for independent development
git clone https://github.com/Amichban/px-auth-service.git
cd px-auth-service
# Work normally with full git history
git add .
git commit -m "feat: Add JWT token validation"
git push origin main

# Pull updates from subtree to main repo
cd portfolio-x-ray
git subtree pull --prefix=subtrees/auth-service \
  https://github.com/Amichban/px-auth-service.git main --squash

# Push changes from main repo to subtree
git subtree push --prefix=subtrees/auth-service \
  https://github.com/Amichban/px-auth-service.git main
```

### Makefile for Subtree Management
```makefile
# Makefile additions for subtree management

## Subtree Management Commands
subtree-pull-all: ## Pull all subtree updates
	@echo "📥 Pulling updates from all subtrees..."
	git subtree pull --prefix=subtrees/auth-service \
		https://github.com/Amichban/px-auth-service.git main --squash
	git subtree pull --prefix=subtrees/risk-engine \
		https://github.com/Amichban/px-risk-engine.git main --squash
	git subtree pull --prefix=subtrees/csv-processor \
		https://github.com/Amichban/px-csv-processor.git main --squash
	git subtree pull --prefix=subtrees/portfolio-service \
		https://github.com/Amichban/px-portfolio-service.git main --squash
	git subtree pull --prefix=subtrees/dashboard-ui \
		https://github.com/Amichban/px-dashboard-ui.git main --squash

subtree-push-all: ## Push all changes to subtrees
	@echo "📤 Pushing changes to all subtrees..."
	git subtree push --prefix=subtrees/auth-service \
		https://github.com/Amichban/px-auth-service.git main
	git subtree push --prefix=subtrees/risk-engine \
		https://github.com/Amichban/px-risk-engine.git main
	git subtree push --prefix=subtrees/csv-processor \
		https://github.com/Amichban/px-csv-processor.git main
	git subtree push --prefix=subtrees/portfolio-service \
		https://github.com/Amichban/px-portfolio-service.git main
	git subtree push --prefix=subtrees/dashboard-ui \
		https://github.com/Amichban/px-dashboard-ui.git main

subtree-status: ## Check status of all subtrees
	@echo "📊 Subtree Status:"
	@echo "Auth Service:" && cd subtrees/auth-service && git log --oneline -1
	@echo "Risk Engine:" && cd subtrees/risk-engine && git log --oneline -1
	@echo "CSV Processor:" && cd subtrees/csv-processor && git log --oneline -1
	@echo "Portfolio Service:" && cd subtrees/portfolio-service && git log --oneline -1
	@echo "Dashboard UI:" && cd subtrees/dashboard-ui && git log --oneline -1

# Track-specific subtree commands
subtree-pull-auth: ## Pull auth service updates
	git subtree pull --prefix=subtrees/auth-service \
		https://github.com/Amichban/px-auth-service.git main --squash

subtree-push-auth: ## Push auth service changes
	git subtree push --prefix=subtrees/auth-service \
		https://github.com/Amichban/px-auth-service.git main

subtree-pull-risk: ## Pull risk engine updates
	git subtree pull --prefix=subtrees/risk-engine \
		https://github.com/Amichban/px-risk-engine.git main --squash

subtree-push-risk: ## Push risk engine changes
	git subtree push --prefix=subtrees/risk-engine \
		https://github.com/Amichban/px-risk-engine.git main
```

## Parallel Development Workflow

### 1. Team Assignment
Each team clones their specific repository:
```bash
# Team 1: Authentication
git clone https://github.com/Amichban/px-auth-service.git
cd px-auth-service

# Team 2: Risk Engine
git clone https://github.com/Amichban/px-risk-engine.git
cd px-risk-engine

# Teams work completely independently
```

### 2. Independent CI/CD
Each subtree has its own CI/CD pipeline:

#### px-auth-service/.github/workflows/ci.yml
```yaml
name: Auth Service CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          pip install -r requirements.txt
          pytest tests/ --cov=src --cov-report=xml
      - name: Upload coverage
        uses: codecov/codecov-action@v2
  
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build Docker image
        run: docker build -t px-auth-service:${{ github.sha }} .
      - name: Push to registry
        run: docker push px-auth-service:${{ github.sha }}
```

### 3. Contract Testing
Ensure subtrees can integrate:

#### integration/contracts/auth-service.yaml
```yaml
openapi: 3.0.0
info:
  title: Auth Service API
  version: 1.0.0
paths:
  /api/auth/login:
    post:
      requestBody:
        content:
          application/json:
            schema:
              type: object
              properties:
                email: {type: string}
                password: {type: string}
      responses:
        200:
          content:
            application/json:
              schema:
                type: object
                properties:
                  token: {type: string}
                  user: {type: object}
```

### 4. Integration Testing
Main repository runs integration tests:

```python
# integration/tests/test_auth_risk_integration.py
import pytest
from subtrees.auth_service import AuthClient
from subtrees.risk_engine import RiskClient

def test_authenticated_risk_calculation():
    """Test that risk engine accepts auth tokens"""
    # Get token from auth service
    auth = AuthClient()
    token = auth.login("test@example.com", "password")
    
    # Use token for risk calculation
    risk = RiskClient(token=token)
    portfolio_risk = risk.calculate_portfolio_risk(portfolio_id=1)
    
    assert portfolio_risk is not None
    assert "total_risk" in portfolio_risk
```

## Development Scenarios

### Scenario 1: Feature Development
```bash
# Developer works on auth service
cd px-auth-service
git checkout -b feature/oauth-support
# Develop feature with TDD
make test
git commit -m "feat: Add OAuth support"
git push origin feature/oauth-support
# Create PR in px-auth-service repo
```

### Scenario 2: Integration Update
```bash
# In main repository
cd portfolio-x-ray
# Pull latest from all subtrees
make subtree-pull-all
# Run integration tests
make test-integration
# If passing, commit
git commit -m "chore: Update subtrees with latest features"
git push
```

### Scenario 3: Hotfix Deployment
```bash
# Fix in subtree repository
cd px-risk-engine
git checkout -b hotfix/calculation-error
# Fix issue
git commit -m "fix: Correct VAR calculation"
git push origin main

# Deploy independently
kubectl set image deployment/risk-engine \
  risk-engine=px-risk-engine:hotfix-v1.2.3

# Later sync to main repo
cd portfolio-x-ray
make subtree-pull-risk
```

## Benefits of Subtree Approach

### 1. Independent Development
- Each team has full autonomy
- Separate issue tracking per service
- Independent release cycles
- Service-specific CI/CD pipelines

### 2. Clean Integration
- Main repo sees unified codebase
- Easy local development with all services
- Single deployment option available
- Integrated testing possible

### 3. Flexibility
- Can deploy services independently
- Can deploy as monolith
- Easy to extract services later
- Simple to merge services if needed

## Subtree vs Submodule Comparison

| Aspect | Subtrees | Submodules |
|--------|----------|------------|
| Cloning | Automatic, full code included | Requires `--recursive` flag |
| History | Merged into main repo | Separate history maintained |
| Dependencies | None, pure git | Requires submodule commands |
| Team workflow | Simple, normal git | More complex, special commands |
| Integration | Easy, code is present | Harder, requires initialization |
| Best for | Parallel development with integration | True microservices |

## Migration Path

### From Monorepo to Subtrees
```bash
# Extract existing code to subtree
git subtree split --prefix=apps/api/auth -b auth-extraction
git push https://github.com/Amichban/px-auth-service.git auth-extraction:main

# Remove old code
git rm -rf apps/api/auth
git commit -m "refactor: Extract auth to subtree"

# Add as subtree
git subtree add --prefix=subtrees/auth-service \
  https://github.com/Amichban/px-auth-service.git main --squash
```

### From Subtrees to Microservices
```bash
# Each subtree is already a separate repo
# Just update deployment to use separate services
kubectl apply -f k8s/microservices/
```

## Docker Compose for Local Development

```yaml
# docker-compose.yml for integrated development
version: '3.8'
services:
  auth-service:
    build: ./subtrees/auth-service
    ports:
      - "8001:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/auth
  
  risk-engine:
    build: ./subtrees/risk-engine
    ports:
      - "8002:8000"
    environment:
      - AUTH_SERVICE_URL=http://auth-service:8000
      - EUR_USD_API_KEY=${EUR_USD_API_KEY}
  
  csv-processor:
    build: ./subtrees/csv-processor
    ports:
      - "8003:8000"
    
  portfolio-service:
    build: ./subtrees/portfolio-service
    ports:
      - "8004:8000"
    depends_on:
      - auth-service
  
  dashboard-ui:
    build: ./subtrees/dashboard-ui
    ports:
      - "3000:3000"
    environment:
      - API_BASE_URL=http://localhost:8080
  
  api-gateway:
    image: nginx
    volumes:
      - ./integration/nginx.conf:/etc/nginx/nginx.conf
    ports:
      - "8080:80"
    depends_on:
      - auth-service
      - risk-engine
      - csv-processor
      - portfolio-service
```

## Team Coordination

### Daily Workflow
```bash
# Morning sync
make subtree-pull-all
make test-integration

# During development
# Each team works in their own repo

# Evening integration
make subtree-pull-all
make test-integration
git commit -m "chore: Daily integration sync"
```

### Weekly Integration
```bash
# Full integration test
make subtree-pull-all
docker-compose up -d
make test-e2e
make test-performance
make test-security
```

## Monitoring Subtree Health

### Health Check Script
```bash
#!/bin/bash
# check-subtree-health.sh

echo "🏥 Checking subtree health..."

# Check each subtree for uncommitted changes
for dir in subtrees/*; do
  if [ -d "$dir" ]; then
    echo "Checking $dir..."
    cd "$dir"
    if [ -n "$(git status --porcelain)" ]; then
      echo "⚠️  WARNING: $dir has uncommitted changes"
    fi
    cd - > /dev/null
  fi
done

# Check for divergence
echo "Checking for divergence from upstream..."
for repo in px-auth-service px-risk-engine px-csv-processor px-portfolio-service px-dashboard-ui; do
  echo "Checking $repo..."
  git ls-remote https://github.com/Amichban/$repo.git HEAD
done
```

## Conclusion

Git subtrees provide the perfect balance for parallel development:
- **Independence**: Teams work in separate repositories
- **Integration**: Code automatically integrates in main repo
- **Flexibility**: Can deploy as monolith or microservices
- **Simplicity**: Uses standard git commands
- **Testing**: Enables both isolated and integrated testing

This approach allows your teams to work at maximum velocity while maintaining code quality and integration capabilities.