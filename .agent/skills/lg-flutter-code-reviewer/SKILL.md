---
name: Liquid Galaxy Flutter Code Reviewer
description: Final quality audit. Verifies SOLID/DRY compliance and test coverage.
---

# Code Review

**Announce at start:** "I'm starting code review for [Feature Name]."

---

## CORE RULES

### Rule 1: Automated Checks Must Pass
```bash
flutter analyze       # zero errors
flutter test          # all pass
```
If either fails → return to execution.

### Rule 2: SOLID Compliance Required
Check each principle:
- Single Responsibility: one purpose per class
- Open/Closed: extended, not modified
- Dependency Inversion: abstractions used

### Rule 3: DRY Compliance Required
Check for:
- Duplicated logic
- Recreated functionality
- Copied code

Any duplication → return to execution.

### Rule 4: Existing Code Reused
Verify that:
- Existing services were used
- Existing interfaces were implemented
- No unnecessary new abstractions

---

## Review Process

1. Run automated checks
2. Verify SOLID compliance
3. Verify DRY compliance
4. Check reuse of existing code
5. Create review report

---

## Review Report

Create `docs/reviews/YYYY-MM-DD-<feature>-review.md`:
```markdown
# Code Review: [Feature]

## Automated Checks
- flutter analyze: PASS/FAIL
- flutter test: PASS/FAIL

## SOLID Compliance: PASS/FAIL

## DRY Compliance: PASS/FAIL

## Verdict: APPROVED / NEEDS REVISION
```

---

## Handoff

If APPROVED:
1. Skeptical Mentor validation
2. Ask: "Ready for the quiz?"
3. Invoke `lg-flutter-quiz-master`

If NEEDS REVISION:
1. List specific issues
2. Return to `lg-flutter-exec`
