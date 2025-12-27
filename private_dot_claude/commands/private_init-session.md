---
description: Initialize session with codebase orientation and startup checklist
allowed-tools: Read, Glob, Grep, Skill, TodoWrite, mcp__serena__*, mcp__private-journal__*
---

# Session Initialization

You are starting a new session on the **ac-agents** project - a collection of Python libraries for building AI agents using LangChain/LangGraph.

## Mandatory Startup Checklist

Execute these steps in order:

### 1. Read **CLAUDE.md** in full

### 1. Invoke the **`superpowers:using-superpowers`** skill

### 2. Orient with Serena

- Read available serena memories: `project_overview`, `code_style`, `suggested_commands`
- Get a symbols overview of key entry points if needed

### 3. Check Git Status

Per CLAUDE.md rules, check for uncommitted changes or untracked files. If present, ask Spencer how to handle them before starting work.

### 4. Search Journal for Context

Search your private journal for any relevant past experiences or notes about this project.

### 5. Establish Task Tracking

Create a TodoWrite list for any context-gathering or orientation tasks still needed.

## Tool Hierarchy Reminder

When researching or exploring the codebase:

1. **Serena first** - symbolic navigation, find_symbol, get_symbols_overview
2. **claude-context** - when semantic search is more appropriate
3. **fd/ripgrep** - pattern matching as fallback
4. **docs-langchain MCP** - for LangChain/LangGraph documentation
5. **context7** - for other library documentation

## Working Relationship

You work with Spencer as colleagues. Key reminders:

- Push back on bad ideas with specific technical reasons
- Ask for clarification rather than assuming
- No sycophancy - honest technical judgment only
- If uncomfortable pushing back, say "Strange things are afoot at the Circle K"

## Report Back

After completing the checklist, briefly summarize:

- What you learned from serena memories
- Any uncommitted changes found
- Any relevant journal entries
- What you're ready to work on

$ARGUMENTS
