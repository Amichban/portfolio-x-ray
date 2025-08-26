# Spec & PRD Process with Claude Code

## Overview

This template uses an AI-driven specification process that transforms ideas into actionable development plans through GitHub Issues and Claude Code agents.

## The Process Flow

```mermaid
graph LR
    A[Idea] --> B[Intent Issue]
    B --> C[/scope Command]
    C --> D[Review Slices]
    D --> E[/accept-scope]
    E --> F[GitHub Issues Created]
    F --> G[Development]
```

## Step 1: Create an Intent Issue

Create a new GitHub Issue with your product idea or feature request. Use this template:

```markdown
# Intent: [Feature Name]

## Problem Statement
What problem are we solving? Who has this problem?

## Proposed Solution
High-level description of what we want to build.

## Success Criteria
- What does success look like?
- Key metrics or outcomes

## Constraints
- Budget: 
- Timeline:
- Technical limitations:

## User Stories (optional)
- As a [user], I want to [action] so that [benefit]

## Non-Goals
What are we explicitly NOT doing?
```

### Example Intent Issue:

```markdown
# Intent: Task Management System MVP

## Problem Statement
Small teams need a simple way to track tasks and projects without the complexity of enterprise tools.

## Proposed Solution
Web app for creating, assigning, and tracking tasks with basic project grouping.

## Success Criteria
- Users can create and assign tasks
- Tasks have status (todo/in-progress/done)
- Basic project grouping
- Works on mobile

## Constraints
- Budget: <$50/month hosting
- Timeline: 2 weeks
- Technical: Simple authentication, PostgreSQL

## User Stories
- As a user, I want to create tasks with descriptions
- As a user, I want to see all my assigned tasks
- As a user, I want to mark tasks as complete

## Non-Goals
- No complex workflows
- No time tracking (initially)
- No integrations with other tools
```

## Step 2: Generate Scope with AI

Run the `/scope` command with your Intent Issue URL:

```bash
/scope https://github.com/yourusername/repo/issues/1
```

The PM agent will:
1. Analyze your intent
2. Generate 4-8 vertical slices
3. Define acceptance criteria
4. Identify dependencies
5. Estimate complexity
6. **Propose agent allocation sequence for each slice**
7. **Analyze parallelization opportunities**
8. **Create Git branching strategy for parallel work**
9. Output `scope.json` and post a summary

## Step 3: Validate Specification Quality 🆕

Before proceeding, ensure your specification meets quality standards:

```bash
# Required: Check for issues
/spec-lint

# If issues found, enhance the spec
/spec-enhance

# Define all technical terms
/define-terms

# Verify quality score (must be >= 7.0)
/spec-score

# Example output:
# Overall Score: 8.5/10 ✅
# - Clarity: 9/10
# - Completeness: 8/10
# - Ready for development
```

**Quality Gate**: Score must be >= 7.0 to proceed

### What's a Vertical Slice?

A vertical slice is an end-to-end feature that delivers value:
- ✅ Database schema changes
- ✅ API endpoints
- ✅ Frontend UI
- ✅ Tests
- ✅ Documentation

Example slice:
```json
{
  "id": "create-task",
  "title": "Task creation flow",
  "summary": "Users can create tasks with title, description, and assignee",
  "acceptance_criteria": [
    "Form validates required fields",
    "Tasks persist to database",
    "Shows in task list immediately",
    "Sends notification to assignee"
  ],
  "estimate": "M",
  "risk": "Low"
}
```

## Step 4: Review Parallelization Strategy (Optional)

Review how to maximize efficiency through parallel work:

```bash
/parallel-strategy
```

This shows you:
- Which slices can be worked on simultaneously
- Recommended Git branching strategy
- Work tracks that can run in parallel
- Specific commands to create branches

Example output:
```
Currently Available (No blockers):
✅ Ready to start:
- auth-backend: Authentication API
- monitoring: Basic Dashboard

Parallel Tracks:
Track 1: Backend Pipeline
- auth-backend → user-management → sessions

Track 2: Frontend Components  
- auth-ui → dashboard → reports

Git Workflow:
git checkout -b feature/auth-backend
git checkout -b feature/monitoring
```

## Step 4: Review Agent Allocations (Optional)

Review the proposed agent sequence for each slice:

```bash
/review-agents
```

This shows you the recommended development sequence:
- Which agents to use
- In what order
- What each agent should accomplish

You can:
- Accept the proposed sequence
- Edit/reorder agents
- Add or remove agents
- Skip this step to use default allocations

## Step 5: Review and Refine Scope

Review the generated scope. You can:
- Edit the scope.json manually
- Re-run `/scope` with more details
- Add comments to the Intent Issue

## Step 6: Accept and Create Issues

When satisfied, comment on the Intent Issue:

```
/accept-scope
```

This triggers GitHub Actions to:
1. Create individual GitHub Issues for each slice
2. Add them to your GitHub Project
3. Set initial status to "Todo"
4. Link back to the Intent Issue

## Step 7: Work the Slices (With Parallelization!)

For each slice issue:

1. **Select the issue**: `/issue #5`
2. **Check the Development Sequence** section in the issue
3. **Follow the recommended agent sequence** or adjust as needed

### With Agent Recommendations:
```bash
/issue #5
# Issue shows recommended sequence:
# 1. /architect - Design auth flow
# 2. /dba - Create user tables
# 3. /backend - Implement login endpoint
# 4. /frontend - Create login form
# 5. /security - Review implementation

# Follow the sequence:
/architect Design the authentication flow
/dba Create user and session tables
/backend Implement login endpoint with JWT
/frontend Build login form component
/security Review auth implementation
```

### Without Recommendations (Manual):
```bash
/issue #5
# Decide which agents to use based on the task
/dba Create schema for holdings table
/backend Implement POST /api/holdings endpoint
/frontend Create AddHolding component with form
/backend Write tests for holdings endpoint
```

## Step 8: PM Sync

The PM Sync workflow runs every 30 minutes to:
- Update issue statuses based on PR activity
- Flag blockers
- Track velocity
- Update PROJECT_STATE.md

## Advanced: Custom Agents for Your Domain

Create domain-specific agents in `.claude/agents/`:

```markdown
---
name: domain-expert
description: Specialist for your specific domain
tools: [Read, Edit, Bash]
---

Expertise:
- Domain-specific knowledge
- Industry best practices
- Compliance requirements
- Performance optimization

Rules:
- Follow domain conventions
- Ensure data integrity
- Handle edge cases gracefully
```

## Tips for Better Specs

1. **Be specific about constraints** - The AI works better with clear boundaries
2. **Include examples** - Show sample data or UI mockups
3. **Define success metrics** - What does "done" look like?
4. **Start small** - Better to ship MVP and iterate
5. **Use domain language** - The agents learn from your terminology

## Monitoring Progress

Check progress at any time:
- `/issues` - List all issues and status
- View GitHub Project board
- Check `.claude/PROJECT_STATE.md`
- Review PM Sync comments on issues

## Example Commands Flow

```bash
# Start new feature
/scope https://github.com/user/repo/issues/10

# Review and accept
/accept-scope

# Start development
/issue #15
/architect How should we structure the task service?
/backend Implement the task CRUD operations
/frontend Build the task list view

# Check progress
/issues
/pm What's blocking the task management feature?
```

## Making it a GitHub Template

To make this repo a template for future projects:

1. Go to Settings → General
2. Check "Template repository"
3. Future projects: "Use this template" → Create new repository
4. Each project gets its own Issues, Project board, and customization

---

Now you're ready to turn any idea into working software with AI-driven development!