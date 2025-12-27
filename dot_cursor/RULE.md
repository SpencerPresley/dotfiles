---
globs: "**/*.py"
alwaysApply: false
---

# Python Google Style Docstrings

When writing Python, always add Google style docstrings to the top of files, classes, methods, and functions.

## General Structure

\`\`\`python
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
\`\`\`

## Section Formatting

### Args Section

- Format: `param_name (type): description`
- Continuation lines align with the start of the description
- Include default values in description when relevant

\`\`\`python
Args:
name (str): The user's display name.
count (int): Number of retries. Defaults to 3.
config (dict[str, Any]): Configuration options. Must contain
at least a 'host' key.
\`\`\`

### Returns Section

- Format: `type: description` (no variable name)
- For multiple return values, document the tuple structure

\`\`\`python
Returns:
bool: True if the operation succeeded, False otherwise.
\`\`\`

\`\`\`python
Returns:
tuple[str, int]: A tuple containing the processed name and
the number of transformations applied.
\`\`\`

### Raises Section

- List all exceptions that the function explicitly raises
- Include inherited exceptions only if particularly relevant

\`\`\`python
Raises:
FileNotFoundError: If the specified path does not exist.
PermissionError: If the user lacks read permissions.
\`\`\`

## Code Examples in Docstrings

Use `.. code-block:: python` directive for examples:

\`\`\`python
"""Process and validate user input.

Transforms raw input into a normalized format suitable for storage.

.. code-block:: python

    result = process_input("  Hello World  ")
    print(result)  # "hello world"

    result = process_input("", strict=True)
    # Raises ValueError

Args:
text (str): The raw input text to process.
strict (bool): If True, raise on empty input. Defaults to False.

Returns:
str: The normalized, lowercase, stripped text.

Raises:
ValueError: If strict is True and text is empty.
"""
\`\`\`

## Class Docstrings

Document class purpose and any class-level attributes:

\`\`\`python
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

\`\`\`

## Module Docstrings

Place at the top of the file:

\`\`\`python
"""Utility functions for data transformation and validation.

This module provides helpers for normalizing, validating, and
transforming data structures used throughout the application.

.. code-block:: python

    from utils import normalize_record

    clean_data = normalize_record(raw_record)

"""
\`\`\`

## Additional Guidelines

- Always end the one-line summary with a period
- Leave a blank line between the summary and longer description
- Leave a blank line between the description and the first section
- Sections appear in order: Args, Returns, Yields, Raises, Examples
- Use backticks for inline code references: \`None\`, \`True\`
- Reference other classes/functions with backticks: \`SomeClass\`
