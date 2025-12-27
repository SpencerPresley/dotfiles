# LangChain/LangGraph Code Review Task

Review the provided file for code quality, potential issues, and alignment with current LangChain/LangGraph patterns.

## Available Tools

You have MCP tools available—**use them liberally**:

- **LangChain MCP**: Search LangChain, LangGraph, and deep-agents documentation
- **Context7 MCP**: Search Pydantic and general Python library documentation
- **Web Search**: Investigate patterns, best practices, recent changes

**Do not rely on cached knowledge.** Fetch current documentation to verify patterns.

## Target Versions

For a source of truth, see:
- pyproject.toml
- libs/core/pyproject.toml
- libs/purplehaze/pyproject.toml
- libs/atlas/pyproject.toml

In general:

langchain==1.1.3
langchain-core==1.2.0
langgraph==1.0.5
langgraph-checkpoint==3.0.1
langgraph-prebuilt==1.0.5
langgraph-sdk==0.3.0
langsmith==0.4.59
langchain-ollama==1.0.1
langchain-anthropic==1.3.0
langchain-openai==1.1.3
deepagents==0.3.0
pydantic==2.12.5
Python==3.10+ (3.11/3.12/3.13 features allowed)

When in doubt, check the source code for the latest version.

## Review Checklist

### LangChain/LangGraph Patterns

Search LangChain MCP for current patterns before flagging issues:

- [ ] Message types: Is `AnyMessage` vs `BaseMessage` used correctly for serialization?
- [ ] State management: Does it align with `MessagesAnnotation`, `add_messages` reducer patterns?
- [ ] Tool definitions: Using `@tool` decorator correctly? Proper type hints on tool functions?
- [ ] Graph structure: Appropriate use of nodes, edges, conditional edges?
- [ ] Checkpointing: Compatible with `JsonPlusSerializer`? Thread ID handling?
- [ ] Streaming: Aligned with current stream modes (`values`, `updates`, `messages`, `custom`)?

### Pydantic Patterns

Search Context7 for Pydantic best practices:

- [ ] `model_config` usage (ConfigDict vs class Config)
- [ ] Field definitions (Field() vs default values)
- [ ] Serialization: `model_dump()` with appropriate mode ("json", "python")
- [ ] Generic models: TypeVar bounds, SerializeAsAny usage
- [ ] Discriminated unions where appropriate
- [ ] Avoiding `arbitrary_types_allowed=True` if possible

### General Code Quality

- [ ] Type hints present and accurate
- [ ] Clear naming and single responsibility
- [ ] Proper exception handling
- [ ] Resource management (async context managers if async)
- [ ] No deprecated patterns (check docs for deprecations)

### Serialization & Storage Compatibility

- [ ] JSON-serializable for PostgreSQL JSONField
- [ ] Celery task result compatible
- [ ] Datetime handling (timezone-aware if needed)

### Documentation

- [ ] Docstrings with usage examples
- [ ] Type information in docstrings matches actual types
- [ ] Module-level docstring explaining purpose

## Investigation Queries

Run these searches to inform your review:

**LangChain MCP:**

Run numerous parallel searches. The langchain mcp allows you to search all documentation under the langchain namespace including:
- langchain
- langgraph
- deepagents

Within those is also the JS versions, construct your queries to target the python version since that is what we are using.

Some example queries:
- "AnyMessage BaseMessage serialization langgraph"
- "langgraph state TypedDict vs Pydantic"
- "langgraph checkpoint serialization"
- "create_agent vs create_react_agent langchain v1"
- "tool decorator langchain type hints"

These are only example queries. Do not limit yourself to these.

Always think through what queries to run, you should run as many as needed. Lean on the side of running more searches.

---

**Context7 (Pydantic):**

Context7 mcp provides up to date documentation for numerous libraries. The most applicable use case here is for Pydantic. But if you believe another library is relevant, you absolutely should run searches against that library.

Some example queries:
- "pydantic v2 model_dump mode json"
- "pydantic generic TypeVar bound serialization"
- "pydantic ConfigDict arbitrary_types_allowed"

These are only example queries. Do not limit yourself to these.

---

**Web Search:**

Web search can provide filler that others cannot such as general python patterns, design patterns, best practices, or anything else that's not covered by the other MCP tools.

These are only example queries. Do not limit yourself to these.

Always think through what queries to run, you should run as many as needed. Lean on the side of running more searches.

The current year is 2025. For any web searches where you plan to include a year, use 2025.

Reason for this is because the langchain and pydantic libraries move fast, 2024 searches will not be relevant to the current codebase.

---

## Output Format

1. **Summary**: Overall assessment and alignment with LangChain patterns
2. **Documentation Findings**: What you learned from MCP searches that's relevant
3. **Critical Issues**: Must-fix problems
4. **Pattern Misalignments**: Where code diverges from current LangChain/LangGraph patterns
5. **Suggestions**: Recommended improvements with code examples
6. **Minor/Style**: Nitpicks
7. **Questions**: Clarifications needed

For each issue:
- Location (line/function)
- Current code behavior
- Recommended pattern (with doc reference if found)
- Suggested fix

## Important Notes

- LangChain v1 introduced `create_agent` replacing `create_react_agent` from langgraph.prebuilt
- LangGraph v1 is stability-focused with unchanged core APIs
- deep-agents uses middleware architecture (TodoList, Filesystem, SubAgent)
- Pydantic v2 uses `model_dump()` not `.dict()`, `model_validate()` not `.parse_obj()`
- Python 3.11+: Use `|` for unions, lowercase generics (`list[]` not `List[]`)

---

## Clarifying Questions

If you are unsure about something or want to confirm something, ask clarifying questions.

You may ask clarifying questions or general questions to me. Feel free to do so. The more you ask, the better the review will be.
