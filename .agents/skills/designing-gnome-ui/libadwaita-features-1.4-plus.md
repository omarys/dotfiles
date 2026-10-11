---
name: libadwaita-features-1-4-plus
description: Libadwaita 1.4-1.7 new features including AdwDialog, Breakpoints, BottomSheet, Spinner, ButtonRow, MultiLayoutView, accent colors. Use when upgrading apps or using modern libadwaita widgets. Don't use for basic GTK4 widgets.
license: CC-BY-SA-4.0
metadata:
  author: Paresh-Maheshwari
  source: https://github.com/Paresh-Maheshwari/gnome-skills
---

# Libadwaita 1.4–1.7 New Features Reference

Complete reference for new libadwaita widgets and patterns introduced in versions 1.4 through 1.7.

## When to Use

- Upgrading apps to use modern libadwaita features
- Choosing between old and new dialog/navigation widgets
- Implementing responsive layouts with breakpoints
- Using system accent colors in apps
- Understanding widget deprecations and migrations

## Version Summary

| Version | GNOME | Key Features |
|---------|-------|--------------|
| 1.4 | 45 | Breakpoints, NavigationView, NavigationSplitView |
| 1.5 | 46 | AdwDialog, AdwAlertDialog, AdwPreferencesDialog, AdwAboutDialog |
| 1.6 | 47 | BottomSheet, Spinner, ButtonRow, MultiLayoutView, Accent Colors |
| 1.7 | 48 | ToggleGroup, WrapBox, InlineViewSwitcher, ShortcutsDialog |

---

## Libadwaita 1.4 Features

### Breakpoint System

Allows changing UI based on window size without code.

```xml
<object class="AdwBreakpoint">
  <condition>max-width: 500sp</condition>
  <setter object="split-view" property="collapsed">True</setter>
</object>
```

**Units:**
- `px` — Physical pixels
- `pt` — Points
- `sp` — Scalable pixels (recommended, scales with text size)

**Key Widgets:**
- `AdwWindow` / `AdwApplicationWindow` — Support breakpoints natively
- `AdwBreakpointBin` — For more control in specific areas

**Usage in Code (Python):**
```python
breakpoint = Adw.Breakpoint.new(Adw.BreakpointCondition.parse("max-width: 500sp"))
breakpoint.add_setter(split_view, "collapsed", True)
window.add_breakpoint(breakpoint)
```

### AdwNavigationView

Implements browsing/drill-down pattern with automatic gestures and shortcuts.

```python
nav_view = Adw.NavigationView()

# Add pages
page1 = Adw.NavigationPage(title="Home", child=content1)
nav_view.push(page1)

# Navigate
nav_view.push(page2)  # Go forward
nav_view.pop()        # Go back
```

**Features:**
- Swipe-back gesture on mobile
- Automatic back button
- Page transition animations
- Can be populated statically from UI files

### AdwNavigationSplitView

Sidebar + content pattern that collapses on narrow screens.

```python
split_view = Adw.NavigationSplitView()
split_view.set_sidebar(sidebar_widget)
split_view.set_content(content_widget)

# Control collapse
split_view.set_collapsed(True)   # Force collapsed
split_view.set_show_content(True) # Show content (when collapsed)
```

---

## Libadwaita 1.5 Features

### AdwDialog (New Dialog System)

Client-side dialogs that render inside the parent window and become bottom sheets on mobile.

**Advantages over GtkWindow dialogs:**
- Size never exceeds parent window
- Swipe-down to close on mobile
- Consistent dimming in light/dark modes
- Future per-tab dialog support

**Basic Usage:**
```python
dialog = Adw.Dialog()
dialog.set_title("My Dialog")
dialog.set_child(content)
dialog.present(parent_widget)
```

**Closing Behavior:**
```python
# Control whether dialog can close
dialog.set_can_close(False)  # Prevent closing (unsaved data)

# Handle close attempt
dialog.connect("close-attempt", on_close_attempt)

# Force close (after confirmation)
dialog.force_close()
```

### AdwAlertDialog (Replaces AdwMessageDialog)

Alert dialogs with response buttons.

```python
dialog = Adw.AlertDialog()
dialog.set_heading("Delete File?")
dialog.set_body("This cannot be undone.")

dialog.add_response("cancel", "_Cancel")
dialog.add_response("delete", "_Delete")
dialog.set_response_appearance("delete", Adw.ResponseAppearance.DESTRUCTIVE)

dialog.connect("response", on_response)
dialog.present(parent)
```

### AdwPreferencesDialog (Replaces AdwPreferencesWindow)

