---
name: github-flow
description: Use when starting any coding task, creating branches, handling worktrees, resolving merge conflicts, creating PRs, or working in CI. Covers GitHub Flow branching, worktree protocol, conflict resolution, and PR conventions.
---

# GitHub Flow & Worktree Protocol

## Core Rules

Coding directly on the default branch (`master` or `main`) is strictly prohibited.

We use GitHub Flow:
- All work happens in feature branches
- Changes are submitted via Pull Requests
- PRs are reviewed and then squash merged into the default branch
- Never merge directly to the default branch without PR review and acceptance
- Branch convention is `issue<number>` or `<short-description>` if there is no issue open

## Worktree Protocol

In CI, regular branching is enough. When working locally, always use worktrees for isolation.

The `.worktrees/` directory must be listed in `.gitignore`. Verify before creating worktrees:

```bash
git check-ignore -q .worktrees
```

If not ignored, add `.worktrees` to `.gitignore` and commit before proceeding.

### Step 1: Verify Environment

Check the current branch and working directory path:

```bash
git branch --show-current
pwd
```

### Step 2: Determine if Already on a Working Branch

- Run `git branch --show-current`
- Check if the current absolute path contains `.worktrees/`
- **If NOT on `master` or `main`, OR path contains `.worktrees/`:** already on a working branch. Do not create a new worktree unless explicitly requested. Proceed with the task in the current directory.
- **If on `master` or `main` AND path does NOT contain `.worktrees/`:** must create a worktree.

### Step 3: Create Worktree (When Needed)

Sync the default branch first, then create the worktree:

```bash
git pull origin <default-branch>
git worktree add ./.worktrees/<branch_name> -b <branch_name>
```

Switch working directory to the new worktree and perform all operations from there. Never work inside `.worktrees/` from the main repo directory.

### Step 4: Run Project Setup

After creating the worktree, install dependencies:

```bash
if [ -f package.json ]; then npm install; fi
if [ -f Cargo.toml ]; then cargo build; fi
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
if [ -f pyproject.toml ]; then poetry install; fi
if [ -f go.mod ]; then go mod download; fi
```

### Step 5: Integrate Before Completing

Before considering local work complete, bring the current default branch into the working branch:

```bash
git pull origin <default-branch>
```

If conflicts appear, resolve them manually, complete the merge, and continue from that merged history. Never use rebase or anything that rewrites git history.

### Step 6: Reconcile Before Push

After pulling the default branch and before the final push from a local worktree, pull the latest remote state:

```bash
git pull origin <current-branch>
```

Resolve conflicts manually if they appear.

### Step 7: Cleanup

After the branch is merged, remove the worktree:

```bash
git worktree remove ./.worktrees/<branch_name>
```

## Conflict Resolution

### Local Development

When a working branch needs the latest `master` or `main`:

```bash
git pull origin <default-branch>
```

- Treat this as the required integration step before work is considered complete
- If conflicts occur: resolve manually, stage resolved files, complete the merge commit
- Do not replace this flow with rebase or other history-rewriting commands
- When describing updates in logs or comments, say plainly that you pulled the default branch and resolved conflicts

### CI (GitHub Actions)

Before pushing, check for and resolve merge conflicts:

1. Detect the base branch: `gh pr view --json baseRefName`
2. Check for conflicts: `gh pr view --json mergeable` — if `CONFLICTING`, must resolve
3. Pull the base branch: `git fetch origin <base-branch>` then `git pull origin <base-branch>` (no rebase)
4. Resolve conflicts: remove all conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`), keeping correct content from both sides
5. Stage and commit: `git add` resolved files and commit the merge
6. Push the resolved branch

## Superpowers Agent Rules

Agents must use the relevant Superpowers skill flow for the task they are performing.

- PR review agents must use Superpowers and follow the repository review format
- Reviewer approvals and change requests must start with `# REVIEW <sha>` where `<sha>` is the commit under review
- Approval reviews must stay concise, avoid cosmetic notes, and end with `LGTM`
- Requested-change reviews must use a short enumerated list and end with `/coder fix this`

## Pull Request Summary

Use this format for all PR descriptions:

```markdown
## Summary
Your summary of what was implemented.

Always close issues with `closes #<number>`. A list is preferred because GitHub adds the issue title, not just the number.

 - closes #1
 ...
 - closes #N
```

## Issues & Documentation Protocol

1. **Language:** ALWAYS use English for Issue titles, bodies, and any documentation files
2. **Issue Creation:**
   - Title: concise and descriptive (e.g., `fix: incorrect status code on missing endpoints`)
   - Body: include Summary, Context, and Steps to Reproduce (for bugs)
   - Verification: always verify the issue was created correctly using `gh issue view`
3. **Documentation:** keep it technical, concise, and up to date with standard Markdown formatting
