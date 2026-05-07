---
name: frontend-design-discipline
description: >-
  Apply opinionated frontend craftsmanship rules when designing or modifying
  any UI. Use when building or editing a web app / website / dashboard / game,
  choosing UI controls, styling components, composing pages, defining layout,
  picking icons, or designing landing pages and hero sections. Adopted from
  Codex's frontend guidance — codifies the small, easily-skipped decisions
  that separate amateur UI from professional UI. Read this before generating
  any non-trivial UI markup or proposing visual changes.
---

# Frontend Design Discipline

Use these rules as a hard gate on every UI change. They are deliberately
opinionated; if you must deviate, name the rule and the reason.

## Build with empathy

- Read the existing design system / framework first. Be consistent with it
  before introducing new styles or components.
- Match tone to domain. SaaS, CRM, internal tooling, ops dashboards must
  feel **quiet, utilitarian, and work-focused** — dense organized
  information, restrained styling, predictable navigation, scannable.
  Not editorial, not card-heavy, not marketing-style. Save expressive,
  illustrative, animated palettes for games and creative tools.
- Common workflows must be ergonomic and complete. The user must be
  able to navigate in and out of views seamlessly.

## Control choice

- **Icons in buttons** for tools.
- **Swatches** for color.
- **Segmented controls** for modes.
- **Toggles / checkboxes** for binary settings.
- **Sliders / steppers / inputs** for numeric values.
- **Menus** for option sets.
- **Tabs** for views.
- Text or icon+text buttons only for clear commands.

Never use a rounded rectangular UI element with text inside if a familiar
symbol or icon would communicate the same thing (undo/redo arrows,
B/I for bold/italics, save/download/zoom icons).

Build tooltips that name unfamiliar icons on hover.

Use **lucide** icons inside buttons whenever one exists. Don't hand-roll
SVG icons. If the project has its own icon library, use that.

## Cards and layout

- Card border radius: **8px or less**, unless the existing design system
  requires otherwise.
- **Never put a UI card inside another UI card.** Don't style page
  sections as floating cards. Cards are reserved for individual repeated
  items, modals, and genuinely framed tools. Page sections are
  **full-width bands** or **unframed layouts** with constrained inner
  content.
- Don't put hero text or the primary experience inside a card.
- Never use a split text/media layout where one side is a card and the
  other is text.

## Hero and landing pages

- Don't make a landing page unless explicitly required. When asked for
  a site / app / game / tool, **build the actual usable experience as
  the first screen**, not marketing or explanatory content.
- For a hero page: use a relevant image, generated bitmap, or full-bleed
  immersive scene as the background, with text laid over it (no card).
  **Never** use gradient/SVG hero pages. Don't create an SVG hero
  illustration when a real or generated image can carry the subject.
- Brand / product / place / object must be a **first-viewport signal**,
  not just tiny nav text or an eyebrow.
- Hero content must leave a hint of the next section visible on every
  mobile and desktop viewport, including wide desktop.
- Make the H1 the **brand / product / place / person name** or a literal
  offer / category. Put descriptive value props in supporting copy, not
  the headline.

## Visual content

- Websites and games must use **visual assets** (real images, image
  search, generated bitmaps). Don't substitute SVGs unless you're making
  a game or extending an established icon system.
- Primary images and media should reveal the **actual thing** —
  product, place, object, state, gameplay, person. Avoid dark, blurred,
  cropped, stock-like, or purely atmospheric media when the user needs
  to inspect the real subject.
- For 3D, use **Three.js**. Make the primary 3D scene full-bleed or
  unframed, never inside a decorative card.
- Don't add discrete orbs, gradient orbs, or bokeh blobs as decoration
  or background.

## Typography and dimensions

- Match display text to its container. Reserve hero-scale type for true
  heroes; use smaller, tighter headings inside compact panels, cards,
  sidebars, dashboards, and tool surfaces.
- Define **stable dimensions with responsive constraints** for
  fixed-format UI (boards, grids, toolbars, icon buttons, tiles).
  Use `aspect-ratio`, grid tracks, `min` / `max`, container-relative
  sizing — so hover states, dynamic content, loading text, or icons
  cannot resize / shift the layout.
- Make sure text fits in its parent on every mobile and desktop
  viewport. Wrap to a new line if needed; if it still doesn't fit,
  use dynamic sizing so the longest word fits.
- Text inside UI buttons / cards must look professionally designed
  and polished.
- **Never scale font-size with viewport width.** Letter-spacing must
  be **0**, not negative.

## Colour palettes

Avoid one-note palettes — UIs dominated by variations of a single hue
family. Specifically watch for and revise:

- Dominant **purple / purple-blue** gradients.
- **Beige / cream / sand / tan** monochromes.
- **Dark blue / slate** monochromes.
- **Brown / orange / espresso** palettes.

Scan your CSS colours before finalising. If the page reads as one of
these themes, redesign for diversity.

## No-overlap / no-occlusion

UI elements and on-screen text must not overlap incoherently with each
other or with following / preceding content. Verify this on real
viewports.

## Don't tell, do

Don't use visible in-app text to **describe** the application's
features, functionality, keyboard shortcuts, styling, or how to use it.
Build the affordance instead.

## Verification before declaring done

For Three.js / canvas / interactive scenes, take Playwright screenshots
across desktop and mobile viewports. Do canvas-pixel checks. Verify:

- Scene is non-blank.
- Framing is correct.
- Interactivity / motion is present.
- Referenced assets render as intended.
- Nothing overlaps.

For static UI, manually trace one common workflow on each viewport
before declaring done.

---

## When to invoke

Read this at the start of any of:

- Building a new web app / website / dashboard / game.
- Adding any non-trivial UI surface (page, panel, modal, hero, form,
  toolbar).
- Styling work that touches more than one component.
- Choosing icon sets, palette, typography, or layout primitives.

Skip for: single-prop tweaks, copy edits, accessibility-only fixes,
back-end-only changes.
