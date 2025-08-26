# Testing Strategy

Simple, effective testing for solo developers.

## Test Pyramid

```
         /\        E2E (10%)
        /  \       - Critical user journeys
       /    \      - Smoke tests
      /------\     Integration (20%)  
     /        \    - API endpoints
    /          \   - Database operations
   /____________\  Unit (70%)
                   - Business logic
                   - Pure functions
```

## Testing Principles

1. **Fast Feedback**: Unit tests < 5s, all tests < 2 min
2. **Independent**: Each test runs in isolation
3. **Deterministic**: No flaky tests allowed
4. **Maintainable**: Update tests with code
5. **Valuable**: Test behavior, not implementation

## What to Test

### Always Test
- Business logic and calculations
- API endpoints and contracts
- Data validation and sanitization
- Error handling and edge cases
- Security boundaries

### Skip Testing
- Third-party libraries
- Framework code
- Simple getters/setters
- UI styling
- Configuration files

## Test Types

### Unit Tests
**Purpose**: Verify individual functions/methods
**Tools**: pytest (Python), Jest (JS/TS)
**Location**: `tests/unit/`
**Run**: On every save

### Integration Tests
**Purpose**: Verify component interactions
**Tools**: pytest + TestClient, supertest
**Location**: `tests/integration/`
**Run**: Before commit

### E2E Tests
**Purpose**: Verify complete user flows
**Tools**: Playwright
**Location**: `e2e/`
**Run**: Before merge

## Test Data Management

### Fixtures
- Use factories for consistent test data
- Reset database between tests
- Mock external services

### Seeds
```python
# tests/seeds.py
def seed_users(db):
    users = [
        create_user(email="admin@example.com", role="admin"),
        create_user(email="user@example.com", role="user"),
    ]
    db.add_all(users)
    db.commit()
```

## Coverage Targets

- **Overall**: 80% minimum
- **Critical paths**: 100%
- **New code**: 90%
- **Legacy refactors**: Improve by 10%

## Performance Benchmarks

| Test Type | Target Time | Max Time |
|-----------|------------|----------|
| Unit | < 10ms | 50ms |
| Integration | < 200ms | 1s |
| E2E | < 5s | 30s |
| Full Suite | < 2 min | 5 min |

## Security Testing

### Input Validation
```python
@pytest.mark.parametrize("payload", [
    "'; DROP TABLE users--",
    "<script>alert('XSS')</script>",
    "../../../etc/passwd",
])
def test_input_sanitization(client, payload):
    response = client.post("/api/data", json={"input": payload})
    assert response.status_code in (400, 422)
```

### Authentication
- Test expired tokens
- Test invalid tokens
- Test missing auth
- Test wrong permissions

## CI/CD Integration

```yaml
# Run tests in parallel
test:
  parallel:
    - unit
    - integration
    - e2e
  
  unit:
    script: pytest tests/unit --cov
    
  integration:
    script: pytest tests/integration
    services: [postgres, redis]
    
  e2e:
    script: npx playwright test
    artifacts: screenshots/
```

## Debugging Failed Tests

1. **Check test output**: Read error messages carefully
2. **Run in isolation**: `pytest tests/test_file.py::test_name -v`
3. **Add debugging**: Use `pytest.set_trace()` or `console.log()`
4. **Check test data**: Verify fixtures and mocks
5. **Review recent changes**: `git diff HEAD~1`

## Test Writing Checklist

- [ ] Test has clear, descriptive name
- [ ] Follows Arrange-Act-Assert pattern
- [ ] Tests one behavior
- [ ] Includes edge cases
- [ ] Cleans up after itself
- [ ] Runs fast (< 200ms)
- [ ] No external dependencies

## Example Test Structure

```python
def test_user_can_update_own_profile():
    """Users should be able to update their own profile data."""
    # Arrange
    user = create_user()
    client = create_authenticated_client(user)
    update_data = {"name": "New Name"}
    
    # Act
    response = client.patch(f"/users/{user.id}", json=update_data)
    
    # Assert
    assert response.status_code == 200
    assert response.json()["name"] == "New Name"
    # Verify in database
    updated_user = get_user(user.id)
    assert updated_user.name == "New Name"
```

## Parallel Testing

Tests can run in parallel tracks:

```bash
# Track 1: Backend tests
pytest tests/unit tests/integration

# Track 2: Frontend tests  
npm test
npx playwright test

# Track 3: Security/Performance
bandit -r src/
python security_tests.py
```

Use `/parallel-strategy` to identify which tests can run simultaneously.