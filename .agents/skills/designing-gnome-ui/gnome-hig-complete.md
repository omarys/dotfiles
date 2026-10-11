---
name: gnome-hig-complete
description: Complete GNOME Human Interface Guidelines with design principles, app icons, typography, colors, and all UI patterns. Use as comprehensive HIG reference. Don't use for implementation code.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# GNOME HIG Complete Guidelines Reference

Comprehensive reference for GNOME Human Interface Guidelines covering all design guidelines and patterns.

## Design Principles

### Design for People
- Be as inclusive as possible
- Accommodate different physical abilities, cultures, device form factors
- Require little specialist knowledge

### Make it Simple
- Do one thing and do it well
- Don't overwhelm with too many elements at once
- Use progressive disclosure
- Frequently used actions should be close at hand

### Reduce User Effort
- Automate what can be automated
- Minimize steps required for tasks
- Reduce information people need to remember
- Keep text short and to the point

### Be Considerate
- Anticipate and prevent mistakes
- Allow undo instead of asking confirmation
- Respect time and attention
- Don't interrupt unnecessarily

## App Naming

### Guidelines
- Short names (1-3 words)
- Unique and memorable
- Easy to pronounce
- Avoid generic terms
- Don't include "GNOME" in the name

### Good Examples
- Files, Music, Photos, Calendar
- Boxes, Cheese, Polari

## App Icons

### Metaphor
- Simple, recognizable
- Related to app name/function
- Avoid unrelated mascots or logos

### Style
- Simple and geometric
- 128×128px canvas, visually weighted smaller
- Use depth: top surface + front profile
- Front profile shaded darker
- Use standard color palette

### Symbolic Icons
- Simplified version for small sizes
- Same metaphor as full icon
- Used at smaller sizes and special contexts

### Nightly Variant
- Distinct variant for nightly/beta builds
- App Icon Preview can generate automatically

## Pointer & Touch

### Click/Tap
- Primary action: single click/tap
- Context menu: right-click or long press

### Drag
- Selection, rearranging, resizing
- Use visible drag handles

### Touch Targets
- Minimum 48×48px for touch
- Adequate spacing between targets

## Keyboard

### General
- All functionality keyboard accessible
- Visible focus indicators
- Logical tab order

### Standard Shortcuts
- Ctrl+Q: Quit
- Ctrl+W: Close window
- Ctrl+S: Save
- Ctrl+Z: Undo
- Ctrl+Shift+Z: Redo
- F1: Help
- Ctrl+F: Search

### Navigation
- Tab: Move forward
- Shift+Tab: Move backward
- Arrow keys: Navigate within containers
- Enter/Space: Activate

## UI Icons

### Symbolic Icons
- Monochrome, outline style
- 16×16px grid
- Consistent stroke width (2px)
- Use GNOME Icon Library

### Naming
- Action format: `verb-noun-symbolic`
- Object format: `noun-symbolic`
- Examples: `list-add-symbolic`, `folder-symbolic`

## UI Styling

### CSS Classes
- `suggested-action`: Primary button
- `destructive-action`: Dangerous action
- `flat`: Flat button
- `card`: Card container
- `boxed-list`: Boxed list style
- `title-1` through `title-4`: Heading sizes
- `heading`, `body`, `caption`: Text styles

### Colors
- Use system colors via CSS variables
- Don't hardcode colors
- Respect dark/light mode

## Writing Style

### Voice
- Friendly and conversational
- Clear and direct
- Avoid jargon

### Capitalization
- Header capitalization for labels
- Sentence case for descriptions
- Don't use ALL CAPS

### Labels
- Be concise
- Use action verbs for buttons
- Avoid generic labels ("OK", "Cancel")

## Typography

### Style Classes
| Class | Use |
|-------|-----|
| `title-1` | Large headings |
| `title-2` | Section headings |
| `title-3` | Subsection headings |
| `title-4` | Minor headings |
| `heading` | List headings |
| `body` | Body text |
| `caption` | Small text, descriptions |
| `monospace` | Code |

### Alignment
- Left-align most text
- Center titles in dialogs

## Navigation Guidelines

### Structure
- Flat structure preferred (2-3 levels max)
- Consistent navigation placement
- Clear back navigation

### Patterns by Content
| Content Type | Pattern |
|--------------|---------|
| Single view | No navigation needed |
| 2-5 views | View switcher |
| Many views | Sidebar |
| Hierarchical | Drill-down |
| Documents | Tabs |

## Scaling & Adaptiveness

### Breakpoints
- Compact: < 360px
- Small: 360-600px
- Medium: 600-840px
- Large: > 840px

