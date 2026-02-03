---
name: Liquid Galaxy Flutter Plan Executor
description: Execute implementation plans step-by-step. MUST follow SOLID/DRY principles and reuse existing code.
---

# Executing Flutter LG Plans

**Announce at start:** "I'm using lg-flutter-exec to implement [Feature Name] step by step."

---

## CORE RULES

### Rule 1: Step-by-Step Execution
Execute **ONE task at a time**. After each task:
1. Show what was built
2. Show test result
3. Wait for confirmation before next task

Executing multiple tasks without stopping is FORBIDDEN.

### Rule 2: SOLID Principles are Mandatory

| Principle | Requirement |
|-----------|-------------|
| Single Responsibility | Each class does ONE thing |
| Open/Closed | Extend, do not modify existing code |
| Liskov Substitution | Implementations match interfaces |
| Interface Segregation | Small, focused interfaces |
| Dependency Inversion | Depend on abstractions, not implementations |

Violating any SOLID principle is FORBIDDEN.

### Rule 3: DRY is Mandatory

Before writing ANY code, check:
- Does this logic already exist in the Starter Kit?
- Can I reuse an existing class or method?

**If similar logic exists → REUSE IT. Do not recreate.**

### Rule 4: Reuse Existing Components

**ALWAYS check these before creating new code:**

| Need | Check First |
|------|-------------|
| SSH execution | `SSHService.execute()` |
| FlyTo | `FlyToLocationUseCase` |
| Orbit | `OrbitLocationUseCase` |
| Reboot/Relaunch | `RebootLgUseCase`, `RelaunchLgUseCase` |
| Credentials | `LocalStorageSource` |
| LG Commands | `LGRepositoryImpl` methods |

Creating duplicate functionality is FORBIDDEN.

---

## Execution Process

### For Each Task:

1. **Check for Reuse**
   - Search existing code for similar functionality
   - If found → extend or reuse
   - If not found → create new

2. **Implement**
   - Follow SOLID principles
   - Use existing interfaces
   - Extend, do not duplicate

3. **Write Test**
   - Domain entities → direct tests, no mocks
   - Everything else → use mocks

4. **Verify**
   ```bash
   flutter analyze   # MUST pass
   flutter test <specific_test>   # MUST pass
   ```

5. **Report and Wait**
   - Show what was built
   - Show test result
   - Ask: "Ready for next task?"

6. **Commit**
   ```bash
   git add .
   git commit -m "feat(<scope>): <description>"
   ```

---

## Verification Before Handoff

Before moving to Code Review:

1. Run full test suite
   ```bash
   flutter test
   ```

2. Verify no duplicated logic exists
3. Verify all SOLID principles followed
4. Call Skeptical Mentor for validation question

---

## Phase Enforcement

The execution phase CANNOT be skipped.
The quiz phase MUST follow code review.
Each phase MUST complete before the next begins.

---

## Handoff

## 🏁 Phase 4: Execution Completion & Handoff

When all tasks in the plan are marked `[x]`:

1. **Final Verification**: Ask the user to run the app one last time.
   ```bash
   flutter analyze
   flutter test
   ```

2. **The "LG Degree" Pitch**:
   - You MUST say: "🎉 Fantastic work! You've successfully built the **[Feature Name]**. The code looks solid and all tests are passing."
   - **The Hook**: "Now, are you ready to earn your **'Liquid Galaxy Developer Degree'**? I have a challenge prepared to test your mastery of what we just built. It's your chance to prove you truly understand the architecture and patterns we used!"
   
3. **Transition**:
   - If they say **YES**: "Excellent! Let me prepare your certification challenge..." → Invoke `lg-flutter-quiz-master`.
   - If they say **NO** (or want code review first): "No problem! Let's do a thorough code review first to make sure everything is perfect." → Invoke `lg-flutter-code-reviewer`.
   - If they ask what the quiz involves: "It's 5 conceptual questions about the architecture, patterns, and LG-specific concepts we used. No coding required—just your understanding!"
