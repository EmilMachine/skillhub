# MD 3-Step Workflow Plugin

A terse markdown-based research-plan-implement workflow for Claude Code.

## Skills

This plugin provides four slash commands for structured development:

### `/mdresearch`
Research codebase state from context file.
- **Input:** `0_context.md`
- **Output:** `1_research.md` with terse findings
- **Usage:** `/mdresearch path/to/0_context.md`

### `/mdplan`
Generate step-by-step implementation plan.
- **Input:** `1_research.md`
- **Output:** `2_plan.md` with detailed implementation steps
- **Usage:** `/mdplan path/to/1_research.md`

### `/mdupdate`
Refine plan by integrating user's inline answers.
- **Input:** `2_plan.md` with inline user edits
- **Output:** Updates same file with answers worked into main text
- **Usage:** `/mdupdate path/to/2_plan.md`

### `/mdimplement`
Execute the plan with testing and verification.
- **Input:** `2_plan.md`
- **Output:** `3_changelog.md` documenting changes
- **Usage:** `/mdimplement path/to/2_plan.md`

## Workflow

1. Create `0_context.md` describing your goal
2. Run `/mdresearch 0_context.md` → generates `1_research.md`
3. Run `/mdplan 1_research.md` → generates `2_plan.md`
4. Review plan, add inline questions/answers if needed
5. Run `/mdupdate 2_plan.md` → integrates your edits (optional)
6. Run `/mdimplement 2_plan.md` → generates `3_changelog.md` and implements changes

## Features

- Sequential numbered files (1, 2, 3)
- Output in same directory as input
- Open questions section at top of each file
- Supports absolute and relative paths
- Terse, focused output
- Test/verify after each implementation step
- No automatic git commits

## Implementation Details

### /mdresearch
- Uses Task/Explore for broad codebase searches
- Uses Grep/Glob/Read for targeted searches
- Includes file:line references in findings
- Aborts if context file missing

### /mdplan
- Breaks work into atomic, testable steps
- Each step includes Actions, Files, Verify sections
- Carries forward open questions from research
- Aborts if research file missing

### /mdimplement
- Executes steps sequentially with verification
- Uses Read/Edit/Write for file operations
- Runs tests after each step and at completion
- Documents all changes with status indicators
- Never creates git commits
- Attempts to fix failures, documents issues

### /mdupdate
- Detects various answer formats (A:, Answer:, inline edits)
- Updates plan in-place (same file)
- Preserves original structure
- Informs user if no edits found