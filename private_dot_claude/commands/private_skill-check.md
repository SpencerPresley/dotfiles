---
description: Find relevant skills and apply them to your query
allowed-tools: Bash(tree:*), Bash(fd:*), Bash(rg:*), Glob, Grep, Read, Skill
argument-hint: <your task or question>
---

# Skill Discovery and Application

## Your Task

$ARGUMENTS

## Instructions

Before responding to the task above, you MUST complete skill discovery:

---

### Step 1: Get structure overview with `tree`

Start with a high-level view of skill directories:

```bash
tree -L 3 -d ~/.claude/plugins/cache 2>/dev/null | head -60
```

This shows the directory structure. From names alone, identify directories that have
even 1% chance of being relevant to: "$ARGUMENTS"

Look for patterns like:
- `skills/` directories
- Names matching task domain (debugging, testing, backend, etc.)
- Generic names that might contain useful guidance

---

### Step 2: Find skill files with `fd`

For promising directories identified in Step 1, locate SKILL.md files:

```bash
fd -t f "SKILL.md" ~/.claude/plugins/cache/<promising-path> 2>/dev/null
```

Or search all skills if unsure:

```bash
fd -t f "SKILL.md" ~/.claude/plugins/cache 2>/dev/null | head -30
```

---

### Step 3: Search skill content with `rg`

If you need to find skills by content/keywords rather than location:

```bash
rg -l "debugging|error|bug" ~/.claude/plugins/cache --glob "SKILL.md" 2>/dev/null
```

Or search for task-relevant terms:

```bash
rg -l "<relevant-keyword>" ~/.claude/plugins/cache --glob "*.md" 2>/dev/null | head -20
```

---

### Step 4: Read descriptions (fallback)

Only if tree/fd/rg didn't give enough info, read the first 20-30 lines of candidate SKILL.md files to check descriptions and "When to Use" sections.

---

### Step 5: Select and invoke skill

If a skill is relevant:

1. **Announce:** "I'm using [skill-name] for this task"
2. **Invoke with the `Skill` tool** - e.g., `Skill(superpowers:brainstorming)`
3. **Follow the skill's instructions exactly**

**Important:** tree/fd/rg are for DISCOVERY only. When you decide to use a skill,
invoke it with the `Skill` tool, NOT by reading files manually.

Skill tool format: `Skill(plugin-name:skill-name)`

Examples:
- `Skill(superpowers:brainstorming)`
- `Skill(superpowers:systematic-debugging)`
- `Skill(superpowers:test-driven-development)`
- `Skill(ai-research-skills:langchain)`

---

### Step 6: Reference project guidance

Also consult:
- @CLAUDE.md for project-specific skill guidance and MCP tool recommendations
- @AGENTS.md if it exists for agent-specific patterns

---

### Step 7: Proceed with task

- If relevant skill found: Follow the skill's workflow
- If no relevant skill: Proceed with standard approaches, noting no specific skill applied

## Now execute the task using discovered skills and guidance
