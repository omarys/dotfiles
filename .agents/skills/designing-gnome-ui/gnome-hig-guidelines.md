---
name: gnome-hig-guidelines
description: GNOME Human Interface Guidelines reference for app design principles, visual design, writing style, and accessibility. Use when checking HIG compliance or understanding GNOME design philosophy. Don't use for code implementation details.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# GNOME HIG Guidelines

Source: https://developer.gnome.org/hig/

## Design Principles

### Design for People
Be inclusive — accommodate different physical abilities, cultures, device form factors. Software should require little specialist knowledge.

### Make it Simple
- Focus on one situation, one experience
- Use progressive disclosure
- Frequently used actions close at hand

### Reduce User Effort
- Automate what can be automated
- Minimize steps for tasks
- Keep text short

### Be Considerate
- Anticipate and prevent mistakes
- Prefer undo over confirmation dialogs
- Don't interrupt unnecessarily

---

## App Naming

**Good names:**
- 1–2 simple nouns
- Related to app domain
- <15 characters
- Easy to pronounce
- Header capitalization

**Avoid:**
- Trademarks/other project names
- "G" prefix
- Acronyms, puns
- Non-standard punctuation

---

## App Icons

- Simple, recognizable metaphor related to app name
- 128×128px canvas, visual weight matches other icons
- Simple geometric style with subtle depth (top + front profile)
- Use standard color palette
- Also create symbolic version (16×16 monochrome)
- Tool: App Icon Preview app

---

## UI Icons

**Style:** Symbolic (simple, monochrome, 16×16px SVG)
- Can scale to 32, 64, 128px
- Source: Icon Library app or GTK built-ins

**Usage:**
- Icon OR label, not both (exceptions: sidebars, view switchers)
- Only use recognized icons (search, menu, back, forward, share)
- Some icons need context (stop needs play/pause nearby)

**Creation:**
- 16×16 with margin
- 2px strokes (avoid 1px)
- Align to pixel grid
- Test color inversion

---

## UI Styling

**Adwaita:** Light and dark styles.

- Most apps: light default, follow system preference
- Visual content apps: dark default acceptable
- Per-app preference: light, dark, follow system

**High Contrast:** Test with `GTK_THEME=Adwaita:hc`

**Custom Styling:**
- Minimize — use existing style classes/CSS variables
- Never use color alone to convey information
- Avoid flashing/blinking

---

## Writing Style

**General:** Short, neutral tone. Avoid "you"/"my".

**Header Capitalization** (headings, buttons, menus, tooltips):
- Capitalize 4+ letter words, all verbs/nouns, first/last word
- Example: "Find and Replace"

**Sentence Capitalization** (checkboxes, radio labels, body text):
- First word + proper nouns only

**Ellipses (…):** When further input needed: "Save As…"
**Periods:** Don't end text with periods (except multi-sentence paragraphs)

---

## Typography

**Font:** System default (Adwaita Sans). Never text over textured backgrounds.

| Style | CSS Class | Use |
|-------|-----------|-----|
| Body | `body` | Default text |
| Heading | `heading` | Titles, group headings |
| Caption | `caption` | Sub-text |
| Title 1–4 | `title-1` to `title-4` | Display headings |

**Unicode:** Use proper quotes ""'', multiplication ×, ellipsis …, en-dash –

---

## Keyboard

**Shortcuts:**
- Use standard GNOME shortcuts
- Ctrl+letter preferred
- Shift+Ctrl for reverse/extend
- Avoid Alt (access keys) and Super (system)

**Access Keys:** Alt+underlined letter for all labelled controls

**Navigation:** Tab/Shift+Tab, Return (activate), Space (toggle), Esc (close transient)

---

## Pointer & Touch

- Large click targets
- Don't rely on hover
- Primary click: activate/select
- Secondary click: context menu only
- Esc cancels drag operations
- 3/4 finger gestures reserved for system

**Scrolling:**
| | Mouse | Touchpad | Touch |
|---|-------|----------|-------|
| Scroll | Wheel | 2-finger | 1-finger |
| Zoom | Ctrl+wheel | Pinch | Pinch |

---

## Navigation

**Flat:** View switchers (3–5 views), sidebars (many views)
**Hierarchical:** Parent → sub-views with back button
**Combined:** Flat top-level + hierarchical below

- Each view: clear focus, easy to digest
- Max 1 level hierarchy depth
- Support standard keyboard shortcuts

---

## Scaling & Adaptiveness

**Adaptive:** Scale from 360×294px (phone) to large desktop.

- Design smallest first, then scale up
- Use established patterns (view switchers, lists)
- Lists scale well
- Use breakpoints for layout changes
- Smooth resize without glitches

**Minimum:** Desktop 1024×600px, Phone 360×294px
**Large:** Use max-width containers

---

## Accessibility

**Testing:**
1. High contrast: `GTK_THEME=Adwaita:hc`
2. Large text (Accessibility settings)
3. Keyboard-only navigation
4. Screen reader (Orca)
5. On-screen keyboard

All elements need descriptive accessible names.
