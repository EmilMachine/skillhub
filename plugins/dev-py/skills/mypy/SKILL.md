---
name: mypy
description: Run mypy on Python files and fix type errors — single file, list of files, or folder scan
argument-hint: <file_or_folder> (optional — if omitted, scan all *.py in the project)
---

Run `uv run --with mypy mypy` on the target(s), then fix every reported error. Print one line per fix. Don't touch logic.

## Scope

- **File path** — mypy on that file only.
- **Folder path** — find all `*.py` under it (skip `.venv`, `__pycache__`, `*.egg-info`, `build/`, `dist/`) and run mypy on each.
- **No argument** — scan `*.py` from the project root (same exclusions).

Discover files first with `find`, then run mypy. Run once per file, or once for the whole package if a `py.typed` marker or `mypy.ini` is present — prefer the package invocation for cross-module inference.

```sh
# single file
uv run --with mypy mypy path/to/file.py

# folder or project
find <root> -name "*.py" \
  ! -path "*/.venv/*" ! -path "*/__pycache__/*" \
  ! -path "*.egg-info/*" ! -path "*/build/*" ! -path "*/dist/*"
uv run --with mypy mypy <package_or_file_list>
```

## Fixing errors

For each error, apply the minimal correct fix, in order of preference:

1. **Type narrowing** — `assert x is not None`, `isinstance` guard, or early `return`/`raise`. Use when control flow already makes the type safe but mypy can't see it.
2. **Annotation fix** — correct or add a missing annotation on the variable, parameter, or return type.
3. **`cast()`** — `from typing import cast; cast(SomeType, expr)`, only when the value is provably correct and 1-2 don't apply.
4. **`# type: ignore[<code>]`** — last resort, only for unavoidable third-party stub gaps. Add a brief inline comment explaining why.

Never use bare `# type: ignore` (always include the error code). Never add `Any` to silence errors.

## When to ask

Stop and ask via plain text before changing code when:

- The correct type is genuinely ambiguous and the wrong choice would change runtime behaviour.
- A function's declared return type is `None` but it visibly returns values in some branches — clarify intent first.
- Fixing the error requires changing a public API signature (adding/removing/renaming a parameter).
- A `# type: ignore` seems necessary but it's unclear whether it's a stub gap or a real bug.

State the file, line, mypy error text, and 2-3 options. Wait for the answer before proceeding.

## Output format

```
✓ path/to/file.py — N fix(es): <comma-separated one-liners>
```
```
✓ path/to/file.py — no issues
```
```
⚠ path/to/file.py — N fix(es) applied, M remaining (see above)
```

Re-run mypy after all fixes to confirm zero errors before reporting done.
