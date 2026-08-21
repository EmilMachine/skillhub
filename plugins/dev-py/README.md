# Dev Py Plugin

Python dev workflow: type-check, docstrings, lint/format, aggregate fix, project setup.

## Skills

### `/pydoc`
Add/improve docstrings in Python files — Google style for functions and modules, argparse epilog examples for CLIs.
- **Input:** `<file_or_folder>` (optional, defaults to all `*.py` in the project)
- **Usage:** `/pydoc [path]`

### `/mypy`
Run mypy on Python files and fix type errors.
- **Input:** `<file_or_folder>` (optional, defaults to all `*.py` in the project)
- **Usage:** `/mypy [path]`

### `/ruff`
Format and lint-fix Python file(s) or directory via `ruff format` + `ruff check --fix`.
- **Input:** `<file_or_folder>` (optional, defaults to current directory)
- **Usage:** `/ruff [path]`

### `/pyfix`
Run `pydoc`, `mypy`, and `ruff` on a file or directory.
- **Input:** `<file_or_folder>` (optional, defaults to current directory)
- **Usage:** `/pyfix [path]`

### `/pysetup`
Bootstrap a Python project via `dev-essentials` `setup`, then add `uv`/`ruff` conventions to `AGENTS.md`.
- **Input:** `<project-root-path>` (optional)
- **Usage:** `/pysetup [path]`

## Features

- `ruff` is a thin skill wrapper over a bundled script (`ruff.sh`)
- `pyfix` aggregates the other 3 skills in one call: pydoc → mypy → ruff
- `pysetup` depends on the `dev-essentials` plugin's `setup` skill — stops with an install hint if missing

## Installation

```
/plugin install dev-py@skillhub
```
