## Setup Secrets

- Add a repository secret named `OPENCODE_AUTH_JSON`.
- Set its value to the full contents of `~/.local/share/opencode/auth.json` from the machine where OpenCode is already authenticated.
- This lets the GitHub Actions runner restore OpenCode provider credentials before running the workflow.

```bash
gh secret set OPENCODE_AUTH_JSON < ~/.local/share/opencode/auth.json
```

## Repository Merge Settings

- Allow only `squash merge`.
- Disable `merge commits`.
- Disable `rebase merge`.
- Enable automatic branch deletion after merge.

```bash
gh api --method PATCH "repos/$(gh repo view --json nameWithOwner -q .nameWithOwner)" \
  -f allow_merge_commit=false \
  -f allow_rebase_merge=false \
  -f allow_squash_merge=true \
  -f delete_branch_on_merge=true
```
