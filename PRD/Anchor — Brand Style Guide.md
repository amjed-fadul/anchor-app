# Anchor — Brand Style Guide

**Version 2.0**

**Last Updated:** November 2025

**Maintained by:** Product & Design Teams

---

## Document Updates (v2.0)

**What's New:**

- Added celebration moments & gradient guidelines
- Added motion & animation principles
- Added RTL/Arabic layout guidelines
- Added bottom sheet, context menu, and tab navigation components
- Expanded empty state voice guidelines
- Added detailed component measurements from designs
- Updated tagline to match product experience
- Added app badge specifications

---

# Brand Essence

## What is Anchor?

Your reference points on the internet. Not just saving links—creating anchors you can always return to.

## Brand Personality

**Steady** • **Clear** • **Confident** • **Minimal** • **Grounded**

## Voice Principles

1. **Steady, Not Urgent** — No pressure, just reliability
2. **Clear, Not Clever** — Direct communication
3. **Confident, Not Boastful** — Trust without ego
4. **Helpful, Not Condescending** — Assume intelligence
5. **Focused on Finding** — It's about retrieval, not just saving

## Positioning

- **Pocket** = Temporary grab
- **Raindrop** = Visual collection
- **Anchor** = Permanent reference point

## Tagline

**English:** "Anchored! Find it anytime"

**Arabic:** رُسّخ! اعثر عليه في أي وقت

---

# Logo & App Icon

## Primary Logo

```
┌────────────────────────────────────┐
│                                    │
│              ANCHOR                │
│                ⚓                   │
│                                    │
│     Anchored! Find it anytime      │
│                                    │
└────────────────────────────────────┘

Wordmark: "ANCHOR" in custom sans-serif
Symbol: Minimalist anchor icon
Tagline: Optional, used in marketing materials
```

## Logo Specifications

**Primary Logo (Horizontal)**

- Wordmark + Symbol
- Use when space allows
- Minimum width: 120px
- Clear space: 1x symbol height on all sides

**Icon Only**

- Use for app icon, small spaces
- Minimum size: 44px × 44px (iOS tap target)
- Must maintain 1:1 ratio

**Wordmark Only**

- Use for text-heavy contexts
- Minimum width: 80px

## App Icon Design

### iOS & Android App Icon

```
┌─────────────────────────┐
│  ███████████████████   │
│  █                 █   │
│  █                 █   │
│  █        ⚓        █   │
│  █                 █   │
│  █                 █   │
│  ███████████████████   │
└─────────────────────────┘

Background: Anchor Slate (#2C3E50)
Symbol: White (#FFFFFF) anchor icon
Style: Minimalist, centered
Shape: iOS rounded square, Android adaptive icon
```

**Icon Specifications:**

- iOS: 1024×1024px with system corner radius
- Android: 512×512px adaptive icon with safe zone
- Symbol size: 60% of canvas
- Perfectly centered
- No text (icon speaks for itself)

### Browser Extension Icon

```
16×16px (toolbar)
32×32px (extension popup)
48×48px (extension management)
128×128px (Chrome Web Store)

Design: Same anchor symbol
Optimized for each size
High contrast for toolbar visibility
```

## Anchor Symbol Design

The anchor icon is our visual identity. It must be:

**Geometric & Simple**

```
     │
     │
     ●  ← Ring
     │
     │
 ╱───┴───╲  ← Flukes
╱         ╲
```

**Design Principles:**

- Single stroke weight (4-6px depending on size)
- Symmetrical
- Rounded caps and joins
- No decorative details
- Recognizable at any size

**Proportions:**

- Height to width ratio: 1.2:1
- Ring: 15% of total height
- Stock (vertical line): 60% of total height
- Flukes: 40% of total width

## Logo Variations

### Light Backgrounds

- **Full color:** Anchor Slate wordmark + Teal symbol
- **Monochrome:** All Anchor Slate
- **Reversed:** Use dark version only

### Dark Backgrounds

- **Full color:** White wordmark + Teal symbol
- **Monochrome:** All white
- **Reversed:** Use light version only

### Clear Space

```
┌─ ⚓ ─┐  ← Minimum 1x symbol height on all sides
│     │
⚓ ⚓ ⚓
│     │
└─ ⚓ ─┘
```

No other elements should enter the clear space zone.

## Logo Don'ts

❌ Don't change colors

❌ Don't rotate or skew

❌ Don't add effects (shadows, glows)

❌ Don't outline or add borders

❌ Don't place on busy backgrounds

❌ Don't stretch or distort proportions

❌ Don't add your own anchor illustrations

---

# Color System

## Design Philosophy

**Content First, Not Color First**

- Minimalist approach
- Colors support content, never compete
- High contrast for accessibility
- Timeless, not trendy
- Works in light and dark modes

---

## Primary Colors

### Anchor Slate (Primary Brand)

```
██████████  #2C3E50
            RGB: 44, 62, 80
            HSL: 210°, 29%, 24%

Usage: App icon, key branding, primary actions
Feel: Grounded, stable, confident
```

### Anchor Teal (Accent)

```
██████████  #0D9488
            RGB: 13, 148, 136
            HSL: 174°, 84%, 32%

Usage: CTAs, active states, "Anchor" button, highlights
Feel: Calm, distinctive, actionable
```

---

## Celebration Gradients

**NEW IN v2.0:** Gradients are allowed ONLY for celebration and success moments.

### Success Gradient (Confirmation Screen)

```
Gradient: Linear, 135° diagonal
Start: #10B981 (Success Green)
End: #0D9488 (Anchor Teal)

Usage: "Anchored!" confirmation screen background
Duration: 3-second display
Feel: Celebratory, accomplished, positive
```

**Rules for Gradient Usage:**

- ✅ Use ONLY for success/confirmation moments
- ✅ Use the defined Success Gradient colors
- ✅ Always 135° diagonal direction
- ❌ Never use for buttons or primary UI elements
- ❌ Never use in navigation or persistent UI
- ❌ Never create custom gradients outside this spec

**When to Use:**

- Confirmation screen after saving a link
- Success animations or transitions
- Celebration overlays (must be temporary, <5 seconds)

**When NOT to Use:**

- Regular backgrounds
- Buttons (use solid colors)
- Cards or content surfaces
- Navigation elements
- Persistent UI elements

---

## Neutral Grays (Light Mode)

### Charcoal (Text Primary)

```
██████████  #1A1A1A
            RGB: 26, 26, 26
            
Usage: Primary text, headings, body copy
Contrast on white: 15.8:1 (AAA)
```

### Slate (Text Secondary)

```
██████████  #4A5568
            RGB: 74, 85, 104
            
Usage: Secondary text, labels, metadata, timestamps
Contrast on white: 7.9:1 (AAA)
```

### Silver (Borders)

```
██████████  #CBD5E1
            RGB: 203, 213, 225
            
Usage: Borders, dividers, disabled states
```

### Ash (Backgrounds)

```
██████████  #F1F5F9
            RGB: 241, 245, 249
            
Usage: Secondary backgrounds, cards, input fields
```

### White (Base)

```
██████████  #FFFFFF
            RGB: 255, 255, 255
            
Usage: Primary backgrounds, content surfaces
```

---

## Dark Mode Colors

### Deep Charcoal (Background)

```
██████████  #0F172A
            RGB: 15, 23, 42
            
Usage: Primary dark mode background
```

### Dark Slate (Surface)

```
██████████  #1E293B
            RGB: 30, 41, 59
            
Usage: Cards, elevated surfaces, navigation
```

### Off White (Text Primary)

```
██████████  #F8FAFC
            RGB: 248, 250, 252
            
Usage: Primary text in dark mode
```

### Light Gray (Text Secondary)

```
██████████  #94A3B8
            RGB: 148, 163, 184
            
Usage: Secondary text, metadata in dark mode
```

### Dark Border

```
██████████  #334155
            RGB: 51, 65, 85
            
Usage: Borders and dividers in dark mode
```

### Anchor Teal (Dark Mode Adjusted)

```
██████████  #14B8A6
            RGB: 20, 184, 166
            
Usage: Same as light mode but slightly brighter for dark backgrounds
```

---

## Semantic Colors

Use sparingly. Only when necessary.

### Success

```
██████████  #059669 (Light)
██████████  #10B981 (Dark)

Usage: Success messages, confirmations
Example: "Anchored ✓"
```

### Warning

```
██████████  #D97706 (Light)
██████████  #F59E0B (Dark)

Usage: Warnings, approaching limits, cautions
Example: "90/100 anchors used"
```

### Error

```
██████████  #DC2626 (Light)
██████████  #EF4444 (Dark)

Usage: Errors, destructive actions, failures
Example: "Couldn't anchor this link"
```

---

## Color Usage Matrix

| Element | Light Mode | Dark Mode | Notes |
| --- | --- | --- | --- |
| App Background | #FFFFFF | #0F172A | Pure white / Deep charcoal |
| Card Surface | #F1F5F9 | #1E293B | Subtle elevation |
| Text (Primary) | #1A1A1A | #F8FAFC | High contrast |
| Text (Secondary) | #4A5568 | #94A3B8 | Labels, metadata |
| Borders | #CBD5E1 | #334155 | Subtle separation |
| Primary Button | #0D9488 | #14B8A6 | "Anchor" action |
| Button Text | #FFFFFF | #FFFFFF | On teal buttons |
| Links | #0D9488 | #14B8A6 | Interactive text |
| Icons (Primary) | #2C3E50 | #F8FAFC | Brand or neutral |
| Icons (Accent) | #0D9488 | #14B8A6 | Actions |
| Success | #059669 | #10B981 | Confirmations |
| Warning | #D97706 | #F59E0B | Cautions |
| Error | #DC2626 | #EF4444 | Problems |
| Success Gradient | #10B981→#0D9488 | Same | Celebration only |

---

## Accessibility Standards

All color combinations meet **WCAG 2.1 AA minimum** (4.5:1 for normal text).

### Contrast Ratios

| Combination | Ratio | Level |
| --- | --- | --- |
| Charcoal on White | 15.8:1 | AAA ✅ |
| Slate on White | 7.9:1 | AAA ✅ |
| Anchor Teal on White | 4.5:1 | AA (Large text) ⚠️ |
| White on Anchor Slate | 12.6:1 | AAA ✅ |
| White on Anchor Teal | 3.2:1 | AA Large only ⚠️ |

**Important:** Use Anchor Teal only for:

- Large text (18px+ regular, 14px+ bold)
- Icons and graphics
- Backgrounds with white text

For small text, use Charcoal or Slate.

---

## Color in Context

### Primary Action Button

```
┌─────────────────────────┐
│                         │
│    Anchor This Page     │  ← White text (#FFFFFF)
│                         │     on Teal background (#0D9488)
└─────────────────────────┘
     Bold, 16px, centered
```

### Success Confirmation Screen

```
┌─────────────────────────────────┐
│  ╱╲ Success Gradient Background │
│ ╱  ╲ (#10B981 → #0D9488)        │
│╱    ╲                           │
│                                 │
│   Anchored! Find it anytime     │  ← White text, bold, 32px
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━       │  ← Progress bar (3s)
│                                 │
│   [ Add Details ]               │  ← White button outline
│                                 │
└─────────────────────────────────┘
```

### Success Message

```
┌─────────────────────────────────┐
│  ✓  Anchored from Safari        │  ← Teal checkmark
│                                 │     Charcoal text
└─────────────────────────────────┘
     Ash background or transparent
```

### Text Hierarchy Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Article Title Here          ← Charcoal #1A1A1A, Bold, 20px

Added 2 hours ago          ← Slate #4A5568, Regular, 14px

This is the preview text   ← Charcoal #1A1A1A, Regular, 14px
showing the first few...

#design #research          ← Teal #0D9488, Regular, 12px

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

