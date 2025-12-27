---
description: Generate structured pre-plan analysis before implementation
allowed-tools: Read, Glob, Grep, Task
argument-hint: <code review, feature spec, or task description>
---

# Pre-Plan: Structured Analysis Before Implementation

Generate a structured pre-plan analysis to organize thinking before implementation. This is not about writing code or making changes - it's about understanding the problem space, identifying dependencies, and preparing for effective execution.

## Philosophy

Plan mode is powerful, but jumping straight in can lead to:

- Missed dependencies between tasks
- Unnecessary rework from addressing things in the wrong order
- Overlooked questions that block progress mid-implementation
- Scope creep from unclear boundaries

This pre-plan phase answers: **"What do I need to understand and decide before I start?"**

Think like an architect reviewing blueprints before construction begins. The goal is to surface everything that would cause you to pause, backtrack, or ask questions during implementation.

## Input Context

$ARGUMENTS

The input may be:

- A code review with findings and suggestions
- A feature request or specification
- A bug report with investigation notes
- An architectural decision that needs implementation
- Any complex task that benefits from structured thinking

**Read the input carefully.** Extract every discrete item, suggestion, question, and observation. Don't skip over implied work.

## Analysis Framework

### 1. Extract All Work Items

Systematically identify every piece of work mentioned or implied:

**Explicit items**: Things directly stated as needing change

- "Remove duplicate `review_task`"
- "Add `BaseConfig` to Atlas"

**Implicit items**: Work required to accomplish explicit items

- If aligning configs, may need to update dependent code
- If removing duplication, need to verify no behavioral differences

**Questions requiring decisions**: Items that can't proceed without answers

- "Is the divergence intentional?"
- "What's the intended relationship between X and Y?"

### 2. Categorize by Nature

Group items by what kind of work they represent:

**Breaking changes**: Would affect external consumers or require migration

- API signature changes
- Removed functionality
- Changed default behavior

**Internal refactors**: Improve code without changing external behavior

- Code deduplication
- Consistency alignment
- Pattern standardization

**Additions**: New capabilities or features

- New configuration options
- New abstractions or utilities

**Documentation/clarity**: No code change, improves understanding

- Adding comments
- Renaming for clarity
- Updating docstrings

### 3. Map Dependencies

For each item, ask:

- Does this depend on another item being completed first?
- Does this enable or unlock other items?
- Does this conflict with another item (mutually exclusive approaches)?
- Does this require a decision that affects multiple items?

Build a dependency graph. Look for:

- **Blocking decisions**: Questions that must be answered before multiple items can proceed
- **Foundation work**: Items that many others depend on
- **Leaf items**: Independent items that can be done in any order
- **Clusters**: Groups of related items that should be done together

### 4. Identify Blocking Questions

Surface questions that would halt implementation:

**Design questions**: Multiple valid approaches, need to choose

- "Should we use pattern A or pattern B?"
- "Is this intentional divergence or an oversight?"

**Scope questions**: Unclear boundaries

- "Should this include X or is that a separate effort?"
- "How far should consistency go?"

**Knowledge gaps**: Missing information needed to proceed

- "How is this currently used?"
- "What was the original reasoning?"

**Risk questions**: Concerns about impact

- "What would break if we change this?"
- "Is this used externally?"

### 5. Assess Effort and Risk

For significant items, note:

**Effort signals**:

- Touches many files
- Requires careful migration
- Has test implications
- Needs documentation updates

**Risk signals**:

- Public API changes
- Behavioral changes
- Cross-cutting concerns
- Removes functionality

### 6. Propose Sequencing

Based on dependencies and categories, suggest an order:

**Phase 0 - Decisions**: Questions that must be answered first
**Phase 1 - Foundation**: Items that others depend on
**Phase 2 - Core work**: Main implementation tasks
**Phase 3 - Polish**: Independent cleanup and consistency
**Phase 4 - Validation**: Testing and verification

Within phases, items can often be parallelized.

## Output Format

Structure your analysis as follows:

---

### Summary

2-3 sentences on what the input contains and the overall scope of work.

### Work Items Extracted

List every discrete item with a short identifier for reference:

```
[A] Short description of item A
[B] Short description of item B
...
```

Use consistent identifiers throughout the document.

### Blocking Questions

Questions that must be answered before implementation can proceed effectively. For each:

- The question
- Why it blocks (what items depend on the answer)
- Your recommendation if you have one

### Dependency Map

Describe the dependencies between items:

```
[A] -> [B], [C]  (A must happen before B and C)
[D] <-> [E]      (D and E are mutually exclusive)
[F]              (independent, can happen anytime)
```

Or describe in prose if more complex.

### Recommended Phases

Group items into logical phases with rationale:

**Phase 0: Decisions Required**

- Question 1 (blocks [A], [B])
- Question 2 (blocks [C])

**Phase 1: Foundation**

- [X] - rationale for doing this first
- [Y] - rationale

**Phase 2: Core Implementation**

- [A], [B], [C] - can be parallelized
- [D] - after [A] completes

**Phase 3: Polish**

- [E], [F] - independent cleanup

### Scope Boundaries

What's included vs. explicitly out of scope. Note any items that were mentioned but should be deferred.

### Risk Assessment

Items that warrant extra caution during implementation, with specific concerns.

### Notes for Implementation

Any other observations that would help during execution:

- Patterns to follow
- Gotchas to watch for
- Related code to be aware of
- Testing considerations

---

## Guidelines

**Be thorough**: Miss nothing from the input. It's better to list something trivial than to overlook something important.

**Be concrete**: Reference specific items, files, and concepts from the input. Avoid vague statements.

**Be opinionated**: If you have a recommendation, state it. The user can disagree.

**Be honest about uncertainty**: If dependencies are unclear or questions are speculative, say so.

**Don't solve problems yet**: This is analysis, not implementation. Note what needs to be figured out, don't figure it out.

**Preserve context**: Include enough detail that the pre-plan is useful on its own, without re-reading the original input.

## When to Ask Clarifying Questions

If the input is ambiguous about:

- Intended scope (fix everything vs. specific items)
- Priorities (what matters most)
- Constraints (timeline, breaking changes acceptable, etc.)
- Context (why this work is being done)

Ask before producing the pre-plan. A focused pre-plan is more useful than a comprehensive one that covers the wrong scope.