```python
dialog = Adw.PreferencesDialog()

page = Adw.PreferencesPage()
page.set_title("General")
page.set_icon_name("preferences-system-symbolic")

group = Adw.PreferencesGroup()
group.set_title("Appearance")
page.add(group)

dialog.add(page)
dialog.present(parent)
```

**Differences from AdwPreferencesWindow:**
- Search disabled by default
- No deprecated subpage API

### AdwAboutDialog (Replaces AdwAboutWindow)

```python
dialog = Adw.AboutDialog()
dialog.set_application_name("My App")
dialog.set_application_icon("com.example.myapp")
dialog.set_version("1.0.0")
dialog.set_developer_name("Developer")
dialog.set_developers(["Developer <dev@example.com>"])
dialog.set_copyright("© 2026 Developer")
dialog.set_license_type(Gtk.License.GPL_3_0)
dialog.set_website("https://example.com")
dialog.set_issue_url("https://github.com/user/app/issues")
dialog.present(parent)
```

---

## Libadwaita 1.6 Features

### AdwBottomSheet

Persistent bottom sheet for music players, controls, etc.

```python
bottom_sheet = Adw.BottomSheet()
bottom_sheet.set_content(main_content)
bottom_sheet.set_sheet(sheet_content)
bottom_sheet.set_open(True)

# Show as bottom bar (collapsed state)
bottom_sheet.set_show_drag_handle(True)
```

**Modes:**
- **Open** — Full sheet visible
- **Closed** — Only bottom bar visible (if set)
- Swipeable between states

### AdwSpinner

Modern spinner that works with animations disabled.

```python
spinner = Adw.Spinner()
# That's it! No need to set spinning=True

# For use in images/paintables
paintable = Adw.SpinnerPaintable.new(widget)
image = Gtk.Image.new_from_paintable(paintable)
```

**Advantages over GtkSpinner:**
- Works when animations disabled
- Max size 64×64 (no giant spinners)
- Better visuals at large sizes
- No need to manually start/stop

### AdwButtonRow

List row that looks like a button.

```python
row = Adw.ButtonRow()
row.set_title("Add Item")
row.set_start_icon_name("list-add-symbolic")
row.connect("activated", on_add_clicked)

# Destructive style
delete_row = Adw.ButtonRow()
delete_row.set_title("Delete All")
delete_row.add_css_class("destructive-action")
```

**For separate (non-linked) rows:**
```python
group = Adw.PreferencesGroup()
group.set_separate_rows(True)  # Or use .boxed-list-separate class
```

### AdwMultiLayoutView

Automatically reparent widgets between different layouts.

```xml
<object class="AdwMultiLayoutView" id="multi_layout">
  <child>
    <object class="AdwLayout" id="desktop_layout">
      <property name="name">desktop</property>
      <property name="content">
        <object class="GtkBox">
          <child>
            <object class="AdwLayoutSlot">
              <property name="id">sidebar</property>
            </object>
          </child>
          <child>
            <object class="AdwLayoutSlot">
              <property name="id">content</property>
            </object>
          </child>
        </object>
      </property>
    </object>
  </child>
  <child>
    <object class="AdwLayout" id="mobile_layout">
      <property name="name">mobile</property>
      <!-- Different arrangement -->
    </object>
  </child>
  <child type="sidebar">
    <object class="GtkLabel">
      <property name="label">Sidebar</property>
    </object>
  </child>
  <child type="content">
    <object class="GtkLabel">
      <property name="label">Content</property>
    </object>
  </child>
</object>
```

```python
# Switch layouts
multi_layout.set_layout_name("mobile")
multi_layout.set_layout_name("desktop")
```

### System Accent Colors

Apps automatically follow system accent color.

**Reading System Accent:**
```python
style_manager = Adw.StyleManager.get_default()

# Get accent color enum
accent = style_manager.get_accent_color()  # AdwAccentColor

# Get as RGBA
rgba = Adw.AccentColor.to_rgba(accent)

# Get standalone color (for text on white/dark backgrounds)
standalone = Adw.AccentColor.to_standalone_rgba(accent)

# React to changes
style_manager.connect("notify::accent-color", on_accent_changed)
```

**Available Colors:**
- `ADW_ACCENT_COLOR_BLUE` (default)
- `ADW_ACCENT_COLOR_TEAL`
- `ADW_ACCENT_COLOR_GREEN`
- `ADW_ACCENT_COLOR_YELLOW`
- `ADW_ACCENT_COLOR_ORANGE`
- `ADW_ACCENT_COLOR_RED`
- `ADW_ACCENT_COLOR_PINK`
- `ADW_ACCENT_COLOR_PURPLE`
- `ADW_ACCENT_COLOR_SLATE`

