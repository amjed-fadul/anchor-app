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

### 4. Make Small, Incremental Changes
- **Never** create large files or make sweeping changes
- Break everything into tiny, digestible steps
- One logical change per commit
- Easier to understand, review, and learn from

### 5. Push to GitHub Frequently
- Commit after each small change
- Clear, descriptive commit messages
- Keep commit history clean and educational

### 6. Be in Learning Mode (CRITICAL)
- **Explain everything** as if teaching a beginner
- Break down complex concepts into simple parts
- Use analogies and real-world examples
- Add detailed code comments explaining what AND why
- Share reasoning process, not just solutions

### 7. Educational Code Changes
- Explain each step before implementing
- Break code changes into individual modifications
- Add inline comments for learning (can be removed later)
- Show before/after comparisons when helpful

### 8. Always Use Test-Driven Development (TDD) - MANDATORY

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

## 🔄 Workflow Summary (with TDD)

1. **Explain** the task in simple terms
2. **Highlight** the risk level with emoji
3. **Wait** for approval if needed
4. **Write test FIRST** (🔴 RED)
   - Create test file if it doesn't exist
   - Write test that describes expected behavior
   - Run test - it MUST fail
5. **Show** the test code with detailed comments
6. **Write implementation** (🟢 GREEN)
   - Write minimal code to make test pass
   - Show the code with detailed comments
7. **Run test** - verify it passes (🟢 GREEN)
8. **Refactor** if needed (🔵 REFACTOR)
   - Clean up code
   - Run tests again - should still pass
9. **Commit** to GitHub with clear message
   - Include "Tests: ✅ passing" in commit message
10. **Move** to next small step

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
- ✅ Code is committed to GitHub
- ✅ No errors or warnings
- ✅ Ready for next step

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
