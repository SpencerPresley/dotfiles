# Code Review Task

Review the provided file for code quality, potential issues, and improvement opportunities.

## Review Checklist

### Correctness & Logic
- [ ] Logic errors or edge cases not handled
- [ ] Off-by-one errors, null/None checks missing
- [ ] Race conditions or concurrency issues
- [ ] Resource leaks (file handles, connections, etc.)

### Code Quality
- [ ] Clear naming (variables, functions, classes)
- [ ] Appropriate function/method length (single responsibility)
- [ ] DRY violations (duplicated logic)
- [ ] Dead code or unused imports
- [ ] Overly complex conditionals or nesting

### Type Safety & Python Best Practices
- [ ] Type hints present and accurate
- [ ] Proper use of Optional, Union, Literal where appropriate
- [ ] f-strings over .format() or concatenation
- [ ] Context managers for resource handling
- [ ] Appropriate exception handling (not bare except)

### Documentation
- [ ] Docstrings for public functions/classes
- [ ] Complex logic explained with comments
- [ ] Module-level docstring if appropriate

### Performance
- [ ] Obvious inefficiencies (N+1 patterns, repeated computation)
- [ ] Appropriate data structures for the use case
- [ ] Generator expressions where memory matters

### Security (if applicable)
- [ ] Input validation
- [ ] No hardcoded secrets
- [ ] Safe string formatting (no SQL/command injection vectors)

## Target Environment

- **Python**: 3.10+ (features from 3.11/3.12/3.13 are acceptable)
- Use `|` union syntax over `Union[]`
- Use `list[]`, `dict[]` over `List[]`, `Dict[]` from typing

## Output Format

Provide your review as:

1. **Summary**: One paragraph overall assessment
2. **Critical Issues**: Must-fix problems (if any)
3. **Suggestions**: Recommended improvements
4. **Minor/Style**: Nitpicks and style suggestions
5. **Questions**: Clarifications about intent or requirements

For each issue, include:
- File location (line number or function name)
- What the problem is
- Why it matters
- Suggested fix (code snippet if helpful)
