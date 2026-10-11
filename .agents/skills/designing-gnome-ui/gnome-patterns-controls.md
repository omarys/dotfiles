---
name: gnome-patterns-controls
description: GNOME control patterns including buttons, menus, switches, sliders, text fields, and selection widgets. Use when implementing user input controls. Don't use for navigation or feedback patterns.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# GNOME Patterns: Controls

## Buttons

- Icon OR label (not both, except header bars)
- Imperative verbs, header capitalization
- Make invalid buttons insensitive
- No double-click/right-click actions

### Toggle Buttons
- Binary modes (set/unset)
- Can be linked for option selection

### Styles
| Style | Use |
|-------|-----|
| `suggested-action` | Affirmative/next step (one per view) |
| `destructive-action` | Warning/danger (one per view) |
| `pill` | Primary action in open space |
| `circular` | Clustered small buttons |

**API:** `GtkButton`, `GtkToggleButton`

---

## Menus

- 3–12 items; submenus 3–6 items
- No nested submenus
- Verbs for commands, adjectives for settings
- Group similar items
- Important items at top/bottom

### Primary Menu
- `open-menu-symbolic` icon
- End of header bar
- Standard items (bottom group):
  - Preferences
  - Keyboard Shortcuts
  - Help
  - About App

### Secondary Menu
- View/content-specific actions
- Don't duplicate primary menu items

**API:** `GtkMenuButton`, `GtkPopoverMenu`

---

## Switches

Binary on/off. Preferred over checkboxes.

- Label with nouns, header capitalization
- Access key for keyboard focus
- Background color indicates state
- Make insensitive if feature unavailable

**API:** `GtkSwitch`, `AdwSwitchRow`

---

## Text Fields

- Placeholder text OR label (placeholder preferred)
- Header capitalization for labels
- Size according to expected content
- Apply changes on Return or focus loss

### Validation
- Show positive feedback when valid (not negative while editing)
- Real-time feedback preferred

### Features
- Password fields: `GtkPasswordEntry`
- Suggestions: completion as user types
- Tags/tokens for recipients, etc.

**API:** `GtkEntry`, `GtkTextView`, `AdwEntryRow`

---

## Checkboxes

For non-exclusive options.

- Use switches when possible for settings
- Sentence capitalization
- Can have third "inconsistent" state

**API:** `GtkCheckButton`

---

## Radio Buttons

Mutually exclusive options when all visible.

- Group related options
- One always selected
- Sentence capitalization

**API:** `GtkCheckButton` (in group)

---

## Drop-Down Lists

Single selection from options.

- Use `AdwComboRow` in lists
- Add search for many options
- Default to most common/useful option

**API:** `GtkDropDown`, `AdwComboRow`

---

## Sliders

Continuous value selection.

- Show current value
- Provide keyboard support
- Use when precise value less important than relative position

**API:** `GtkScale`

---

## Spin Buttons

Number entry with increment/decrement.

- Use for precise numeric input
- Can type directly or use +/- buttons

**API:** `GtkSpinButton`, `AdwSpinRow`

---

## Overlaid Controls

Controls shown over content (video, images).

- Auto-hide after timeout
- Show on hover/tap
- Semi-transparent background for contrast
