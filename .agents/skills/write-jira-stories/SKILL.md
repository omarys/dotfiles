---
name: write-jira-stories
description: Create or replace Jira-ready backlog Stories when a user asks to plan a sprint, decompose pending work, update a backlog, or prepare tickets for a scrum master.
---

# Write Jira stories

Turn current, pending work into Stories that a human can enter in Jira without
another requirements interview. Treat repository evidence and current user
instructions as the source of truth. Do not assume that Jira is reachable.

## Establish the planning baseline

Read project instructions before planning. Find issue-tracker conventions,
the domain glossary, Epic or feature documents, ADRs, specifications, existing
backlogs, and relevant tests. Inspect worktree state when implementation may
have moved beyond the written backlog.

Apply this order when sources conflict:

1. Current user instructions.
2. Project agent instructions and issue-tracker rules.
3. Current repository implementation and tests.
4. Current specifications, ADRs, and domain documentation.
5. Existing backlog text.
6. External documentation for facts that can change.

Identify the exact Epic name or key. Preserve it in every Story. If the Epic no
longer matches the current scope, record a rename recommendation without
inventing a new Jira identity.

Separate the work into three sets:

- completed work, which is context and does not become a new Story;
- pending work needed for the next outcome;
- deferred work that lacks a requirement, dependency, or sprint capacity.

When the user says to replace a backlog, remove completed Stories and write the
pending set. Preserve unrelated repository changes.

## Decompose the outcome

Write vertical Stories that produce an observable result. Each Story should be
independently reviewable and small enough to finish in one sprint. Split work
that exceeds 8 points or combines unrelated outcomes.

Use a research or decision Story only when an unresolved choice blocks later
implementation. Its result must be a concrete decision, contract, compatibility
proof, or rejected-option record.

Order Stories by real dependency. Mark work as parallel only when it can start
without unfinished output from another Story. Put optional scope in stretch or
follow-on work instead of hiding it in core acceptance criteria.

## Write every required field

Follow the project's required field order and wording when it defines one.
Otherwise use the template in
[references/story-template.md](references/story-template.md).

Each Story must include:

- **Epic:** The exact parent Epic name or key.
- **Name:** A short verb-led outcome. Name what becomes possible.
- **Description:** Why the work is needed and who benefits. Keep implementation
  detail only when it constrains the result.
- **Definition of Done:** Evidence the team must produce before closing the
  Story, such as working implementation, tests, documentation, and required
  review.
- **Dependencies:** Earlier Stories, teams, people, access, artifacts, or
  decisions required to start or finish. Write `None` when there are none.
- **Acceptance Criteria:** Observable results that the customer, operator, or
  consuming developer can verify. Use unambiguous bullet points.
- **Assignee:** A known person, or `Unassigned` with the role needed during
  grooming.
- **Story Points:** One of `1`, `2`, `3`, `5`, or `8`.

Definition of Done describes closure evidence. Acceptance Criteria describe the
behavior or result. Do not repeat the same sentence in both fields.

Acceptance Criteria must cover the successful path. Add failure, security,
recovery, idempotency, or negative cases when those behaviors are part of the
Story. Name the real artifact, command, event, field, or user-visible result.
Avoid criteria such as "works correctly", "is tested", or "is documented"
without stating what the test or document proves.

## Estimate consistently

Use the project's scale when provided. Otherwise use this scale:

| Points | Planning meaning |
| ---: | --- |
| 1 | About one day; isolated change with known inputs |
| 2 | One or two days; small change with a limited test path |
| 3 | Several days; one module or one integration seam |
| 5 | Multi-module work or moderate technical uncertainty |
| 8 | Most of a two-week sprint; split when a clean seam exists |

Points include implementation, meaningful verification, documentation, and
review. Do not convert points into a false hour estimate.

## Package the request

Start with the Epic, one sprint goal, and a grooming table containing order,
Story name, points, and scheduling. State which Stories form the recommended
sprint slice and its total points. Treat that total as a planning input unless
team capacity is known.

Use the project's ubiquitous language. Keep one name for each domain concept.
Explain assumptions and unresolved dependencies in the relevant Story instead
of adding a detached list that Jira users will miss.

If Jira is unavailable, write or update the repository's backlog request and
leave Jira entry to a human. Create or modify remote Jira issues only when the
user has authorized that external action and the required integration exists.

## Verify before handoff

Confirm all of these conditions:

- Every Story points to the Epic.
- Every Story contains every required field.
- Every point value is allowed.
- Story dependencies refer to existing Stories and contain no cycle.
- The recommended slice reaches the sprint goal.
- Completed work does not reappear as pending work.
- Deferred work is outside core acceptance criteria.
- Acceptance Criteria are observable and do not merely restate the Definition
  of Done.
- Names and terms match project documentation.
- Modified documentation passes the repository's relevant checks.

Report the artifact path, the number and total points of recommended Stories,
and any decision that still requires grooming.
