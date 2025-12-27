# Docstring Style Enforcement Task

Analyze the provided file(s) for Google Style docstring compliance and fix any violations.

## Style Reference

The authoritative style guide is located at `.cursor/rules/RULE.md`. **You MUST read this file first** before analyzing any code.

## Pre-Analysis Steps

**Required before making any changes:**

1. **Read the style guide**: Fetch `.cursor/rules/RULE.md` to get the exact formatting requirements
2. **Read the target files**: Open each file specified in `{{input}}` to understand the code
3. **Systematically scan**: Check every module, class, function, and method for compliance

## Docstring Requirements Checklist

### Module Level

- [ ] Module docstring present at top of file (after imports but before code, or at very top)
- [ ] One-line summary ends with a period
- [ ] Longer description separated by blank line
- [ ] Code examples use `.. code-block:: python` directive

### Class Level

- [ ] Class docstring immediately after class definition
- [ ] One-line summary ends with a period
- [ ] Attributes section documents class-level attributes
- [ ] Code example shows typical usage

### Function/Method Level

- [ ] Docstring present for all public functions/methods
- [ ] One-line summary ends with a period
- [ ] Args section present if function has parameters
  - Format: `param_name (type): description`
  - Continuation lines align with description start
  - Default values mentioned in description
- [ ] Returns section present if function returns a value
  - Format: `type: description` (no variable name)
  - Tuple returns document the structure
- [ ] Raises section documents explicitly raised exceptions
- [ ] Yields section for generators (instead of Returns)

### Formatting Rules

- [ ] Blank line between summary and longer description
- [ ] Blank line between description and first section
- [ ] **CRITICAL - Section order**: Args, Returns, Yields, Raises, Examples (code blocks LAST)
- [ ] Inline code uses backticks: `None`, `True`, `SomeClass`
- [ ] No trailing whitespace in docstrings

## Common Violations to Look For

### Missing Docstrings

```python
# BAD: No docstring
def process_data(items):
    return [x * 2 for x in items]

# GOOD: Has docstring
def process_data(items):
    """Double each item in the input list.

    Args:
        items (list[int]): The items to process.

    Returns:
        list[int]: The processed items with values doubled.
    """
    return [x * 2 for x in items]
```

### Missing Period on Summary

```python
# BAD: No period
"""Process the input data"""

# GOOD: Has period
"""Process the input data."""
```

### Incorrect Args Format

```python
# BAD: Missing type, wrong format
"""
Args:
    name - the user's name
    count: number of items
"""

# GOOD: Correct format
"""
Args:
    name (str): The user's name.
    count (int): Number of items to process.
"""
```

### Incorrect Returns Format

```python
# BAD: Has variable name
"""
Returns:
    result (bool): Whether it succeeded.
"""

# GOOD: Type only
"""
Returns:
    bool: Whether the operation succeeded.
"""
```

### Missing Blank Lines

```python
# BAD: No blank line before Args
"""Process data.
Args:
    data (list): Input data.
"""

# GOOD: Blank line present
"""Process data.

Args:
    data (list): Input data.
"""
```

### Wrong Continuation Alignment

```python
# BAD: Continuation not aligned
"""
Args:
    config (dict[str, Any]): Configuration dictionary that must
    contain required keys.
"""

# GOOD: Aligned to description start
"""
Args:
    config (dict[str, Any]): Configuration dictionary that must
                             contain required keys.
"""
```

### Wrong Section Order (Code Examples Before Args/Returns)

Code examples (`.. code-block:: python`) must come LAST, after all other sections.

```python
# BAD: Code example placed BEFORE Args/Returns
"""Create a model from config.

Configures the model based on provided settings.

.. code-block:: python

    config = ModelConfig(model="llama3.2:3b")
    model = create_model(config)

Args:
    config (ModelConfig): The model configuration.

Returns:
    BaseChatModel: The configured model instance.
"""

# GOOD: Code example placed AFTER Args/Returns (sections in correct order)
"""Create a model from config.

Configures the model based on provided settings.

Args:
    config (ModelConfig): The model configuration.

Returns:
    BaseChatModel: The configured model instance.

.. code-block:: python

    config = ModelConfig(model="llama3.2:3b")
    model = create_model(config)
"""
```

## Execution Process

1. **Read Style Guide**: Fetch `.cursor/rules/RULE.md` to understand exact requirements

2. **Read Target Files**: Open all files specified in `{{input}}`

3. **Systematic Scan**: For each file, check in order:

   - Module-level docstring (top of file)
   - Each class definition
   - Each function/method definition
   - Note: Skip private methods (`_name`) unless they're complex
   - Note: Skip magic methods except `__init__`

4. **Identify Issues**: Build a list of violations:

   - Missing docstrings entirely
   - Summary line missing period
   - Missing Args/Returns/Raises sections
   - Incorrect formatting (alignment, blank lines)
   - Undocumented parameters
   - **Wrong section order** (code examples must come LAST, after Args/Returns/Raises)

5. **Apply Fixes**: For each issue:

   - Make the minimal change needed
   - Preserve existing docstring content where possible
   - Add missing sections
   - Fix formatting
   - Infer descriptions from code context and type hints

6. **Verify**: Re-read modified files to confirm all issues resolved

## Output Format

Provide your work as:

1. **Files Analyzed**: List of files reviewed with line counts
2. **Issues Found**: Categorized by type and severity
   - **Missing docstrings**: Module/class/function with no docstring
   - **Incomplete docstrings**: Missing Args/Returns/Raises sections
   - **Formatting violations**: Period missing, bad alignment, missing blank lines
3. **Changes Made**: For each file changed:
   - Location (line number, entity name)
   - What was fixed
   - Before/after snippets for non-trivial changes
4. **Summary**: Total issues found and fixed per file

## Important Notes

- **Preserve Intent**: When adding docstrings, infer purpose from code. If unclear, ask.
- **Type Hints**: Use types from type hints if present. Use lowercase generics (`list`, `dict`).
- **Private Functions**: Functions starting with `_` can have simpler docstrings or none if truly internal.
- **Property Methods**: Properties need docstrings describing what the property represents.
- **Magic Methods**: `__init__` should document args, others typically don't need docstrings.
- **Overrides**: Methods that override a parent can reference parent docstring or provide their own.

## Scope Control

If given a directory, process files in this order:

1. `__init__.py` files (module docstrings)
2. Main module files
3. Test files (lighter requirements - focus on test functions having basic docstrings)

For large directories, process in batches and confirm with user before continuing.

---

**Target**: {{input}}
