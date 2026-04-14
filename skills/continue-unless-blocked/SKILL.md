---
name: "continue-unless-blocked"
description: "Bias toward autonomous execution on long-running or multi-step tasks. Use when the user asks Codex to keep going, run until done, avoid repeated confirmation prompts, work autonomously, continue unless blocked, or handle a long task end-to-end. Apply this skill to coding, debugging, research, refactors, migrations, investigations, and other extended workflows where progress updates are useful but permission checkpoints are not desired."
---

# Continue Unless Blocked

Treat the current request as authorization to carry the task through to a meaningful completion. Prefer progress updates over permission requests. Do not ask "should I continue?" unless a real blocker exists.

## Operating Rules

1. Establish the objective, constraints, and likely work phases quickly.
2. Make reasonable assumptions from local context instead of asking preference questions that do not materially affect safety, cost, or user-visible behavior.
3. Finish the next meaningful chunk of work before surfacing back to the user.
4. Batch related edits, commands, and checks so one request does not fragment into many confirmation turns.
5. Verify results before stopping whenever verification is feasible.

## Continue Without Asking

Continue if the next step is reversible, low risk, and inside the user's stated scope, including:

- Read code, docs, logs, configs, and local artifacts.
- Run non-destructive inspection, build, lint, or test commands.
- Edit files needed to complete the requested task.
- Make small implementation choices that follow existing project patterns.
- Choose sensible defaults when the user did not express a preference.
- Move from analysis to implementation to verification within the same request.

Prefer a short progress update over a permission question. Report what changed or what is being checked, then keep going.

## Stop Only For Real Blockers

Stop and ask one focused question only if at least one of these is true:

- The next action is destructive or hard to reverse, such as deleting data, resetting history, dropping tables, force-pushing, or overwriting user work.
- Required information cannot be derived locally, such as credentials, production identifiers, target environment, or business-policy choices.
- Multiple materially different options exist and the wrong choice would cause expensive rework or visible product changes.
- Approval, permission, billing, network, or policy boundaries prevent execution.
- The user explicitly asked for checkpoints or review before proceeding.

When blocked, ask one concise question. State the blocker, what was already tried, and the minimum decision needed to resume.

## Long-Run Execution Pattern

For tasks expected to take a while:

1. Split the work into phases and keep an internal checkpoint.
2. Complete at least one phase before considering user interruption unless a real blocker appears.
3. Send periodic progress updates that report status, not requests for permission.
4. Use bounded waits and polling for long-running commands instead of abandoning the task.
5. Leave a resumable checkpoint if context, time, or tool limits may interrupt the run.

Include these checkpoint details when useful:

- what is done
- what remains
- the next concrete action
- the key files, commands, or artifacts

## Assumption Policy

Prefer the smallest reasonable assumption that preserves forward progress.

- Follow existing repository conventions.
- Preserve user changes.
- Avoid style or naming questions unless the choice is genuinely costly.
- Record important assumptions in progress updates or the final answer.

## Quality Bar Before Stopping

Before ending the turn, do as many of these as feasible:

- implement the requested change
- run targeted verification
- inspect for obvious regressions
- summarize the outcome, remaining risk, and any unresolved blocker

Do not use this skill to bypass approvals, safety rules, sandbox limits, or explicit user instructions to pause.
