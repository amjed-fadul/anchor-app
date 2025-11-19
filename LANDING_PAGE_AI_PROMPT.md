# AI Prompt: Generate Anchor App Beta Landing Page

**Use this prompt with AI coding assistants (ChatGPT, Claude, v0.dev, etc.) to generate your landing page**

---

## 🎯 Primary Prompt (Copy & Paste This)

```
I need you to create a modern, professional beta landing page for a link management app called "Anchor".

**Context:**
I have a comprehensive content document (BETA_LANDING_PAGE.md) that contains all the copy, design specs, legal documents, and technical requirements. I'll paste the relevant sections below.

**Your Task:**
Build a complete, production-ready landing page using modern web technologies with the following requirements:

## Technical Stack:
- **Framework:** Next.js 14+ (App Router) with TypeScript
- **Styling:** Tailwind CSS 3+ (utility-first approach)
- **Form Handling:** React Hook Form + Zod validation
- **Animations:** Framer Motion for smooth transitions
- **Icons:** Lucide React (or Heroicons)
- **Deployment:** Vercel-ready (optimized for production)

## Design Requirements:
- **Mobile-first responsive design** (works on 320px to 1920px screens)
- **Dark mode support** (optional but nice to have)
- **Accessibility:** WCAG 2.1 AA compliant
- **Performance:** Lighthouse score 90+ (Performance, Accessibility, Best Practices, SEO)
- **SEO optimized:** Meta tags, Open Graph, structured data

## Brand Identity (from BETA_LANDING_PAGE.md):
**Colors:**
- Primary (Anchor Teal): #0D9488
- Secondary (Anchor Slate): #2C3E50
- Neutrals: Gray-50 to Gray-900
- Success: #16A34A
- Error: #DC2626

**Typography:**
- Font Family: Geist (fallback: System fonts)
- Headlines: 48px desktop / 32px mobile
- Body: 16px
- Line height: 1.5

**Spacing:**
- 8px base unit system
- Section padding: 64px vertical (desktop) / 48px (mobile)
- Max content width: 1200px

## Page Structure (10 Sections):

### 1. Hero Section
- Sticky navigation bar (logo + "Join Beta" CTA)
- Large headline: "Save Links. Find Them Later. Actually."
- Subheadline explaining the value prop
- Primary CTA button: "Join the Beta Waitlist"
- Trust indicators (3 badges)
- Hero image/mockup placeholder
- Smooth scroll to form on CTA click

### 2. Problem Statement
- Section header: "Too Many Links, Too Much Chaos"
- 3-column grid (1 column on mobile)
- Each column: Icon + Title + Description
- Relatable pain points about bookmark management

### 3. Solution Overview
- Header: "Anchored! Find it anytime"
- Intro paragraph
- 4-column feature grid (2 cols tablet, 1 col mobile)
- Each feature: Icon + Title + Description
- Features: Save in <1s, Find Instantly, Organize Visually, Works Everywhere

### 4. Features Showcase
- Alternating left-right layout (image + text)
- 6 features total
- Each: Large screenshot placeholder + title + description
- On mobile: Stack vertically (text first, image second)

### 5. How It Works
- 3-step process with large numbers (01, 02, 03)
- Icon + Title + Description for each step
- Horizontal layout desktop, vertical mobile
- Visual connectors between steps (arrows/lines)

### 6. Beta Program Details
- Two-column layout (details + benefits)
- Left: What you get (checklist with green checkmarks)
- Right: Timeline + Limited spots callout
- CTA button: "Join the Waitlist"

### 7. Beta Signup Form (CRITICAL - Most Important Section)
**Form Fields:**
- Email (required, validated)
- Full Name (required)
- User Type (required, radio buttons: Designer, Developer, Student, Creator, Knowledge Worker, Other)
- Platforms (required, checkboxes: iOS, Android, Web - at least 1)
- Links per week (optional dropdown)
- Privacy Policy checkbox (required, with link)
- Beta Terms checkbox (required, with link)
- Submit button: "Join the Waitlist" (disabled until valid)

**Form Validation:**
- Real-time validation on blur
- Show error messages below fields
- Disable submit until all required fields + checkboxes valid
- Email format validation
- Success state: Show confetti animation + success message

**Form Submission:**
- POST to /api/beta-signup
- Loading state (spinner on button)
- Success: Show modal with waitlist position
- Error: Display error message, allow retry

### 8. FAQ Section
- Accordion-style (click to expand/collapse)
- 10 questions minimum (use content from BETA_LANDING_PAGE.md FAQ section)
- Search/filter functionality (optional but nice)
- Smooth expand/collapse animations

### 9. Social Proof
- Testimonials carousel (3 testimonials)
- Trust badges (500+ testers, 4.8 stars, platforms, privacy)
- Placeholder images for avatars

### 10. Footer
- 4 columns: Anchor (logo + tagline), Legal, Connect, Beta Program
- Links styled in brand colors
- Social media icons
- Copyright notice
- Mobile: Stack columns vertically

## Component Architecture:

Create these reusable components:
```typescript
// Core Components
- Navigation.tsx (sticky header)
- Hero.tsx
- ProblemStatement.tsx
- SolutionOverview.tsx
- FeaturesShowcase.tsx
- HowItWorks.tsx
- BetaDetails.tsx
- SignupForm.tsx (with validation)
- FAQ.tsx (accordion)
- SocialProof.tsx
- Footer.tsx

