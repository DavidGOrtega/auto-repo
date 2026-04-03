# AGENTS.md - Developer & AI Guide

This repository uses the **github-flow** agent skill for all Git workflow, branching, worktree, conflict resolution, and PR conventions. The skill is located at `.agents/skills/github-flow/SKILL.md` and is loaded automatically by OpenCode.

## Superpowers Agent Rules

This repository uses Superpowers for agent-driven work. Agents must use the relevant Superpowers skill flow for the task they are performing instead of improvising repository policy on their own.

- PR review agents must use Superpowers and follow the repository review format.
- Reviewer approvals and change requests must start with `# REVIEW <sha>` where `<sha>` is the commit under review.
- Approval reviews must stay concise, avoid cosmetic notes that do not require action, and end with `LGTM`.
- Requested-change reviews must use a short enumerated list and end with `/coder fix this`.
