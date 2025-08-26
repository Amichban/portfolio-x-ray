---
name: user-story
description: Generate user stories with mandatory Gherkin acceptance criteria
tools: [Read, Write, Edit]
---

# User Story Generator

Creates comprehensive user stories with MANDATORY Gherkin format acceptance criteria.

## Usage

```bash
/user-story "As a [role], I want to [action] so that [benefit]"
/user-story --epic "Data Analytics"       # Create story within an epic
/user-story --template                    # Show story template
/user-story --from-issue #5              # Generate from GitHub issue
```

## What It Generates

### 1. User Story Document (WITH GHERKIN)

```markdown
# US-[NUMBER]: [Title]

## Story Statement
**As a** [role/persona]  
**I want to** [capability/action]  
**So that** [business value/benefit]

## Persona & Jobs-to-be-Done
- **Persona**: [Detailed user description]
- **Job**: When [situation], I want to [motivation], so I can [outcome]
- **Pain Points**: [Current frustrations]
- **Gains**: [Desired improvements]

## Hypothesis
We believe that **[this capability]**
For **[these users]**
Will achieve **[this measurable outcome]**
We'll know we're successful when **[specific metrics change]**

## Acceptance Criteria (GHERKIN FORMAT REQUIRED)

### AC1: [Main Happy Path]
```gherkin
Given I am a [role] with [permissions]
And [additional context]
When I [perform primary action]
And [additional action if needed]
Then I should [see primary outcome]
And [additional outcome]
But not [negative outcome]
```

### AC2: [Alternative Path]
```gherkin
Given [different context]
When [alternative action]
Then [alternative outcome]
```

### AC3: [Edge Case]
```gherkin
Given [edge condition]
When [action under edge condition]
Then [expected handling]
```

### AC4: [Error Handling]
```gherkin
Given [error condition]
When [action that triggers error]
Then I should see "[specific error message]"
And [recovery option should be available]
```

### AC5: [Performance]
```gherkin
Given [load condition]
When [performance-critical action]
Then response time should be less than [200ms]
And throughput should exceed [100 req/sec]
```

## Non-Functional Requirements (NFRs)

### Performance
- Response time: P95 < 200ms
- Throughput: > 100 req/sec
- Concurrent users: Support 1000

### Security
- Authentication: [Required/Optional]
- Authorization: [RBAC/ABAC]
- Data encryption: [At rest/In transit]
- Audit logging: [Required actions]

### Accessibility
- WCAG 2.2 Level AA compliant
- Keyboard navigation: Full support
- Screen reader: Tested with NVDA/JAWS
- Color contrast: 4.5:1 minimum

### Observability
- Metrics: [Key metrics to track]
- Logging: Structured JSON format
- Tracing: OpenTelemetry enabled
- Alerts: [Critical thresholds]

## Test Scenarios (BDD Format)

### Scenario 1: Happy Path
```gherkin
Feature: [Feature Name]
  Scenario: Successful [action]
    Given [precondition]
    When [user action]
    Then [expected result]
```

### Scenario 2: Data Validation
```gherkin
  Scenario Outline: Input validation
    Given I am on [page]
    When I enter "<input>" in [field]
    Then I should see "<result>"
    
    Examples:
      | input    | result                |
      | valid123 | Success              |
      | 123      | Letters required     |
      | abc      | Numbers required     |
      | empty    | Field is required    |
```

### Scenario 3: Error Recovery
```gherkin
  Scenario: Network failure handling
    Given I am performing [action]
    When network connection fails
    Then I should see "Connection lost" message
    And data should be saved locally
    And retry should happen automatically
```

## Technical Specifications

### API Endpoints
```yaml
- method: GET
  path: /api/v1/[resource]
  auth: Bearer token required
  response: 
    200: { data: [], pagination: {} }
    401: { error: "Unauthorized" }
    
- method: POST
  path: /api/v1/[resource]
  request: 
    body: { field1: string, field2: number }
    validation: [rules]
  response:
    201: { id: string, created_at: datetime }
    400: { errors: [field errors] }
