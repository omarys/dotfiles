---
name: gnome-patterns-containers
description: GNOME container patterns including windows, header bars, popovers, dialogs, and boxed lists. Use when implementing window structure or container widgets. Don't use for navigation or control widgets.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# GNOME Patterns: Containers

## Windows

### Primary Windows
- Main app functionality
- Independent (closing one doesn't close others)
- Resizable, appropriate default size
- Ctrl+W to close

### Secondary Windows
- About, Preferences, Properties
- Modal to parent, close with parent
- Esc to close
- Don't stack multiple

**API:** `AdwApplicationWindow`, `AdwAboutWindow`, `AdwPreferencesWindow`

---

## Header Bars

- Buttons at start (left), heading center, menus at end
- Small number of controls
- Update content with view/mode changes
- Leave blank space for dragging
- All controls need tooltips

**Button Style:**
- Icon-only or icon+label (avoid text-only)
- No `suggested-action`/`destructive-action` in primary header bars
- Group related buttons with spacing (not linked style)

**API:** `AdwHeaderBar`

---

## Popovers

- Overlaid container opened by button
- Small (≤1/3 parent window), low complexity
- Esc to close
- No Close/Done button needed
- Can have heading if purpose unclear

**API:** `GtkPopover`

---

## Utility Panes

- Vertical panels beside main view
- Left if affects main view; right if subordinate
- F9 shortcut to toggle
- Overlap main view when narrow (use flap)

**API:** `AdwOverlaySplitView`

---

## Boxed Lists

For small static lists (preferences, recent docs).

### Predefined Rows

| Row Type | Use |
|----------|-----|
| `AdwSwitchRow` | Title, subtitle, switch |
| `AdwActionRow` | Title, subtitle, control |
| `AdwComboRow` | Dropdown selection |
| `AdwEntryRow` | Text entry |
| `AdwSpinRow` | Number with +/- |
| `AdwExpanderRow` | Expandable content |
| `AdwButtonRow` | Clickable action row |

### Guidelines
- Organize semantically, group similar items
- Max 1–2 controls per row
- Click row background triggers control
- Use `go-next-symbolic` for drill-down rows
- Min/max width for adaptive scaling

### Editable Lists
- Add button at top or add row at end
- Remove button at row end
- Drag handles for reordering
- Menu fallback for accessibility (move up/down/remove)

**API:** `GtkListBox` with `.boxed-list` style class

---

## Grid Views

- Unique thumbnails per item
- Order by usefulness (often most recent)
- Max-width to prevent long rows
- Can offer list view alternative
- Test at various window sizes

**API:** `GtkGridView`

---

## List & Column Views

For large/dynamic data with virtual scrolling.

- Keep rows simple (1–2 elements)
- Symbolic icons
- Min/max width for adaptive

**Column Sorting:**
- Down arrow = natural order (A-Z, oldest first)
- Up arrow = reverse order

**API:** `GtkListView`, `GtkColumnView`

---

## Selection & Edit Modes

### Selection Mode
For bulk operations on large collections.

- Checkbox on hover, click toggles selection
- When items selected:
  - Header shows count + cancel button
  - Action bar at bottom with available actions
- Use when ≥3 actions available

### Edit Mode
For distinct editing tasks (playlist editing).

- Triggered by edit button
- "Done" button to exit
- Actions shown inline on items

**API:** `GtkActionBar`, `.selection-mode` style class
