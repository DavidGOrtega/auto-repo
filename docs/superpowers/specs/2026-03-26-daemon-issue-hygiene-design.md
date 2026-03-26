# Conservative Enhancement Spec: Scheduled Daemon Issue Hygiene

## Goal

Extend the scheduled daemon so it not only opens new issues for newly detected problems, but also performs limited repository hygiene by closing open issues that are clearly obsolete, duplicate, or already fixed in the current repository state.

This enhancement must stay conservative: it should reduce obvious issue tracker noise without introducing aggressive or speculative closure behavior.

## Current State

- The scheduled daemon in `.github/workflows/opencode-scheduled.yml` reviews the codebase and may open new issues.
- It already avoids opening duplicates by checking existing open and recently closed issues first.
- A separate legacy workflow, `.github/workflows/issues-triage.yml`, still adds a `triage` label on issue creation.
- The triage-label flow is no longer desired and should be removed entirely from the design.

## Proposed Behavior

On each scheduled run, the daemon should perform two lightweight passes:

1. Review the current repository state for new bugs, broken behavior, missing error handling, and actionable TODOs, then open issues only when no equivalent issue already exists.
2. Review existing open issues and close only those that have strong, current evidence showing they are:
   - obsolete,
   - duplicates of another active or resolved issue, or
   - already fixed in the repository.

The daemon should prefer no action over uncertain action. If evidence is incomplete or ambiguous, the issue remains open.

When closing an issue, the daemon must leave a short technical explanation before or as part of closure, citing the evidence used.

## Closing Criteria

An open issue may be closed only when at least one of these conditions is clearly met:

- `Obsolete`: the issue describes behavior, files, or workflows that no longer exist in the repository.
- `Duplicate`: the issue is substantively covered by another issue or merged fix, with clear overlap in scope and expected resolution.
- `Already fixed`: the reported problem is demonstrably resolved by the current codebase, configuration, or merged changes.

Evidence should come from the current repository state, such as:

- relevant files or workflow definitions,
- merged PRs or commits,
- existing closed issues,
- code paths that now implement the requested fix,
- tests or documentation that confirm the current behavior.

## Safety Rules

- Do not close issues for age alone.
- Do not close issues when the daemon is uncertain.
- Do not close feature requests merely because they are still unimplemented.
- Do not close reports that cannot be verified either way from repository state.
- Do not preserve or introduce any `triage` label flow.
- Always include a short technical explanation when closing, with concrete references where possible.

Recommended closure comment shape:

- one-sentence conclusion,
- one or two technical evidence points,
- a pointer to the matching issue, PR, commit, file, or workflow when available.

## Workflow Changes

- Update the scheduled daemon design so issue review includes both:
  - duplicate prevention before opening new issues, and
  - conservative hygiene review of existing open issues.
- Remove the legacy `.github/workflows/issues-triage.yml` workflow from the intended workflow model.
- Ensure no part of the daemon behavior depends on adding, removing, or routing through a `triage` label.
- Keep permissions focused on what the daemon already needs for issue and repository interaction.

A practical execution order for each run is:

1. inspect current open issues and recent repository changes,
2. identify clearly closable issues,
3. close only those with explicit evidence and explanation,
4. then evaluate whether any new issues should be opened.

This ordering helps reduce duplicate issue creation against stale tracker state.

## Verification

Verify the enhancement with repository-level scenarios:

- an open issue describing a removed workflow is closed with a short explanation referencing the current workflow files;
- two clearly duplicate issues result in only the redundant one being closed, with a reference to the canonical issue;
- an issue fixed by merged code is closed with a technical explanation citing the relevant repository evidence;
- an old but still plausible issue remains open;
- an unimplemented feature request remains open;
- no workflow, prompt, or automation path uses the `triage` label anymore.

Success means the daemon remains conservative, explainable, and low-risk while keeping the issue tracker cleaner.
