---
name: designing-gnome-ui
description: Design GNOME UIs following Human Interface Guidelines with GTK 4 and libadwaita. Use when designing UI, selecting widgets/patterns, reviewing HIG compliance, or implementing responsive layouts. Covers containers, navigation, controls, feedback, icons, typography. Don't use for backend code, database design, or non-GNOME toolkits like Qt/Electron.
license: CC-BY-SA-4.0
compatibility: GTK 4.x, libadwaita 1.4+, GNOME 45+
metadata:
  author: Paresh-Maheshwari
  version: "1.0.0"
  category: design
  last-updated: "2026-10-02"
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# Designing GNOME UI

Design GNOME UIs that are HIG-compliant, polished, and user-centered.

## When to Use

- Designing, implementing, or modifying UI for GNOME apps
- Before writing UI code
- Reviewing existing UI for HIG compliance
- Working with GTK 4/libadwaita
- Styling Qt/PySide6 apps for GNOME

## Reference Files

Load these as needed:
- [gnome-hig-complete.md](gnome-hig-complete.md) — Full HIG reference when doing comprehensive UI review
- [gnome-hig-guidelines.md](gnome-hig-guidelines.md) — Core design principles and philosophy
- [gnome-patterns-containers.md](gnome-patterns-containers.md) — When selecting window types, dialogs, lists
- [gnome-patterns-navigation.md](gnome-patterns-navigation.md) — When designing app navigation flow
- [gnome-patterns-controls.md](gnome-patterns-controls.md) — When selecting buttons, entries, switches
- [gnome-patterns-feedback.md](gnome-patterns-feedback.md) — When adding toasts, progress, status indicators
- [gnome-reference-keyboard.md](gnome-reference-keyboard.md) — When implementing keyboard shortcuts
- [libadwaita-features-1.4-plus.md](libadwaita-features-1.4-plus.md) — When using latest libadwaita widgets

## Core Principle

No UI code without design decisions. Pattern selection and quality verification happen before implementation.

## Quality Layers

1. **Compliance** — follows HIG
2. **Polish** — feels premium
3. **Rigor** — handles edge cases

## The Process

1. **Context** — User goal, app type, constraints (screen size, input)
2. **Patterns** — Select containers, navigation, controls, feedback
3. **Details** — Typography, spacing, icons, writing style
4. **Checklist** — Verify compliance, polish, rigor before code

## Container Selection

| Scenario | Widget | Notes |
|----------|--------|-------|
| App window | `AdwApplicationWindow` + `AdwHeaderBar` | Remember user size, start ~800×600 |
| Settings | `AdwPreferencesWindow` | Handles groups, search, subpages |
| List of items | `AdwPreferencesGroup` with rows | Boxed list style |
| Modal action | `AdwDialog` | For decisions, confirmations |
| Primary action | Single button, header bar end | `suggested-action` class |
| Destructive action | `destructive-action` class | Requires undo or confirmation |

## Navigation Selection

| Structure | Pattern |
|-----------|---------|
| Single view | None needed |
| 2–5 views | `AdwViewSwitcher` in header bar |
| Many/dynamic views | `AdwNavigationSplitView` (sidebar) |
| Hierarchical | `AdwNavigationView` (drill-down) |
| Documents/tabs | `AdwTabBar` + `AdwTabView` |

## Control Defaults

| Need | Use | Avoid |
|------|-----|-------|
| On/Off | `AdwSwitchRow` | Checkbox for settings |
| Choose one (few) | `AdwComboRow` | Radio buttons outside dialogs |
| Choose one (many) | `AdwComboRow` + search | Long unsearchable dropdowns |
| Text input | `AdwEntryRow` | Bare `GtkEntry` |
| Multiline text | `GtkTextView` + `card` class | Unstyled text view |
| Number | `AdwSpinRow` | Text entry for numbers |
| Action in list | `AdwActionRow` + suffix button | Multiple buttons per row |
| Search | `GtkSearchBar` + toggle button | Always-visible search box |

## Feedback Selection

| Scenario | Widget | Details |
|----------|--------|---------|
| Action done | `AdwToast` | Short message, optional undo |
| Destructive action | `AdwToast` + undo | Prefer over confirmation dialog |
| Error (recoverable) | `AdwToast` | Brief, auto-retry silently |
| Error (blocking) | `AdwDialog` | Explain problem and required fix |
| Persistent state | `AdwBanner` | Offline, degraded mode |
| Needs decision | `AdwDialog` | Conflicts, irreversible actions |
| Short wait (<5s) | `AdwSpinner` | No progress bar |
| Long operation (>30s) | Progress bar + text | "13 of 42 processed" |