// UI Components (shadcn/ui style)
- Button.tsx (primary, secondary, ghost variants)
- Input.tsx (with error states)
- Checkbox.tsx
- RadioGroup.tsx
- Select.tsx
- Card.tsx
- Badge.tsx
- Accordion.tsx
- Modal.tsx

// Utilities
- FormSchema.ts (Zod validation)
- animations.ts (Framer Motion variants)
```

## Animations & Interactions:

1. **Scroll Animations:**
   - Fade in + slide up on scroll (using Framer Motion)
   - Stagger children animations (0.1s delay between items)
   - Trigger when element enters viewport

2. **Button Hovers:**
   - Slight lift (translateY -2px)
   - Shadow enhancement
   - Color darkening
   - 200ms transition

3. **Form Interactions:**
   - Focus ring on inputs (teal glow)
   - Smooth error message slide-in
   - Success confetti animation
   - Loading spinner on submit

4. **Smooth Scrolling:**
   - Clicking navigation items smoothly scrolls to section
   - CTA buttons scroll to form
   - Offset for sticky header

## API Route (Next.js):

```typescript
// app/api/beta-signup/route.ts
// POST endpoint that:
// 1. Validates input with Zod
// 2. Checks for duplicate emails
// 3. Stores in database (or sends to email service)
// 4. Sends confirmation email
// 5. Returns success with waitlist position
```

## SEO & Meta Tags:

```typescript
// app/layout.tsx or page.tsx metadata
export const metadata = {
  title: 'Anchor - Save Links, Find Them Later | Beta Signup',
  description: 'Join the Anchor beta and never lose a link again. Visual link manager for iOS, Android, and Web. Limited beta spots available.',
  keywords: ['bookmark manager', 'link manager', 'save links', 'visual bookmarks'],
  openGraph: {
    title: 'Anchor - Never Lose a Link Again',
    description: 'Join our exclusive beta program',
    images: ['/og-image.png'],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Anchor Beta Signup',
    description: 'Save links in <1 second. Find them instantly.',
    images: ['/twitter-image.png'],
  },
}
```

## Deliverables:

Please provide:

1. **Complete Next.js project structure:**
   - All component files (.tsx)
   - API route for form submission
   - Tailwind config with custom colors
   - TypeScript types/interfaces
   - Zod schemas for validation

2. **README.md with:**
   - Setup instructions
   - Environment variables needed
   - Deployment guide (Vercel)
   - Customization guide

3. **Responsive at these breakpoints:**
   - Mobile: < 768px
   - Tablet: 768px - 1024px
   - Desktop: > 1024px

4. **Accessibility features:**
   - Proper heading hierarchy (h1 → h2 → h3)
   - ARIA labels for icons
   - Keyboard navigation support
   - Focus management
   - Alt text for images
   - Form labels properly associated

5. **Performance optimizations:**
   - Image optimization (next/image)
   - Lazy loading below fold
   - Code splitting
   - Minimal bundle size

## Content to Use:

Here's the key content from BETA_LANDING_PAGE.md:

**Hero:**
- Headline: "Save Links. Find Them Later. Actually."
- Subheadline: "The modern link manager for people who save everything but can't find anything. Join our exclusive beta and never lose a link again."
- CTA: "Join the Beta Waitlist"

**Problem Statement (3 columns):**
1. "The Bookmark Black Hole" - You save links to read later, but "later" never comes. Your browser bookmarks are a graveyard of forgotten tabs.
2. "Lost in Translation" - That design inspiration you saved 3 weeks ago? Good luck finding it among 847 other links.
3. "Tool Fatigue" - Tried Pocket, Notion, Raindrop... Still can't find what you need when you need it.

**Features (4 value props):**
1. ⚡ Save in <1 Second - Share any link from any app directly to Anchor. No copy-paste. No switching apps.
2. 🔍 Find It Instantly - Full-text search across titles, notes, tags, and URLs. Type "design inspiration blue" and boom — there it is.
3. 🎨 Organize Visually - Create colorful Spaces for different contexts: Work, Personal, Inspiration, Research. See your links, not just a list.
4. 🔄 Works Everywhere - Save on your phone, find on your laptop. Real-time sync across iOS, Android, and Web. Offline-first so you're never blocked.

**How It Works (3 steps):**
1. 📱 Share Any Link - Found something interesting? Tap the share button and select Anchor. Works from any app on your phone.
2. 🏷️ Add Optional Details - Give it a quick tag or note if you want. Or skip it and move on — you can add context later.
3. ✨ Find It Instantly - Search by anything: title, tag, note, or URL. Your link appears in milliseconds. No folders to dig through.

**Beta Benefits (checklist):**
✓ Early access to iOS, Android & Web apps
✓ Free premium features during beta
✓ Direct feedback channel with the dev team
✓ Influence product roadmap with your ideas
✓ Priority support (< 24hr response)
✓ Beta tester badge in the app
✓ Grandfathered pricing when we launch

**FAQ (sample questions):**
- When does the beta start?
- What platforms are supported?
- Is my data safe during beta?
- Will I lose my data after beta ends?
- How long is the beta period?
- Will Anchor be free?

## Additional Instructions:

1. **Use placeholder images:**
   - Hero: `/images/hero-mockup.png`
   - Features: `/images/feature-1.png` through `/images/feature-6.png`
   - Screenshots: Use colored rectangles with text "Screenshot Placeholder" for now

2. **Make it easy to customize:**
   - Extract all colors to Tailwind config
   - Extract all copy to a `content.ts` file
   - Use TypeScript interfaces for type safety

3. **Production-ready code:**
   - No console.logs
   - Proper error handling
   - Loading states everywhere
   - TypeScript strict mode
   - ESLint + Prettier configured

4. **Comments in code:**
   - Explain complex logic
   - Mark TODOs for customization
   - Document props for components

## Start Building!

Please create the complete landing page with all sections, components, and functionality described above. Make it modern, fast, and beautiful!
```