# Typography

## Font Families

### Primary Typeface: Geist

**Why Geist:**

- Designed for UI and screens
- Excellent legibility at all sizes
- Open source and free
- Variable font (flexible weights)
- Great Arabic support for bilingual app

**Fallback Stack:**

```
font-family: 'Geist', -apple-system, BlinkMacSystemFont, 
             'Segoe UI', 'Roboto', 'Helvetica Neue', 
             Arial, sans-serif;
```

### Arabic Typeface: **IBM Plex Sans Arabic**

**Why IBM Plex Arabic:**

- Modern, clean, professional
- Designed to harmonize with Latin sans-serifs
- Excellent screen rendering
- Open source
- Matches Geist's personality

**Fallback Stack (Arabic):**

```
font-family: 'IBM Plex Sans Arabic', 'Noto Sans Arabic',
             'Arial', sans-serif;
```

---

## Type Scale

### Mobile (iOS/Android)

| Style | Weight | Size | Line Height | Letter Spacing |
| --- | --- | --- | --- | --- |
| **Hero** | Bold (700) | 32px | 40px | -0.5px |
| **Title 1** | Bold (700) | 28px | 36px | -0.5px |
| **Title 2** | Semibold (600) | 24px | 32px | -0.25px |
| **Title 3** | Semibold (600) | 20px | 28px | 0px |
| **Headline** | Semibold (600) | 17px | 24px | 0px |
| **Body** | Regular (400) | 16px | 24px | 0px |
| **Subhead** | Medium (500) | 15px | 22px | 0px |
| **Footnote** | Regular (400) | 13px | 18px | 0px |
| **Caption 1** | Regular (400) | 12px | 16px | 0px |
| **Caption 2** | Regular (400) | 11px | 14px | 0.5px |

### Desktop/Web

| Style | Weight | Size | Line Height | Letter Spacing |
| --- | --- | --- | --- | --- |
| **Display** | Bold (700) | 48px | 56px | -1px |
| **H1** | Bold (700) | 36px | 44px | -0.5px |
| **H2** | Semibold (600) | 30px | 38px | -0.5px |
| **H3** | Semibold (600) | 24px | 32px | -0.25px |
| **H4** | Semibold (600) | 20px | 28px | 0px |
| **Body Large** | Regular (400) | 18px | 28px | 0px |
| **Body** | Regular (400) | 16px | 24px | 0px |
| **Body Small** | Regular (400) | 14px | 20px | 0px |
| **Caption** | Regular (400) | 12px | 16px | 0.5px |

---

## Typography Examples

### Card Title + Metadata

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

How to Design Better Mobile Apps    ← Title 3, Semibold, 20px
                                       Charcoal #1A1A1A

