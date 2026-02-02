---
name: Liquid Galaxy Flutter Plan Executor
description: Execute implementation plans in batches with review checkpoints and educational validation for Flutter LG projects.
---

# Executing Flutter LG Plans

## Overview

Execute implementation plans in batches. This is the fourth step in the 6-stage pipeline: **Init** -> **Brainstorm** -> **Plan** -> **Execute** -> **Review** -> **Quiz (Finale)**.

**⚠️ PROMINENT GUARDRAIL**: Do not be a "coding robot." If the student stops participating or just says "Go on," you **MUST** trigger the **Skeptical Mentor**.

**Announce at start:** "I'm using the lg-flutter-exec skill to implement the [Feature Name] plan."

## The Process

### Step 1: Load and Review Plan

1. Read the plan file in `docs/plans/`.
2. **Critical Review**: Identify questions about the architecture or Riverpod patterns.
3. **Flutter Context**: Ensure the proposed names and structures follow project conventions.
4. If concerns: Raise them with the student before starting.

### Step 2: Execute Batch

**Default: Execute tasks in batches of 2-3.**

For each task in the batch:

1. Mark as `in_progress`.
2. Follow the steps exactly (Logic → Implementation → Verification).
3. **Educational Check**: Briefly explain why this specific task is necessary.
4. Run verifications as specified:
   - `flutter analyze` for static analysis
   - `flutter test` for unit tests
   - Hot reload on device/emulator for UI
5. **Quality Check**: Ensure no analyzer warnings.
6. Commit with a descriptive message: `feat: [task name]`.

### Step 3: Educational Report

When a batch is complete, report back with:

- **What was built**: A summary of the changes.
- **Verification Result**: Console outputs or screenshots showing it works.
- **Engineering Principles**: Mention which principle was applied (e.g., "I applied Separation of Concerns by keeping SSH logic in the service layer").
- **Device Check**: How does it look on the tablet emulator?
- **Checklist**: Mark the completed tasks in the `docs/plans/` folder.
- **Learning Journal**: Append this educational report to `docs/learning-journal.md`.

### Step 4: Continue

- Ask: "Ready for the next batch? Does the architecture still make sense to you?"
- Execute next batch until complete.

### Step 5: Final Review & Completion

After all tasks are complete:

1. Perform a final device test (connect to LG if possible, or use mock).
2. Finalize the `docs/plans/` document by marking it as complete.
3. **Review Handoff**: Ask: "Feature implementation is complete. Ready for a professional Code Review?"
4. Use the **Liquid Galaxy Flutter Code Reviewer** to perform the final quality audit.

## When to Stop and Ask for Help

- Hit a blocker (SSH connection issues, unclear instruction).
- Plan has logic gaps.
- Verification fails repeatedly.
- **Don't guess—ask for clarification.**

## Remember

- Review critically first.
- **SSH is the bridge**: All LG commands must go through the SSH service.
- Report engineering principles after every batch.
- **Guardrail**: If the student asks for too much automation, call in the **Skeptical Mentor**.
- Stop when blocked.
