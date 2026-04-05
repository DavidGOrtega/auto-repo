# auto-repo

Automated code assistant powered by [OpenCode](https://opencode.ai) running inside GitHub Actions. OpenCode responds to issue comments, reviews pull requests, triages new issues, and performs scheduled repository maintenance — all triggered from within your GitHub workflow.

## How it works

The automation cycle consists of four workflows:

| Workflow | Trigger | Purpose |
|---|---|---|
| **opencode** | `/coder` in an issue or PR comment | Executes code changes requested in the comment |
| **opencode-review** | PR opened, synced, reopened, or marked ready for review | Reviews every pull request and posts feedback |
| **triage** | Issue opened | Finds related issues and answers configuration questions |
| **opencode-scheduled** | Every 12 hours (`0 */12 * * *`) | Closes stale issues and opens new ones for problems found in the codebase |

### `/coder` lifecycle

1. A collaborator posts `/coder <instructions>` on an issue or PR comment.
2. The **opencode** workflow parses the invocation, including any per-run timeout.
3. OpenCode checks out the correct branch (feature branch for PRs, default branch for issues), installs itself, configures git hooks, and runs.
4. Commits created by the workflow are tagged with the trailer `By: coder`.
5. On push, the **opencode-review** workflow runs and posts a review comment. If changes are needed and the commit has the `By: coder` trailer, the review appends `/coder fix this` for a follow-up cycle.
6. The **opencode-scheduled** workflow periodically reviews open issues and the codebase to keep everything current.

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  /coder      │────▶│  opencode    │────▶│  commit with │
│  comment     │     │  workflow    │     │  By: coder   │
└──────────────┘     └──────────────┘     └──────┬───────┘
                                                 │
                    ┌──────────────┐     ┌────────▼───────┐
                    │  /coder fix  │◀────│  review        │
                    │  this        │     │  workflow      │
                    └──────────────┘     └────────────────┘
```

## Install

### Prerequisites

- [GitHub CLI (`gh`)](https://cli.github.com/) authenticated for the target repository
- [OpenCode](https://opencode.ai) installed locally
- `MASTER_GITHUB_TOKEN` — a GitHub PAT with `workflows` and `repo` permissions, set as a repository secret
- `ZAI_API_KEY` — ZCode provider API key, set as a repository secret

### One-command install

From inside the target repository:

```bash
curl -fsSL https://raw.githubusercontent.com/DavidGOrtega/auto-repo/master/oc-init | bash
```

Or from a local clone:

```bash
./oc-init
```

### What `oc-init` does

- Copies workflow files into `.github/workflows/`
- Copies `.agents/skills/github-flow/SKILL.md`
- Appends `.worktrees` to `.gitignore` when missing
- Creates the `bug` label via `gh`
- Enables GitHub Actions write permissions and PR approval permissions
- Configures squash-merge with automatic branch deletion

### Install options

```bash
./oc-init ../target-repo                    # install into a different repo
./oc-init --source-base-url https://...     # use a custom source URL
```

### Environment variables

The workflows expect these secrets configured on the repository:

| Secret | Source | Used by |
|---|---|---|
| `ZAI_API_KEY` | Set manually as a repository secret | All workflows — API key for the ZCode provider |
| `MASTER_GITHUB_TOKEN` | Set manually — a GitHub PAT or app token with repo scope | opencode, opencode-review, opencode-scheduled — enables push, PR creation, and cross-workflow triggers |
| `GITHUB_TOKEN` | Automatic GitHub Actions token | triage — sufficient for read-only issue operations |

## `/coder`

### Usage

Post `/coder` in an issue comment, PR comment, or PR review body:

```
/coder                        # default 20-minute timeout
/coder fix the login bug      # include instructions in the comment
/coder timeout=60             # override timeout to 60 minutes
/coder timeout 60             # alternative syntax
/coder fix this timeout=45    # timeout can appear anywhere in the body
```

Only repository owners, members, and collaborators can invoke `/coder`. Fork PRs are rejected.

### How `/coder` works

1. The **parse-invocation** job detects `/coder` in the comment body and extracts an optional `timeout=N` value.
2. The **coder** job checks out the correct ref:
   - PR comments → the PR's head branch
   - Issue comments → the repository's default branch
3. Git hooks are installed:
   - **commit-msg**: appends `By: coder` to every commit message so downstream workflows can identify automation-generated commits.
   - **pre-push**: blocks direct pushes to `master` or `main`.
4. OpenCode runs with the full comment body as its prompt, using model `ZCode/glm-5.1`.
5. OpenCode creates a feature branch, makes changes, commits, pushes, and opens a pull request.

### Timeout

The default timeout is **20 minutes**. Override it per-invocation by adding `timeout=N` (or `timeout N`) anywhere in the comment body, where `N` is the number of minutes. The timeout applies to the entire `coder` job, including checkout and setup.

### Review loop

When a commit with the `By: coder` trailer is pushed, the **opencode-review** workflow runs automatically. If the reviewer requests changes, it appends `/coder fix this` to its review comment, which triggers another `/coder` cycle on the same PR. This loop continues until the reviewer approves the changes (`LGTM`).

## Files

```
.
├── oc-init                              # Bootstrap installer script
├── .github/
│   ├── workflows/
│   │   ├── opencode.yml                 # /coder invocation handler
│   │   ├── opencode-review.yml          # Automated PR reviews
│   │   ├── opencode-scheduled.yml       # Scheduled repo maintenance
│   │   └── triage.yml                   # New issue triage
│   └── scripts/
│       └── install-opencode.sh          # Installs OpenCode and writes config
└── .agents/
    └── skills/
        └── github-flow/SKILL.md         # GitHub Flow branching skill
```
