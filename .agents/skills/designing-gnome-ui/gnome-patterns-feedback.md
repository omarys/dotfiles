---
name: gnome-patterns-feedback
description: GNOME feedback patterns including notifications, toasts, banners, dialogs, progress indicators, and spinners. Use when implementing user feedback and status communication. Don't use for input controls.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# GNOME Patterns: Feedback

## Notifications

System-level, shown outside app window.

**Use for:**
- Download/operation finished
- New content available
- Message received

**Elements:**
| Element | Description |
|---------|-------------|
| App Icon | Identifies sender app |
| Title | Short summary, header capitalization |
| Body | Optional extra detail, sentence capitalization |
| Default Action | Click dismisses + shows relevant app view |
| Actions | Up to 3 buttons |

**Guidelines:**
- Don't over-notify (restrict frequency for high-volume apps)
- Remove outdated notifications
- Provide option to disable/reduce
- Don't rely solely on notifications

**API:** `GNotification`

---

## Toasts

In-app transient popups.

**Use for:**
- Event feedback within app
- Undo after destructive action
- Brief messages

**Guidelines:**
- Short title, informal heading style
- Optional button (often undo)
- Bottom center of window
- Transient (auto-dismiss)

**API:** `AdwToast`

---

## Banners

Persistent strip at top for ongoing states.

**Use for:**
- Offline mode
- Read-only document
- Degraded functionality

**Guidelines:**
- Title only (short, informal)
- Optional action button
- Don't use for events (use notifications/toasts)

**Examples:**
- "Metered network — automatic updates paused"
- "Unlock to change settings"
- "Working offline"

**API:** `AdwBanner`

---

## Progress Bars

For tasks >30 seconds.

**The Bar:**
- Show proportion complete
- Estimate time if possible
- "Almost done" if paused at 100%
- Activity mode (back/forth) only if estimation impossible

**Progress Text:**
- "13 of 19 images rotated"
- "12.1 of 30 MB downloaded"
- "About 3 minutes left"

**Guidelines:**
- Single bar for multiple subtasks (usually)
- Thin bars for background tasks (bottom of header bar)
- Consider pause/cancel buttons for destructive operations
- Display inline, close to related content

**API:** `GtkProgressBar`

---

## Spinners

For tasks >3 seconds but <30 seconds.

**Guidelines:**
- Don't show for very short periods (distracting)
- Place close to related UI
- Only one spinner at a time (usually)
- Add label if clarification needed
- Can add progress text for longer waits

**API:** `GtkSpinner`, `AdwSpinner`

---

## Dialogs

### Alert Dialogs
Message + 1–3 response buttons.

**Confirmation Dialogs:**
- Check user wants to proceed
- Cancel + action button
- Prefer undo over confirmation

**Error Dialogs:**
- Present error message
- Often single button to close
- Prefer toasts for non-critical errors

### Action Dialogs
Options before action (Print, Save).

- Header bar with heading
- Cancel + action button
- Specific verbs ("Save", "Print"), not "OK"
- Insensitive action button until required options selected

### Button Order
- Cancel first (left), action last (right)
- Return activates affirmative (unless destructive)
- Esc activates cancel

### Guidelines
- Never pop up unexpectedly
- Always modal to parent window
- Focus first expected control on open

**API:** `AdwAlertDialog`, `AdwDialog`

---

## Placeholder Pages

Fill empty views.

### Illustration Style
- Initial empty state
- Colorful graphic
- Positive, upbeat text
- Can address user directly

### Symbolic Style
- Other empty spaces (empty folder, no results)
- Monochrome icon
- Neutral tone
- Subtle, not attention-grabbing

**Elements:**
- Heading (required): "Empty Folder", "No Results"
- Description (optional): "Use the + button to add items"
- Action button (optional): `suggested-action` style

**API:** `AdwStatusPage`

---

## Tooltips

Additional info on hover.

**When to Use:**
- Required for header bar controls
- Useful info (full URL, syntax error)
- If one control has tooltip, all in container should

**Guidelines:**
- Header capitalization
- Short, not sentences
- Don't duplicate existing labels
- Don't rely on for essential info (not accessible on touch)

**Standard Tooltips:**
| Button | Tooltip |
|--------|---------|
| Back | Back |
| Search | Search (or "Search Documents") |
| Primary menu | Main Menu |
| Secondary menu | Menu (or "Document Menu") |
| New tab | New Tab |

**API:** `GtkTooltip`
