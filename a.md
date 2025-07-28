## Quick Action Menu - Development Notes

This markdown file is a reference guide for developers and AI agents working on the `quick_action_menu` Flutter package. It summarizes the architecture, capabilities, and TODO items to ensure a consistent development flow.

---

### ✅ Overview

`quick_action_menu` is a Flutter overlay system inspired by Facebook Messenger's reaction/action menu. It allows any widget to trigger a floating overlay menu aligned to that widget.

---

### ✅ Core Widgets & Classes

#### `QuickActionMenu`

* An `InheritedWidget` that provides access to `MenuController`
* Maintains anchor registry
* Optional for users unless listening to open/close state

#### `QuickActionAnchor`

* Wraps a target widget
* Auto-registers the `GlobalKey` to the anchor registry
* Identified by a `String tag`

#### `MenuController`

* Provides `show(...)` and `dismiss()` methods
* Uses `OverlayEntry` to insert/remove overlay
* Accepts context at `show()` call time

#### `OverlayMenuWidget`

* The overlay UI widget shown above all content
* Supports:

  * Animation (scale, fade, slide)
  * Background blur
  * Measurement with `MeasureSize`
  * Scroll overflow fallback
  * Configurable alignment (X, Y)

#### `OverlayMenuConfig`

* Data class passed into `OverlayMenuWidget`
* Properties:

  * `anchorKey`
  * `topWidget`, `bottomWidget`
  * `anchorAlignment` (Y alignment)
  * `topWidgetAlign`, `bottomWidgetAlign` (X alignment)
  * `onDismissed()`

#### `OverlayMenuHorizontalAlignment`

* Enum: `left`, `center`, `right`
* Aligns widget to anchor edges

---

### ✅ Features Completed

* [x] Measure widgets dynamically via `MeasureSize`
* [x] Position and animate overlay relative to anchor
* [x] Fade, scale, and anchor movement animations
* [x] Scroll overflow support when height exceeds safe bounds
* [x] Auto anchor registration via `QuickActionAnchor`
* [x] `topWidgetAlign` and `bottomWidgetAlign` (left/center/right)

---

### 🚧 TODO / Next Steps

* [ ] Add RTL layout awareness
* [ ] Expose `animationDuration` per section
* [ ] Support different alignment strategies (e.g. screen edge, custom offset)
* [ ] Keyboard avoidance on mobile (adjust layout when keyboard is up)
* [ ] Add unit and golden tests
* [ ] Create `QuickActionScope.of(context)` to get anchorKey by tag
* [ ] Add `onOpen`, `onClose`, `onPositionResolved` lifecycle events to `MenuController`
* [ ] Expose menu constraints (min/max width, etc.)

---

### 🧠 Notes

* Prefer calculating scroll-safe bounds with `MediaQuery.viewPadding`
* All widgets animate independently (top, bottom, overlay, anchor)
* Menu width currently uses max(top, bottom, anchor width)

---

### 📂 Suggested File Structure

```
lib/
  quick_action_menu.dart
  src/
    overlay_menu_widget.dart
    menu_position_calculator.dart
    quick_action_anchor.dart
    menu_controller.dart
    quick_action_menu_scope.dart
```

---

### 🧪 Example Usage

```dart
QuickActionAnchor(
  tag: 'msg1',
  child: Text('Hello'),
);

QuickActionMenu.of(context).showByTag(
  tag: 'msg1',
  topWidget: ReactionsBar(),
  bottomWidget: MessageActions(),
);
```

---

This file should be maintained and expanded as new features are added.
