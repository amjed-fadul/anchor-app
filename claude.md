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

### 2. Make Small, Incremental Changes
- **Never** create large files or make sweeping changes
- Break everything into tiny, digestible steps
- One logical change per commit
- Easier to understand, review, and learn from

### 3. Push to GitHub Frequently
- Commit after each small change
- Clear, descriptive commit messages
- Keep commit history clean and educational

### 4. Be in Learning Mode (CRITICAL)
- **Explain everything** as if teaching a beginner
- Break down complex concepts into simple parts
- Use analogies and real-world examples
- Add detailed code comments explaining what AND why
- Share reasoning process, not just solutions

### 5. Educational Code Changes
- Explain each step before implementing
- Break code changes into individual modifications
- Add inline comments for learning (can be removed later)
- Show before/after comparisons when helpful

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

## 🔄 Workflow Summary

1. **Explain** the task in simple terms
2. **Show** the code with detailed comments
3. **Highlight** the risk level with emoji
4. **Wait** for approval if needed
5. **Create** the file/change
6. **Commit** to GitHub with clear message
7. **Verify** it works
8. **Move** to next small step

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

## 📚 Learning Resources

When introducing new concepts, provide:
- Simple explanation in own words
- Link to official docs (if helpful)
- Real-world analogy
- Example usage
- Common pitfalls to avoid

---

*This document guides all AI interactions on the Anchor App project. Updated: November 2025*
