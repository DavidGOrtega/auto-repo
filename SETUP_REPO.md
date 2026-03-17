## Setup Secrets

- Add a repository secret named `OPENCODE_AUTH_JSON`.
- Set its value to the full contents of `~/.local/share/opencode/auth.json` from the machine where OpenCode is already authenticated.
- This lets the GitHub Actions runner restore OpenCode provider credentials before running the workflow.

```bash
gh secret set OPENCODE_AUTH_JSON < ~/.local/share/opencode/auth.json
```
