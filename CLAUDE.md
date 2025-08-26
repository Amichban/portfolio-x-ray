# CLAUDE.md - AI Assistant Configuration

This file configures Claude Code for your project. It's automatically loaded when Claude starts.

## Core Principles

1. **Quality First**: All specs must score ≥ 7.0 before implementation
2. **Incremental Development**: Build UI in 4 steps, test at each phase
3. **Parallel Work**: Identify and execute parallel development opportunities
4. **GitHub Integration**: Sync stories with issues and project boards

## Memory & Context

The template uses adaptive memory management:
- **Decisions**: Stored in `.claude/DECISIONS.md`
- **Patterns**: Learned and stored in `.claude/PATTERNS.md`
- **State**: Current progress in `.claude/STATE.md`

Context is automatically managed based on your current work.

## Available Commands

Essential commands (15 total):
- `/define-architecture` - Define project architecture
- `/spec-score` - Check specification quality
- `/user-story` - Create user story
- `/spec-to-stories` - Generate multiple stories
- `/story-ui` - Build UI incrementally
- `/gen-tests` - Generate tests
- `/test-plan` - Create test plan
- `/test-fixit` - Fix failing tests
- `/parallel-strategy` - Find parallel work
- `/spawn-expert` - Create domain expert
- `/issue` - Work on GitHub issue
- `/issues` - List GitHub issues
- `/stories-to-github` - Create GitHub issues
- `/db-setup` - Database setup
- `/spec-enhance` - Improve specifications

## Agents

Core agents (7) plus domain experts:
- **pm** - Product management & parallel work analysis
- **architect** - System design decisions
- **backend** - API development
- **frontend** - UI development
- **dba** - Database design
- **qa** - Testing and quality assurance
- **security** - Security review
- **[domain experts]** - Spawned as needed via `/spawn-expert`

## Project Structure

The template adapts to your project type. Common structures:
```
apps/api/         # Backend (if API detected)
apps/web/         # Frontend (if UI detected)
user-stories/     # Requirements
.claude/          # AI configuration
```

## Best Practices

### Always
- Start with user stories
- Check quality score before building
- Test incrementally
- Commit with story references (e.g., "feat: Add auth (US-001)")
- Identify parallel work opportunities

### Never
- Skip quality checks (< 7.0 score)
- Build complete features without testing
- Commit secrets or credentials
- Work on multiple stories simultaneously without planning

## Testing Commands

```bash
# Run tests based on your stack
make test          # If Makefile exists
npm test           # For Node.js projects
pytest             # For Python projects
```

## Security & Guardrails

### Security
- Pre-commit hook scans for secrets
- Never commit credentials
- Use environment variables for sensitive data

### Agent Guardrails System
The template includes comprehensive guardrails to prevent agents from making unwanted changes:

**Active Protections:**
- Branch protection (blocks main/master edits)
- Dangerous command blocking (rm -rf, sudo, etc.)
- Sensitive file protection (.env, secrets, keys)
- Quality gates (spec score ≥ 7.0 enforcement)
- Operation limits (max 50 file operations per session)
- Automatic checkpointing for rollback
- Gitignored file backups

**Hook System:**
All agent operations pass through validation hooks:
- `user-prompt-validate.sh` - Validates requests and suggests best practices
- `pre-tool-guard.sh` - Blocks dangerous operations before execution
- `post-tool-log.sh` - Creates checkpoints and backups
- `session-summary.sh` - Generates session reports
- `subagent-cleanup.sh` - Validates parallel work boundaries

**Management:**
```bash
./hooks/guardrails-manager.sh status  # Check system status
./hooks/guardrails-manager.sh test    # Test guardrails
./hooks/guardrails-manager.sh logs    # View activity
```

Configuration in `.claude/settings.json` allows customization of all thresholds and protected patterns.

---

*This file configures Claude's behavior. Users should read README.md for usage instructions.*