## Iconography Rules

- **Symbolic icons only** (outline, monochrome) — never full-color in UI
- Source from GNOME Icon Library (`icon-library` app)
- Header bar: icon-only buttons, always add tooltips
- Naming: `action-object-symbolic` (e.g., `list-add-symbolic`)

| Action | Icon |
|--------|------|
| Add/New | `list-add-symbolic` |
| Delete | `user-trash-symbolic` |
| Settings | `emblem-system-symbolic` |
| Menu | `open-menu-symbolic` |
| Search | `system-search-symbolic` |
| Edit | `document-edit-symbolic` |
| Back | `go-previous-symbolic` |
| Close | `window-close-symbolic` |

## New in libadwaita 1.6–1.8

| Need | Widget | Notes |
|------|--------|-------|
| Exclusive toggles | `AdwToggleGroup` | Replaces multiple `GtkToggleButton` |
| Loading indicator | `AdwSpinner` | Works with animations disabled |
| Bottom controls | `AdwBottomSheet` | Music player, persistent actions |
| Wrapping content | `AdwWrapBox` | Auto-wraps like text |
| Inline switching | `AdwInlineViewSwitcher` | For cards, sidebars |
| Shortcuts dialog | `AdwShortcutsDialog` | Replaces `GtkShortcutsWindow` |

## Quality Checklist

### Layer 1: Compliance
- [ ] Correct container type and header bar structure
- [ ] Navigation pattern matches content structure
- [ ] Standard widgets used (not custom where native exists)
- [ ] Symbolic icons from GNOME Icon Library
- [ ] Typography uses style classes (`title-1`, `heading`, `body`, `caption`)
- [ ] Libadwaita spacing defaults (no custom margins)
- [ ] Header capitalization for labels, sentence for descriptions

### Layer 2: Polish
- [ ] Clear visual hierarchy
- [ ] Controls and text properly aligned
- [ ] Empty states have placeholder page (icon + message + action)
- [ ] Loading states show spinner, never frozen UI
- [ ] Smooth resize and view transitions

### Layer 3: Rigor
- [ ] All controls keyboard-accessible (Tab, Enter, Space)
- [ ] All elements have accessible names
- [ ] Works with high contrast (`GTK_THEME=Adwaita:hc`)
- [ ] Works with 200% text scaling
- [ ] Destructive actions have undo where possible
- [ ] Responsive: works at 360px wide, adapts to larger

## Red Flags — STOP

- Custom styling where libadwaita has a pattern
- Multiple "suggested" or "destructive" buttons per view
- Confirmation dialogs for reversible actions (use undo)
- Text over images or textured backgrounds
- Non-GNOME icons without strong justification
- Missing tooltips on icon-only header bar buttons
- Generic labels ("OK", "Yes", "No", "Submit")
- Frozen UI during operations

## Accessibility Testing

```bash
# High contrast
GTK_THEME=Adwaita:hc ./myapp

# Screen reader
orca &
./myapp

# Keyboard-only: navigate with Tab/Enter/Space
```

## Reference Files

| Topic | File |
|-------|------|
| Full HIG guidelines | [gnome-hig-guidelines.md](gnome-hig-guidelines.md) |
| Complete HIG reference | [gnome-hig-complete.md](gnome-hig-complete.md) |
| Container patterns | [gnome-patterns-containers.md](gnome-patterns-containers.md) |
| Navigation patterns | [gnome-patterns-navigation.md](gnome-patterns-navigation.md) |
| Control patterns | [gnome-patterns-controls.md](gnome-patterns-controls.md) |
| Feedback patterns | [gnome-patterns-feedback.md](gnome-patterns-feedback.md) |
| Keyboard shortcuts | [gnome-reference-keyboard.md](gnome-reference-keyboard.md) |
| libadwaita 1.4+ features | [libadwaita-features-1.4-plus.md](libadwaita-features-1.4-plus.md) |

## External Resources

- [GNOME HIG](https://developer.gnome.org/hig/)
- [Libadwaita Docs](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1-latest/)
- [GTK 4 Docs](https://docs.gtk.org/gtk4/)
- [Icon Library App](https://flathub.org/apps/org.gnome.design.IconLibrary)
- [App Icon Preview](https://flathub.org/apps/org.gnome.design.AppIconPreview)