```

### Database Changes
```sql
-- Migration required
ALTER TABLE [table_name] 
ADD COLUMN [column] TYPE;

-- Indexes for performance
CREATE INDEX idx_[name] ON [table]([column]);
```

## Dependencies
- **Blocked by**: [US-XXX]
- **Blocks**: [US-YYY]
- **Related**: [US-ZZZ]

## Definition of Ready (Must Pass /dor-check)
- [x] Gherkin acceptance criteria
- [x] NFRs specified
- [x] Test scenarios in BDD format
- [x] API contracts defined
- [x] Mockups available
- [x] Team questions answered

## Definition of Done (Must Pass /dod-check)
- [ ] All Gherkin scenarios passing
- [ ] NFRs validated
- [ ] Test coverage > 80%
- [ ] Performance benchmarks met
- [ ] Security scan passed
- [ ] Accessibility validated
- [ ] Code reviewed
- [ ] Documentation updated
```

### 2. Automated Gherkin Tests

```typescript
// tests/acceptance/us-[number].test.ts
import { test, expect } from '@playwright/test';

test.describe('US-[NUMBER]: [Title]', () => {
  test.describe('AC1: [Description]', () => {
    test('Given [context] When [action] Then [outcome]', async ({ page }) => {
      // Given
      await page.goto('/login');
      await setupContext();
      
      // When
      await page.click('[data-testid="action-button"]');
      
      // Then
      await expect(page.locator('[data-testid="result"]')).toBeVisible();
      await expect(page).toHaveURL('/success');
    });
  });
});
```

### 3. Living Documentation

The Gherkin scenarios serve as:
- Executable specifications
- Test automation scripts
- Living documentation
- Communication tool
- Quality gate

## MANDATORY: Gherkin Validation

All stories MUST have:
1. **Given** - Context/preconditions
2. **When** - Action/trigger
3. **Then** - Expected outcome
4. **And/But** - Additional steps

### ✅ VALID Gherkin
```gherkin
Given I am a logged-in admin
And I have permission to edit users
When I click "Edit" on user profile
And I change the email to "new@example.com"
And I click "Save"
Then I should see "User updated successfully"
And the user should receive a confirmation email
But the old email should not receive notifications
```

### ❌ INVALID (Not Gherkin)
```
- User can edit profile
- Email can be changed
- Confirmation sent
```

## Quality Gates

Story will be REJECTED if:
- No Gherkin format (automatic fail)
- NFRs missing (security/performance/accessibility)
- No hypothesis with metrics
- Test scenarios not in BDD format
- Score < 8.5 on `/spec-score`

## Integration Commands

```bash
# Validate Gherkin format
/gherkin-convert --validate US-001

# Check readiness
/dor-check US-001  # Must pass

# Generate tests from Gherkin
/acceptance-test US-001

# Convert to executable tests
/test-generate --gherkin US-001
```

## Best Practices

### DO ✅
- Write Gherkin BEFORE implementation
- Include concrete examples
- Cover happy path + edge cases + errors
- Make NFRs explicit
- Define success metrics

### DON'T ❌
- Skip Gherkin format
- Use vague language
- Forget NFRs
- Mix multiple behaviors
- Ignore test scenarios

## Story Quality Metrics

Each story tracked for:
- Gherkin compliance: 100% required
- NFR coverage: Must include all categories
- Test automation: Generated from Gherkin
- Hypothesis validation: Metrics defined
- DoR/DoD compliance: Both must pass

## Output Files

```
user-stories/
├── US-001-[title].md           # Full story with Gherkin
├── US-001-[title].feature      # Extracted Gherkin file
├── US-001-hypothesis.md        # Hypothesis & metrics
└── US-001-nfrs.yaml           # NFR specifications
```

## Enforcement

Stories without proper Gherkin will:
- Fail `/dor-check`
- Be blocked from development
- Not generate tests
- Score < 8.5 on quality
- Trigger alerts in CI/CD