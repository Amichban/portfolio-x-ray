---
name: test-plan
description: Generate comprehensive test plan for a user story
tools: [Read, Write]
---

# Test Plan Generator

Create a structured test plan from user stories and acceptance criteria.

## Usage

```bash
/test-plan US-001
/test-plan "Create user authentication"
```

## Process

1. **Analyze Story**: Read acceptance criteria and requirements
2. **Identify Test Cases**: Unit, integration, E2E scenarios  
3. **Edge Cases**: Boundary conditions, error paths
4. **Performance**: Response time, load considerations
5. **Security**: Auth, validation, injection prevention

## Output Format

```markdown
# Test Plan: [Story ID]

## Unit Tests
- [ ] Function: validate_email() - valid/invalid formats
- [ ] Function: hash_password() - correct hashing
- [ ] Class: UserService.create() - user creation logic

## Integration Tests  
- [ ] POST /auth/register - successful registration
- [ ] POST /auth/register - duplicate email handling
- [ ] POST /auth/login - valid credentials
- [ ] POST /auth/login - invalid credentials

## E2E Tests
- [ ] User registration flow - complete journey
- [ ] Login and access protected route

## Edge Cases
- [ ] Empty inputs
- [ ] SQL injection attempts
- [ ] Rate limiting behavior
- [ ] Concurrent requests

## Performance Targets
- Registration: < 500ms p95
- Login: < 200ms p95
- Token validation: < 50ms p95

## Test Data Required
- Valid user fixtures
- Invalid input examples
- Token samples
```

## Best Practices

- Cover all acceptance criteria
- Include negative test cases
- Test boundaries and limits
- Consider security implications
- Keep tests maintainable