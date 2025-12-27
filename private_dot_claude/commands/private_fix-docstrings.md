---
description: Analyze files for Google Style docstring compliance and fix violations
allowed-tools: Read, Edit, Write, Glob, Grep
argument-hint: <file or directory path>
---

# Docstring Style Enforcement Task

Analyze the provided file(s) for Google Style docstring compliance and fix any violations.

## Target

$ARGUMENTS

## Pre-Analysis Steps

**Required before making any changes:**

1. **Review the style reference below** to understand exact formatting requirements
2. **Read the target files** to understand the code
3. **Systematically scan**: Check every module, class, function, and method for compliance

---

## Style Reference: Google Style Docstrings

### General Structure

```python
"""Short one-line summary ending in a period.

Longer description that can span multiple lines. This section provides
additional context, explains the purpose, and documents any important
behavior or side effects.

Args:
    param_name (type): Description of the parameter. If the description
                       is too long, continue on the next line with
                       indentation aligned to the start of the description.
    another_param (dict[str, int]): Another parameter description.

Returns:
    type: Description of the return value. Use just the type when there
          is no variable name to reference.

Raises:
    ValueError: Description of when this exception is raised.
    TypeError: Description of when this exception is raised.
"""
```

### Section Formatting

#### Args Section
- Format: `param_name (type): description`
- Continuation lines align with the start of the description
- Include default values in description when relevant

```python
Args:
    name (str): The user's display name.
    count (int): Number of retries. Defaults to 3.
    config (dict[str, Any]): Configuration options. Must contain
                             at least a 'host' key.
```

#### Returns Section
- Format: `type: description` (no variable name)
- For multiple return values, document the tuple structure

```python
Returns:
    bool: True if the operation succeeded, False otherwise.
```

```python
Returns:
    tuple[str, int]: A tuple containing the processed name and
                     the number of transformations applied.
```

#### Raises Section
- List all exceptions that the function explicitly raises
- Include inherited exceptions only if particularly relevant

```python
Raises:
    FileNotFoundError: If the specified path does not exist.
    PermissionError: If the user lacks read permissions.
```

### Code Examples in Docstrings

Use `.. code-block:: python` directive for examples:

```python
"""Process and validate user input.

Transforms raw input into a normalized format suitable for storage.

Args:
    text (str): The raw input text to process.
    strict (bool): If True, raise on empty input. Defaults to False.

Returns:
    str: The normalized, lowercase, stripped text.

Raises:
    ValueError: If strict is True and text is empty.

.. code-block:: python

    result = process_input("  Hello World  ")
    print(result)  # "hello world"

    result = process_input("", strict=True)
    # Raises ValueError
"""
```

### Class Docstrings

Document class purpose and any class-level attributes:

```python
class DataProcessor:
    """Handles batch processing of incoming data streams.

    This class manages connection pooling, retry logic, and result
    aggregation for processing large datasets efficiently.

    Attributes:
        batch_size (int): Number of items processed per batch.
        max_retries (int): Maximum retry attempts for failed items.

    .. code-block:: python

        processor = DataProcessor(batch_size=100)
        results = processor.run(data_stream)
    """
```

### Module Docstrings

Place at the top of the file:

```python
"""Utility functions for data transformation and validation.

This module provides helpers for normalizing, validating, and
transforming data structures used throughout the application.

.. code-block:: python

    from utils import normalize_record

    clean_data = normalize_record(raw_record)
"""
```

### Additional Guidelines

- Always end the one-line summary with a period
- Leave a blank line between the summary and longer description
- Leave a blank line between the description and the first section
- **Section order**: Args, Returns, Yields, Raises, Examples (code blocks LAST)
- Use backticks for inline code references: `None`, `True`
- Reference other classes/functions with backticks: `SomeClass`

---

## Docstring Requirements Checklist

### Module Level

- [ ] Module docstring present at top of file
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

---

## Common Violations to Look For

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

### Wrong Section Order

Code examples (`.. code-block:: python`) must come LAST, after all other sections.

```python
# BAD: Code example placed BEFORE Args/Returns
"""Create a model from config.

.. code-block:: python

    model = create_model(config)

Args:
    config (ModelConfig): The model configuration.

Returns:
    BaseChatModel: The configured model instance.
"""

# GOOD: Code example placed AFTER Args/Returns
"""Create a model from config.

Args:
    config (ModelConfig): The model configuration.

Returns:
    BaseChatModel: The configured model instance.

.. code-block:: python

    model = create_model(config)
"""
```

---

## Execution Process

1. **Read Target Files**: Open all files specified in the target

2. **Systematic Scan**: For each file, check in order:
   - Module-level docstring (top of file)
   - Each class definition
   - Each function/method definition
   - Note: Skip private methods (`_name`) unless they're complex
   - Note: Skip magic methods except `__init__`

3. **Identify Issues**: Build a list of violations:
   - Missing docstrings entirely
   - Summary line missing period
   - Missing Args/Returns/Raises sections
   - Incorrect formatting (alignment, blank lines)
   - Undocumented parameters
   - Wrong section order (code examples must come LAST)

4. **Apply Fixes**: For each issue:
   - Make the minimal change needed
   - Preserve existing docstring content where possible
   - Add missing sections
   - Fix formatting
   - Infer descriptions from code context and type hints

5. **Verify**: Re-read modified files to confirm all issues resolved

## Output Format

Provide your work as:

1. **Files Analyzed**: List of files reviewed with line counts
2. **Issues Found**: Categorized by type and severity
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
