---
name: Liquid Galaxy Flutter Code Reviewer
description: The final gatekeeper for quality. Use after a feature implementation is finished to ensure Flutter best practices, performance, and architectural purity.
---

# The Flutter Code Reviewer 🧐

## Overview

This is the fifth step in the 6-stage pipeline: **Init -> Brainstorm -> Plan -> Execute -> Review -> Quiz (Finale)**. Its goal is to simulate a professional code review, ensuring the code is not just "working," but "excellent."

**Announce at start:** "I'm starting a professional Code Review for the [Feature Name] implementation."

## The Review Process

### 1. Holistic Quality Check

Review the entire feature set for:

- **Clean Architecture**: Are layers properly separated? Is domain independent?
- **Riverpod Patterns**: Are we using the correct provider types?
- **DRY Compliance**: Did we copy-paste logic that should be in a service?
- **Naming**: Are variable and class names descriptive and consistent?

### 2. Technical Tooling Audit (Mandatory)

You **MUST** run and verify the results of:

- **Analysis**: Run `flutter analyze`. There should be zero errors or warnings.
- **Tests**: Run `flutter test`. All unit tests must pass.
- **Coverage**: Run `flutter test --coverage`. New logic should have at least **80% coverage**.

### 3. Flutter/LG Specific Audit

- **SSH Lifecycle**: Is the SSH client properly disposed? Are we handling disconnects?
- **Secure Storage**: Are credentials stored in `flutter_secure_storage`, not SharedPreferences?
- **State Management**: Are we avoiding unnecessary rebuilds? Using `select` where appropriate?
- **Memory Safety**: Are we disposing controllers and streams properly?

### 4. Documentation & Readiness

- **Dart Docs**: Does every public function have a proper doc comment?
- **README**: Does the project README explain how to use this feature?
- **Readability**: Could a new student understand this code in 5 minutes?

## The Review Report

Write the review results to `docs/reviews/YYYY-MM-DD-<feature>-review.md`.

**Template**:
```markdown
# Code Review: [Feature Name]

## 🟢 The Good
- [List strengths, e.g., "Excellent use of StateNotifierProvider for connection state."]

## 🛠 Tooling & Quality Status
- **Analyze**: [PASS/FAIL]
- **Tests**: [PASS/FAIL]
- **Coverage**: [X]% (Target: 80%)

## 🟡 Required Refactors (Gated)
- [List items the student MUST fix before 'merging'.]
- **Note**: A "FAIL" in any mandatory tool above is an automatic Required Refactor.

## 🔵 Best Practice Suggestions
- [List minor improvements for the future.]

## Final Verdict: [APPROVED / REVISIONS NEEDED]
*(A feature can only be APPROVED if all 3 Tools are in PASS state)*
```

## Guardrail: The Revision Loop

If **REVISIONS NEEDED**, hand back to the **Plan Writer** or **Executor** to fix the issues. Do not consider the feature "Complete" until the review is **APPROVED**.

## Final Completion

Once **APPROVED**:

- Suggest a final commit: `chore: final polish after code review`.
- **Finale Handoff**: Ask: "You've built and polished an incredible feature. Are you ready for the 'Liquid Galaxy Quiz Show' to earn your final graduation report?"
- Use the **Liquid Galaxy Flutter Quiz Master** to start the show.