---

## 🎨 Alternative Prompt for No-Code AI Builders (v0.dev, Framer AI, etc.)

If you're using a visual AI builder like v0.dev or Framer AI, use this shorter prompt:

```
Create a modern beta signup landing page for "Anchor" - a visual link management app.

**Design Style:**
- Modern, minimalist, clean
- Primary color: Teal (#0D9488)
- Secondary color: Slate (#2C3E50)
- Mobile-first responsive
- Smooth animations on scroll

**Sections (in order):**

1. **Hero** - Headline "Save Links. Find Them Later. Actually." + CTA button + hero image mockup
2. **Problem** - 3 columns showing pain points of traditional bookmark managers
3. **Solution** - 4 features in grid: Save in <1s, Find Instantly, Organize Visually, Works Everywhere
4. **Features** - 6 detailed features with alternating image-text layout
5. **How It Works** - 3-step process (Share → Tag → Find) with icons and numbers
6. **Beta Details** - Two columns: benefits checklist + timeline
7. **Signup Form** - Fields: Email, Name, User Type (radio), Platforms (checkboxes), Privacy/Terms checkboxes, Submit button
8. **FAQ** - Accordion with 10 questions about beta program
9. **Testimonials** - 3 testimonial cards with avatars
10. **Footer** - 4 columns: Brand, Legal, Connect, Beta Program

**CTA:** "Join the Beta Waitlist" button that scrolls to form

**Animations:**
- Fade in on scroll
- Button hover effects (lift + shadow)
- Smooth section transitions
- Form validation animations

Make it professional, modern, and optimized for conversions.
```

