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
  4. **Push your work once completed** Once the work is completed, do a final push to the repository.
  5. **Pull the default branch to include latest changes** Once the branch is pushed, bring in the current default branch changes using a merge strategy if needed. Resolve conflicts manually. Never use rebase or anything that rewrites the git history.

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
