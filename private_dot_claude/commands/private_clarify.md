---
description: Clarify and expand user query before taking action
argument-hint: <your request>
---

# Query Clarification Protocol

## Original Request
$ARGUMENTS

## Before Taking Action

You MUST NOT start implementing until you've completed this clarification process:

### Step 1: Restate Understanding

In 2-3 sentences, explain what you understand the user is asking for.
Be specific about:
- The goal/outcome they want
- The scope (what's included vs excluded)
- Any constraints you infer

### Step 2: Identify Ambiguities

List anything unclear or that could be interpreted multiple ways:
- Technical choices that aren't specified
- Scope boundaries that are fuzzy
- Assumptions you're making
- Alternative interpretations

### Step 3: Ask Clarifying Questions

Ask 1-3 focused questions to resolve the most critical ambiguities.
Format as multiple choice when possible to make answering easy.

Structure questions from most to least important.

### Step 4: Wait for Response

**DO NOT proceed with implementation until the user confirms your **understanding**
or answers your questions.**

This is a hard stop. No "I'll assume X and proceed" - wait for explicit confirmation.

---

## Output Format

```
**My understanding:**
[2-3 sentence specific interpretation of what you think they want]

**Assumptions I'm making:**
- [assumption 1]
- [assumption 2]
- [assumption 3]

**Before I proceed, I need to clarify:**

1. [Most critical question - multiple choice if possible]
   - Option A: [description]
   - Option B: [description]

2. [Second question if needed]

3. [Third question if needed]
```

---

## When to Skip Clarification

You may skip this process ONLY if ALL of these are true:
- The request is completely unambiguous
- There is exactly one reasonable interpretation
- The scope is explicitly bounded
- No architectural or design decisions are needed

If in doubt, clarify.
