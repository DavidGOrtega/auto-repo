# oc-init Reconciliation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `oc-init` require local OpenCode, reconcile `AGENTS.md` with OpenCode, and merge `opencode.json` structurally instead of writing `*.oc-init-new` files for those two files.

**Architecture:** The implementation stays inside the `oc-init` shell script plus documentation updates. `oc-init` gains a stricter prerequisite check for the local `opencode` binary, a deterministic JSON merge path for `opencode.json`, and a non-interactive OpenCode reconciliation path for `AGENTS.md`. README text is updated to describe the new overwrite-and-reconcile behavior.

**Tech Stack:** Bash, Python 3 for deterministic JSON merge helpers, OpenCode CLI, Markdown

---

## File Structure

- Modify: `oc-init` - add prerequisite checks, JSON merge logic, AGENTS reconciliation, and overwrite behavior changes.
- Modify: `README.md` - update bootstrap behavior and requirements documentation.
- Test: `oc-init` with temporary repositories and fixture files from shell commands.

### Task 1: Tighten prerequisites and scope the two special files

**Files:**
- Modify: `oc-init`

- [ ] **Step 1: Read the current prerequisite and copy flow**

Review `oc-init` to locate:
- command requirements,
- `copy_file`,
- auth checks,
- the existing install calls for `AGENTS.md` and `opencode.json`.

- [ ] **Step 2: Write the failing expectations as a checklist**

Record the new expectations the current script does not satisfy:
- `opencode` is required before bootstrap continues,
- `AGENTS.md` never goes through `copy_file` merge-copy behavior,
- `opencode.json` never goes through `copy_file` merge-copy behavior,
- failures abort instead of emitting `*.oc-init-new` for those two files.

- [ ] **Step 3: Verify the current script fails that checklist**

Run: `grep -n "copy_file 'AGENTS.md'\|copy_file 'opencode.json'\|require_command" oc-init`
Expected: current output shows generic copy behavior for both files and no `require_command opencode` line.

- [ ] **Step 4: Add the minimal prerequisite change**

Update `oc-init` so `opencode` is required before repository configuration starts, alongside the existing `git` and `gh` requirements.

- [ ] **Step 5: Review the prerequisite diff**

Run: `git diff -- oc-init`
Expected: `opencode` is now an explicit hard requirement and no unrelated behavior changed yet.

### Task 2: Implement deterministic `opencode.json` reconciliation

**Files:**
- Modify: `oc-init`

- [ ] **Step 1: Create a dedicated helper for JSON reconciliation**

Add a focused helper in `oc-init` that:
- loads bootstrap and target JSON through Python 3,
- recursively merges objects,
- unions arrays by exact JSON value while preserving target order,
- preserves unrelated target keys,
- forces bootstrap-required keys to match the bootstrap file.

- [ ] **Step 2: Define bootstrap-required JSON keys in one place**

Introduce a single source of truth in `oc-init` for the bootstrap-required `opencode.json` keys so the merge remains deterministic. Add an explicit step in code or comments that documents the exact key set taken from the bootstrap `opencode.json`, limited to the keys required to keep the bundled Superpowers plugin active.

- [ ] **Step 3: Route `opencode.json` through the new helper**

Replace the generic `copy_file 'opencode.json' ...` path with:
- direct write if the file is absent,
- merge-and-overwrite if the file exists,
- hard failure if either JSON file is malformed.

- [ ] **Step 4: Verify the helper on a target-owned key**

Run a temporary-repo test where the target `opencode.json` contains an unrelated key and the bootstrap file contains the required plugin configuration.
Expected: the resulting file preserves the unrelated key and includes the required bootstrap configuration.

- [ ] **Step 5: Verify duplicate bootstrap items collapse cleanly**

Run a temporary-repo test where the target file already contains the bootstrap plugin entry.
Expected: the merged file contains one effective bootstrap plugin entry, not duplicates.

### Task 3: Implement `AGENTS.md` reconciliation through OpenCode

**Files:**
- Modify: `oc-init`

- [ ] **Step 1: Create a dedicated helper for AGENTS reconciliation**

