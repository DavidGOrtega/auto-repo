# Superpowers Review Guidance Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update `AGENTS.md` and the reviewer workflow so Superpowers usage and local pull rules are defined centrally and the review prompt stays short.

**Architecture:** The repo policy moves into `AGENTS.md`, where agent classes, Superpowers usage, and local git merge requirements are documented. The review workflow then references that policy with a short Superpowers instruction plus only the repo-specific review output rules.

**Tech Stack:** Markdown, GitHub Actions YAML

---

## File Structure

- Modify: `AGENTS.md` - add Superpowers agent rules and clarify that `git pull origin <default-branch>` is the required local integration step, while `git pull origin <current-branch>` is only a pre-push reconciliation step.
- Modify: `.github/workflows/opencode-review.yml` - replace the long Superpowers explanation with a concise instruction and keep only review-scope/output rules.

### Task 1: Update repo policy in AGENTS.md

**Files:**
- Modify: `AGENTS.md`

- [ ] **Step 1: Review the current git and agent policy wording**

Read `AGENTS.md` and note the existing pull guidance plus any current mention of agents or review behavior.

- [ ] **Step 2: Record the missing requirements before editing**

Confirm the current file does not yet clearly state:
- Superpowers is the general repo policy for different agent types
- PR reviewers should use Superpowers
- `git pull origin <default-branch>` is the required local integration step
- `git pull origin <current-branch>` is additional pre-push reconciliation, not the main rule

- [ ] **Step 3: Add the minimal AGENTS.md policy update**

Edit `AGENTS.md` to:
- add a short section describing Superpowers agent expectations across the repo
- explicitly mention PR review agents
- clarify the local git rule hierarchy around default-branch pull versus current-branch reconciliation

- [ ] **Step 4: Review the AGENTS.md diff**

Run: `git diff -- AGENTS.md`
Expected: the file adds Superpowers agent guidance and clarifies the local pull rules without unrelated edits.

### Task 2: Shorten the reviewer workflow prompt

**Files:**
- Modify: `.github/workflows/opencode-review.yml`

- [ ] **Step 1: Review the current workflow prompt**

Read `.github/workflows/opencode-review.yml` and note which lines explain Superpowers in too much detail versus which lines are genuinely repo-specific.

- [ ] **Step 2: Replace the long Superpowers preamble with a short instruction**

Edit the prompt so it says, in essence, `You have Superpowers: use them to review this pull request.`

Keep the repo-specific rules for:
- reviewing only the current PR diff
- staying in scope
- using prior review context on re-review
- output format for requested changes versus `LGTM`
- review-round limit

- [ ] **Step 3: Review the workflow diff**

Run: `git diff -- .github/workflows/opencode-review.yml`
Expected: the prompt is shorter, keeps the repo-specific review rules, and no longer repeats the long Superpowers explanation.

### Task 3: Validate and commit the expanded PR changes

**Files:**
- Modify: `AGENTS.md`
- Modify: `.github/workflows/opencode-review.yml`

- [ ] **Step 1: Validate workflow YAML syntax**

Run: `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/opencode-review.yml"); puts "YAML OK"'`
Expected: `YAML OK`

- [ ] **Step 2: Review the full diff for the branch**

Run: `git diff -- AGENTS.md .github/workflows/opencode-review.yml`
Expected: only the policy and reviewer prompt guidance changes appear in this validation step.

- [ ] **Step 3: Commit and push the updated branch**

```bash
git add AGENTS.md .github/workflows/opencode-review.yml
git commit -m "Clarify Superpowers review guidance"
git push
```
