---
name: test-fixit
description: Analyze and fix failing tests
tools: [Read, Edit, Grep]
---

# Test Fix Assistant

Diagnose test failures and provide minimal fixes.

## Usage

```bash
/test-fixit                           # Analyze recent test output
/test-fixit .claude/out/test-report.txt  # Specific report
/test-fixit "test_user_creation"     # Fix specific test
```

## Process

1. **Parse Failure**: Extract error messages and stack traces
2. **Identify Root Cause**: Common patterns:
   - Assertion failures
   - Missing mocks/fixtures
   - Timing issues
   - Environment differences
   - Schema changes
3. **Propose Fix**: Minimal change to make test pass
4. **Verify Logic**: Ensure test still validates correctly

## Common Fixes

### Assertion Failures
```python
# Before: Test expects old behavior
assert response.json()["status"] == "active"

# After: Updated for new behavior
assert response.json()["status"] == "pending"
```

### Missing Fixtures
```python
# Add missing test data
@pytest.fixture
def user_fixture():
    return {"id": 1, "email": "test@example.com"}
```

### Async/Timing Issues
```python
# Add proper waits
await asyncio.sleep(0.1)  # Allow background task
# Or use explicit wait
await wait_for_condition(lambda: item.processed)
```

### Environment Issues
```python
# Use test-specific config
os.environ["DATABASE_URL"] = "sqlite:///:memory:"
```

## Output Format

```markdown
## Test Failure Analysis

### Failed Test: test_user_creation
**Error**: KeyError: 'user_id'
**Root Cause**: API response structure changed
**Fix**: Update assertion to use 'id' instead of 'user_id'

### Diff:
\`\`\`diff
- assert response.json()["user_id"] == 1
+ assert response.json()["id"] == 1
\`\`\`
```

## Best Practices

- Fix the test, not the code (unless code is wrong)
- Keep fixes minimal and focused
- Maintain test intent
- Add comments explaining non-obvious fixes
- Run full suite after fixing