[medium.com](http://medium.com) • 5 min read • 2d ago    ← Caption, Regular, 12px
                                       Slate #4A5568

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Button Text

```
┌─────────────────────┐
│   Anchor This Page  │  ← Subhead, Medium, 15px
└─────────────────────┘     White on Teal
```

### Empty State

```
         ⚓

No anchors yet               ← Title 2, Semibold, 24px
                               Charcoal #1A1A1A

Start anchoring pages        ← Body, Regular, 16px
you want to return to         Slate #4A5568
```

### Search Results Count

```
48 anchors found             ← Footnote, Regular, 13px
                               Slate #4A5568
```

---

## Typography Do's and Don'ts

### ✅ Do

- Use Geist for English text
- Use IBM Plex Sans Arabic for Arabic text
- Maintain hierarchy with size and weight
- Keep line length between 50-75 characters
- Use consistent line heights (1.5x for body)
- Left-align body text (right-align for Arabic)
- Use semantic HTML tags

### ❌ Don't

- Don't use more than 3 weights per page
- Don't use font sizes smaller than 11px (except legal)
- Don't use all caps for long text
- Don't use italic for emphasis (use semibold instead)
- Don't use decorative or script fonts
- Don't center-align large blocks of text
- Don't use tight letter-spacing on body text

---

# Motion & Animation

**NEW IN v2.0**

## Animation Principles

Motion should feel **steady, confident, and purposeful**—never flashy or gratuitous.

### Core Principles

1. **Purposeful** — Every animation communicates state or guides attention
2. **Quick** — Animations should be fast enough to not impede workflow
3. **Smooth** — Use easing curves that feel natural, not robotic
4. **Subtle** — Minimal movement; let content be the focus
5. **Consistent** — Same animation speeds and styles throughout

---

## Animation Speeds

| Duration | Use Case | Easing |
| --- | --- | --- |
| **100ms** | Micro-interactions (button press, toggle) | ease-out |
| **200ms** | State changes (tab switch, checkbox) | ease-in-out |
| **300ms** | Navigation (screen transitions) | ease-in-out |
| **400ms** | Modals & sheets (slide up/down) | ease-out |
| **3000ms** | Celebration (confirmation screen) | linear (progress bar) |

---

## Animation Types

### Micro-interactions

```
Button Press:
- Duration: 100ms
- Transform: scale(0.96)
- Easing: ease-out

Toggle Switch:
- Duration: 200ms
- Transform: translateX()
- Easing: ease-in-out
```

### Transitions

```
Screen Navigation:
- Duration: 300ms
- Transform: translateX(100%) → translateX(0)
- Easing: cubic-bezier(0.4, 0, 0.2, 1)

Tab Switch:
- Duration: 200ms
- Opacity: 0 → 1
- Transform: translateY(8px) → translateY(0)
- Easing: ease-in-out
```

### Bottom Sheets

```
Sheet Appearance:
- Duration: 400ms
- Transform: translateY(100%) → translateY(0)
- Easing: cubic-bezier(0.0, 0.0, 0.2, 1)

Sheet Dismissal:
- Duration: 300ms
- Transform: translateY(0) → translateY(100%)
- Easing: cubic-bezier(0.4, 0.0, 1, 1)

Backdrop:
- Duration: 300ms (sync with sheet)
- Opacity: 0 → 0.4 (appear)
- Opacity: 0.4 → 0 (dismiss)
```

### Celebration Moments

```
Confirmation Screen:
- Duration: 3000ms (auto-dismiss)
- Gradient background (no animation)
- Progress bar: 0% → 100% (linear)
- Text: fade in 200ms, stay visible
- Button: fade in 400ms (delayed)
```

### Loading States

```
Skeleton Screens:
- Duration: 1500ms (loop)
- Gradient shimmer effect
- Direction: left → right
- Easing: ease-in-out

Spinner:
- Duration: 800ms (loop)
- Rotation: 0deg → 360deg
- Easing: linear
```

---

## Animation Don'ts

❌ Don't use bounce or elastic easing (too playful)

❌ Don't animate multiple properties at once (cluttered)

❌ Don't use animations longer than 500ms (except celebration)

❌ Don't animate on scroll (can cause motion sickness)

❌ Don't use parallax effects (off-brand)

❌ Don't auto-play looping animations (distracting)

---

## Reduced Motion

**Accessibility Requirement:**

Always respect `prefers-reduced-motion` system setting.

When reduced motion is enabled:

- Disable all transitions longer than 200ms
- Replace animations with instant state changes
- Keep essential feedback (e.g., button press)
- Disable celebration screen auto-dismiss animation

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

# Iconography

## Icon Style

**Minimalist Outline Style**

- 2px stroke weight (1.5px for small icons)
- Rounded line caps and joins
- No fill (outline only)
- Geometric and simple
- Consistent visual weight

## Icon Library

We use **Lucide Icons** as our base library (open source, consistent, minimal).

### Primary Icons

```
⚓  Anchor         🔍  Search        ⚙️  Settings
📑  Collections    🏷️  Tags         ↗️  Share
✓   Check         ✕   Close        +   Add
←   Back          →   Forward      ⋮   More
⭐  Favorite      📱  Mobile       🌐  Browser
```

### Custom Anchor Icon

Our primary "Anchor" icon is custom and unique to our brand.

```
     │
     │
     ●      ← 2px stroke
     │         Rounded caps
     │         Symmetrical
 ────┴────
╱         ╲
```

**Usage:**

- Main action button
- Navigation tab
- App icon
- Success confirmations

---

## Icon Sizing

| Context | Size | Stroke Width |
| --- | --- | --- |
| Navigation/Tab Bar | 24×24px | 2px |
| Button Icons | 20×20px | 2px |
| Inline Icons | 16×16px | 1.5px |
| List Item Icons | 20×20px | 2px |
| Empty State Icons | 48×48px | 2px |
| Large Hero Icons | 64×64px | 2.5px |

---

## Icon Colors

### Light Mode

- **Primary Icons:** Charcoal (#1A1A1A)
- **Secondary Icons:** Slate (#4A5568)
- **Accent Icons:** Anchor Teal (#0D9488)
- **Success Icons:** Deep Green (#059669)
- **Warning Icons:** Warm Amber (#D97706)
- **Error Icons:** Deep Red (#DC2626)

### Dark Mode

- **Primary Icons:** Off White (#F8FAFC)
- **Secondary Icons:** Light Gray (#94A3B8)
- **Accent Icons:** Anchor Teal (#14B8A6)
- **Success Icons:** Light Green (#10B981)
- **Warning Icons:** Light Amber (#F59E0B)
- **Error Icons:** Light Red (#EF4444)

---

## Icon Usage Examples

### Navigation Bar

```
┌────────────────────────────────────┐
│                                    │
│    🏠 Home    ⚓ Anchor    ⚙️ Settings
│                                    │
└────────────────────────────────────┘

Inactive: Slate (#4A5568)
Active: Anchor Teal (#0D9488)
```

### Action Button with Icon

```
┌────────────────────────┐
│  ⚓  Anchor This Page  │
└────────────────────────┘

Icon: White on Teal background
16px icon + 8px spacing + text
```

### List Item

```
┌────────────────────────────────────┐
│  📰  Design System Best...         │
│      [medium.com](http://medium.com) • 2d ago           │
└────────────────────────────────────┘

Icon: 20×20px, Slate color
8px spacing from text
```

---

## Icon Don'ts

❌ Don't mix icon styles (filled + outline)

❌ Don't use icons smaller than 16×16px

❌ Don't use too many colors

❌ Don't rotate icons awkwardly

❌ Don't stretch or distort icons

❌ Don't use icons without labels for primary actions

---

# Layout & Spacing

## Grid System

### Mobile Grid (iOS/Android)

- **Columns:** 4 columns (for 2-column card layout)
- **Margins:** 16px (left/right)
- **Gutters:** 12px between cards
- **Container:** Full width minus margins

### Tablet Grid

- **Columns:** 8 columns
- **Margins:** 24px (left/right)
- **Gutters:** 16px between columns
- **Max width:** None (fluid)

### Desktop/Web Grid

- **Columns:** 12 columns
- **Margins:** Auto (centered)
- **Gutters:** 24px between columns
- **Max width:** 1200px

---

## Spacing System

Use an 8px base unit for all spacing.

### Spacing Scale

| Token | Value | Usage |
| --- | --- | --- |
| **XXS** | 4px | Icon-text gap, tight spacing |
| **XS** | 8px | Text line breaks, small gaps |
| **SM** | 12px | Input padding, compact spacing |
| **MD** | 16px | Standard spacing, margins |
| **LG** | 24px | Section spacing, card padding |
| **XL** | 32px | Large section breaks |
| **2XL** | 48px | Major section separation |
| **3XL** | 64px | Hero spacing, empty states |

### Common Spacing Patterns

```
Card Padding: 16px all sides
List Item: 12px vertical, 16px horizontal
Button Padding: 12px vertical, 24px horizontal
Input Field: 12px vertical, 16px horizontal
Section Margin: 24px between sections
Page Margin: 16px mobile, 24px tablet, auto desktop
Grid Gap (2-column): 12px between cards
```

---

## Layout Principles

### 1. **Content First**

Prioritize readable content over decorative elements.

### 2. **Generous Whitespace**

Don't be afraid of empty space—it creates clarity.

### 3. **Clear Hierarchy**

Use spacing to show relationships between elements.

### 4. **Consistent Rhythm**

Use the 8px spacing system everywhere.

### 5. **Responsive**

Scale gracefully from mobile to desktop.

---

## Layout Examples

### Mobile List View

```
┌────────────────────────────────────┐ ←─ 16px margin
│  ┌──────────────────────────────┐ │
│  │  [Image]  Title Text Here    │ │ ←─ 12px padding
│  │           [medium.com](http://medium.com) • 2d     │ │
│  └──────────────────────────────┘ │
│                                    │ ←─ 8px gap
│  ┌──────────────────────────────┐ │
│  │  [Image]  Another Title       │ │
│  │           [website.com](http://website.com) • 5h    │ │
│  └──────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
```

### Card Layout (2-Column Grid)

```
┌─────────────────────────────────────┐
│  ┌──────────┐  ┌──────────┐        │ ←─ 16px margin
│  │          │  │          │        │
│  │  Image   │  │  Image   │        │
│  │          │  │          │        │
│  ├──────────┤  ├──────────┤        │
│  │ Title    │  │ Title    │        │
│  │ Domain   │  │ Domain   │        │
│  └──────────┘  └──────────┘        │
│       ↑            ↑                │
│       └─── 12px ───┘                │
│                                     │
└─────────────────────────────────────┘

Card dimensions: 173×242px (from designs)
Gap between cards: 12px
Total width: 173 + 12 + 173 = 358px
```

### Empty State

```
┌─────────────────────────────────────┐
│                                     │
│                                     │ ←─ 64px top margin
│             ⚓                      │
│                                     │ ←─ 24px spacing
│       No anchors yet               │
│                                     │ ←─ 12px spacing
│    Start anchoring pages           │
│    you want to return to           │
│                                     │ ←─ 24px spacing
│    ┌─────────────────────┐        │
│    │  Anchor Your First  │        │
│    └─────────────────────┘        │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

---

# Components

## Buttons

### Primary Button (Anchor Action)

```
┌───────────────────────────┐
│                           │
│    Anchor This Page       │  ← White text, 15px, Medium
│                           │     Teal background (#0D9488)
└───────────────────────────┘     12px vertical, 24px horizontal
                                  8px border radius
                                  
States:
- Default: #0D9488
- Hover: #0A7B72 (darker)
- Pressed: #085D56 (even darker)
- Disabled: 40% opacity
```

### Secondary Button

```
┌───────────────────────────┐
│                           │
│    Cancel                 │  ← Charcoal text, 15px, Medium
│                           │     Ash background (#F1F5F9)
└───────────────────────────┘     Same padding as primary

States:
- Default: Charcoal on Ash
- Hover: Slate on Ash
- Pressed: Charcoal on Silver
```

### Ghost Button (Outline)

```
┌───────────────────────────┐
│    Add Details            │  ← White text, 15px, Medium
└───────────────────────────┘     White 2px border
                                  Transparent background
                                  8px border radius

Usage: On gradient confirmation screen
States:
- Default: White border + text
- Hover: White background (10% opacity)
- Pressed: White background (20% opacity)
```

### Text Button

```
   Anchor This Page           ← Teal text, 15px, Medium
   ─────────────────             No background
                                 No border
                                 
States:
- Default: Teal text
- Hover: Darker teal
- Pressed: Even darker
```

---

## Input Fields

### Text Input

```
┌─────────────────────────────────────┐
│  Search your anchors               │  ← Charcoal text
└─────────────────────────────────────┘     Ash background
                                           Silver border (1px)
                                           8px border radius
                                           12px vertical padding
                                           16px horizontal padding

States:
- Default: Silver border (#CBD5E1)
- Focus: Teal border (#0D9488), 2px
- Error: Error red border (#DC2626), 2px
- Disabled: 50% opacity
```

### Search Bar

```
┌─────────────────────────────────────┐
│  🔍  Search your anchors           │  ← Icon + input
└─────────────────────────────────────┘     Slate icon
                                           12px icon-text gap
                                           
Placeholder: Slate (#4A5568)
Input text: Charcoal (#1A1A1A)
```

### Textarea (Note Field)

```
┌─────────────────────────────────────┐
│  Why did you save this?            │
│                                     │
│                                     │  ← 3-5 lines visible
│                                     │
└─────────────────────────────────────┘
                                    0/200  ← Character counter

Same styling as text input
Height: Auto-expand up to 206px
Character limit: 200
```

---

## Cards

### Link Card (2-Column Grid View)

```
┌────────────────────┐
│                    │
│   [Thumbnail]      │  ← 16:9 or 1:1, 173px wide
│     16:9           │
│                    │
├────────────────────┤
│                    │
│  Title Text Here   │  ← Semibold, 14px, 2 lines max
│                    │
│  [site.com](http://site.com) • 2d     │  ← Regular, 11px, Slate
│                    │
└────────────────────┘

Dimensions: 173×242px (from designs)
Border radius: 8px
Border: 1px Silver (#CBD5E1)
Background: White
Padding (text area): 12px
Shadow on hover: 0 4px 12px rgba(0,0,0,0.08)
```

### Link Card (List View - Alternative)

```
┌─────────────────────────────────────┐
│  ┌────┐                             │
│  │Img │  Article Title Here         │  ← Title, Semibold, 16px
│  │64px│  [website.com](http://website.com) • 2 hours ago  │  ← Metadata, Regular, 12px
│  └────┘                             │
│        Preview text showing...      │  ← Body, Regular, 14px
│                                     │
│        #design #research            │  ← Tags, Teal, 12px
└─────────────────────────────────────┘

White background
Silver border (1px)
8px border radius
16px padding
Subtle shadow on hover
```

---

## Bottom Sheets

**NEW IN v2.0: Comprehensive bottom sheet specs**

### Bottom Sheet Container

```
┌─────────────────────────────────────┐
│            ────                     │  ← Grabber (36×5px, Slate)
│                                     │     6px from top
│  [Content Area]                     │
│                                     │
│                                     │
│  ┌─────────────────────────────┐  │  ← Action button area
│  │         Done                │  │     Always visible (sticky)
│  └─────────────────────────────┘  │
│                                     │
│  [Home Indicator]                  │  ← iOS home indicator
└─────────────────────────────────────┘

Corner radius: 16px (top corners only)
Background: White (light) / Dark Slate (dark)
Backdrop: Black, 40% opacity
Min height: 166px (small sheets)
Max height: 758px (full sheets)
Padding: 16px horizontal
```

### Bottom Sheet Variants

**Small Sheet (Context Menu):**

- Height: Auto-fit content (166px typical)
- Use: Quick actions (Copy, Delete, Share)
- Content: List of action items

**Medium Sheet (Add Details):**

- Height: 515px
- Use: Tag/Note/Space tabs
- Content: Tabs + form fields + action button

**Large Sheet (Create Space):**

- Height: 758px
- Use: Multi-step forms
- Content: Logo, title, description, form, action button

### Bottom Sheet Grabber

```
────  ← 36×5px rounded rectangle
      Slate color (#4A5568)
      6px from top edge
      Centered horizontally
```

### Bottom Sheet Animation

- Entrance: 400ms, cubic-bezier(0.0, 0.0, 0.2, 1)
- Exit: 300ms, cubic-bezier(0.4, 0.0, 1, 1)
- Backdrop fade: 300ms sync with sheet

---

## Tab Navigation

**NEW IN v2.0: Tab navigation specs**

### Tab Bar (Bottom Navigation)

```
┌─────────────────────────────────────┐
│                                     │
│   Home     Anchor    Spaces         │  ← Labels
│    🏠        ⚓        📑            │  ← Icons (24×24px)
│    ━                                │  ← Active indicator
│                                     │
└─────────────────────────────────────┘

Height: 79px (56px tab + 23px home indicator space)
Background: White (light) / Dark Slate (dark)
Border top: 1px Silver (#CBD5E1)
Icon size: 24×24px
Label: Caption 1 (12px, Regular)
Spacing: Icon above label, 4px gap
```

### Tab States

**Active Tab:**

- Icon: Anchor Teal (#0D9488)
- Label: Anchor Teal (#0D9488), Regular
- Indicator: 2px line under icon, Teal, 24px wide

**Inactive Tab:**

- Icon: Slate (#4A5568)
- Label: Slate (#4A5568), Regular
- No indicator

**Pressed State:**

- Background: Ash (#F1F5F9), 10% opacity
- Circle around icon: 48×48px
- Duration: 100ms

### Tab Switching Animation

- Duration: 200ms
- Content fade: Opacity 1 → 0 → 1
- Content shift: translateY(8px) → translateY(0)
- Indicator slide: translateX() to new position

---

## Context Menus

**NEW IN v2.0: Context menu specs**

### Context Menu Container

```
┌─────────────────────────────────────┐
│  📋  Copy to clipboard              │  ← Menu item
│  🏷️  Add Tag                        │
│  📁  Add to space                   │
│  🗑️  Delete Link                    │  ← Destructive
└─────────────────────────────────────┘

Background: White (light) / Dark Slate (dark)
Border radius: 12px
Shadow: 0 8px 24px rgba(0,0,0,0.15)
Padding: 0 (items have their own padding)
```

### Context Menu Item

```
┌─────────────────────────────────────┐
│  📋  Copy to clipboard              │
└─────────────────────────────────────┘

Height: 56px
Padding: 16px horizontal, 18px vertical
Icon: 24×24px, 20px from left
Text: Body (16px), 52px from left
Icon-text gap: 8px
```

### Context Menu Item States

**Default:**

- Background: Transparent
- Text: Charcoal (#1A1A1A)
- Icon: Slate (#4A5568)

**Hover/Pressed:**

- Background: Ash (#F1F5F9)
- Text: Same
- Icon: Same

**Destructive Action:**

- Text: Error Red (#DC2626)
- Icon: Error Red (#DC2626)
- Background on press: Red, 5% opacity

### Context Menu Divider

```
─────────────────────────────  ← 1px Silver line
                                  0 vertical margin
                                  Between item groups
```

---

## App Badge

**NEW IN v2.0: Badge specifications**

### Unread Count Badge

```
   ┌───────┐
   │  12   │  ← Badge on app icon
   └───────┘

Background: Error Red (#DC2626)
Text: White (#FFFFFF), Bold, 11px
Border radius: 12px (pill shape)
Min size: 20×20px
Padding: 4px horizontal, 2px vertical
Position: Top-right of app icon, -4px offset
```

### Badge States

**1-9 items:**

- Display: Single digit (e.g., "5")
- Size: 20×20px (circular)

**10-99 items:**

- Display: Two digits (e.g., "42")
- Size: Auto-width, 20px height (pill)

**100+ items:**

- Display: "99+"
- Size: Auto-width, 20px height (pill)

**No unread items:**

- Display: No badge
- Badge disappears with fade animation (200ms)

---

## Lists

### Standard List Item

```
┌─────────────────────────────────────┐
│  📰  Design System Guide            │  ← Icon + title
│      [medium.com](http://medium.com) • Added 2 days ago  │  ← Metadata
├─────────────────────────────────────┤  ← Silver divider
│  📖  React Documentation            │
│      [react.dev](http://react.dev) • Added 1 week ago   │
├─────────────────────────────────────┤
│  🎨  Figma Best Practices           │
│      [figma.com](http://figma.com) • Added 3 days ago   │
└─────────────────────────────────────┘

Height: 72px per item
Padding: 16px horizontal, 16px vertical
Divider: 1px Silver
```

---

## Modals & Sheets

### Confirmation Modal (Desktop)

```
┌─────────────────────────────────────┐
│                                     │
│  Delete this anchor?                │  ← Title
│                                     │
│  This action cannot be undone       │  ← Body
│                                     │
│     ┌────────┐  ┌────────────┐    │
│     │ Cancel │  │   Delete   │    │  ← Buttons
│     └────────┘  └────────────┘    │
│                                     │
└─────────────────────────────────────┘

Max width: 400px
Border radius: 12px
Padding: 24px
Centered on screen
Shadow: 0 20px 40px rgba(0,0,0,0.2)
Backdrop: Black, 50% opacity
```

---

## States

### Loading State

```
┌─────────────────────────────────────┐
│                                     │
│           ⚪ ⚪ ⚪                   │  ← Animated dots
│                                     │     Slate color
│        Loading...                  │     Caption, 12px
│                                     │
└─────────────────────────────────────┘
```

### Empty State

```
┌─────────────────────────────────────┐
│                                     │
│              ⚓                      │  ← Silver icon, 48px
│                                     │
│        No anchors yet              │  ← Title, Semibold, 20px
│                                     │
│   Start anchoring pages            │  ← Body, Regular, 16px
│   you want to return to            │
│                                     │
└─────────────────────────────────────┘
```

### Error State

```
┌─────────────────────────────────────┐
│   ✕  Couldn't anchor this          │  ← Error red icon
│      Check your connection         │     Charcoal text
│                                     │
│      [Try Again]                   │  ← Secondary button
└─────────────────────────────────────┘
```

---

# Empty States & Voice

**NEW IN v2.0: Empty state voice guidelines**

## Empty State Principles

Empty states should be **calm, clear, and instructional**—never anxious or overly encouraging.

### Voice Guidelines

**Do:**

- ✅ Use simple, factual language: "No anchors yet"
- ✅ Provide clear next steps: "Start anchoring pages"
- ✅ Keep it brief (2 lines max)
- ✅ Use present tense
- ✅ Be direct and confident

**Don't:**

- ❌ Use exclamation marks excessively
- ❌ Be overly enthusiastic: "Let's get started!"
- ❌ Use multiple sentences
- ❌ Apologize: "Sorry, nothing here yet"
- ❌ Use cutesy language: "Oops! It's empty!"

---

## Empty State Examples

### Home Screen (No Anchors)

```
         ⚓

No anchors yet

Start anchoring pages
you want to return to
```

### Space (Empty)

```
         📁

This space is empty

Add links from Home or
save directly to this space
```

### Search (No Results)

```
         🔍

No anchors found

Try different keywords or
remove filters
```

### Tags (No Tags)

```
         🏷️

No tags yet

Add tags when saving links
to organize and find them
```

---

# RTL & Arabic Support

**NEW IN v2.0: RTL layout guidelines**

## RTL Layout Principles

When the app language is set to Arabic:

- All layouts mirror horizontally
- Text aligns right by default
- Icons that indicate direction (arrows) flip
- Icons that represent objects (anchor, tags) don't flip

---

## RTL Layout Rules

### What Flips

**UI Elements:**

- Navigation bars (back button moves to right)
- Tab bars (order reverses)
- List items (icon moves to right)
- Buttons in button groups (order reverses)
- Bottom sheets (align right)
- Context menus (align right)
- Search bar (icon moves to right)

**Icons:**

- Directional arrows (←→ flip to →←)
- Back/Forward buttons
- Chevrons and carets
- Share icon (if directional)

### What Doesn't Flip

**Icons:**

- Anchor symbol (⚓ stays same)
- Settings gear
- Search magnifying glass
- Tags icon
- Checkmarks
- Plus/minus signs
- Close (X) icon

**Media:**

- Images (don't mirror)
- Thumbnails (don't mirror)
- Logos (don't mirror)
- App icon (don't mirror)

---

## RTL Layout Examples

### Navigation Bar (RTL)

```
LTR:  ←  Anchor              🔍  ⋮
RTL:  ⋮  🔍              Anchor  →

Back button flips sides
Icons reverse order
Title stays centered or aligns right
```

### Tab Bar (RTL)

```
LTR:  Home    Anchor    Spaces
RTL:  Spaces  Anchor    Home

Tab order reverses
Icons stay the same
Active indicator follows
```

### List Item (RTL)

```
LTR:  📰  Design System Guide
          [medium.com](http://medium.com) • 2d ago

RTL:  Design System Guide  📰
      2d ago • [medium.com](http://medium.com)

Icon moves to right
Text aligns right
Metadata order may adjust
```

### Button Group (RTL)

```
LTR:  [Cancel]  [Save]
RTL:  [Save]  [Cancel]

Button order reverses
Primary action stays right-most
```

---

## Arabic Typography Adjustments

### Font Sizes (Same as English)

Arabic uses the same type scale as English:

- No size adjustments needed
- IBM Plex Sans Arabic designed to match Geist metrics

### Line Heights (Slightly Increased)

Arabic has more vertical strokes, so adjust:

- Body text: 1.6x (vs 1.5x for English)
- Headings: 1.3x (vs 1.25x for English)

### Letter Spacing (None)

Arabic doesn't use letter spacing:

- Always set to 0 for Arabic text
- Don't apply Latin letter-spacing values

---

## Testing RTL Layouts

**iOS Testing:**

- Settings → General → Language & Region → Arabic
- Use Xcode RTL preview mode

**Android Testing:**

- Settings → System → Languages → Add Arabic
- Developer Options → Force RTL layout direction

**Web Testing:**

```html
<html dir="rtl" lang="ar">
```

---

# Imagery & Photography

## Image Guidelines

### Content Images (User's Saved Links)

- **Aspect Ratio:** 16:9 or 1:1 preferred
- **Quality:** Original quality preserved
- **Treatment:** No filters or overlays
- **Fallback:** Generic icon if no image available

### Placeholder Images

- **Color:** Ash (#F1F5F9) background
- **Icon:** Relevant icon in Silver (#CBD5E1)
- **Size:** Match intended image size
- **Style:** Minimal, clean

### Image Loading

- **Progressive loading:** Show placeholder first
- **Blur-up technique:** Low-res blur → full image
- **Error state:** Show broken image icon + "Image unavailable"

---

## Illustration Style

**Minimalist Line Illustrations**

- Single color (Anchor Slate or Silver)
- 2px stroke weight
- Simple, geometric shapes
- No gradients or shadows
- Used for empty states and onboarding

### Illustration Examples

**Empty State Illustrations:**

```
   ⚓              📑              🔍
No anchors    No collections   No results
```

Simple, iconic, recognizable at small sizes.

---

## Screenshot Guidelines

For marketing and App Store:

### Do:

✅ Use actual app screenshots

✅ Show real, quality content

✅ Include device frames (mockups)

✅ Show both light and dark modes

✅ Highlight key features

✅ Use consistent device (iPhone Pro, Pixel)

### Don't:

❌ Use fake/lorem ipsum content

❌ Overcrowd with annotations

❌ Use outdated designs

❌ Show empty states in marketing

❌ Inconsistent styling

---

# Do's and Don'ts

## Color Do's and Don'ts

### ✅ Do

- Use Anchor Teal for primary actions only
- Maintain high contrast for accessibility
- Test in both light and dark modes
- Use semantic colors sparingly
- Keep backgrounds simple
- Use gradients ONLY for celebration moments

### ❌ Don't

- Don't use Teal for small text
- Don't use more than 3 colors per screen
- Don't use gradients in persistent UI
- Don't use bright, saturated colors
- Don't forget dark mode
- Don't create custom gradients

---

## Typography Do's and Don'ts

### ✅ Do

- Use Geist for English
- Use IBM Plex Sans Arabic for Arabic
- Maintain clear hierarchy
- Keep line length readable (50-75 chars)
- Use semantic HTML

### ❌ Don't

- Don't use more than 3 font weights
- Don't go below 11px
- Don't use all caps for long text
- Don't center long paragraphs
- Don't use decorative fonts

---

## Logo Do's and Don'ts

### ✅ Do

- Maintain clear space
- Use approved color variations
- Scale proportionally
- Place on clean backgrounds
- Use vector files

### ❌ Don't

- Don't change colors
- Don't rotate or distort
- Don't add effects
- Don't use low-resolution files
- Don't violate clear space

---

## Layout Do's and Don'ts

### ✅ Do

- Use 8px spacing system
- Maintain consistent margins
- Create clear hierarchy
- Use whitespace generously
- Design mobile-first

### ❌ Don't

- Don't use random spacing values
- Don't crowd elements
- Don't ignore responsive behavior
- Don't forget touch targets (44px min)
- Don't over-design

---

## Component Do's and Don'ts

### ✅ Do

- Keep buttons consistent
- Make interactive elements obvious
- Provide clear feedback
- Use loading states
- Handle empty states gracefully

### ❌ Don't

- Don't use too many button styles
- Don't hide important actions
- Don't leave users hanging
- Don't ignore error states
- Don't use fake interactions

---

## Animation Do's and Don'ts

**NEW IN v2.0**

### ✅ Do

- Keep animations under 500ms (except celebration)
- Use purposeful motion
- Respect reduced motion preferences
- Use consistent easing
- Provide visual feedback

### ❌ Don't

- Don't use bounce or elastic easing
- Don't animate multiple properties at once
- Don't auto-play looping animations
- Don't use parallax effects
- Don't ignore accessibility settings

---

# Appendix

## File Naming Conventions

### Design Files

```
anchor-[component]-[variant]-[size].[ext]

Examples:
anchor-logo-primary-dark.svg
anchor-icon-app-ios.png
anchor-screenshot-home-light.png
```

### Code Assets

```
[component]_[variant]_[size].[ext]

Examples:
button_primary_large.xml
icon_anchor_24px.svg
```

---

## Export Specifications

### App Icon

- iOS: 1024×1024px PNG (no alpha)
- Android: 512×512px PNG (with alpha for adaptive icon)
- Web: 192×192px and 512×512px PNG

### Logo Files

- SVG: Vector (preferred)
- PNG: @1x, @2x, @3x (iOS), mdpi through xxxhdpi (Android)

### Colors

- Hex values for design
- RGB for web/CSS
- UIColor/Color for iOS
- Color resource XML for Android

---

## Resources & Tools

### Design Tools

- **Figma:** Primary design tool
- **SF Symbols:** iOS iconography
- **Material Symbols:** Android iconography
- **Lucide Icons:** Cross-platform icons

### Fonts

- **Inter:** [rsms.me/inter](http://rsms.me/inter)
- **IBM Plex Sans Arabic:** [IBM Plex](https://www.ibm.com/plex)

### Accessibility

- **Contrast Checker:** WebAIM Contrast Checker
- **Color Blind Simulator:** Stark plugin
- **Screen Readers:** iOS VoiceOver, Android TalkBack

### Development

- **iOS:** SwiftUI with custom theme
- **Android:** Jetpack Compose with Material Theme
- **Web:** CSS variables for theming
- **React Native:** StyleSheet with theme provider

---

## Version History

| Version | Date | Changes |
| --- | --- | --- |
| 2.0 | Nov 2025 | Added gradients, motion, RTL, components, empty states |
| 1.0 | Nov 2025 | Initial brand style guide |

---

## Contact & Feedback

**For questions about this guide:**

- Product Team: [Contact]
- Design Team: [Contact]

**To suggest updates:**

- Create a pull request
- Contact the Design Lead
- Submit feedback via [Process]

---

**This is a living document.** As Anchor evolves, this guide will be updated to reflect new patterns, components, and brand decisions.

**Last Updated:** November 2025

**Version:** 2.0

**Next Review:** February 2026

**Maintained by:** Product & Design Teams

# Anchor — Brand Style Guide

**Version 2.0**

**Last Updated:** November 2025

**Maintained by:** Product & Design Teams

---

## Document Updates (v2.0)

**What's New:**

- Added celebration moments & gradient guidelines
- Added motion & animation principles
- Added RTL/Arabic layout guidelines
- Added bottom sheet, context menu, and tab navigation components
- Expanded empty state voice guidelines
- Added detailed component measurements from designs
- Updated tagline to match product experience
- Added app badge specifications

---

# Brand Essence

## What is Anchor?

Your reference points on the internet. Not just saving links—creating anchors you can always return to.

## Brand Personality

**Steady** • **Clear** • **Confident** • **Minimal** • **Grounded**

## Voice Principles

1. **Steady, Not Urgent** — No pressure, just reliability
2. **Clear, Not Clever** — Direct communication
3. **Confident, Not Boastful** — Trust without ego
4. **Helpful, Not Condescending** — Assume intelligence
5. **Focused on Finding** — It's about retrieval, not just saving

## Positioning

- **Pocket** = Temporary grab
- **Raindrop** = Visual collection
- **Anchor** = Permanent reference point

## Tagline

**English:** "Anchored! Find it anytime"

**Arabic:** رُسّخ! اعثر عليه في أي وقت

---

# Logo & App Icon

## Primary Logo

```
┌────────────────────────────────────┐
│                                    │
│              ANCHOR                │
│                ⚓                   │
│                                    │
│     Anchored! Find it anytime      │
│                                    │
└────────────────────────────────────┘

Wordmark: "ANCHOR" in custom sans-serif
Symbol: Minimalist anchor icon
Tagline: Optional, used in marketing materials
```

## Logo Specifications

**Primary Logo (Horizontal)**

- Wordmark + Symbol
- Use when space allows
- Minimum width: 120px
- Clear space: 1x symbol height on all sides

**Icon Only**

- Use for app icon, small spaces
- Minimum size: 44px × 44px (iOS tap target)
- Must maintain 1:1 ratio

**Wordmark Only**

- Use for text-heavy contexts
- Minimum width: 80px

## App Icon Design

### iOS & Android App Icon

```
┌─────────────────────────┐
│  ███████████████████   │
│  █                 █   │
│  █                 █   │
│  █        ⚓        █   │
│  █                 █   │
│  █                 █   │
│  ███████████████████   │
└─────────────────────────┘

Background: Anchor Slate (#2C3E50)
Symbol: White (#FFFFFF) anchor icon
Style: Minimalist, centered
Shape: iOS rounded square, Android adaptive icon
```

**Icon Specifications:**

- iOS: 1024×1024px with system corner radius
- Android: 512×512px adaptive icon with safe zone
- Symbol size: 60% of canvas
- Perfectly centered
- No text (icon speaks for itself)

### Browser Extension Icon

```
16×16px (toolbar)
32×32px (extension popup)
48×48px (extension management)
128×128px (Chrome Web Store)

Design: Same anchor symbol
Optimized for each size
High contrast for toolbar visibility
```

## Anchor Symbol Design

The anchor icon is our visual identity. It must be:

**Geometric & Simple**

```
     │
     │
     ●  ← Ring
     │
     │
 ╱───┴───╲  ← Flukes
╱         ╲
```

**Design Principles:**

- Single stroke weight (4-6px depending on size)
- Symmetrical
- Rounded caps and joins
- No decorative details
- Recognizable at any size

**Proportions:**

- Height to width ratio: 1.2:1
- Ring: 15% of total height
- Stock (vertical line): 60% of total height
- Flukes: 40% of total width

## Logo Variations

### Light Backgrounds

- **Full color:** Anchor Slate wordmark + Teal symbol
- **Monochrome:** All Anchor Slate
- **Reversed:** Use dark version only

### Dark Backgrounds

- **Full color:** White wordmark + Teal symbol
- **Monochrome:** All white
- **Reversed:** Use light version only

### Clear Space

```
┌─ ⚓ ─┐  ← Minimum 1x symbol height on all sides
│     │
⚓ ⚓ ⚓
│     │
└─ ⚓ ─┘
```

No other elements should enter the clear space zone.

## Logo Don'ts

❌ Don't change colors

❌ Don't rotate or skew

❌ Don't add effects (shadows, glows)

❌ Don't outline or add borders

❌ Don't place on busy backgrounds

❌ Don't stretch or distort proportions

❌ Don't add your own anchor illustrations

---

# Color System

## Design Philosophy

**Content First, Not Color First**

- Minimalist approach
- Colors support content, never compete
- High contrast for accessibility
- Timeless, not trendy
- Works in light and dark modes

---

## Primary Colors

### Anchor Slate (Primary Brand)

```
██████████  #2C3E50
            RGB: 44, 62, 80
            HSL: 210°, 29%, 24%

Usage: App icon, key branding, primary actions
Feel: Grounded, stable, confident
```

### Anchor Teal (Accent)

```
██████████  #0D9488
            RGB: 13, 148, 136
            HSL: 174°, 84%, 32%

Usage: CTAs, active states, "Anchor" button, highlights
Feel: Calm, distinctive, actionable
```

---

## Celebration Gradients

**NEW IN v2.0:** Gradients are allowed ONLY for celebration and success moments.

### Success Gradient (Confirmation Screen)

```
Gradient: Linear, 135° diagonal
Start: #10B981 (Success Green)
End: #0D9488 (Anchor Teal)

Usage: "Anchored!" confirmation screen background
Duration: 3-second display
Feel: Celebratory, accomplished, positive
```

**Rules for Gradient Usage:**

- ✅ Use ONLY for success/confirmation moments
- ✅ Use the defined Success Gradient colors
- ✅ Always 135° diagonal direction
- ❌ Never use for buttons or primary UI elements
- ❌ Never use in navigation or persistent UI
- ❌ Never create custom gradients outside this spec

**When to Use:**

- Confirmation screen after saving a link
- Success animations or transitions
- Celebration overlays (must be temporary, <5 seconds)

**When NOT to Use:**

- Regular backgrounds
- Buttons (use solid colors)
- Cards or content surfaces
- Navigation elements
- Persistent UI elements

---

## Neutral Grays (Light Mode)

### Charcoal (Text Primary)

```
██████████  #1A1A1A
            RGB: 26, 26, 26
            
Usage: Primary text, headings, body copy
Contrast on white: 15.8:1 (AAA)
```

### Slate (Text Secondary)

```
██████████  #4A5568
            RGB: 74, 85, 104
            
Usage: Secondary text, labels, metadata, timestamps
Contrast on white: 7.9:1 (AAA)
```

### Silver (Borders)

```
██████████  #CBD5E1
            RGB: 203, 213, 225
            
Usage: Borders, dividers, disabled states
```

### Ash (Backgrounds)

```
██████████  #F1F5F9
            RGB: 241, 245, 249
            
Usage: Secondary backgrounds, cards, input fields
```

### White (Base)

```
██████████  #FFFFFF
            RGB: 255, 255, 255
            
Usage: Primary backgrounds, content surfaces
```

---

## Dark Mode Colors

### Deep Charcoal (Background)

```
██████████  #0F172A
            RGB: 15, 23, 42
            
Usage: Primary dark mode background
```

### Dark Slate (Surface)

```
██████████  #1E293B
            RGB: 30, 41, 59
            
Usage: Cards, elevated surfaces, navigation
```

### Off White (Text Primary)

```
██████████  #F8FAFC
            RGB: 248, 250, 252
            
Usage: Primary text in dark mode
```

### Light Gray (Text Secondary)

```
██████████  #94A3B8
            RGB: 148, 163, 184
            
Usage: Secondary text, metadata in dark mode
```

### Dark Border

```
██████████  #334155
            RGB: 51, 65, 85
            
Usage: Borders and dividers in dark mode
```

### Anchor Teal (Dark Mode Adjusted)

```
██████████  #14B8A6
            RGB: 20, 184, 166
            
Usage: Same as light mode but slightly brighter for dark backgrounds
```

---

## Semantic Colors

Use sparingly. Only when necessary.

### Success

```
██████████  #059669 (Light)
██████████  #10B981 (Dark)

Usage: Success messages, confirmations
Example: "Anchored ✓"
```

### Warning

```
██████████  #D97706 (Light)
██████████  #F59E0B (Dark)

Usage: Warnings, approaching limits, cautions
Example: "90/100 anchors used"
```

### Error

```
██████████  #DC2626 (Light)
██████████  #EF4444 (Dark)

Usage: Errors, destructive actions, failures
Example: "Couldn't anchor this link"
```

---

## Color Usage Matrix

| Element | Light Mode | Dark Mode | Notes |
| --- | --- | --- | --- |
| App Background | #FFFFFF | #0F172A | Pure white / Deep charcoal |
| Card Surface | #F1F5F9 | #1E293B | Subtle elevation |
| Text (Primary) | #1A1A1A | #F8FAFC | High contrast |
| Text (Secondary) | #4A5568 | #94A3B8 | Labels, metadata |
| Borders | #CBD5E1 | #334155 | Subtle separation |
| Primary Button | #0D9488 | #14B8A6 | "Anchor" action |
| Button Text | #FFFFFF | #FFFFFF | On teal buttons |
| Links | #0D9488 | #14B8A6 | Interactive text |
| Icons (Primary) | #2C3E50 | #F8FAFC | Brand or neutral |
| Icons (Accent) | #0D9488 | #14B8A6 | Actions |
| Success | #059669 | #10B981 | Confirmations |
| Warning | #D97706 | #F59E0B | Cautions |
| Error | #DC2626 | #EF4444 | Problems |
| Success Gradient | #10B981→#0D9488 | Same | Celebration only |

---

## Accessibility Standards

All color combinations meet **WCAG 2.1 AA minimum** (4.5:1 for normal text).

### Contrast Ratios

| Combination | Ratio | Level |
| --- | --- | --- |
| Charcoal on White | 15.8:1 | AAA ✅ |
| Slate on White | 7.9:1 | AAA ✅ |
| Anchor Teal on White | 4.5:1 | AA (Large text) ⚠️ |
| White on Anchor Slate | 12.6:1 | AAA ✅ |
| White on Anchor Teal | 3.2:1 | AA Large only ⚠️ |

**Important:** Use Anchor Teal only for:

- Large text (18px+ regular, 14px+ bold)
- Icons and graphics
- Backgrounds with white text

For small text, use Charcoal or Slate.

---

## Color in Context

### Primary Action Button

```
┌─────────────────────────┐
│                         │
│    Anchor This Page     │  ← White text (#FFFFFF)
│                         │     on Teal background (#0D9488)
└─────────────────────────┘
     Bold, 16px, centered
```

### Success Confirmation Screen

```
┌─────────────────────────────────┐
│  ╱╲ Success Gradient Background │
│ ╱  ╲ (#10B981 → #0D9488)        │
│╱    ╲                           │
│                                 │
│   Anchored! Find it anytime     │  ← White text, bold, 32px
│                                 │
│   ━━━━━━━━━━━━━━━━━━━━━       │  ← Progress bar (3s)
│                                 │
│   [ Add Details ]               │  ← White button outline
│                                 │
└─────────────────────────────────┘
```

### Success Message

```
┌─────────────────────────────────┐
│  ✓  Anchored from Safari        │  ← Teal checkmark
│                                 │     Charcoal text
└─────────────────────────────────┘
     Ash background or transparent
```

### Text Hierarchy Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Article Title Here          ← Charcoal #1A1A1A, Bold, 20px

Added 2 hours ago          ← Slate #4A5568, Regular, 14px

This is the preview text   ← Charcoal #1A1A1A, Regular, 14px
showing the first few...

#design #research          ← Teal #0D9488, Regular, 12px

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

# Typography

## Font Families

### Primary Typeface: Geist

**Why Geist:**

- Designed for UI and screens
- Excellent legibility at all sizes
- Open source and free
- Variable font (flexible weights)
- Great Arabic support for bilingual app

**Fallback Stack:**

```
font-family: 'Geist', -apple-system, BlinkMacSystemFont, 
             'Segoe UI', 'Roboto', 'Helvetica Neue', 
             Arial, sans-serif;
```

### Arabic Typeface: **IBM Plex Sans Arabic**

**Why IBM Plex Arabic:**

- Modern, clean, professional
- Designed to harmonize with Latin sans-serifs
- Excellent screen rendering
- Open source
- Matches Inter's personality

**Fallback Stack (Arabic):**

```
font-family: 'IBM Plex Sans Arabic', 'Noto Sans Arabic',
             'Arial', sans-serif;
```

---

## Type Scale

### Mobile (iOS/Android)

| Style | Weight | Size | Line Height | Letter Spacing |
| --- | --- | --- | --- | --- |
| **Hero** | Bold (700) | 32px | 40px | -0.5px |
| **Title 1** | Bold (700) | 28px | 36px | -0.5px |
| **Title 2** | Semibold (600) | 24px | 32px | -0.25px |
| **Title 3** | Semibold (600) | 20px | 28px | 0px |
| **Headline** | Semibold (600) | 17px | 24px | 0px |
| **Body** | Regular (400) | 16px | 24px | 0px |
| **Subhead** | Medium (500) | 15px | 22px | 0px |
| **Footnote** | Regular (400) | 13px | 18px | 0px |
| **Caption 1** | Regular (400) | 12px | 16px | 0px |
| **Caption 2** | Regular (400) | 11px | 14px | 0.5px |

### Desktop/Web

| Style | Weight | Size | Line Height | Letter Spacing |
| --- | --- | --- | --- | --- |
| **Display** | Bold (700) | 48px | 56px | -1px |
| **H1** | Bold (700) | 36px | 44px | -0.5px |
| **H2** | Semibold (600) | 30px | 38px | -0.5px |
| **H3** | Semibold (600) | 24px | 32px | -0.25px |
| **H4** | Semibold (600) | 20px | 28px | 0px |
| **Body Large** | Regular (400) | 18px | 28px | 0px |
| **Body** | Regular (400) | 16px | 24px | 0px |
| **Body Small** | Regular (400) | 14px | 20px | 0px |
| **Caption** | Regular (400) | 12px | 16px | 0.5px |

---

## Typography Examples

### Card Title + Metadata

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

How to Design Better Mobile Apps    ← Title 3, Semibold, 20px
                                       Charcoal #1A1A1A

[medium.com](http://medium.com) • 5 min read • 2d ago    ← Caption, Regular, 12px
                                       Slate #4A5568

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Button Text

```
┌─────────────────────┐
│   Anchor This Page  │  ← Subhead, Medium, 15px
└─────────────────────┘     White on Teal
```

### Empty State

```
         ⚓

No anchors yet               ← Title 2, Semibold, 24px
                               Charcoal #1A1A1A

Start anchoring pages        ← Body, Regular, 16px
you want to return to         Slate #4A5568
```

### Search Results Count

```
48 anchors found             ← Footnote, Regular, 13px
                               Slate #4A5568
```

---

## Typography Do's and Don'ts

### ✅ Do

- Use Geist for English text
- Use IBM Plex Sans Arabic for Arabic text
- Maintain hierarchy with size and weight
- Keep line length between 50-75 characters
- Use consistent line heights (1.5x for body)
- Left-align body text (right-align for Arabic)
- Use semantic HTML tags

### ❌ Don't

- Don't use more than 3 weights per page
- Don't use font sizes smaller than 11px (except legal)
- Don't use all caps for long text
- Don't use italic for emphasis (use semibold instead)
- Don't use decorative or script fonts
- Don't center-align large blocks of text
- Don't use tight letter-spacing on body text

---

# Motion & Animation

**NEW IN v2.0**

## Animation Principles

Motion should feel **steady, confident, and purposeful**—never flashy or gratuitous.

### Core Principles

1. **Purposeful** — Every animation communicates state or guides attention
2. **Quick** — Animations should be fast enough to not impede workflow
3. **Smooth** — Use easing curves that feel natural, not robotic
4. **Subtle** — Minimal movement; let content be the focus
5. **Consistent** — Same animation speeds and styles throughout

---

## Animation Speeds

| Duration | Use Case | Easing |
| --- | --- | --- |
| **100ms** | Micro-interactions (button press, toggle) | ease-out |
| **200ms** | State changes (tab switch, checkbox) | ease-in-out |
| **300ms** | Navigation (screen transitions) | ease-in-out |
| **400ms** | Modals & sheets (slide up/down) | ease-out |
| **3000ms** | Celebration (confirmation screen) | linear (progress bar) |

---

## Animation Types

### Micro-interactions

```
Button Press:
- Duration: 100ms
- Transform: scale(0.96)
- Easing: ease-out

Toggle Switch:
- Duration: 200ms
- Transform: translateX()
- Easing: ease-in-out
```

### Transitions

```
Screen Navigation:
- Duration: 300ms
- Transform: translateX(100%) → translateX(0)
- Easing: cubic-bezier(0.4, 0, 0.2, 1)

Tab Switch:
- Duration: 200ms
- Opacity: 0 → 1
- Transform: translateY(8px) → translateY(0)
- Easing: ease-in-out
```

### Bottom Sheets

```
Sheet Appearance:
- Duration: 400ms
- Transform: translateY(100%) → translateY(0)
- Easing: cubic-bezier(0.0, 0.0, 0.2, 1)

Sheet Dismissal:
- Duration: 300ms
- Transform: translateY(0) → translateY(100%)
- Easing: cubic-bezier(0.4, 0.0, 1, 1)

Backdrop:
- Duration: 300ms (sync with sheet)
- Opacity: 0 → 0.4 (appear)
- Opacity: 0.4 → 0 (dismiss)
```

### Celebration Moments

```
Confirmation Screen:
- Duration: 3000ms (auto-dismiss)
- Gradient background (no animation)
- Progress bar: 0% → 100% (linear)
- Text: fade in 200ms, stay visible
- Button: fade in 400ms (delayed)
```

### Loading States

```
Skeleton Screens:
- Duration: 1500ms (loop)
- Gradient shimmer effect
- Direction: left → right
- Easing: ease-in-out

Spinner:
- Duration: 800ms (loop)
- Rotation: 0deg → 360deg
- Easing: linear
```

---

## Animation Don'ts

❌ Don't use bounce or elastic easing (too playful)

❌ Don't animate multiple properties at once (cluttered)

❌ Don't use animations longer than 500ms (except celebration)

❌ Don't animate on scroll (can cause motion sickness)

❌ Don't use parallax effects (off-brand)

❌ Don't auto-play looping animations (distracting)

---

## Reduced Motion

**Accessibility Requirement:**

Always respect `prefers-reduced-motion` system setting.

When reduced motion is enabled:

- Disable all transitions longer than 200ms
- Replace animations with instant state changes
- Keep essential feedback (e.g., button press)
- Disable celebration screen auto-dismiss animation

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

# Iconography

## Icon Style

**Minimalist Outline Style**

- 2px stroke weight (1.5px for small icons)
- Rounded line caps and joins
- No fill (outline only)
- Geometric and simple
- Consistent visual weight

## Icon Library

We use **Lucide Icons** as our base library (open source, consistent, minimal).

### Primary Icons

```
⚓  Anchor         🔍  Search        ⚙️  Settings
📑  Collections    🏷️  Tags         ↗️  Share
✓   Check         ✕   Close        +   Add
←   Back          →   Forward      ⋮   More
⭐  Favorite      📱  Mobile       🌐  Browser
```

### Custom Anchor Icon

Our primary "Anchor" icon is custom and unique to our brand.

```
     │
     │
     ●      ← 2px stroke
     │         Rounded caps
     │         Symmetrical
 ────┴────
╱         ╲
```

**Usage:**

- Main action button
- Navigation tab
- App icon
- Success confirmations

---

## Icon Sizing

| Context | Size | Stroke Width |
| --- | --- | --- |
| Navigation/Tab Bar | 24×24px | 2px |
| Button Icons | 20×20px | 2px |
| Inline Icons | 16×16px | 1.5px |
| List Item Icons | 20×20px | 2px |
| Empty State Icons | 48×48px | 2px |
| Large Hero Icons | 64×64px | 2.5px |

---

## Icon Colors

### Light Mode

- **Primary Icons:** Charcoal (#1A1A1A)
- **Secondary Icons:** Slate (#4A5568)
- **Accent Icons:** Anchor Teal (#0D9488)
- **Success Icons:** Deep Green (#059669)
- **Warning Icons:** Warm Amber (#D97706)
- **Error Icons:** Deep Red (#DC2626)

### Dark Mode

- **Primary Icons:** Off White (#F8FAFC)
- **Secondary Icons:** Light Gray (#94A3B8)
- **Accent Icons:** Anchor Teal (#14B8A6)
- **Success Icons:** Light Green (#10B981)
- **Warning Icons:** Light Amber (#F59E0B)
- **Error Icons:** Light Red (#EF4444)

---

## Icon Usage Examples

### Navigation Bar

```
┌────────────────────────────────────┐
│                                    │
│    🏠 Home    ⚓ Anchor    ⚙️ Settings
│                                    │
└────────────────────────────────────┘

Inactive: Slate (#4A5568)
Active: Anchor Teal (#0D9488)
```

### Action Button with Icon

```
┌────────────────────────┐
│  ⚓  Anchor This Page  │
└────────────────────────┘

Icon: White on Teal background
16px icon + 8px spacing + text
```

### List Item

```
┌────────────────────────────────────┐
│  📰  Design System Best...         │
│      [medium.com](http://medium.com) • 2d ago           │
└────────────────────────────────────┘

Icon: 20×20px, Slate color
8px spacing from text
```

---

## Icon Don'ts

❌ Don't mix icon styles (filled + outline)

❌ Don't use icons smaller than 16×16px

❌ Don't use too many colors

❌ Don't rotate icons awkwardly

❌ Don't stretch or distort icons

❌ Don't use icons without labels for primary actions

---

# Layout & Spacing

## Grid System

### Mobile Grid (iOS/Android)

- **Columns:** 4 columns (for 2-column card layout)
- **Margins:** 16px (left/right)
- **Gutters:** 12px between cards
- **Container:** Full width minus margins

### Tablet Grid

- **Columns:** 8 columns
- **Margins:** 24px (left/right)
- **Gutters:** 16px between columns
- **Max width:** None (fluid)

### Desktop/Web Grid

- **Columns:** 12 columns
- **Margins:** Auto (centered)
- **Gutters:** 24px between columns
- **Max width:** 1200px

---

## Spacing System

Use an 8px base unit for all spacing.

### Spacing Scale

| Token | Value | Usage |
| --- | --- | --- |
| **XXS** | 4px | Icon-text gap, tight spacing |
| **XS** | 8px | Text line breaks, small gaps |
| **SM** | 12px | Input padding, compact spacing |
| **MD** | 16px | Standard spacing, margins |
| **LG** | 24px | Section spacing, card padding |
| **XL** | 32px | Large section breaks |
| **2XL** | 48px | Major section separation |
| **3XL** | 64px | Hero spacing, empty states |

### Common Spacing Patterns

```
Card Padding: 16px all sides
List Item: 12px vertical, 16px horizontal
Button Padding: 12px vertical, 24px horizontal
Input Field: 12px vertical, 16px horizontal
Section Margin: 24px between sections
Page Margin: 16px mobile, 24px tablet, auto desktop
Grid Gap (2-column): 12px between cards
```

---

## Layout Principles

### 1. **Content First**

Prioritize readable content over decorative elements.

### 2. **Generous Whitespace**

Don't be afraid of empty space—it creates clarity.

### 3. **Clear Hierarchy**

Use spacing to show relationships between elements.

### 4. **Consistent Rhythm**

Use the 8px spacing system everywhere.

### 5. **Responsive**

Scale gracefully from mobile to desktop.

---

## Layout Examples

### Mobile List View

```
┌────────────────────────────────────┐ ←─ 16px margin
│  ┌──────────────────────────────┐ │
│  │  [Image]  Title Text Here    │ │ ←─ 12px padding
│  │           [medium.com](http://medium.com) • 2d     │ │
│  └──────────────────────────────┘ │
│                                    │ ←─ 8px gap
│  ┌──────────────────────────────┐ │
│  │  [Image]  Another Title       │ │
│  │           [website.com](http://website.com) • 5h    │ │
│  └──────────────────────────────┘ │
│                                    │
└────────────────────────────────────┘
```

### Card Layout (2-Column Grid)

```
┌─────────────────────────────────────┐
│  ┌──────────┐  ┌──────────┐        │ ←─ 16px margin
│  │          │  │          │        │
│  │  Image   │  │  Image   │        │
│  │          │  │          │        │
│  ├──────────┤  ├──────────┤        │
│  │ Title    │  │ Title    │        │
│  │ Domain   │  │ Domain   │        │
│  └──────────┘  └──────────┘        │
│       ↑            ↑                │
│       └─── 12px ───┘                │
│                                     │
└─────────────────────────────────────┘

Card dimensions: 173×242px (from designs)
Gap between cards: 12px
Total width: 173 + 12 + 173 = 358px
```

### Empty State

```
┌─────────────────────────────────────┐
│                                     │
│                                     │ ←─ 64px top margin
│             ⚓                      │
│                                     │ ←─ 24px spacing
│       No anchors yet               │
│                                     │ ←─ 12px spacing
│    Start anchoring pages           │
│    you want to return to           │
│                                     │ ←─ 24px spacing
│    ┌─────────────────────┐        │
│    │  Anchor Your First  │        │
│    └─────────────────────┘        │
│                                     │
│                                     │
└─────────────────────────────────────┘
```

---

# Components

## Buttons

### Primary Button (Anchor Action)

```
┌───────────────────────────┐
│                           │
│    Anchor This Page       │  ← White text, 15px, Medium
│                           │     Teal background (#0D9488)
└───────────────────────────┘     12px vertical, 24px horizontal
                                  8px border radius
                                  
States:
- Default: #0D9488
- Hover: #0A7B72 (darker)
- Pressed: #085D56 (even darker)
- Disabled: 40% opacity
```

### Secondary Button

```
┌───────────────────────────┐
│                           │
│    Cancel                 │  ← Charcoal text, 15px, Medium
│                           │     Ash background (#F1F5F9)
└───────────────────────────┘     Same padding as primary

States:
- Default: Charcoal on Ash
- Hover: Slate on Ash
- Pressed: Charcoal on Silver
```

### Ghost Button (Outline)

```
┌───────────────────────────┐
│    Add Details            │  ← White text, 15px, Medium
└───────────────────────────┘     White 2px border
                                  Transparent background
                                  8px border radius

Usage: On gradient confirmation screen
States:
- Default: White border + text
- Hover: White background (10% opacity)
- Pressed: White background (20% opacity)
```

### Text Button

```
   Anchor This Page           ← Teal text, 15px, Medium
   ─────────────────             No background
                                 No border
                                 
States:
- Default: Teal text
- Hover: Darker teal
- Pressed: Even darker
```

---

## Input Fields

### Text Input

```
┌─────────────────────────────────────┐
│  Search your anchors               │  ← Charcoal text
└─────────────────────────────────────┘     Ash background
                                           Silver border (1px)
                                           8px border radius
                                           12px vertical padding
                                           16px horizontal padding

States:
- Default: Silver border (#CBD5E1)
- Focus: Teal border (#0D9488), 2px
- Error: Error red border (#DC2626), 2px
- Disabled: 50% opacity
```

### Search Bar

```
┌─────────────────────────────────────┐
│  🔍  Search your anchors           │  ← Icon + input
└─────────────────────────────────────┘     Slate icon
                                           12px icon-text gap
                                           
Placeholder: Slate (#4A5568)
Input text: Charcoal (#1A1A1A)
```

### Textarea (Note Field)

```
┌─────────────────────────────────────┐
│  Why did you save this?            │
│                                     │
│                                     │  ← 3-5 lines visible
│                                     │
└─────────────────────────────────────┘
                                    0/200  ← Character counter

Same styling as text input
Height: Auto-expand up to 206px
Character limit: 200
```

---

## Cards

### Link Card (2-Column Grid View)

```
┌────────────────────┐
│                    │
│   [Thumbnail]      │  ← 16:9 or 1:1, 173px wide
│     16:9           │
│                    │
├────────────────────┤
│                    │
│  Title Text Here   │  ← Semibold, 14px, 2 lines max
│                    │
│  [site.com](http://site.com) • 2d     │  ← Regular, 11px, Slate
│                    │
└────────────────────┘

Dimensions: 173×242px (from designs)
Border radius: 8px
Border: 1px Silver (#CBD5E1)
Background: White
Padding (text area): 12px
Shadow on hover: 0 4px 12px rgba(0,0,0,0.08)
```

### Link Card (List View - Alternative)

```
┌─────────────────────────────────────┐
│  ┌────┐                             │
│  │Img │  Article Title Here         │  ← Title, Semibold, 16px
│  │64px│  [website.com](http://website.com) • 2 hours ago  │  ← Metadata, Regular, 12px
│  └────┘                             │
│        Preview text showing...      │  ← Body, Regular, 14px
│                                     │
│        #design #research            │  ← Tags, Teal, 12px
└─────────────────────────────────────┘

White background
Silver border (1px)
8px border radius
16px padding
Subtle shadow on hover
```

---

## Bottom Sheets

**NEW IN v2.0: Comprehensive bottom sheet specs**

### Bottom Sheet Container

```
┌─────────────────────────────────────┐
│            ────                     │  ← Grabber (36×5px, Slate)
│                                     │     6px from top
│  [Content Area]                     │
│                                     │
│                                     │
│  ┌─────────────────────────────┐  │  ← Action button area
│  │         Done                │  │     Always visible (sticky)
│  └─────────────────────────────┘  │
│                                     │
│  [Home Indicator]                  │  ← iOS home indicator
└─────────────────────────────────────┘

Corner radius: 16px (top corners only)
Background: White (light) / Dark Slate (dark)
Backdrop: Black, 40% opacity
Min height: 166px (small sheets)
Max height: 758px (full sheets)
Padding: 16px horizontal
```

### Bottom Sheet Variants

**Small Sheet (Context Menu):**

- Height: Auto-fit content (166px typical)
- Use: Quick actions (Copy, Delete, Share)
- Content: List of action items

**Medium Sheet (Add Details):**

- Height: 515px
- Use: Tag/Note/Space tabs
- Content: Tabs + form fields + action button

**Large Sheet (Create Space):**

- Height: 758px
- Use: Multi-step forms
- Content: Logo, title, description, form, action button

### Bottom Sheet Grabber

```
────  ← 36×5px rounded rectangle
      Slate color (#4A5568)
      6px from top edge
      Centered horizontally
```

### Bottom Sheet Animation

- Entrance: 400ms, cubic-bezier(0.0, 0.0, 0.2, 1)
- Exit: 300ms, cubic-bezier(0.4, 0.0, 1, 1)
- Backdrop fade: 300ms sync with sheet

---

## Tab Navigation

**NEW IN v2.0: Tab navigation specs**

### Tab Bar (Bottom Navigation)

```
┌─────────────────────────────────────┐
│                                     │
│   Home     Anchor    Spaces         │  ← Labels
│    🏠        ⚓        📑            │  ← Icons (24×24px)
│    ━                                │  ← Active indicator
│                                     │
└─────────────────────────────────────┘

Height: 79px (56px tab + 23px home indicator space)
Background: White (light) / Dark Slate (dark)
Border top: 1px Silver (#CBD5E1)
Icon size: 24×24px
Label: Caption 1 (12px, Regular)
Spacing: Icon above label, 4px gap
```

### Tab States

**Active Tab:**

- Icon: Anchor Teal (#0D9488)
- Label: Anchor Teal (#0D9488), Regular
- Indicator: 2px line under icon, Teal, 24px wide

**Inactive Tab:**

- Icon: Slate (#4A5568)
- Label: Slate (#4A5568), Regular
- No indicator

**Pressed State:**

- Background: Ash (#F1F5F9), 10% opacity
- Circle around icon: 48×48px
- Duration: 100ms

### Tab Switching Animation

- Duration: 200ms
- Content fade: Opacity 1 → 0 → 1
- Content shift: translateY(8px) → translateY(0)
- Indicator slide: translateX() to new position

---

## Context Menus

**NEW IN v2.0: Context menu specs**

### Context Menu Container

```
┌─────────────────────────────────────┐
│  📋  Copy to clipboard              │  ← Menu item
│  🏷️  Add Tag                        │
│  📁  Add to space                   │
│  🗑️  Delete Link                    │  ← Destructive
└─────────────────────────────────────┘

Background: White (light) / Dark Slate (dark)
Border radius: 12px
Shadow: 0 8px 24px rgba(0,0,0,0.15)
Padding: 0 (items have their own padding)
```

### Context Menu Item

```
┌─────────────────────────────────────┐
│  📋  Copy to clipboard              │
└─────────────────────────────────────┘

Height: 56px
Padding: 16px horizontal, 18px vertical
Icon: 24×24px, 20px from left
Text: Body (16px), 52px from left
Icon-text gap: 8px
```

### Context Menu Item States

**Default:**

- Background: Transparent
- Text: Charcoal (#1A1A1A)
- Icon: Slate (#4A5568)

**Hover/Pressed:**

- Background: Ash (#F1F5F9)
- Text: Same
- Icon: Same

**Destructive Action:**

- Text: Error Red (#DC2626)
- Icon: Error Red (#DC2626)
- Background on press: Red, 5% opacity

### Context Menu Divider

```
─────────────────────────────  ← 1px Silver line
                                  0 vertical margin
                                  Between item groups
```

---

## App Badge

**NEW IN v2.0: Badge specifications**

### Unread Count Badge

```
   ┌───────┐
   │  12   │  ← Badge on app icon
   └───────┘

Background: Error Red (#DC2626)
Text: White (#FFFFFF), Bold, 11px
Border radius: 12px (pill shape)
Min size: 20×20px
Padding: 4px horizontal, 2px vertical
Position: Top-right of app icon, -4px offset
```

### Badge States

**1-9 items:**

- Display: Single digit (e.g., "5")
- Size: 20×20px (circular)

**10-99 items:**

- Display: Two digits (e.g., "42")
- Size: Auto-width, 20px height (pill)

**100+ items:**

- Display: "99+"
- Size: Auto-width, 20px height (pill)

**No unread items:**

- Display: No badge
- Badge disappears with fade animation (200ms)

---

## Lists

### Standard List Item

```
┌─────────────────────────────────────┐
│  📰  Design System Guide            │  ← Icon + title
│      [medium.com](http://medium.com) • Added 2 days ago  │  ← Metadata
├─────────────────────────────────────┤  ← Silver divider
│  📖  React Documentation            │
│      [react.dev](http://react.dev) • Added 1 week ago   │
├─────────────────────────────────────┤
│  🎨  Figma Best Practices           │
│      [figma.com](http://figma.com) • Added 3 days ago   │
└─────────────────────────────────────┘

Height: 72px per item
Padding: 16px horizontal, 16px vertical
Divider: 1px Silver
```

---

## Modals & Sheets

### Confirmation Modal (Desktop)

```
┌─────────────────────────────────────┐
│                                     │
│  Delete this anchor?                │  ← Title
│                                     │
│  This action cannot be undone       │  ← Body
│                                     │
│     ┌────────┐  ┌────────────┐    │
│     │ Cancel │  │   Delete   │    │  ← Buttons
│     └────────┘  └────────────┘    │
│                                     │
└─────────────────────────────────────┘

Max width: 400px
Border radius: 12px
Padding: 24px
Centered on screen
Shadow: 0 20px 40px rgba(0,0,0,0.2)
Backdrop: Black, 50% opacity
```

---

## States

### Loading State

```
┌─────────────────────────────────────┐
│                                     │
│           ⚪ ⚪ ⚪                   │  ← Animated dots
│                                     │     Slate color
│        Loading...                  │     Caption, 12px
│                                     │
└─────────────────────────────────────┘
```

### Empty State

```
┌─────────────────────────────────────┐
│                                     │
│              ⚓                      │  ← Silver icon, 48px
│                                     │
│        No anchors yet              │  ← Title, Semibold, 20px
│                                     │
│   Start anchoring pages            │  ← Body, Regular, 16px
│   you want to return to            │
│                                     │
└─────────────────────────────────────┘
```

### Error State

```
┌─────────────────────────────────────┐
│   ✕  Couldn't anchor this          │  ← Error red icon
│      Check your connection         │     Charcoal text
│                                     │
│      [Try Again]                   │  ← Secondary button
└─────────────────────────────────────┘
```

---

# Empty States & Voice

**NEW IN v2.0: Empty state voice guidelines**

## Empty State Principles

Empty states should be **calm, clear, and instructional**—never anxious or overly encouraging.

### Voice Guidelines

**Do:**

- ✅ Use simple, factual language: "No anchors yet"
- ✅ Provide clear next steps: "Start anchoring pages"
- ✅ Keep it brief (2 lines max)
- ✅ Use present tense
- ✅ Be direct and confident

**Don't:**

- ❌ Use exclamation marks excessively
- ❌ Be overly enthusiastic: "Let's get started!"
- ❌ Use multiple sentences
- ❌ Apologize: "Sorry, nothing here yet"
- ❌ Use cutesy language: "Oops! It's empty!"

---

## Empty State Examples

### Home Screen (No Anchors)

```
         ⚓

No anchors yet

Start anchoring pages
you want to return to
```

### Space (Empty)

```
         📁

This space is empty

Add links from Home or
save directly to this space
```

### Search (No Results)

```
         🔍

No anchors found

Try different keywords or
remove filters
```

### Tags (No Tags)

```
         🏷️

No tags yet

Add tags when saving links
to organize and find them
```

---

# RTL & Arabic Support

**NEW IN v2.0: RTL layout guidelines**

## RTL Layout Principles

When the app language is set to Arabic:

- All layouts mirror horizontally
- Text aligns right by default
- Icons that indicate direction (arrows) flip
- Icons that represent objects (anchor, tags) don't flip

---

## RTL Layout Rules

### What Flips

**UI Elements:**

- Navigation bars (back button moves to right)
- Tab bars (order reverses)
- List items (icon moves to right)
- Buttons in button groups (order reverses)
- Bottom sheets (align right)
- Context menus (align right)
- Search bar (icon moves to right)

**Icons:**

- Directional arrows (←→ flip to →←)
- Back/Forward buttons
- Chevrons and carets
- Share icon (if directional)

### What Doesn't Flip

**Icons:**

- Anchor symbol (⚓ stays same)
- Settings gear
- Search magnifying glass
- Tags icon
- Checkmarks
- Plus/minus signs
- Close (X) icon

**Media:**

- Images (don't mirror)
- Thumbnails (don't mirror)
- Logos (don't mirror)
- App icon (don't mirror)

---

## RTL Layout Examples

### Navigation Bar (RTL)

```
LTR:  ←  Anchor              🔍  ⋮
RTL:  ⋮  🔍              Anchor  →

Back button flips sides
Icons reverse order
Title stays centered or aligns right
```

### Tab Bar (RTL)

```
LTR:  Home    Anchor    Spaces
RTL:  Spaces  Anchor    Home

Tab order reverses
Icons stay the same
Active indicator follows
```

### List Item (RTL)

```
LTR:  📰  Design System Guide
          [medium.com](http://medium.com) • 2d ago

RTL:  Design System Guide  📰
      2d ago • [medium.com](http://medium.com)

Icon moves to right
Text aligns right
Metadata order may adjust
```

### Button Group (RTL)

```
LTR:  [Cancel]  [Save]
RTL:  [Save]  [Cancel]

Button order reverses
Primary action stays right-most
```

---

## Arabic Typography Adjustments

### Font Sizes (Same as English)

Arabic uses the same type scale as English:

- No size adjustments needed
- IBM Plex Sans Arabic designed to match Geist metrics

### Line Heights (Slightly Increased)

Arabic has more vertical strokes, so adjust:

- Body text: 1.6x (vs 1.5x for English)
- Headings: 1.3x (vs 1.25x for English)

### Letter Spacing (None)

Arabic doesn't use letter spacing:

- Always set to 0 for Arabic text
- Don't apply Latin letter-spacing values

---

## Testing RTL Layouts

**iOS Testing:**

- Settings → General → Language & Region → Arabic
- Use Xcode RTL preview mode

**Android Testing:**

- Settings → System → Languages → Add Arabic
- Developer Options → Force RTL layout direction

**Web Testing:**

```html
<html dir="rtl" lang="ar">
```

---

# Imagery & Photography

## Image Guidelines

### Content Images (User's Saved Links)

- **Aspect Ratio:** 16:9 or 1:1 preferred
- **Quality:** Original quality preserved
- **Treatment:** No filters or overlays
- **Fallback:** Generic icon if no image available

### Placeholder Images

- **Color:** Ash (#F1F5F9) background
- **Icon:** Relevant icon in Silver (#CBD5E1)
- **Size:** Match intended image size
- **Style:** Minimal, clean

### Image Loading

- **Progressive loading:** Show placeholder first
- **Blur-up technique:** Low-res blur → full image
- **Error state:** Show broken image icon + "Image unavailable"

---

## Illustration Style

**Minimalist Line Illustrations**

- Single color (Anchor Slate or Silver)
- 2px stroke weight
- Simple, geometric shapes
- No gradients or shadows
- Used for empty states and onboarding

### Illustration Examples

**Empty State Illustrations:**

```
   ⚓              📑              🔍
No anchors    No collections   No results
```

Simple, iconic, recognizable at small sizes.

---

## Screenshot Guidelines

For marketing and App Store:

### Do:

✅ Use actual app screenshots

✅ Show real, quality content

✅ Include device frames (mockups)

✅ Show both light and dark modes

✅ Highlight key features

✅ Use consistent device (iPhone Pro, Pixel)

### Don't:

❌ Use fake/lorem ipsum content

❌ Overcrowd with annotations

❌ Use outdated designs

❌ Show empty states in marketing

❌ Inconsistent styling

---

# Do's and Don'ts

## Color Do's and Don'ts

### ✅ Do

- Use Anchor Teal for primary actions only
- Maintain high contrast for accessibility
- Test in both light and dark modes
- Use semantic colors sparingly
- Keep backgrounds simple
- Use gradients ONLY for celebration moments

### ❌ Don't

- Don't use Teal for small text
- Don't use more than 3 colors per screen
- Don't use gradients in persistent UI
- Don't use bright, saturated colors
- Don't forget dark mode
- Don't create custom gradients

---

## Typography Do's and Don'ts

### ✅ Do

- Use Geist for English
- Use IBM Plex Sans Arabic for Arabic
- Maintain clear hierarchy
- Keep line length readable (50-75 chars)
- Use semantic HTML

### ❌ Don't

- Don't use more than 3 font weights
- Don't go below 11px
- Don't use all caps for long text
- Don't center long paragraphs
- Don't use decorative fonts

---

## Logo Do's and Don'ts

### ✅ Do

- Maintain clear space
- Use approved color variations
- Scale proportionally
- Place on clean backgrounds
- Use vector files

### ❌ Don't

- Don't change colors
- Don't rotate or distort
- Don't add effects
- Don't use low-resolution files
- Don't violate clear space

---

## Layout Do's and Don'ts

### ✅ Do

- Use 8px spacing system
- Maintain consistent margins
- Create clear hierarchy
- Use whitespace generously
- Design mobile-first

### ❌ Don't

- Don't use random spacing values
- Don't crowd elements
- Don't ignore responsive behavior
- Don't forget touch targets (44px min)
- Don't over-design

---

## Component Do's and Don'ts

### ✅ Do

- Keep buttons consistent
- Make interactive elements obvious
- Provide clear feedback
- Use loading states
- Handle empty states gracefully

### ❌ Don't

- Don't use too many button styles
- Don't hide important actions
- Don't leave users hanging
- Don't ignore error states
- Don't use fake interactions

---

## Animation Do's and Don'ts

**NEW IN v2.0**

### ✅ Do

- Keep animations under 500ms (except celebration)
- Use purposeful motion
- Respect reduced motion preferences
- Use consistent easing
- Provide visual feedback

### ❌ Don't

- Don't use bounce or elastic easing
- Don't animate multiple properties at once
- Don't auto-play looping animations
- Don't use parallax effects
- Don't ignore accessibility settings

---

# Appendix

## File Naming Conventions

### Design Files

```
anchor-[component]-[variant]-[size].[ext]

Examples:
anchor-logo-primary-dark.svg
anchor-icon-app-ios.png
anchor-screenshot-home-light.png
```

### Code Assets

```
[component]_[variant]_[size].[ext]

Examples:
button_primary_large.xml
icon_anchor_24px.svg
```

---

## Export Specifications

### App Icon

- iOS: 1024×1024px PNG (no alpha)
- Android: 512×512px PNG (with alpha for adaptive icon)
- Web: 192×192px and 512×512px PNG

### Logo Files

- SVG: Vector (preferred)
- PNG: @1x, @2x, @3x (iOS), mdpi through xxxhdpi (Android)

### Colors

- Hex values for design
- RGB for web/CSS
- UIColor/Color for iOS
- Color resource XML for Android

---

## Resources & Tools

### Design Tools

- **Figma:** Primary design tool
- **SF Symbols:** iOS iconography
- **Material Symbols:** Android iconography
- **Lucide Icons:** Cross-platform icons

### Fonts

- **Inter:** [rsms.me/inter](http://rsms.me/inter)
- **IBM Plex Sans Arabic:** [IBM Plex](https://www.ibm.com/plex)

### Accessibility

- **Contrast Checker:** WebAIM Contrast Checker
- **Color Blind Simulator:** Stark plugin
- **Screen Readers:** iOS VoiceOver, Android TalkBack

### Development

- **iOS:** SwiftUI with custom theme
- **Android:** Jetpack Compose with Material Theme
- **Web:** CSS variables for theming
- **React Native:** StyleSheet with theme provider

---

## Version History

| Version | Date | Changes |
| --- | --- | --- |
| 2.0 | Nov 2025 | Added gradients, motion, RTL, components, empty states |
| 1.0 | Nov 2025 | Initial brand style guide |

---

## Contact & Feedback

**For questions about this guide:**

- Product Team: [Contact]
- Design Team: [Contact]

**To suggest updates:**

- Create a pull request
- Contact the Design Lead
- Submit feedback via [Process]

---

**This is a living document.** As Anchor evolves, this guide will be updated to reflect new patterns, components, and brand decisions.

**Last Updated:** November 2025

**Version:** 2.0

**Next Review:** February 2026

**Maintained by:** Product & Design Teams