Add a helper in `oc-init` that:
- reads the current target `AGENTS.md` and bootstrap `AGENTS.md`,
- invokes `opencode` non-interactively with a reconciliation prompt, passing file content in and capturing reconciled Markdown out in a deterministic way,
- writes the reconciled output to a temporary file first.

Use the supported `opencode run` CLI path explicitly. The implementation should build a reconciliation prompt string, run `opencode run <prompt> --format json --dir <target-repo>`, and capture the final assistant text from the JSON event stream into a temporary file.

- [ ] **Step 2: Encode the reconciliation prompt explicitly**

The prompt must instruct OpenCode to:
- preserve repo-specific guidance,
- include the bootstrap-required OpenCode and Superpowers rules,
- update overlapping sections instead of duplicating them,
- keep the result concise and valid Markdown.

- [ ] **Step 3: Add output validation rules**

Reject reconciliation output when:
- the file is empty or whitespace only,
- the bootstrap-required guidance is missing, including the OpenCode/Superpowers policy shipped in the bootstrap `AGENTS.md`,
- all repo-specific top-level content disappears even though the original file had meaningful content; for this check, repo-specific content means any top-level heading or section present in the target file that is not part of the bootstrap template.

- [ ] **Step 4: Route `AGENTS.md` through the new helper**

Replace the generic `copy_file 'AGENTS.md' ...` path with:
- direct write if the file is absent,
- reconcile-and-overwrite if the file exists,
- hard failure if OpenCode returns a non-zero status or invalid output.

- [ ] **Step 5: Verify reconciliation on a repo-specific section**

Run a temporary-repo test where `AGENTS.md` contains a custom repo section plus overlapping bootstrap topics.
Expected: the resulting file keeps the repo-specific section and includes the bootstrap-required guidance in a single reconciled document.

### Task 4: Clarify overwrite behavior and README documentation

**Files:**
- Modify: `oc-init`
- Modify: `README.md`

- [ ] **Step 1: Make `--force` behavior explicit for the two reconciled files**

Update `oc-init` comments/messages so `--force` does not bypass reconciliation for `AGENTS.md` and `opencode.json`; those files always reconcile and overwrite.

- [ ] **Step 2: Update README requirements**

Edit `README.md` so it states that local `opencode` is now required.

- [ ] **Step 3: Update README behavior description**

Edit `README.md` so it explains:
- `AGENTS.md` is reconciled and overwritten,
- `opencode.json` is merged and overwritten,
- other managed files still use `*.oc-init-new` unless `--force` is used.

- [ ] **Step 4: Review the documentation diff**

Run: `git diff -- README.md oc-init`
Expected: the docs match the new script behavior and do not still promise `*.oc-init-new` for the two reconciled files.

### Task 5: End-to-end verification and commit

**Files:**
- Modify: `oc-init`
- Modify: `README.md`

- [ ] **Step 1: Validate syntax**

Run: `bash -n oc-init`
Expected: no output

- [ ] **Step 2: Run focused fixture-style verifications**

Run shell-based temporary repository tests covering:
- clean repo with no `AGENTS.md` or `opencode.json` -> both files written directly,
- missing `opencode` binary -> clear failure,
- malformed bootstrap `opencode.json` -> clear failure,
- malformed existing `opencode.json` -> clear failure,
- existing `opencode.json` with unrelated keys -> successful merge,
- existing `AGENTS.md` with repo-specific content -> successful reconciliation,
- OpenCode reconciliation failure -> abort without emitting `AGENTS.md.oc-init-new` or `opencode.json.oc-init-new`.

Use a reproducible harness strategy for these checks:
- create temporary git repositories under `mktemp -d`,
- stub `gh` and `opencode` through a temporary `PATH` override where needed,
- provide fixture auth files under a temporary `HOME`,
- inspect resulting files and exit codes without relying on the developer's real machine state.

Expected: each scenario matches the design behavior exactly.

- [ ] **Step 3: Review the final diff**

Run: `git diff -- oc-init README.md`
Expected: only the oc-init reconciliation implementation and documentation changes are present.

- [ ] **Step 4: Commit the implementation**

```bash
git add oc-init README.md
git commit -m "Reconcile bootstrap config during oc-init"
```