**CSS Variables:**
```css
/* Use specific accent colors */
.my-widget {
  background: var(--accent-purple);
}

/* Override accent for specific widget */
.custom-accent {
  --accent-bg-color: var(--accent-green);
  --accent-color: oklab(from var(--accent-bg-color) var(--standalone-color-oklab));
}
```

### New CSS Variables

```css
/* Opacity variables */
--dim-opacity
--disabled-opacity
--border-opacity

/* Window properties */
--window-radius

/* All named colors now have CSS variable equivalents */
--accent-bg-color
--accent-color
--destructive-bg-color
--destructive-color
/* etc. */
```

---

## Libadwaita 1.7+ Features

### AdwToggleGroup

Exclusive toggle buttons in a group.

```python
group = Adw.ToggleGroup()

group.add(Adw.Toggle(label="Day"))
group.add(Adw.Toggle(label="Week"))
group.add(Adw.Toggle(label="Month"))

group.connect("notify::active", on_toggle_changed)
```

### AdwWrapBox

Auto-wrapping box layout (like text flow).

```python
wrap_box = Adw.WrapBox()
wrap_box.set_spacing(6)
wrap_box.set_line_spacing(6)

for tag in tags:
    wrap_box.append(create_tag_widget(tag))
```

### AdwInlineViewSwitcher

View switcher for use inside cards/sidebars (not header bar).

```python
switcher = Adw.InlineViewSwitcher()
switcher.set_stack(view_stack)
```

### AdwShortcutsDialog (Replaces GtkShortcutsWindow)

```python
dialog = Adw.ShortcutsDialog()
# Configure shortcuts groups and shortcuts
dialog.present(parent)
```

---

## Migration Guide

### Dialog Widgets

| Old Widget | New Widget | Notes |
|------------|------------|-------|
| `AdwMessageDialog` | `AdwAlertDialog` | Can scroll contents |
| `AdwPreferencesWindow` | `AdwPreferencesDialog` | Search off by default |
| `AdwAboutWindow` | `AdwAboutDialog` | Same API |
| `GtkDialog` | `AdwDialog` | Esc-to-close automatic |

### Navigation Widgets

| Old Widget | New Widget | Notes |
|------------|------------|-------|
| `AdwLeaflet` (unfold=false) | `AdwNavigationView` | Gestures/shortcuts built-in |
| `AdwLeaflet` | `AdwNavigationSplitView` | For sidebar patterns |
| `AdwFlap` | `AdwOverlaySplitView` | Overlay sidebar |

### Key API Changes

**Dialog presenting:**
```python
# Old
dialog.set_transient_for(window)
dialog.show()

# New
dialog.present(widget)  # Any widget in window works
```

**Close handling:**
```python
# Old (GtkWindow)
def on_close_request(window):
    return True  # Prevent close

# New (AdwDialog)
dialog.set_can_close(False)
dialog.connect("close-attempt", on_close_attempt)
```

---

## Best Practices

### Use New Dialogs
- Prefer `AdwDialog` subclasses over `GtkWindow`-based dialogs
- Better mobile support automatically
- Consistent with platform

### Breakpoints Over Code
- Define layouts declaratively in UI files
- Use `sp` units for text-scale awareness
- Set minimum window size (360×200 default in 1.6+)

### Accent Color Awareness
- Don't assume blue accent
- Use CSS variables, not hardcoded colors
- Test with different system accents
- Redraw custom widgets when accent changes

### Bottom Sheets for Persistent UI
- Use `AdwBottomSheet` for player controls, toolbars
- Works with `AdwHeaderBar` (hides title when drag handle shown)
- Swipe-down works from header bar area

---

## External Resources

- [libadwaita 1.4 Blog Post](https://blogs.gnome.org/alicem/2023/09/15/libadwaita-1-4/)
- [libadwaita 1.5 Blog Post](https://blogs.gnome.org/alicem/2024/03/15/libadwaita-1-5/)
- [libadwaita 1.6 Blog Post](https://blogs.gnome.org/alicem/2024/09/13/libadwaita-1-6/)
- [Migration to Adaptive Dialogs](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/migrating-to-adaptive-dialogs.html)
- [CSS Variables Reference](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/css-variables.html)
- [Style Classes Reference](https://gnome.pages.gitlab.gnome.org/libadwaita/doc/main/style-classes.html)
