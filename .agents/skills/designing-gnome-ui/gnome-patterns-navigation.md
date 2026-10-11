---
name: gnome-patterns-navigation
description: GNOME navigation patterns including view switchers, tabs, sidebars, browsing, and search. Use when implementing app navigation structure. Don't use for container layout or control widgets.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# GNOME Patterns: Navigation

## Browsing

Hierarchical navigation with back button.

- Back button top-left (standard position)
- Header bar updates with current view
- Support standard keyboard shortcuts (Alt+←/→)

**API:** `AdwNavigationView`

---

## View Switchers

3–5 predefined views.

- Header capitalization, nouns not verbs
- Similar label lengths
- Can indicate activity in views
- Move to bottom bar when window too narrow

**API:** `AdwViewSwitcher`, `AdwViewSwitcherBar`

---

## Tabs

For mutable sets (documents, pages, browser tabs).

- Icon and/or label
- Keep labels short, useful part first
- Show/hide tab bar based on app needs

### Context Menu
- Move to New Window (if supported)
- Duplicate, Pin/Unpin, Mute, Reload (as needed)
- Close (always last)
- Avoid left/right references (RTL issues)

### Keyboard Shortcuts
| Shortcut | Action |
|----------|--------|
| Ctrl+T | New tab |
| Ctrl+W | Close tab |
| Ctrl+PageUp/Down | Next/Previous tab |
| Ctrl+Home/End | First/Last tab |
| Alt+1–9 | Switch to tab 1–9 |

**API:** `AdwTabBar`, `AdwTabView`, `AdwTabOverview`

---

## Sidebars

For many/dynamic locations (messaging, file managers).

- Order by usefulness (often most recent at top)
- Header bar controls above list
- Multiple lines of text + images allowed
- Avoid for rich/immersive content apps

**API:** `AdwNavigationSplitView`

---

## Search

Filter content (distinct from find/highlight).

### Activation
1. Type-to-search (typing focuses search)
2. Ctrl+F keyboard shortcut
3. Search button in header bar (toggles)

### Search Bar
- Slides from under header bar
- Hidden until activated (usually)
- Can be permanently visible if search is primary function

### Results
- Live filtering as user types
- Fast results
- "No results" feedback when empty
- Show incrementally as collected
- Order by relevance

### Guidelines
- Global search across all views (not just current)
- Fuzzy matching, tolerate mistakes
- Broad matching (city returns country matches)

**API:** `GtkSearchBar`, `GtkSearchEntry`
