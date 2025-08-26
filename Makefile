.PHONY: help dev stop clean test deploy test-auth test-risk test-csv test-portfolio test-dashboard test-integration test-e2e test-all coverage coverage-auth coverage-risk coverage-csv test-parallel test-watch

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

dev: ## Start local development
	docker-compose up -d
	cd apps/api && uvicorn main:app --reload --host 0.0.0.0 --port $${API_PORT:-8000} &
	cd apps/web && PORT=$${WEB_PORT:-3000} npm run dev &
	@echo "✅ API: http://localhost:$${API_PORT:-8000}"
	@echo "✅ Web: http://localhost:$${WEB_PORT:-3000}"

stop: ## Stop all services
	docker-compose stop
	pkill -f "uvicorn main:app" || true
	pkill -f "next dev" || true

clean: ## Clean everything
	docker-compose down -v
	rm -rf apps/web/.next apps/web/node_modules
	rm -rf apps/api/__pycache__

test: ## Run all tests
	cd apps/api && python -m pytest
	cd apps/web && npm test

# === PARALLEL TDD COMMANDS ===

## Track 1: Authentication Tests
test-auth: ## Run authentication tests only
	cd apps/api && python -m pytest tests/auth/ -v --tb=short

coverage-auth: ## Check auth coverage
	cd apps/api && python -m pytest tests/auth/ --cov=app/auth --cov-report=term-missing

## Track 2: Risk Engine Tests  
test-risk: ## Run risk engine tests
	cd apps/api && python -m pytest tests/risk_engine/ -v --tb=short

coverage-risk: ## Check risk engine coverage
	cd apps/api && python -m pytest tests/risk_engine/ --cov=app/risk_engine --cov-report=term-missing

## Track 3: CSV Processing Tests
test-csv: ## Run CSV processing tests
	cd apps/api && python -m pytest tests/csv_processing/ -v --tb=short

coverage-csv: ## Check CSV processing coverage
	cd apps/api && python -m pytest tests/csv_processing/ --cov=app/csv_processing --cov-report=term-missing

## Track 4: Portfolio Management Tests
test-portfolio: ## Run portfolio management tests
	cd apps/api && python -m pytest tests/portfolio/ -v --tb=short

coverage-portfolio: ## Check portfolio coverage
	cd apps/api && python -m pytest tests/portfolio/ --cov=app/portfolio --cov-report=term-missing

## Track 5: Dashboard Tests
test-dashboard: ## Run dashboard component tests
	cd apps/web && npm test -- --testPathPattern=dashboard

coverage-dashboard: ## Check dashboard coverage
	cd apps/web && npm test -- --coverage --testPathPattern=dashboard

## Integration Testing
test-integration: ## Run integration tests
	cd apps/api && python -m pytest tests/integration/ -v
	cd apps/web && npm run test:integration

test-e2e: ## Run end-to-end tests
	docker-compose up -d
	cd apps/web && npm run test:e2e
	docker-compose stop

## Parallel Testing
test-parallel: ## Run all track tests in parallel
	@echo "🚀 Running parallel tests for all tracks..."
	@echo "Track 1: Authentication..." & cd apps/api && python -m pytest tests/auth/ -q &
	@echo "Track 2: Risk Engine..." & cd apps/api && python -m pytest tests/risk_engine/ -q &
	@echo "Track 3: CSV Processing..." & cd apps/api && python -m pytest tests/csv_processing/ -q &
	@echo "Track 4: Portfolio Mgmt..." & cd apps/api && python -m pytest tests/portfolio/ -q &
	@echo "Track 5: Dashboard..." & cd apps/web && npm test -- --silent &
	wait
	@echo "✅ All parallel tests completed"

test-watch: ## Run tests in watch mode (TDD)
	cd apps/api && python -m pytest-watch tests/ &
	cd apps/web && npm test -- --watch &
	@echo "👀 Watching for test changes..."

## Coverage Reports
coverage: ## Generate full coverage report
	cd apps/api && python -m pytest --cov=app --cov-report=html --cov-report=term
	cd apps/web && npm test -- --coverage
	@echo "📊 Coverage reports generated"

coverage-all: ## Check coverage for all tracks
	@echo "📊 Coverage Summary:"
	@echo "===================="
	@make coverage-auth | grep TOTAL || echo "Auth: No tests yet"
	@make coverage-risk | grep TOTAL || echo "Risk: No tests yet"
	@make coverage-csv | grep TOTAL || echo "CSV: No tests yet"
	@make coverage-portfolio | grep TOTAL || echo "Portfolio: No tests yet"
	@echo "Dashboard: " && make coverage-dashboard | grep "All files" || echo "No tests yet"

## Test Utilities
test-failed: ## Re-run only failed tests
	cd apps/api && python -m pytest --lf
	cd apps/web && npm test -- --onlyFailures

test-create: ## Create test structure for a story (usage: make test-create STORY=US-001)
	@echo "Creating test structure for $(STORY)..."
	@mkdir -p apps/api/tests/$(STORY)
	@mkdir -p apps/web/__tests__/$(STORY)
	@echo "✅ Test directories created for $(STORY)"

deploy: ## Deploy to GCP Cloud Run
	gcloud builds submit --config cloudbuild.yaml

setup: ## Initial setup (use ./install.sh for better error handling)
	./install.sh

install: ## Install dependencies with error handling
	./install.sh