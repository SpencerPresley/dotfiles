---
description: Enhanced query processing with full guidance stack - skills, clarification, and project context
allowed-tools: Bash(tree:*), Bash(fd:*), Bash(rg:*), Glob, Grep, Read, Skill, Task, TodoWrite
argument-hint: <your task>
---

# Enhanced Query Processing

## Your Task

$ARGUMENTS

## Pre-Processing Checklist

Complete ALL of these before taking action:

---

### 1. Skill Discovery

Use a layered search approach:

**Layer 1 - Structure with `tree`:**
```bash
tree -L 3 -d ~/.claude/plugins/cache 2>/dev/null | head -60
```
From directory names, identify anything with 1%+ chance of relevance.

**Layer 2 - Find files with `fd`:**
```bash
fd -t f "SKILL.md" ~/.claude/plugins/cache 2>/dev/null | head -30
```

**Layer 3 - Search content with `rg`:**
```bash
rg -l "<task-relevant-keyword>" ~/.claude/plugins/cache --glob "SKILL.md" 2>/dev/null
```

**Layer 4 - Read (fallback):**
Only if above layers insufficient, read first 20-30 lines of candidate files.

**Invoke with `Skill` tool:**
Discovery tools (tree/fd/rg) are for finding. Use `Skill` tool to invoke:
- `Skill(superpowers:brainstorming)` - design/ideation tasks
- `Skill(superpowers:systematic-debugging)` - bugs/errors
- `Skill(superpowers:test-driven-development)` - implementation
- `Skill(superpowers:verification-before-completion)` - before claiming done
- `Skill(ai-research-skills:langchain)` - LangChain work

For commands where you limit the results e.g., `[...] | head -30`: you should use that to get a general overview but then run them again with a more narrow scope to ensure you are thorough.

If a skill applies, announce it and invoke it before proceeding.

---

### 2. Project Context

Reference project guidance:
- @CLAUDE.md - Project instructions, conventions, and tool recommendations
- @AGENTS.md - Agent-specific guidance (if exists)

Pay attention to:
- Required tools (serena, context7, SearchDocsByLangChain, etc.)
- Code style requirements
- Testing requirements
- Any project-specific workflows

---

### 3. Clarification Check

For non-trivial tasks, briefly assess:
- What specific outcome does the user want?
- What's in scope vs out of scope?
- Are there multiple valid approaches?

**If ambiguous:** Ask ONE focused clarifying question before proceeding.
Format as multiple choice when possible.

**If clear:** State your interpretation in one sentence and proceed.

---

### 4. Task Tracking

If the task has 3+ distinct steps:
- Create a TodoWrite todo list
- Mark items in_progress as you work
- Mark completed immediately when done

---

### 5. Tool Selection

Consider which tools are best for this task:

| Need                       | Tool                                                        |
| -------------------------- | ----------------------------------------------------------- |
| Symbolic code navigation   | `serena` MCP (find_symbol, get_symbols_overview)            |
| LangChain/LangGraph docs   | `SearchDocsByLangChain` from docs-langchain MCP             |
| Other library docs         | `context7` MCP (resolve-library-id then get-library-docs)   |
| Codebase exploration       | Task tool with `subagent_type=Explore`                      |
| Complex reasoning          | `sequential-thinking` MCP                                   |
| Find code patterns         | `rg` for content, `fd` for files, `tree` for structure      |

---

### 6. Execution Guidelines

- **TDD for code changes:** Write failing test first, then implementation
- **Verify before completion:** Run tests/checks before claiming done
- **Code review for significant changes:** Use `Skill(superpowers:requesting-code-review)`

---

## Now Proceed

With skills invoked, context loaded, and approach clarified - execute the task.
