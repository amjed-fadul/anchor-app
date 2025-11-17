# Claude AI Working Preferences for Anchor App

## 🎯 About the Developer

**Background:** Product designer with limited coding experience (NOT a developer)

**Learning Style:** Need detailed explanations, step-by-step breakdowns, and educational context

**Goal:** Learn while building, understand the "why" behind code decisions

---

## ⚙️ Working Principles

### 1. Always Use Context7
- Use Context7 for all code documentation
- Keep documentation up-to-date as code evolves

### 2. Maintain CHANGELOG.md (MANDATORY)

**What is CHANGELOG.md?**
A living document that tracks ALL fixes, features, and changes to the codebase. Think of it as a **history book** for your project.

**Why is this critical?**
- **Track what was fixed and when** - Never forget why a change was made
- **Help future you** - Remember decisions made 6 months ago
- **Onboard new developers** - Understand project evolution quickly
- **Document important decisions** - Reasoning behind architectural choices
- **Debugging aid** - See when issues were introduced or fixed

**When to Update CHANGELOG.md:**

🔴 **ALWAYS update BEFORE committing code!**

- ✅ **After fixing a bug** → Add to `### Fixed` section
- ✅ **After adding a feature** → Add to `### Added` section
- ✅ **After major refactor** → Add to `### Changed` section
- ✅ **After improving code quality** → Add to `### Improved` section
- ✅ **Before every commit** → Update changelog FIRST, then commit

**Format Example:**

```markdown
### Fixed

#### Brief, Clear Title (YYYY-MM-DD HH:MM)
- **Problem**: What was broken? What was the user impact?
- **Root Cause**: Why did it happen? What was the underlying issue?
- **Solution**: How did we fix it? What approach did we use?
- **Files Changed**: List the files modified
- **Result**: ✅ What's the expected behavior now?
```

**Real Example:**

```markdown
### Fixed

#### Signup Flow - Success Message Instead of Navigation (2025-11-13 14:37)
- **Problem**: After signup, user was redirected to `/onboarding` instead of seeing confirmation instructions
- **Root Cause**: Code tried to navigate to `/home` but user wasn't authenticated yet (email confirmation required)
- **Solution**: Show "Check your email!" success message with clear instructions
- **Files Changed**: `lib/features/auth/screens/signup_email_screen.dart`, `lib/features/auth/screens/login_screen.dart`
- **Result**: ✅ No unwanted redirect, clear UX for email confirmation
```

**Tips for Good Changelog Entries:**

1. **Be Specific**: "Fixed signup redirect" ❌ → "Fixed signup redirect to onboarding after email sent" ✅
2. **Include Context**: Don't just say what changed, explain **why**
3. **Add Impact**: How does this affect users? Developers?
4. **Link Files**: Always list which files were changed
5. **Use Checkmarks**: ✅ for successful fixes, makes scanning easier

**Real-World Analogy:**

Think of CHANGELOG.md like a **ship's log** or **flight recorder**:
- When something goes wrong, you can trace back to see what happened
- When you want to understand a decision, the context is preserved
- When a new person joins, they can read the story of the project

**Workflow Integration:**

```bash
# Your workflow should ALWAYS be:
1. Fix the bug / add the feature
2. Update CHANGELOG.md with detailed entry
3. Run tests to verify fix
4. Commit code + changelog together
5. Push to GitHub
```

### 3. Maintain TODO.md (MANDATORY)

**What is TODO.md?**
A living document that tracks active tasks, planned features, and project roadmap. Think of it as your **project dashboard** or **command center**.

**Why is this critical?**
- **Track current work** - See what's being worked on right now
- **Plan ahead** - Organize upcoming features by priority
- **Avoid forgetting tasks** - Centralized place for all work items
- **Provide visibility** - Understand project status at a glance
- **Stay organized** - Break large goals into manageable tasks

**Difference Between TODO.md and CHANGELOG.md:**

Think of them like a **calendar and history book**:

- **TODO.md** (Calendar) = **Future-focused**
  - What needs to be done
  - What's currently being worked on
  - What's planned for later
  - Updated frequently as work progresses

- **CHANGELOG.md** (History) = **Past-focused**
  - What was done and when
  - Why changes were made
  - Historical record of decisions
  - Updated when committing code

**When to Update TODO.md:**

🔴 **Update FREQUENTLY as work progresses!**

- ✅ **Starting a task** → Move from "Planned" to "Active Tasks" with 🚧 emoji
- ✅ **Completing a task** → Move to "Recently Completed" with ✅ emoji and timestamp
- ✅ **Discovering a bug** → Add to "Known Issues" with 🐛 emoji
- ✅ **Planning a feature** → Add to "Planned Features" with 📋 emoji and priority
- ✅ **Brainstorming ideas** → Add to "Future Ideas" with 💡 emoji
- ✅ **Daily/weekly** → Review and update priorities

