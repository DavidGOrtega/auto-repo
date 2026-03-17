# AGENTS.md - Developer & AI Guide

## GitHub Flow & Branching

Coding directly on the `master` or `main` or `main` branch is strictly prohibited. 

We use `GitHub Flow`:
 - All work happens in feature branches
 - Changes are submitted via Pull Requests
 - PRs are reviewed and then **squash merged** into master
 - Never merge directly to master without PR review and acceptance
 - Branch convention is issue<:number> or <desc> if there is no issue open.

### Branch Verification & Worktree Protocol

While working on CI env regular branching is perfect. However working locally,
before starting any work, you MUST verify your current environment:

 1. **Verify Environment:** Check both the current branch and the working directory path.
 2. **Determine if on a Working Branch:**
   - Run `git branch --show-current`.
   - Check if the current absolute path contains the `.worktrees/` directory.
   - **If you are NOT on `master` or `main` OR the path contains `.worktrees/`:** You are already in a working branch. DO NOT create a new worktree unless explicitly requested. Proceed with your task in the current directory.
 3. **If you ARE on `master` or `main` AND the path does NOT contain `.worktrees/`:**
   - **Sync master:** Always ensure your local `master` or `main` is up to date: `git pull origin master`.
   - **Create Worktree:** Create a separate workspace for your branch:
     ```bash
      git worktree add ./.worktrees/<branch_name> -b <branch_name>
      ```
    - **Switch Directory:** Change your working directory to the newly created path and perform all operations from there.
 4. **Push your work once completed** Once the work is completed we do a final push to the repo.
 5. **Pull origin master to include master changes** Once we have done a final push we need to apply current existing changes into our work. We must solve all the conflicts. NEVER use rebase or anything that rewrites the git history.

### Pull Request's Summary

```
## Summary
Your summary of what was implemented.
    
Alwais close issue via tag closes. Listing is preferred as GH adds the issue title not just the number.

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

