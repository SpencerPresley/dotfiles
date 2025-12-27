---
description: High-level code quality review of libs/ directory
allowed-tools: Read, Glob, Grep, Bash(tree:*), Bash(fd:*), Task
argument-hint: (no arguments - reviews libs/ directory)
---

# Code Quality Review: libs/

Perform a thoughtful, high-level code quality review of the `libs/` directory. Focus on general impressions, architectural observations, and actionable insights rather than line-by-line nitpicks.

## Philosophy

This is not a checklist audit. Think like a senior engineer doing a codebase walkthrough with a colleague. The goal is to surface:

- **Big picture observations** about structure and organization
- **Patterns worth discussing** (good or questionable)
- **Consistency** across the packages
- **Developer experience** when working with this code
- **Areas that feel "off"** even if you can't articulate a specific rule violation

Trust your judgment. If something feels wrong, mention it.

## Pre-Review Exploration

Before forming opinions, explore the codebase:

1. **Read the directory structure** of each package in `libs/`:

   - `libs/core/` - Core abstractions and utilities
   - `libs/purplehaze/` - Security tooling agents (nmap, metasploit, tshark)

2. **Skim the `__init__.py` files** to understand public APIs

3. **Read representative files** from each package:

   - A state module
   - An agent module
   - A tools module
   - The config modules

4. **Check the pyproject.toml files** for dependencies and metadata

Don't rush this phase. Understanding the codebase is more valuable than a quick surface scan.

## Areas to Consider

### Architecture & Organization

- Does the package structure make sense?
- Is the separation between `core` and `purplehaze` clear and justified?
- Are responsibilities well-distributed or is there confusion about where things belong?
- Would a new developer understand how to navigate this?

### Consistency

- Do similar things look similar across packages?
- Are naming conventions consistent (files, classes, functions)?
- Do the packages feel like they were written by the same team?
- Are there unnecessary variations in how common tasks are done?

### API Design

- Are the public interfaces intuitive?
- Is it clear what's meant to be imported vs internal?
- Are there too many concepts a user needs to understand?
- Would you want to use these APIs?

### Code Patterns

- Are there patterns that seem overly clever or hard to follow?
- Is there unnecessary abstraction or indirection?
- Conversely, is there missing abstraction (copy-paste code)?
- How's the error handling philosophy?

### Dependencies & Coupling

- Are the packages appropriately decoupled?
- Does `core` feel like a true foundation, or is it pulling in domain-specific concerns?
- Are there circular or surprising dependencies?

### Testing

- Glance at the test directories. Do tests exist? Are they organized sensibly?
- Does the structure suggest tests are valued or an afterthought?

### Things That "Feel Off"

Sometimes code is technically correct but something feels wrong:

- Overly long files or functions
- Too many parameters
- Confusing control flow
- Magic strings or numbers
- Commented-out code
- TODO comments that suggest technical debt

Trust these instincts and mention them.

## What NOT to Focus On

- **Docstring formatting**: There's a separate command for that (`/fix-docstrings`)
- **Line-by-line style**: Don't nitpick indentation or quote styles
- **Theoretical issues**: Focus on things that would actually cause problems
- **Performance micro-optimization**: Unless there's an obvious issue

## Output Format

Write your review as prose, not a checklist. Organize it however makes sense for what you found. A reasonable structure might be:

### Overall Impressions

A few paragraphs on your general take. What's the vibe? Is this code you'd be happy to work in?

### What's Working Well

Highlight genuinely good patterns or decisions. Be specific about why they're good.

### Areas for Discussion

Things that warrant conversation. These aren't necessarily "wrong" but are worth thinking about. For each:

- What you observed
- Why it caught your attention
- A question or suggestion to consider

### Concrete Suggestions

If you have specific, actionable recommendations, list them here. But keep it to things that would meaningfully improve the codebase, not minor preferences.

### Questions

Things you're curious about or need clarification on to give better feedback.

## Tone

Be honest but constructive. The goal is a useful conversation, not a score. Praise what deserves praise. Be direct about problems but frame them as opportunities.

If the code is generally solid, say so. Don't manufacture issues to fill space.

---

**Scope**: `libs/` directory and its packages (`core`, `purplehaze`)
