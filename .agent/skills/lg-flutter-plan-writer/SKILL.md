---
name: Liquid Galaxy Flutter Plan Writer
description: Create implementation plans. Each phase MUST complete before the next. Skeptical Mentor validates transitions.
---

# Writing Flutter LG Implementation Plans

**Announce at start:** "I'm using lg-flutter-plan-writer to create your implementation plan."

---

## CORE RULES

### Rule 1: Phase Order is Fixed
Init → Brainstorm → **Plan** → Execute → Review → Quiz

Skipping any phase is FORBIDDEN.

### Rule 2: Transition Requires Validation
Before moving to Execute phase:
1. Plan MUST be complete
2. Student MUST pass Skeptical Mentor validation
3. Both conditions MUST be true

### Rule 3: Plans Must Reference Existing Code
Every plan MUST identify:
- Existing components to reuse
- Existing interfaces to implement
- Why new code is needed (if any)

---

## Plan Document Structure

Create: `docs/plans/YYYY-MM-DD-<feature>-plan.md`

```markdown
# [Feature] Implementation Plan

**Goal**: [One sentence]
**Layers Affected**: domain / data / ui

---

## Reuse Check
**Existing components to use:**
- [List existing classes/methods]

**New components needed:**
- [List new classes with justification]

---

## Checklist
- [ ] Task 1: [title]
- [ ] Task 2: [title]
...

---

## Tasks
[Details below]
```

---

## Task Structure

Each task:

```markdown
### Task N: [Name]

**Files:**
- Reuse: [existing files]
- Create: [new files]
- Test: [test file]

**What to Build:**
[Specific implementation details]

**Test:**
[What the test verifies]

**Verification:**
1. flutter analyze — zero warnings
2. flutter test [path] — pass
```

---

## Validation Before Execution

After plan is complete:

1. **Self-Check:**
   - Are all SOLID principles considered?
   - Is DRY followed (no duplicated logic)?
   - Are existing components reused?

2. **Skeptical Mentor Validation:**
   - Ask ONE architecture question
   - Correct answer → proceed to Execute
   - Wrong answer → return to Brainstorm

---

## Handoff

Checklist before handoff:
- [ ] Plan document complete
- [ ] Reuse check complete
- [ ] Skeptical Mentor passed

Then ask: "Plan ready. Shall we start execution?"

Invoke `lg-flutter-exec`