**Format Example:**

```markdown
## 🚧 Active Tasks

- 🚧 Implementing home screen (started 2025-11-13 15:00)
  - Building UI layout
  - Integrating with Supabase
  - Adding pull-to-refresh

## 📋 Planned Features

### High Priority
- 📋 Add link functionality (save URLs)
- 📋 Spaces feature (organize links)

### Medium Priority
- 📋 Search functionality
- 📋 Link sharing

## 🐛 Known Issues

- 🐛 Slow loading on old devices (investigating)

## ✅ Recently Completed (Last 7 Days)

- ✅ Fixed signup redirect bug (2025-11-13 14:37)
- ✅ Configured email deep link (2025-11-13 14:40)
```

**Real-World Analogy:**

Think of TODO.md like a **construction site whiteboard**:
- Shows what's being built today (Active Tasks)
- Lists what's planned next (Planned Features)
- Notes problems to fix (Known Issues)
- Celebrates what's done (Recently Completed)

**Workflow Integration:**

```bash
# Your daily workflow:
1. Check TODO.md - What am I working on today?
2. Move task to "Active Tasks" with 🚧 emoji
3. Work on the task (code, test, commit)
4. Update CHANGELOG.md when committing
5. Move task to "Recently Completed" in TODO.md with ✅
6. Check TODO.md - What's next?
```

**Weekly Cleanup:**

