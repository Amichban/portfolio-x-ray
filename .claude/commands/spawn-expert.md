---
name: spawn-expert
description: Create domain-specific expert agent from project context
tools: [Read, Write]
---

# Domain Expert Spawner

Create specialized agents based on your project's domain and requirements.

## Usage

```bash
/spawn-expert quant          # Financial/quantitative expert
/spawn-expert payments        # Payment processing expert
/spawn-expert privacy         # Data privacy expert
/spawn-expert ml             # Machine learning expert
/spawn-expert compliance      # Regulatory compliance expert
/spawn-expert [domain]        # Any domain you need
```

## Process

1. **Analyze Context**: Read project specification and current state
2. **Identify Expertise**: Determine required domain knowledge
3. **Generate Agent**: Create specialized agent configuration
4. **Configure Tools**: Set appropriate tools and permissions
5. **Add to Registry**: Enable agent for use

## Generated Agent Structure

```markdown
---
name: [domain]
description: Domain expert for [specific area]
tools: [Read, Write, Edit, Grep]
---

# [Domain] Expert

Specialized knowledge in [domain area].

## Expertise Areas
- [Specific expertise 1]
- [Specific expertise 2]
- [Specific expertise 3]

## Domain Guidelines
[Domain-specific best practices]

## Validation Checklist
- [ ] [Domain requirement 1]
- [ ] [Domain requirement 2]
- [ ] [Domain requirement 3]

## Common Patterns
[Domain-specific patterns and solutions]

## Regulatory/Standards
[Relevant standards, regulations, or requirements]
```

## Example Domains

### Quant/Finance
- Risk calculations
- Portfolio optimization
- Market data handling
- Backtesting strategies
- Performance metrics

### Payments
- PCI compliance
- Payment gateways
- Transaction processing
- Fraud detection
- Reconciliation

### Privacy/GDPR
- Data minimization
- Consent management
- Right to deletion
- Data portability
- Audit trails

### Healthcare/HIPAA
- PHI protection
- Access controls
- Audit logging
- Encryption requirements
- Breach procedures

### Machine Learning
- Model training
- Feature engineering
- Evaluation metrics
- Deployment patterns
- Monitoring drift

## Auto-Detection

The spawner can suggest experts based on your spec:
- Financial terms → quant expert
- Payment processing → payments expert
- Personal data → privacy expert
- Medical/health → healthcare expert
- AI/ML mentions → ml expert

## Integration

Spawned experts work with existing agents:
- Collaborate on domain-specific features
- Review code for domain compliance
- Suggest domain best practices
- Validate business logic

## Output Location

Created agents are stored in:
`.claude/agents/domain/[expert-name].md`

They become immediately available via:
`@[expert-name] Review this implementation`