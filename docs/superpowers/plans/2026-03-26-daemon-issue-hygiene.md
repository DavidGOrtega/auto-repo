# Daemon Issue Hygiene Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Update the scheduled daemon so it conservatively closes clearly obsolete, duplicate, or already fixed issues before opening new ones, and remove the legacy triage workflow.

**Architecture:** The change stays inside GitHub workflow configuration. The scheduled workflow prompt becomes the source of daemon behavior, telling the agent to run a hygiene pass over open issues before creating anything new. The legacy triage workflow is deleted so no automation path references triage labels anymore.

**Tech Stack:** GitHub Actions YAML, anomalyco/opencode GitHub action, repository documentation

---

## File Structure

- Modify: `.github/workflows/opencode-scheduled.yml` - refine the scheduled daemon prompt so it closes clearly stale issues with evidence before opening new ones.
- Delete: `.github/workflows/issues-triage.yml` - remove the obsolete triage-label automation entirely.
- Verify: repository-wide search for `triage`, `issue-triage`, and `issues-triage` references after the workflow edits.

### Task 1: Tighten the scheduled daemon prompt

**Files:**
- Modify: `.github/workflows/opencode-scheduled.yml`
- Test: workflow prompt text inspected via `git diff`

- [ ] **Step 1: Read the current scheduled workflow prompt**

Read `.github/workflows/opencode-scheduled.yml` and identify the existing instructions for duplicate prevention and issue creation.

- [ ] **Step 2: Write the failing expectation as a prompt checklist**

Create a short checklist in your notes that the new prompt must satisfy and that the current file does not yet satisfy:
- closes clearly obsolete, duplicate, or already fixed open issues first
- requires clear evidence before closing
- requires a short technical explanation when closing
- avoids closing uncertain or merely old issues
- removes any triage language

- [ ] **Step 3: Verify the current workflow fails that checklist**

Run: `grep -n "close\|triage\|duplicate" .github/workflows/opencode-scheduled.yml`
Expected: the file mentions duplicate prevention but does not yet instruct the daemon to close obsolete issues or remove triage concepts.

- [ ] **Step 4: Update the prompt with the minimal behavior change**

Edit `.github/workflows/opencode-scheduled.yml` so the prompt tells the daemon to:
- inspect open issues first
- close only clearly obsolete, duplicate, or already fixed issues
- leave a concise technical explanation when closing
- prefer no action when uncertain
- review current and recently closed issues before opening anything new
- open new issues only after the hygiene pass

- [ ] **Step 5: Verify the updated prompt matches the checklist**

Run: `git diff -- .github/workflows/opencode-scheduled.yml`
Expected: the prompt now explicitly includes the hygiene pass, closure safeguards, and explanation requirement.

### Task 2: Remove the legacy triage workflow

**Files:**
- Delete: `.github/workflows/issues-triage.yml`
- Test: git status and search output

- [ ] **Step 1: Confirm the legacy workflow still exists**

Run: `ls .github/workflows`
Expected: `issues-triage.yml` appears in the workflow list before deletion.

- [ ] **Step 2: Delete the obsolete triage workflow**

Remove `.github/workflows/issues-triage.yml`.

- [ ] **Step 3: Verify the file is deleted**

Run: `git status --short`
Expected: the triage workflow appears as deleted and the scheduled workflow appears as modified.

### Task 3: Verify there are no triage remnants

**Files:**
- Verify: repository-wide references after workflow changes

- [ ] **Step 1: Search for remaining triage references**

Run: `rg -n "triage|issue-triage|issues-triage" .`
Expected: no matches remain outside the historical design/spec documents that intentionally discuss the removed flow.

- [ ] **Step 2: Validate workflow YAML syntax**

Run: `ruby -e 'require "yaml"; YAML.load_file(".github/workflows/opencode-scheduled.yml"); puts "YAML OK"'`
Expected: `YAML OK`

- [ ] **Step 3: Review the final diff**

Run: `git diff -- .github/workflows/opencode-scheduled.yml .github/workflows/issues-triage.yml`
Expected: one prompt update and one deleted workflow, with no unrelated changes.

- [ ] **Step 4: Commit the workflow cleanup**

```bash
git add .github/workflows/opencode-scheduled.yml .github/workflows/issues-triage.yml
git commit -m "Improve daemon issue hygiene workflow"
```
