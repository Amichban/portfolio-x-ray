# 🚀 Welcome to Solo Software Factory!

**Build production apps 10x faster with AI agents** - Let's get you started in under 5 minutes!

---

## 📋 Pre-flight Checklist

Before we begin, make sure you have:
- ✅ **Python** (3.9 to 3.13) - Check with: `python --version`
- ✅ **Node.js** (18+) - Check with: `node --version`  
- ✅ **Git** installed - Check with: `git --version`
- ✅ **Claude Code** installed - Check with: `claude --version`

Don't have everything? No worries! Our scripts will help you.

---

## 🎯 Quick Start (3 Simple Steps)

### Step 1: Make This YOUR Project (30 seconds)

```bash
./setup-new-project.sh
```

This friendly script will:
1. 📝 Ask for your project name
2. 🏗️ Let you choose your architecture:
   - **Full-Stack Web App** (React + API + Database)
   - **API Service Only** (Backend focused)
   - **Static Website** (Frontend only)
   - **Data Pipeline** (Processing focused)
   - **Custom** (You decide later)
3. 🎨 Personalize everything for your project
4. 🚀 Create your first Git commit

**What happens:** The template becomes YOUR project, with only the tools you need installed!

---

### Step 2: Verify Everything Works (1 minute)

```bash
# Check your Python is compatible
./check-python.sh

# Install dependencies (smart installer handles everything)
./install.sh

# Verify the AI guardrails are protecting you
./hooks/guardrails-manager.sh status
```

You should see:
- ✅ Configuration file exists
- ✅ All protection hooks installed
- ✅ Guardrails active

---

### Step 3: Start Building! (2 minutes)

```bash
# Start your development environment
make dev

# In a new terminal, open Claude Code
claude
```

Now tell Claude what you want to build:

```bash
# Example: Build a task management app
/spec-to-stories "I want a simple task app where users can create, complete, and delete tasks"

# Claude will:
# 1. Create user stories
# 2. Check quality (must score ≥ 7.0)
# 3. Identify what can be built in parallel
# 4. Start building with multiple AI agents
```

---

## 🎓 Your First Feature (Tutorial Mode)

Want to see the magic? Try this guided example:

```bash
# In Claude Code, type:
/user-story "As a user, I want to see a welcome message when I visit the homepage"

# Then:
/spec-score           # Check it's good enough to build
/gen-tests US-001     # Generate tests first
/story-ui US-001      # Build the UI in 4 safe steps
```

Watch as Claude:
- 🧪 Writes tests before code
- 🔨 Builds incrementally
- 🛡️ Protects you from mistakes
- 📝 Commits progress automatically

---

## 🛡️ AI Safety Features (Automatic!)

Your **Guardrails System** is already protecting you from:
- ❌ Accidental deletion of important files
- ❌ Breaking changes to main branch
- ❌ Overwriting your manual edits
- ❌ Dangerous commands (rm -rf, sudo, etc.)
- ❌ Exposing secrets or credentials

Check protection status anytime:
```bash
./hooks/guardrails-manager.sh status
```

---

## 🗺️ What's Next?

### For Beginners
1. **Follow the Tutorial**: Try the welcome message example above
2. **Read the Docs**: Check README.md for all commands
3. **Experiment Safely**: Guardrails prevent mistakes!

### For Pros
1. **Custom Architecture**: Use `/define-architecture` in Claude
2. **Parallel Development**: Use `/parallel-strategy` to maximize speed
3. **Domain Experts**: Spawn specialized agents with `/spawn-expert [domain]`

---

## 🔧 Customization Options

### Change Your Architecture Later
```bash
# If you need to switch architectures
./adaptive-install.sh --preset full-stack  # or api-only, static-site, etc.
```

### Fine-tune Guardrails
```bash
# Edit protection settings
nano .claude/settings.json

# Test your changes
./hooks/guardrails-manager.sh test
```

---

## 📚 Essential Commands Reference

| What You Want | Command to Use | What Happens |
|--------------|----------------|--------------|
| Define project structure | `/define-architecture` | Set up your tech stack |
| Create a feature | `/user-story "..."` | Generate a quality spec |
| Check quality | `/spec-score` | Ensure spec is good (≥7.0) |
| Build UI | `/story-ui US-001` | Build in 4 safe steps |
| Generate tests | `/gen-tests US-001` | Create comprehensive tests |
| Find parallel work | `/parallel-strategy` | Identify what to build simultaneously |
| Create GitHub issues | `/stories-to-github` | Sync with GitHub |

---

## ❓ Need Help?

### Quick Fixes

**Python Issues?**
```bash
./check-python.sh  # Diagnoses problems
./install.sh       # Smart fix for any Python version
```

**Guardrails Too Strict?**
```bash
# Temporarily work on a feature branch
git checkout -b feature/my-feature

# Or adjust settings
nano .claude/settings.json
```

**Not Sure What to Build?**
```bash
# In Claude, try:
/spec-to-stories "I want to learn by building a simple blog"
```

### Get More Help
- 📖 **Full Documentation**: See README.md
- 🤖 **AI Configuration**: Check CLAUDE.md (for Claude's reference)
- 🛡️ **Guardrails Guide**: Read hooks/README.md
- 💬 **In Claude**: Just type `/help`

---

## 🎉 You're Ready!

You now have:
- ✅ A personalized project setup
- ✅ AI agents ready to help
- ✅ Protection from common mistakes
- ✅ Professional development workflow

**Start building something amazing!** 🚀

---

*Pro tip: This file (START_HERE.md) can be deleted once you're comfortable. Everything important is in README.md!*