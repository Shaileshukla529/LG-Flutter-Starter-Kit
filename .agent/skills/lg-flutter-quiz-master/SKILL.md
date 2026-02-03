---
name: Liquid Galaxy Flutter Quiz Master
description: Final assessment. MUST be completed. Cannot be skipped.
---

# The Final Quiz

# 🎓 The Certification Process

**Announce at start:** "Welcome to the Finale! To earn your **Liquid Galaxy Developer Degree**, you must answer 5 conceptual questions about the code you just wrote. No multiple choice—I need to hear your reasoning and understanding!"

---

## CORE RULES

### Rule 1: This is Your Certification Exam
The quiz phase CANNOT be skipped.
Every completed feature MUST end with a quiz.
This is not just a test—it's your **LG Developer Degree** certification.

### Rule 2: 5 Questions Required
Each quiz covers:
1. **Architecture**: Understanding of Clean Architecture and layer separation
2. **LG Specifics**: SSH connectivity, KML handling, and LG command patterns
3. **State Management**: Why Riverpod, how it works with your feature
4. **Security**: Credential handling, SSH safety, error scenarios
5. **Scaling**: How to extend your feature, handle edge cases

### Rule 3: Scoring Determines Outcome
- **5/5 correct** → 🏆 Graduate with Honors + "LG Master" badge
- **3-4 correct** → 🎓 Graduate + "LG Developer" badge
- **1-2 correct** → 📚 Return to learning with targeted review

---

## Quiz Process

### Ask One Question at a Time
Wait for answer before next question.

### Evaluate Each Answer
- Correct: award point
- Wrong: explain correct answer

### Question Categories (Tailor to Feature Built)

**Q1 - Architecture (Clean Architecture):**
"Why did we put the [specific logic] in the [Entity/UseCase/Repository] instead of the [Widget/Page]?"
- Looking for: Understanding of layer separation and Single Responsibility

**Q2 - LG Specifics (Connectivity & Commands):**
"When the user triggers [action], trace the complete path from the button tap to the LG screens updating."
- Looking for: Understanding of SSH execution flow, KML generation, and command delivery

**Q3 - State Management (Riverpod):**
"Why did we use a [StateNotifier/FutureProvider/etc.] for [feature state] instead of just StatefulWidget?"
- Looking for: Understanding of reactive state, dependency injection, and testability

**Q4 - Security (Credentials & Error Handling):**
"What would happen if the SSH connection drops mid-execution? How does our code handle that?"
- Looking for: Understanding of error handling, connection lifecycle, and secure credential storage

**Q5 - Scaling (Extension & Edge Cases):**
"How would you extend this feature to support [realistic addition]? What would you need to change?"
- Looking for: Understanding of Open/Closed principle and architectural flexibility

---

## 🏆 Graduation Report & Award

Create `docs/reviews/YYYY-MM-DD-graduation.md`:
```markdown
# 🎓 LG Developer Degree: [Feature]

## Final Score: [X]/5

## Question Results
| # | Category | Result | Notes |
|---|----------|--------|-------|
| 1 | Architecture | ✅/❌ | [Brief feedback] |
| 2 | LG Specifics | ✅/❌ | [Brief feedback] |
| 3 | State Management | ✅/❌ | [Brief feedback] |
| 4 | Security | ✅/❌ | [Brief feedback] |
| 5 | Scaling | ✅/❌ | [Brief feedback] |

## Outcome: 🎓 GRADUATE / 📚 RETURN TO LEARNING

[Personalized feedback]
```

### Award Announcements

**If 5/5 (Honors):**
"🏆 **CONGRATULATIONS!** You've earned your **LG Developer Degree with Honors**! You have a deep understanding of Clean Architecture, LG connectivity, and Flutter best practices. You've mastered the [Feature Name] implementation. Ready to tackle your next challenge?"

**If 3-4/5 (Graduate):**
"🎓 **Well done!** You've earned your **LG Developer Degree** for [Feature Name]! You have a solid grasp of the fundamentals. Areas to strengthen: [list]. Ready for your next feature?"

**If 1-2/5 (Return to Learning):**
"📚 Not quite yet! You're on the right track, but let's review these concepts together: [list weak areas]. Learning is a journey—shall I explain [weakest area] in a simpler way?"

---

## Handoff

**If GRADUATE (3+ correct):**
- Award the degree
- Offer to start new feature: "What's next on your Liquid Galaxy learning journey?"

**If RETURN TO LEARNING (0-2 correct):**
- Identify the weakest category
- Ask: "Would you like me to explain [weak concept] again, or should we rebuild [component] together with more explanation?"
- Return to relevant skill (`lg-flutter-brainstormer` for architecture, `lg-flutter-exec` for implementation)
