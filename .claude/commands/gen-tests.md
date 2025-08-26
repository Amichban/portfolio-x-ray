---
name: gen-tests
description: Generate tests from stories and test plans
tools: [Read, Write, Edit]
---

# Test Generator

Generate complete test suites from user stories and test plans.

## Usage

```bash
/gen-tests US-001                    # From user story
/gen-tests --from-plan test-plan.md  # From test plan  
/gen-tests --type unit               # Specific test type
```

## Process

1. **Parse Input**: Story acceptance criteria or test plan
2. **Generate Fixtures**: Test data and mocks
3. **Create Tests**: Unit, integration, E2E as needed
4. **Output Location**: Appropriate test directories

## Test Structure

### Python/FastAPI
```python
# tests/unit/test_user_service.py
import pytest
from unittest.mock import Mock

@pytest.fixture
def user_service():
    db = Mock()
    return UserService(db)

def test_create_user_success(user_service):
    # Arrange
    user_data = {"email": "test@example.com"}
    
    # Act
    result = user_service.create(user_data)
    
    # Assert
    assert result.email == user_data["email"]
    assert result.id is not None

# tests/integration/test_auth_api.py
def test_login_endpoint(client, db_session):
    response = client.post("/auth/login", json={
        "email": "test@example.com",
        "password": "testpass"
    })
    
    assert response.status_code == 200
    assert "token" in response.json()
```

### TypeScript/React
```typescript
// tests/components/UserList.test.tsx
import { render, screen } from '@testing-library/react';

describe('UserList', () => {
  it('renders users correctly', () => {
    const users = [
      { id: 1, name: 'Alice' },
      { id: 2, name: 'Bob' }
    ];
    
    render(<UserList users={users} />);
    
    expect(screen.getByText('Alice')).toBeInTheDocument();
    expect(screen.getByText('Bob')).toBeInTheDocument();
  });
});
```

### E2E/Playwright
```typescript
// e2e/auth.spec.ts
import { test, expect } from '@playwright/test';

test('user can login', async ({ page }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('[type="submit"]');
  
  await page.waitForURL('/dashboard');
  await expect(page.locator('h1')).toContainText('Dashboard');
});
```

## Test Data Factories

```python
# tests/factories.py
def create_user(**kwargs):
    defaults = {
        "email": "test@example.com",
        "name": "Test User",
        "active": True
    }
    return User(**{**defaults, **kwargs})

def create_task(**kwargs):
    defaults = {
        "title": "Test Task",
        "status": "pending",
        "user": create_user()
    }
    return Task(**{**defaults, **kwargs})
```

## Coverage Guidelines

- **Unit Tests**: 80% coverage minimum
- **Integration**: Critical paths covered
- **E2E**: Happy path + key error cases
- **Performance**: Response time checks
- **Security**: Input validation tests

## Best Practices

1. **Test Independence**: Each test runs in isolation
2. **Clear Names**: describe_what_when_expected
3. **Fast Execution**: Mock external services
4. **Deterministic**: No random or time-dependent behavior
5. **Maintainable**: Update tests with code changes