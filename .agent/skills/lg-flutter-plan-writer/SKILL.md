---
name: Liquid Galaxy Flutter Plan Writer
description: Write comprehensive implementation plans that guide students through building features for Flutter LG Controllers.
---

# Writing Flutter LG Implementation Plans

## Overview

Write comprehensive implementation plans that guide students through building features for the Liquid Galaxy. This is the third step in the 6-stage pipeline: **Init** -> **Brainstorm** -> **Plan** -> **Execute** -> **Review** -> **Quiz (Finale)**.

**⚠️ PROMINENT GUARDRAIL**: The **Skeptical Mentor** is your educational partner. If the student fails the Educational Verification phase below, call the mentor immediately.

**Announce at start:** "I'm using the lg-flutter-plan-writer skill to create your implementation plan."

**Save plans to:** `docs/plans/YYYY-MM-DD-<feature-name>-plan.md`

## Bite-Sized Task Granularity

Each step should be a single, logical action taking 5-10 minutes. This helps students stay focused and allows for frequent verification.

- **Visual Flow**: Implement provider → Test with print → Build widget → Verify on device.
- **Commit Often**: Every task should end with a git commit.

## Plan Document Header

Every plan **MUST** start with this header:

```markdown
# [Feature Name] Implementation Plan

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach, specifically mentioning Clean Architecture layers]

**Tech Stack:** [e.g. Riverpod, dartssh2, google_maps_flutter]

**Educational Objectives:** [What engineering principles will the student learn?]

---

## 🗺️ Implementation Checklist
- [ ] Task 1: [Short Title]
- [ ] Task 2: [Short Title]
- [ ] ...

---
```

## Task Structure

````markdown
### Task N: [Component/Logic Name]

**Files:**

- Create: `lib/features/<feature>/data/<file>.dart`
- Modify: `lib/features/<feature>/presentation/<widget>.dart`
- Test: `test/<feature>/<test_file>_test.dart`

**Step 1: Architectural Definition**
Briefly explain _why_ we are touching these files.

**Step 2: Define Logic/Interface**
Write out the specific code.

```dart
// Example: lib/features/connection/providers/connection_provider.dart
final connectionProvider = StateNotifierProvider<ConnectionNotifier, LgConnectionState>((ref) {
  return ConnectionNotifier(ref);
});
```

**Step 3: Verification/Testing**
How does the student know it works?

- **Analyze**: "Run `flutter analyze` to check for errors."
- **Test**: "Run `flutter test` to verify logic."
- **Device**: "Hot reload and verify on tablet emulator."

**Step 4: Commit**

```bash
git add .
git commit -m "feat: [brief description]"
```
````

## Engineering Principles to Enforce

- **Clean Architecture**: Domain layer stays independent of Flutter.
- **Separation of Concerns**: UI in `presentation/`, logic in `domain/`, data in `data/`.
- **Riverpod Best Practices**: Use proper provider types for each use case.
- **Security**: Credentials in `flutter_secure_storage`, never in code.

## 🎓 Educational Verification Phase

Before starting the implementation, you **MUST** conduct a short verification dialogue:

**Ask the following types of questions:**
1. **Architecture Check**: "Why are we putting connection logic in a provider instead of the widget?"
2. **Security Trade-offs**: "What would happen if we stored the SSH password in SharedPreferences?"
3. **SSH Flow**: "Walk me through what happens when the user taps 'Connect to LG'."
4. **Riverpod Patterns**: "Why are we using StateNotifierProvider instead of StateProvider here?"

**Requirement**: Do not proceed to execution until the student provides reasonable answers.

## Execution Handoff

After saving the plan and completing the **Educational Verification Phase**:

**"Plan complete and saved to `docs/plans/<filename>.md`. After our discussion, I'll use the Liquid Galaxy Flutter Plan Executor to start Task 1. Ready?"**
