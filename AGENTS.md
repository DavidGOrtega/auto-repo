# AGENTS.md - Developer & AI Guide

## GitHub Flow & Branching

Coding directly on the default branch (`master` or `main`) is strictly prohibited.

We use `GitHub Flow`:
 - All work happens in feature branches
 - Changes are submitted via Pull Requests
 - PRs are reviewed and then squash merged into the default branch
 - Never merge directly to the default branch without PR review and acceptance
 - Branch convention is `issue<number>` or `<short-description>` if there is no issue open.

### Branch Verification & Worktree Protocol

While working in CI, regular branching is enough. However, when working locally,
before starting any work, you MUST verify your current environment:

 1. **Verify Environment:** Check both the current branch and the working directory path.
 2. **Determine if on a Working Branch:**
   - Run `git branch --show-current`.
   - Check if the current absolute path contains the `.worktrees/` directory.
   - **If you are NOT on `master` or `main` OR the path contains `.worktrees/`:** You are already in a working branch. Do not create a new worktree unless explicitly requested. Proceed with your task in the current directory.
  3. **If you ARE on `master` or `main` AND the path does NOT contain `.worktrees/`:**
   - **Sync the default branch:** Ensure your local default branch is up to date before branching.
   - **Create Worktree:** Create a separate workspace for your branch:
     ```bash
       git worktree add ./.worktrees/<branch_name> -b <branch_name>
      ```
    - **Switch Directory:** Change your working directory to the newly created path and perform all operations from there.
  4. **Pull the default branch to include latest changes** Before considering local work complete, bring the current default branch into the working branch with `git pull origin <default-branch>`. If conflicts appear, resolve them manually, complete the merge, and continue from that merged history. Never use rebase or anything that rewrites the git history.
  5. **Reconcile the working branch before the final push when working locally** After pulling the default branch and before the final push from a local worktree, pull the latest remote state into the current working branch with `git pull origin <current-branch>` and resolve conflicts manually if they appear.

### Pull Conflict Handling

When a working branch needs the latest `master` or `main`, prefer an explicit `git pull origin <default-branch>` so it is clear that the branch is incorporating the remote default branch and may require conflict resolution.

- In local development, treat `git pull origin <default-branch>` as the required integration step before the work is considered complete.
- After that integration step and before the final push, also pull `origin/<current-branch>` into the working branch so remote updates are reconciled locally too.
- Treat this as a merge-based update to the current branch.
- If conflicts occur, resolve them manually, stage the resolved files, and complete the merge commit.
- Do not replace this flow with rebase or other history-rewriting commands.
- If you describe the update in logs or comments, say plainly that you pulled the default branch and resolved conflicts.

### Superpowers Agent Rules

This repository uses Superpowers for agent-driven work. Agents must use the relevant Superpowers skill flow for the task they are performing instead of improvising repository policy on their own.

- PR review agents must use Superpowers and follow the repository review format.
- Reviewer approvals and change requests must start with `# REVIEW <sha>` where `<sha>` is the commit under review.
- Approval reviews must stay concise, avoid cosmetic notes that do not require action, and end with `LGTM`.
- Requested-change reviews must use a short enumerated list and end with `/coder fix this`.

### Pull Request Summary

```
## Summary
Your summary of what was implemented.
    
Always close issues with `closes #<number>`. A list is preferred because GitHub adds the issue title, not just the number.

 - closes #1
 ...
 - closes #N
```

## Issues & Documentation Protocol
All project management and documentation activities must follow these rules:

1. **Language:** ALWAYS use English for Issue titles, bodies, and any documentation files.
2. **Issue Creation:**
   - **Title:** Concise and descriptive (e.g., `fix: incorrect status code on missing endpoints`).
   - **Body:** Recommended to include:
     - **Summary:** Brief explanation of the problem or feature.
     - **Context:** Mention specific files, functions, or endpoints involved.
     - **Steps to Reproduce:** (For bugs) Clear steps or expected vs. actual behavior.
   - **Verification:** Always verify the issue was created correctly using `gh issue view`.
3. **Documentation:**
   - Keep it technical, concise, and up to date.
   - Use standard Markdown formatting.