### Techniques
- Fold panels into navigation
- Stack horizontal layouts vertically
- Hide secondary content
- Use `AdwClamp` for content width

## Accessibility

### Requirements
- All controls keyboard accessible
- Visible focus indicators
- Sufficient color contrast
- Screen reader compatible

### Testing
```bash
# High contrast
GTK_THEME=Adwaita:hc ./myapp

# Screen reader
orca &
./myapp

# Text scaling
gsettings set org.gnome.desktop.interface text-scaling-factor 2.0
```

## Container Patterns

### Windows
- Use `AdwApplicationWindow`
- Remember user size preferences
- Default size ~800×600

### Header Bars
- Use `AdwHeaderBar`
- Title left-aligned
- Controls at ends
- Icon-only buttons need tooltips

### Popovers
- Use for contextual UI
- Auto-close when clicking outside
- Arrow points to trigger

### Boxed Lists
- Group related rows
- Use `AdwPreferencesGroup`
- Rounded corners, slight background

### Grid Views
- Uniform item sizes
- Responsive columns
- Selection support

## Navigation Patterns

### Browsing
- Clear location indication
- Back button for hierarchy
- Breadcrumbs for deep hierarchies

### View Switchers
- `AdwViewSwitcher` in header bar
- 2-5 views
- Icon + label

### Tabs
- `AdwTabBar` + `AdwTabView`
- Closable tabs
- Tab overflow handling

### Sidebars
- `AdwNavigationSplitView`
- Collapsible on narrow widths
- Selection indicator

### Search
- `GtkSearchBar` with toggle button
- Highlight matches
- Recent searches

## Control Patterns

### Buttons
- `GtkButton` for actions
- `suggested-action` for primary
- `destructive-action` for dangerous
- Icon-only needs tooltip

### Menus
- `GtkMenuButton` + `GMenu`
- Sections for grouping
- Keyboard shortcuts shown

### Switches
- `GtkSwitch` or `AdwSwitchRow`
- Immediate effect
- No "Apply" needed

### Text Fields
- `GtkEntry` or `AdwEntryRow`
- Placeholder text
- Validation feedback

### Checkboxes
- `GtkCheckButton`
- Multiple independent options
- Can be indeterminate

### Radio Buttons
- `GtkCheckButton` with group
- Mutually exclusive options
- One always selected

### Drop-Downs
- `AdwComboRow`
- Finite set of options
- Search for long lists

### Sliders
- `GtkScale`
- Continuous range
- Show current value

### Spin Buttons
- `GtkSpinButton` or `AdwSpinRow`
- Numeric input with increment/decrement
- Min/max bounds

## Feedback Patterns

### Notifications
- `GNotification` for system
- Persistent, clickable
- Include action

### Toasts
- `AdwToast`
- Temporary, auto-dismiss
- Include undo when applicable

### Banners
- `AdwBanner`
- Persistent status
- Dismiss when resolved

### Progress Bars
- `GtkProgressBar`
- Long operations (>30s)
- Show percentage or "X of Y"

### Spinners
- `AdwSpinner`
- Short waits (<5s)
- No progress indication

### Dialogs
- `AdwDialog`
- Blocking decisions
- Clear actions

### Placeholder Pages
- `AdwStatusPage`
- Empty states
- Icon + message + action

### Tooltips
- `GtkWidget.set_tooltip_text()`
- For icon-only buttons
- Brief descriptions

## Reference

### Color Palette
- Blue: #1c71d8 (accent)
- Green: #2ec27e (success)
- Yellow: #f5c211 (warning)
- Red: #e01b24 (error)
- Purple: #9141ac
- Orange: #ff7800

### Standard Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Quit | Ctrl+Q |
| Close | Ctrl+W |
| Save | Ctrl+S |
| Save As | Ctrl+Shift+S |
| Undo | Ctrl+Z |
| Redo | Ctrl+Shift+Z |
| Cut | Ctrl+X |
| Copy | Ctrl+C |
| Paste | Ctrl+V |
| Select All | Ctrl+A |
| Find | Ctrl+F |
| Find Next | Ctrl+G |
| Replace | Ctrl+H |
| Print | Ctrl+P |
| New | Ctrl+N |
| Open | Ctrl+O |
| Help | F1 |
| Fullscreen | F11 |
| Preferences | Ctrl+, |
| Shortcuts | Ctrl+? |

## External Resources

- [GNOME HIG](https://developer.gnome.org/hig/)
- [App Icon Preview](https://flathub.org/apps/org.gnome.design.AppIconPreview)
- [Icon Library](https://flathub.org/apps/org.gnome.design.IconLibrary)
- [Color Palette](https://developer.gnome.org/hig/reference/palette.html)
