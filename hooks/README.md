# Claude Code Guardrails System

## Overview

The Guardrails System provides comprehensive protection and control mechanisms to prevent Claude Code agents from "going crazy" - making unwanted changes, overwriting manual work, or performing dangerous operations.

## Features

### 🛡️ Protection Mechanisms

1. **Branch Protection**
   - Blocks direct modifications to main/master/production branches
   - Suggests creating feature branches for safe development

2. **Dangerous Command Blocking**
   - Prevents execution of destructive commands (rm -rf, sudo rm, etc.)
   - Blocks force pushes and hard resets
   - Protects against credential exposure

3. **File Protection**
   - Prevents modification of sensitive files (.env, secrets, keys)
   - Protects CI/CD configurations
   - Backs up gitignored files before modification

4. **Quality Gates**
   - Enforces minimum spec score (≥7.0) before implementation
   - Validates test coverage requirements
   - Checks for security considerations

### 📊 Monitoring & Tracking

1. **Operation Counting**
   - Tracks file operations per session
   - Alerts when thresholds exceeded
   - Prevents runaway modifications

2. **Event Logging**
   - Comprehensive logging of all hook events
   - Security event tracking (blocks, warnings)
   - Tool usage statistics

3. **Session Summaries**
   - Generates reports at session end
   - Lists modified files and checkpoints
   - Provides recommendations

### 🔄 Smart Checkpointing

1. **Automatic Commits**
   - Creates granular checkpoint commits
   - Preserves work history
   - Easy rollback capability

2. **Backup System**
   - Automatic backup of gitignored files
   - Configurable retention period
   - Metadata tracking

### 👥 Parallel Work Validation

1. **Agent Boundaries**
   - Ensures agents stay within assigned areas
   - Prevents file conflicts between parallel agents
   - Tracks agent performance metrics

## Installation

The guardrails system is automatically installed with the Solo Soft Factory template. To verify installation:

```bash
./hooks/guardrails-manager.sh status
```

## Configuration

Edit `.claude/settings.json` to customize:

```json
{
  "guardrails": {
    "protected_branches": ["main", "master", "production"],
    "dangerous_commands": ["rm -rf", "sudo rm"],
    "protected_files": [".env", "secrets/*"],
    "quality_thresholds": {
      "spec_score_minimum": 7.0,
      "max_operations_per_session": 50
    }
  }
}
```

## Usage

### Check System Status
```bash
./hooks/guardrails-manager.sh status
```

### Test Hooks
```bash
./hooks/guardrails-manager.sh test
```

### View Logs
```bash
./hooks/guardrails-manager.sh logs --tail 50
```

### View Statistics
```bash
./hooks/guardrails-manager.sh stats
```

### Reset Session
```bash
./hooks/guardrails-manager.sh reset
```

### Manage Backups
```bash
./hooks/guardrails-manager.sh backup --list
./hooks/guardrails-manager.sh backup --clean
```

## Hook Lifecycle

1. **user-prompt-validate.sh**
   - Validates user requests
   - Checks spec quality requirements
   - Suggests best practices

2. **pre-tool-guard.sh**
   - Blocks dangerous operations
   - Enforces branch protection
   - Validates file access

3. **post-tool-log.sh**
   - Creates checkpoint commits
   - Backs up modified files
   - Tracks tool usage

4. **session-summary.sh**
   - Generates session report
   - Archives session data
   - Provides recommendations

5. **subagent-cleanup.sh**
   - Validates parallel work
   - Checks agent boundaries
   - Tracks agent metrics

## Exit Codes

- `0`: Operation allowed/successful
- `2`: Operation blocked (critical)

## Blocking Behaviors

When a hook returns exit code 2, Claude Code will:
1. Receive the error message
2. Stop the current operation
3. Display suggestions to the user

## Security Events

The system tracks and logs:
- Blocked dangerous commands
- Protected file access attempts
- Branch protection violations
- Quality threshold breaches

## Best Practices

1. **Always work on feature branches**
   - Protects main branch integrity
   - Enables safe experimentation

2. **Commit frequently**
   - Checkpoint system creates granular commits
   - Easy to rollback if needed

3. **Monitor session operations**
   - Check status regularly
   - Review logs for warnings

4. **Use parallel agents wisely**
   - Define clear boundaries
   - Monitor for conflicts

## Troubleshooting

### Hooks not triggering
- Verify `.claude/settings.json` exists
- Check hook files are executable
- Review Claude Code logs

### Too many blocks
- Adjust thresholds in configuration
- Review protected patterns
- Check branch protection settings

### Performance issues
- Clean old backups regularly
- Archive old logs
- Reset session counters

## Examples

### Example: Blocked Dangerous Command
```bash
# Claude attempts: rm -rf /important
# Hook response:
{
  "decision": "block",
  "reason": "Dangerous command pattern detected",
  "message": "Command contains dangerous pattern: 'rm -rf'"
}
```

### Example: Protected Branch
```bash
# On main branch, Claude attempts file edit
# Hook response:
{
  "decision": "block",
  "reason": "Protected branch detected",
  "message": "Cannot modify protected branch 'main'"
}
```

### Example: Low Spec Score
```bash
# Spec score is 5.2, Claude attempts implementation
# Hook response:
{
  "decision": "warn",
  "reason": "Low specification quality score",
  "message": "Current spec score (5.2) is below minimum (7.0)"
}
```

## Contributing

To add new guardrails:
1. Add pattern to `.claude/settings.json`
2. Update relevant hook script
3. Test with `guardrails-manager.sh test`
4. Document in this README

## Support

For issues or suggestions:
- Check logs: `./hooks/guardrails-manager.sh logs`
- Review status: `./hooks/guardrails-manager.sh status`
- Reset if needed: `./hooks/guardrails-manager.sh reset --all`