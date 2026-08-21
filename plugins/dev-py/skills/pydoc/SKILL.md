---
name: pydoc
description: Add/improve docstrings in Python files — Google style for functions and modules, argparse epilog examples for CLIs
argument-hint: <file_or_folder> (optional — if omitted, scan all *.py in the project)
---

Scope: `$ARGUMENTS` if given, else all `*.py` (skip `.venv`, `__pycache__`, `*.egg-info`). Write each file back, print one line per change. Don't touch logic.

**Functions** — Google style. Omit inapplicable sections. `_private`: one-liner only.
```python
def foo(bar: int) -> list[str]:
    """One-line summary.

    Args:
        bar (int): Description.

    Returns:
        list[str]: Description.
    """
```

**Modules**
```python
"""One-line summary.

Description:
    2-4 sentences.

Example:
    snippet
"""
```

**CLIs** — add epilog with runnable example:
```python
parser = argparse.ArgumentParser(
    epilog="example: my-command --flag value",
    formatter_class=argparse.RawDescriptionHelpFormatter,
)
```

**Logic blocks** — one comment above non-obvious `for`/`while`/multi-line `if`/call block, explaining *why* not *what*. Remove comments that restate the code.

Already compliant: print `✓ <filename> — no changes` and skip.