Every week:
1. Move completed items older than 7 days to CHANGELOG.md only
2. Re-prioritize planned features (what's most important now?)
3. Review "Future Ideas" - promote any to "Planned Features"
4. Update "Last Updated" timestamp at top of TODO.md

**Tips for Good TODO Entries:**

1. **Be Specific**: "Add feature" ❌ → "Implement home screen with saved links display" ✅
2. **Add Context**: Include start date/time when moving to Active
3. **Use Emojis**: Makes scanning easier (🚧 active, ✅ done, 🐛 bug, 📋 planned, 💡 idea)
4. **Set Priorities**: High/Medium/Low helps focus on what matters
5. **Keep It Current**: A stale TODO.md is useless - update it often!

### 4. Documentation Lifecycle - Preventing Drift (MANDATORY)

**The Documentation Pyramid:**
Every change must flow through ALL relevant documentation levels.

```
┌─────────────────────────────────────┐
│   README.md (Project Overview)      │ ← Update when phases/features change
├─────────────────────────────────────┤
│   AMENDMENTS.md (Architecture)      │ ← Update when design decisions made
├─────────────────────────────────────┤
│   TODO.md (Active Work)             │ ← Update when starting/finishing tasks
├─────────────────────────────────────┤
│   CHANGELOG.md (History)            │ ← Update when committing code
└─────────────────────────────────────┘
```

**CRITICAL RULE:** Documentation is NOT optional cleanup - it's PART OF THE TASK.

**A task is NOT complete until ALL relevant documentation is updated.**

---

#### When to Update Each Document

**📋 TODO.md** - Update IMMEDIATELY when:
- ✅ **Starting a task** → Move to "Active Tasks" with 🚧 emoji + timestamp
- ✅ **Finishing a task** → Move to "Recently Completed" with ✅ emoji + timestamp
- ✅ **Discovering a bug** → Add to "Known Issues" with 🐛 emoji
- ✅ **Planning a feature** → Add to "Planned Features" with 📋 emoji and priority
- ✅ **Rejecting a feature** → Add to "🚫 Explicitly Rejected Ideas" with detailed reason
- ✅ **Daily** → Update "Last Updated" timestamp at top of file

**📝 CHANGELOG.md** - Update BEFORE committing:
- ✅ **After every feature** → Add to `### Added` section
- ✅ **After every bug fix** → Add to `### Fixed` section
- ✅ **After refactor** → Add to `### Changed` section
- ✅ **After code quality improvements** → Add to `### Improved` section
- ✅ **Always include**: Problem, Root Cause, Solution, Files Changed, Result
- ✅ **Never commit code without updating CHANGELOG.md first!**

**📖 README.md** - Update when:
- ✅ **Phase/sprint completes** → Update roadmap status (Phase X: ✅ COMPLETE)
- ✅ **New major feature** → Add to "Key Features" section if user-facing
- ✅ **Technology stack changes** → Update "Technology Stack" section
- ✅ **Project structure changes** → Update folder diagram
- ✅ **Version milestones** → Update version number (e.g., 0.7.0 → 0.8.0)
- ✅ **Weekly** → Verify roadmap accuracy vs actual TODO.md progress

**⚙️ PRD/AMENDMENTS.md** - Update when:
- ✅ **Architectural decision made** → Add new section with rationale
- ✅ **Feature explicitly rejected** → Document in "What We're NOT Doing" with reason
- ✅ **Database schema changes** → Update schema examples if they affect core model
- ✅ **Core organizational model changes** → Document design decision (e.g., Spaces-Only model)
- ✅ **Design conflicts discovered** → Document conflict + resolution strategy

---

#### Validation Checklist (Run Weekly)

**Prevent Documentation Drift:**

🔍 **Question 1:** Does TODO.md "Active Tasks" match what you're actually working on?
- ❌ If not: Update TODO.md immediately - you're working on undocumented tasks

🔍 **Question 2:** Does README.md roadmap show the correct current phase?
- ❌ If not: Update README.md with actual progress (e.g., Phase 0 → Phase 5)

🔍 **Question 3:** Are there features in TODO.md marked "✅ Complete" but not in CHANGELOG.md?
- ❌ If yes: Those features aren't actually complete until documented

🔍 **Question 4:** Are there git commits from the last week without CHANGELOG.md entries?
- ❌ If yes: Add retroactive entries immediately (never skip this!)

🔍 **Question 5:** Did you make an architectural decision that's not in AMENDMENTS.md?
- ❌ If yes: Document it now with full rationale before you forget

🔍 **Question 6:** Does README.md reference correct file paths?
- ❌ If not: Fix broken links (e.g., `docs/PRD/` → `PRD/`)

**The 3-Second Rule:**
If you can't find a feature/decision in documentation within 3 seconds, the docs have drifted. **Fix immediately.**

---

#### Real-World Analogy

Think of documentation like a **GPS navigation system**:

**Without proper docs (❌):**
- Like driving without GPS - you might reach the destination, but nobody else knows how
- Team members get lost trying to understand what's been done
- You forget your own decisions 6 months later
- New contributors have no idea where the project is going

**With proper docs (✅):**
- Like GPS with real-time updates - everyone knows current location and destination
- Clear trail of decisions and progress
- New team members can jump in immediately
- Future you says "thank you" when revisiting the project

**Documentation drift is like GPS showing you in the wrong city - dangerous and confusing!**

---

### 5. Make Small, Incremental Changes
- **Never** create large files or make sweeping changes
- Break everything into tiny, digestible steps
- One logical change per commit
- Easier to understand, review, and learn from

### 6. Push to GitHub Frequently
- Commit after each small change
- Clear, descriptive commit messages
- Keep commit history clean and educational

### 7. Be in Learning Mode (CRITICAL)
- **Explain everything** as if teaching a beginner
- Break down complex concepts into simple parts
- Use analogies and real-world examples
- Add detailed code comments explaining what AND why
- Share reasoning process, not just solutions

### 8. Educational Code Changes
- Explain each step before implementing
- Break code changes into individual modifications
- Add inline comments for learning (can be removed later)
- Show before/after comparisons when helpful

### 9. Always Use Test-Driven Development (TDD) - MANDATORY

**What is TDD?**
Test-Driven Development means writing tests BEFORE writing the actual code. It's a three-step cycle called **Red-Green-Refactor**:

1. **🔴 RED** - Write a test that fails (because the code doesn't exist yet)
2. **🟢 GREEN** - Write just enough code to make the test pass
3. **🔵 REFACTOR** - Improve the code while keeping tests passing

**Why TDD Matters:**
- **Confidence:** You know your code works because tests prove it
- **Better Design:** Writing tests first forces you to think about how code should work
- **Living Documentation:** Tests show examples of how to use your code
- **Catch Bugs Early:** Find problems immediately, not in production
- **Easier Refactoring:** Change code fearlessly - tests catch breaking changes

**Real-World Analogy:**
Think of TDD like **building with a safety harness**:

**Without TDD (❌ Risky):**
- Like building on a ladder without safety equipment
- You make changes and HOPE nothing breaks
- You find out it broke when you (or a user) falls

**With TDD (✅ Safe):**
- Like having a safety harness that catches you immediately if something goes wrong
- You make changes and KNOW if they work
- If something breaks, the test catches it before anyone gets hurt

**The TDD Workflow - ALWAYS Follow These Steps:**

1. **Understand the requirement**
   - What should this code do?
   - What inputs does it take?
   - What outputs should it produce?

2. **Write the test FIRST (🔴 RED)**
   - Create a test file: `name_of_file_test.dart`
   - Write a test that describes what the code should do
   - Run the test - it MUST fail (code doesn't exist yet!)
   - If it passes, your test is wrong!

3. **Write minimal code to pass (🟢 GREEN)**
   - Write the simplest code that makes the test pass
   - Don't add extra features or "nice-to-haves"
   - Run the test - it should now pass

4. **Refactor (🔵 REFACTOR)**
   - Clean up the code
   - Remove duplication
   - Improve naming
   - Run tests again - they should still pass

5. **Repeat for next feature**

**Example: Building an Email Validator**

**Step 1: Write test FIRST (before any validator code exists)**
```dart
// test/shared/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:anchor_app/shared/utils/validators.dart';

void main() {
  group('Email Validator', () {
    test('returns null for valid email', () {
      // Arrange: Set up test data
      const validEmail = 'user@example.com';

      // Act: Call the function we want to test
      final result = Validators.email(validEmail);

      // Assert: Check the result is what we expect
      expect(result, null); // null = no error = valid
    });

    test('returns error message for invalid email', () {
      const invalidEmail = 'notanemail';
      final result = Validators.email(invalidEmail);
      expect(result, 'Please enter a valid email');
    });

    test('returns error message for empty email', () {
      const emptyEmail = '';
      final result = Validators.email(emptyEmail);
      expect(result, 'Email is required');
    });
  });
}
```

**Step 2: Run test - Watch it FAIL (🔴 RED)**
```bash
flutter test test/shared/utils/validators_test.dart
# Error: Validators.email doesn't exist yet - GOOD!
```

**Step 3: Write minimal code to pass (🟢 GREEN)**
```dart
// lib/shared/utils/validators.dart
class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }

    return null; // No error = valid
  }
}
```

**Step 4: Run test - Watch it PASS (🟢 GREEN)**
```bash
flutter test test/shared/utils/validators_test.dart
# All tests pass! ✅
```

**Step 5: Refactor if needed (🔵 REFACTOR)**
- Code is already clean
- Tests still pass ✅

**Flutter Testing Basics:**

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage

# Watch mode (re-run on file changes)
flutter test --watch
```

**Common TDD Pitfalls for Beginners:**

1. **❌ Writing code first, tests later**
   - This defeats the purpose! Always test FIRST

2. **❌ Writing tests that always pass**
   - If your test passes before you write code, it's not testing anything
   - Always verify tests fail first (🔴 RED)

3. **❌ Testing implementation instead of behavior**
   - Bad: "The function should call this other function"
   - Good: "The function should return null for valid emails"

4. **❌ Making tests too complex**
   - Each test should verify ONE thing
   - Use descriptive test names: `test('returns error for empty password')`

5. **❌ Skipping tests because "it's a small change"**
   - Small changes can cause big bugs
   - ALWAYS write tests, even for tiny functions

**What to Test (Unit Tests Focus):**
- ✅ Business logic functions
- ✅ Utility functions (validators, formatters)
- ✅ Service methods (auth, API calls)
- ✅ Model methods
- ✅ State management logic
- ✅ Error handling

**Every Code Change Needs Tests:**
- New feature? Write tests first
- Bug fix? Write a test that reproduces the bug, then fix it
- Refactoring? Tests ensure you don't break anything
- Even "simple" functions need tests

### 10. Analyze Impact Before Fixing Bugs (CRITICAL)

**What is Impact Analysis?**
Before fixing ANY bug, analyze ALL related features and workflows that might be affected by your fix. Think of it like **surgery** - you need to know what else is connected before cutting!

**Why This is Critical:**
- **Prevent breaking other features** - A "fix" that breaks something else isn't a fix
- **Understand the full system** - Bugs often exist in complex systems with many interactions
- **Avoid regression** - Don't create new bugs while fixing old ones
- **Learn the architecture** - Understanding related features deepens your knowledge

**Real-World Analogy:**
Think of fixing bugs like **repairing plumbing**:
- ❌ **Bad**: See a leak, patch it quickly → might break water pressure elsewhere
- ✅ **Good**: See a leak, trace all connected pipes, understand the system, then fix carefully

**The Impact Analysis Workflow - ALWAYS Follow These Steps:**

1. **Identify the Bug**
   - What's broken? (the symptom)
   - Why is it broken? (the root cause)
   - When did it break? (recent change? always been this way?)

2. **Map Related Features**
   - What other features use this code?
   - What workflows involve this functionality?
   - What edge cases exist?
   - What assumptions does this code make?

3. **Create a Test Matrix**
   - List ALL scenarios that should work
   - Include normal cases AND edge cases
   - Document expected behavior for each
   - This becomes your validation checklist

4. **Design the Fix**
   - Will this fix handle ALL scenarios?
   - Does it break any existing functionality?
   - Are there any edge cases it doesn't handle?
   - Is there a better architectural solution?

5. **Implement with Tests**
   - Write tests for ALL scenarios (not just the bug)
   - Implement the fix
   - Run ALL tests (not just new ones!)
   - Manual testing on real devices

6. **Validate Everything**
   - Check your test matrix - does everything still work?
   - Test related features manually
   - Look for unintended side effects
   - Get a second opinion if unsure

**Example: Router Redirect Bug**

**BAD Approach (❌ Don't Do This):**
```
1. See bug: "Users stuck on login screen after authentication"
2. Quick fix: "Redirect authenticated users from /login to /home"
3. Commit and push
4. **BREAKS**: Password reset flow now broken!
```

**GOOD Approach (✅ Do This):**
```
1. Identify Bug:
   - Symptom: Users stuck on /login after successful authentication
   - Root cause: Router allows authenticated users on /login
   - When: After logout → login cycle

2. Map Related Features:
   - Normal login flow (unauthenticated → authenticated)
   - Password reset flow (recovery session handling)
   - Logout then login cycle
   - Deep link navigation
   - Session expiry scenarios

3. Create Test Matrix:
   ┌─────────────────────────┬─────────────┬──────────────────┐
   │ Scenario                │ Current Bug │ After Fix        │
   ├─────────────────────────┼─────────────┼──────────────────┤
   │ Authenticated (normal)  │ Stuck       │ Redirect to home │
   │ Authenticated (recovery)│ Works       │ Keep working     │
   │ Unauthenticated         │ Works       │ Keep working     │
   │ After password reset    │ Works       │ Keep working     │
   └─────────────────────────┴─────────────┴──────────────────┘

4. Design Fix:
   - Add redirect for authenticated users WITHOUT recovery
   - Keep existing redirect for recovery sessions
   - Keep access for unauthenticated users
   - Ensures ALL scenarios work

5. Implement:
   - Write tests for all 4 scenarios
   - Implement router changes
   - Run full test suite
   - Manual test each scenario

6. Validate:
   - ✅ Normal login: redirects to home
   - ✅ Recovery login: still goes to reset password
   - ✅ Unauthenticated: can access login
   - ✅ After reset: can test new password
```

**Common Related Features to Check:**

When fixing bugs in:
- **Authentication** → Check: login, signup, logout, password reset, session handling
- **Navigation/Router** → Check: deep links, redirects, back button, auth guards
- **Database** → Check: migrations, RLS policies, queries using that table
- **UI Components** → Check: screens using that component, responsive design
- **State Management** → Check: all providers/notifiers reading that state

**Red Flags That You Need More Analysis:**

🚨 **STOP and analyze more if:**
- You're not sure what other code uses this
- The fix feels hacky or like a workaround
- You're changing code you don't fully understand
- Multiple people have tried to fix this before
- The bug only happens sometimes (race condition?)
- You're about to change core/shared code
- The feature has lots of edge cases

**Questions to Ask Yourself:**

Before committing your fix:
- ✅ Did I test ALL related workflows?
- ✅ Did I check for edge cases?
- ✅ Did I run the full test suite?
- ✅ Did I manually test on a device?
- ✅ Did I update documentation/comments?
- ✅ Would this fix make sense to someone reviewing it?
- ✅ Am I confident this doesn't break anything?

If you answer "no" or "not sure" to ANY of these → **DO MORE ANALYSIS!**

**Real Example from This Project:**

**Bug Report**: "Users stuck on login screen after authentication"

**Quick Fix Temptation**: Just redirect all authenticated users from /login
**Problem**: Would break password reset flow (users with recovery sessions)

**Proper Analysis Revealed**:
- Router has special /login handling for recovery sessions
- Password reset users need to access /login after reset completion
- Different session types need different behavior
- Fix must handle BOTH normal and recovery sessions differently

**Result**: Comprehensive fix that handles all scenarios without breaking existing functionality

**Tips for Good Impact Analysis:**

1. **Draw Diagrams**: Sketch out the system and highlight affected parts
2. **Talk It Through**: Explain the fix to someone (or a rubber duck!)
3. **Check Git History**: See why code was written that way originally
4. **Read Tests**: Existing tests show expected behavior
5. **Ask Questions**: Better to ask than to break something!

**When in Doubt:**
- Ask the user/team for clarification
- Do more research
- Create a proof-of-concept to test your approach
- Write the tests before the fix (TDD helps here!)

Remember: **Taking time to analyze is FASTER than fixing bugs your fix creates!**

### 11. Always Add Debug Logging Before Fixing Bugs (CRITICAL)

**What is Debug Logging First?**
Before attempting to fix ANY bug, ALWAYS add comprehensive debug logging (`debugPrint()`) to trace the execution flow and identify the exact location where the issue occurs.

**Why This is Critical:**
- **Saves massive time** by finding the real root cause immediately instead of guessing
- **Prevents wasted effort** on multiple failed fix attempts based on assumptions
- **Creates a clear execution trail** showing exactly what's happening
- **Helps understand the system** better through visibility into the flow
- **Enables faster future debugging** when logs are left in place

**Real-World Analogy:**
Think of debugging like **diagnosing a car problem**:
- ❌ **Bad**: Hear a noise, start replacing parts randomly → waste time and money
- ✅ **Good**: Use diagnostics to pinpoint the exact issue, then fix it precisely

**The Workflow - ALWAYS Follow These Steps:**

1. **Bug Reported** → ❌ DON'T try to fix immediately!
2. **Add Debug Logging** throughout the suspected code flow:
   - Start of functions: `debugPrint('🔵 [ClassName] methodName START')`
   - Before async operations: `debugPrint('🔵 [ClassName] Awaiting someOperation...')`
   - After success: `debugPrint('🟢 [ClassName] Operation succeeded: $result')`
   - Before errors: `debugPrint('🔴 [ClassName] ERROR: $error')`
   - Key variable states: `debugPrint('🔵 [ClassName] variableName = $value')`
3. **Run the app** and reproduce the bug
4. **Analyze logs** to find the EXACT location where execution stops or fails
5. **THEN fix the bug** with confidence knowing the real issue
6. **Keep the logs** - they help with future debugging and understanding

**Example from Real Bug Fix:**

**Bug**: Loading spinner spins infinitely when opening tag picker

**❌ Wrong Approach** (Guessing):
- "Maybe it's a timeout issue" → Add random timeouts → Doesn't work
- "Maybe it's the provider" → Refactor provider → Doesn't work
- "Maybe it's Supabase" → Change query → Doesn't work
- **Result**: 3 failed attempts, hours wasted, still broken

**✅ Right Approach** (Debug Logging First):
```dart
// Added logs:
debugPrint('🔵 [LinkCard] _showTagPicker START');
debugPrint('🔵 [LinkCard] Awaiting tagsProvider.future...');
debugPrint('🟢 [LinkCard] Tags loaded! Count: ${tags.length}');
debugPrint('🔵 [LinkCard] context.mounted = ${context.mounted}');
debugPrint('🔵 [LinkCard] Closing loading dialog');
```

**Logs revealed**:
```
🟢 [LinkCard] Tags loaded! Count: 36  ← Tags load fine!
🔵 [LinkCard] context.mounted = false  ← AH-HA! Context is unmounted!
(No "Closing loading dialog" log)     ← Dialog never closes!
```

**Result**: Found exact issue in 2 minutes, fixed in 1 line of code!

**Best Practices:**

1. **Use Emojis** for easy visual scanning:
   - 🔵 = Normal flow/info
   - 🟢 = Success
   - 🔴 = Error
   - ⚠️ = Warning

2. **Include Context** in every log:
   - `[ClassName]` prefix shows where log is from
   - Include method name
   - Show variable values

3. **Log Key Decision Points**:
   - Before if statements: `debugPrint('🔵 Checking: condition = $value')`
   - In branches: `debugPrint('🔵 Taking path A')`
   - After async operations

4. **Don't Remove Logs After Fixing**:
   - Leave them in for future debugging
   - `debugPrint()` is production-safe (only shows in debug mode)
   - They serve as inline documentation

**When in Doubt**:
- Add MORE logs, not fewer
- Better to have too much information than too little
- Logs cost nothing but save hours

**Remember:** "Measure twice, cut once" → **Log first, fix second!**

---

## 🚦 Visual Risk Signals

Use clear emoji indicators for change magnitude:

- 🟢 **SAFE** - Documentation, small config changes, comments
- 🟡 **LOW RISK** - Small code files, simple features, isolated changes
- 🟠 **MEDIUM RISK** - Important features, database changes, new dependencies
- 🔴 **HIGH RISK** - Core functionality, complex integrations, large refactors

### Risk Level Guidelines

**🟢 SAFE Changes:**
- README updates
- Comment additions
- Documentation files
- .gitignore modifications
- Small config tweaks

**🟡 LOW RISK Changes:**
- Single small function
- New simple component
- Basic styling
- Test files

**🟠 MEDIUM RISK Changes:**
- Database schema changes
- New API endpoints
- State management updates
- Important feature additions

**🔴 HIGH RISK Changes:**
- Authentication logic
- Payment integrations
- Data migration scripts
- Breaking changes to APIs

**⚠️ IMPORTANT: All Risk Levels Require Unit Tests**
- 🟢 SAFE: Tests not required for pure documentation/config changes
- 🟡 LOW RISK: **Tests required** for all code changes (functions, components, logic)
- 🟠 MEDIUM RISK: **Tests required** + consider integration tests
- 🔴 HIGH RISK: **Tests required** + comprehensive test coverage

**Remember:** If you're writing code, you're writing tests FIRST (TDD). No exceptions!

---

## ⚠️ Change Approval Process

### For 🟢 SAFE changes:
- Proceed with explanation
- Commit immediately

### For 🟡 LOW RISK changes:
- Explain what and why
- Show the code
- Wait for acknowledgment

### For 🟠 MEDIUM RISK changes:
- **⚠️ MEDIUM CHANGE ALERT**
- Detailed explanation of impact
- Show code with comments
- **Wait for explicit approval**
- Offer alternatives if available

### For 🔴 HIGH RISK changes:
- **🔴 HIGH RISK MODIFICATION ALERT**
- Comprehensive explanation of:
  - What it does
  - Why it's needed
  - What could go wrong
  - How to recover if issues occur
- Detailed code walkthrough
- **MUST wait for explicit approval**
- Provide rollback strategy

---

## 💬 Communication Style

### Always Include:
1. **What** we're doing (simple terms)
2. **Why** we're doing it (the purpose)
3. **How** it works (technical explanation)
4. **What to watch for** (potential issues)

### Code Explanations Should:
- Start with high-level overview
- Break down into components
- Explain each line if it's new concept
- Use analogies for complex topics
- Connect to real-world use cases

### Example Format:
```
## 🟡 Task: Create User Model

**What:** Creating a User class to represent user accounts
**Why:** We need a structured way to store user data
**Risk:** 🟡 LOW RISK - Simple data structure

**Explanation:**
Think of a class like a template or blueprint. Just like a house blueprint shows:
- Number of rooms
- Where the kitchen goes
- How big the garage is

Our User class shows:
- What information a user has (email, name, etc.)
- How that information is structured
- What we can do with that information

[Then show the code with inline comments]
```

---

## 📁 Project Structure Preferences

- Keep files small and focused (Single Responsibility)
- Clear folder organization by feature
- Self-documenting file names
- Comments for non-obvious code
- README in each major folder

---

## 🔄 Workflow Summary (with TDD + Documentation)

**Before Starting Any Task:**
1. **Update TODO.md** → Move task to "🚧 Active Tasks" with emoji + timestamp
2. **Check AMENDMENTS.md** → Is this task consistent with architectural decisions?

**During Task Execution:**
3. **Explain** the task in simple terms
4. **Highlight** the risk level with emoji
5. **Wait** for approval if needed (MEDIUM/HIGH risk)
6. **Write test FIRST** (🔴 RED)
   - Create test file if it doesn't exist
   - Write test that describes expected behavior
   - Run test - it MUST fail
7. **Show** the test code with detailed comments
8. **Write implementation** (🟢 GREEN)
   - Write minimal code to make test pass
   - Show the code with detailed comments
9. **Run test** - verify it passes (🟢 GREEN)
10. **Refactor** if needed (🔵 REFACTOR)
    - Clean up code
    - Run tests again - should still pass

**After Completing Task (MANDATORY DOCUMENTATION):**
11. **Update CHANGELOG.md** → Add detailed entry (Problem, Solution, Files, Result)
12. **Update TODO.md** → Move task to "✅ Recently Completed" with emoji + timestamp
13. **Update README.md** (if applicable) → Phase progress, new features, roadmap
14. **Update AMENDMENTS.md** (if applicable) → Architectural decisions, rejected features
15. **Commit** to GitHub with clear message
    - Include "Tests: ✅ passing" in commit
    - Commit code + all updated docs together (NEVER separate!)
16. **Verify docs sync** → Quick scan: Does everything align?
17. **Move** to next task

**📚 Documentation is NOT "cleanup" - it's PART OF COMPLETING THE TASK.**

**🚫 A task with code but no docs = INCOMPLETE TASK**

---

## 🐛 Bug Fixing Workflow

**CRITICAL:** When fixing a bug:
1. **Identify** the root cause (not just the symptom)
2. **Implement** the fix with clear code changes
3. **Verify** with linting (`flutter analyze` or equivalent)
4. **ALWAYS end** with a simple one-sentence summary using exactly 3 alarm emojis (🚨🚨🚨)

**This is MANDATORY and must be the very last sentence in your response.**

Example: "Fixed deprecated Color accessor usage in colorToHex method 🚨🚨🚨"

---

## ✅ Success Criteria

Changes are successful when:
- ✅ Developer understands what was done
- ✅ Developer understands why it was done
- ✅ Developer could explain it to someone else
- ✅ **Tests were written FIRST** (before implementation)
- ✅ **All tests pass** (`flutter test` shows no failures)
- ✅ **Test coverage for new/changed code** (unit tests for all logic)
- ✅ **CHANGELOG.md updated** with detailed entry (Problem, Solution, Files, Result)
- ✅ **TODO.md updated** (moved task to "Recently Completed" with ✅ + timestamp)
- ✅ **README.md updated** (if phase/feature/roadmap changed)
- ✅ **AMENDMENTS.md updated** (if architectural decision made or feature rejected)
- ✅ **Documentation sync verified** - All docs align, no drift detected
- ✅ Code + all updated docs committed to GitHub together (NEVER separate commits!)
- ✅ No errors or warnings
- ✅ Ready for next step

**🚨 CRITICAL: If ANY item above is ❌, the task is NOT complete. No exceptions.**

---

## 🚫 Never Do This

- ❌ Make large, sweeping changes without explanation
- ❌ Use advanced concepts without teaching them first
- ❌ Commit multiple unrelated changes together
- ❌ Skip explanations for "obvious" things
- ❌ Assume prior knowledge
- ❌ Make risky changes without approval

---

## 📱 Responsive Design Requirements (CRITICAL)

### The Problem We're Solving
The app MUST work on all popular device sizes - from small phones (5.4") to large tablets (10"+). Fixed pixel layouts from Figma don't adapt to different screens, causing buttons to be cut off and content to overflow.

### Mandatory Responsive Design Rules

**🚫 NEVER Use These:**
- ❌ `Positioned` with hardcoded `top`/`left`/`right`/`bottom` pixel values
- ❌ Fixed heights that don't account for screen size variations
- ❌ Non-scrollable `Stack` layouts for primary content
- ❌ Assuming a specific screen height or width

**✅ ALWAYS Use These:**
- ✅ `Column` with `Spacer`, `Expanded`, `Flexible` for vertical layouts
- ✅ `Row` with `Spacer`, `Expanded`, `Flexible` for horizontal layouts
- ✅ `MediaQuery.of(context).size` to get actual screen dimensions
- ✅ `SafeArea` to avoid notches and system UI
- ✅ `SingleChildScrollView` for content that might overflow
- ✅ Percentage-based sizing (e.g., `width: MediaQuery.of(context).size.width * 0.8`)
- ✅ `LayoutBuilder` for complex responsive logic

### Popular Device Sizes to Support

**Small Phones (5.4" - 6.1"):**
- iPhone SE (5.4")
- Samsung Galaxy S22 (6.1")
- Google Pixel 5 (6.0")

**Medium Phones (6.1" - 6.5"):**
- iPhone 14 (6.1")
- Samsung Galaxy S23 (6.1")
- Google Pixel 7 (6.3")

**Large Phones (6.5" - 6.9"):**
- iPhone 14 Pro Max (6.7")
- Samsung Galaxy S23 Ultra (6.8")
- Google Pixel 7 Pro (6.7")

**Tablets (7"+):**
- iPad Mini (8.3")
- iPad (10.9")
- Samsung Galaxy Tab (10.5")

### Responsive Layout Patterns

**Pattern 1: Column with Spacer (Recommended)**
```dart
Column(
  children: [
    const Spacer(flex: 2),  // Top spacing
    YourWidget(),
    const Spacer(flex: 1),  // Middle spacing
    AnotherWidget(),
    const SizedBox(height: 24),  // Fixed bottom padding
  ],
)
```

**Pattern 2: MediaQuery for Conditional Sizing**
```dart
Container(
  width: MediaQuery.of(context).size.width * 0.9,  // 90% of screen width
  height: MediaQuery.of(context).size.height < 700
    ? 200  // Small screens
    : 300, // Large screens
)
```

**Pattern 3: LayoutBuilder for Breakpoints**
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return MobileLayout();
    } else {
      return TabletLayout();
    }
  },
)
```

### Testing Checklist

Before committing any UI changes, test on:
- [ ] Small phone emulator (Pixel 5 or similar)
- [ ] Medium phone emulator (Pixel 7 or similar)
- [ ] Large phone emulator (Pixel 7 Pro or similar)
- [ ] Physical device (if available)
- [ ] Tablet emulator (for major screens)

**Quick Test Command:**
```bash
# List available emulators
flutter emulators

# Run on specific emulator
flutter run -d <emulator-id>
```

### Common Responsive Issues to Avoid

**Issue 1: Button Cut Off at Bottom**
- ❌ Using `top: 746px` positioning
- ✅ Use `Column` with `Spacer` or `const SizedBox(height: 40)` at bottom

**Issue 2: Text Overflowing Container**
- ❌ Fixed width without overflow handling
- ✅ Use `Flexible` or `Expanded` with `overflow: TextOverflow.ellipsis`

**Issue 3: Image Stretching Incorrectly**
- ❌ Using `fit: BoxFit.fill`
- ✅ Use `fit: BoxFit.cover` or `fit: BoxFit.contain`

**Issue 4: Keyboard Covering Input Fields**
- ❌ Not using `SingleChildScrollView`
- ✅ Wrap form in `SingleChildScrollView` with `keyboardDismissBehavior`

### Real-World Analogy

Think of responsive design like **furniture in different sized rooms**:

**Fixed Positioning (❌ Bad):**
- Like saying "put the couch 10 feet from the left wall"
- Works in one room, but in a smaller room, the couch hits the opposite wall!

**Flexible Layout (✅ Good):**
- Like saying "put the couch in the center with 20% space on each side"
- Works in ANY room size because it adapts proportionally

### When Adding New Screens

For every new screen, ask:
1. Does this layout work on a 5.4" phone?
2. Does this layout work on a 10" tablet?
3. Can users reach all buttons without scrolling?
4. Does text stay readable at different sizes?
5. Do images scale properly?

If any answer is "no" or "maybe", redesign using flexible layouts.

---

## 📚 Learning Resources

When introducing new concepts, provide:
- Simple explanation in own words
- Link to official docs (if helpful)
- Real-world analogy
- Example usage
- Common pitfalls to avoid

---

*This document guides all AI interactions on the Anchor App project. Updated: November 2025*