---

## 📋 Prompt for ChatGPT/Claude Code Generation

If you want just the React/Next.js code without the full project setup:

```
Generate React components for a beta landing page using:
- React 18+ with TypeScript
- Tailwind CSS for styling
- Framer Motion for animations
- React Hook Form + Zod for form validation

Create these components with full TypeScript types:

1. Hero.tsx - Hero section with headline, subheadline, CTA button
2. FeatureGrid.tsx - 4-column grid of feature cards
3. BetaSignupForm.tsx - Complete form with validation (email, name, user type, platforms, checkboxes)
4. FAQ.tsx - Accordion-style FAQ component
5. Footer.tsx - Multi-column footer

Use these brand colors:
- Primary: #0D9488 (teal)
- Secondary: #2C3E50 (slate)
- Include hover states, loading states, and error handling

Make components reusable with props for customization.
```

---

## 🎯 Prompt for Specific AI Tools

### For **v0.dev** (Vercel AI):
```
Beta landing page for link manager app called Anchor. Teal (#0D9488) brand color. Sections: Hero with CTA, problem statement (3 cols), features (4 cards), signup form with email/name/checkboxes, FAQ accordion, footer. Mobile responsive. Modern design.
```

### For **Framer AI**:
```
Landing page for Anchor app beta signup. Modern design, teal accent color. Hero section with "Save Links. Find Them Later. Actually." headline. Feature showcase grid. Beta signup form. FAQ section. Footer with links. Smooth scroll animations.
```

### For **ChatGPT Code Interpreter**:
```
Create an HTML landing page with embedded CSS and JavaScript for a beta signup. Single file. Includes: navigation, hero, features, form (with validation), FAQ, footer. Brand colors: teal #0D9488, slate #2C3E50. Mobile responsive using CSS Grid and Flexbox.
```

### For **Claude** (Anthropic):
```
I need a complete Next.js 14 landing page for a link management app beta program. Use TypeScript, Tailwind CSS, and Framer Motion. Include hero section, feature showcase, signup form with validation, FAQ accordion, and footer. Make it production-ready with proper SEO, accessibility, and performance optimizations. Brand colors: teal #0D9488 (primary), slate #2C3E50 (secondary).
```

---

## 💡 Tips for Best Results:

1. **Include the content:**
   - Paste specific sections from BETA_LANDING_PAGE.md into the prompt
   - Or provide a link to the file if the AI can access it

2. **Be specific about tech stack:**
   - Mention exact versions (Next.js 14, React 18, Tailwind 3)
   - Specify TypeScript if needed
   - Name specific libraries (Framer Motion, Zod, etc.)

3. **Request deliverables:**
   - "Include a README with setup instructions"
   - "Make components reusable with TypeScript props"
   - "Add comments explaining complex logic"

4. **Iterate:**
   - Start with basic structure
   - Then ask for animations: "Add scroll animations to all sections"
   - Then refine styling: "Make the hero section more modern with glassmorphism"

5. **Test on multiple devices:**
   - After generation, ask: "Make sure this works on mobile screens (320px width)"

---

## 📁 Files to Reference:

When using the prompt, have these ready:

1. **BETA_LANDING_PAGE.md** - Contains all content, copy, legal docs, design specs
2. **Brand assets** - Logo, app screenshots (if you have them)
3. **Example sites** - Show the AI similar landing pages you like

---

## 🚀 Example Workflow:

1. **Copy the "Primary Prompt" above**
2. **Paste into ChatGPT/Claude/v0.dev**
3. **Add specific sections from BETA_LANDING_PAGE.md**
4. **Generate the initial version**
5. **Iterate with refinements:**
   - "Make the CTA button more prominent"
   - "Add smooth scroll animations"
   - "Improve mobile responsive design for the form"
6. **Export the code and deploy to Vercel**

---

**Ready to generate your landing page!** Just copy-paste the prompt that matches your preferred tool. 🎨✨
