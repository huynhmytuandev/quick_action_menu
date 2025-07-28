# quick_action_menu

A Flutter package for showing highly customizable context menus (inspired by Telegram/WeChat-style quick action menus) for any widget, such as chat message bubbles. This package handles complex layout, positioning, and animations, including "flying" anchor effects and sticky menu behaviors during scrolling.

## Features

- **Contextual Menus:** Easily attach and display customizable menus above or below any Flutter widget.
- **Anchor Animation:** Smooth "fly-in" and "fly-out" animations for the anchor widget as the menu appears/disappears.
- **Flexible Positioning:** Automatically calculates optimal menu position based on screen boundaries, padding, and anchor location.
- **Horizontal Alignment:** Control the horizontal alignment of top and bottom menu widgets relative to the anchor (left, center, right).
- **Sticky Menu Behavior:** Define whether the top, bottom, or both menus should stick to the viewport edges or anchor during scrolling.
- **Background Effects:** Customizable overlay background with color and backdrop blur.
- **Dismissal:** Dismiss the menu by tapping outside or programmatically.
- **Performance Optimized:** Uses `CustomMultiChildLayout` for efficient layout and `MeasureSize` for dynamic widget measurements without unnecessary rebuilds.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  quick_action_menu: ^0.1.0 # Use the latest version
````

Then, run `flutter pub get` to fetch the package.

## Usage

### 1\. Wrap your application with `QuickActionMenu`

To enable the quick action menu functionality, wrap your top-level `MaterialApp` or a significant portion of your widget tree with `QuickActionMenu`. This widget manages the overlay.

```dart
import 'package:flutter/material.dart';
import 'package:quick_action_menu/quick_action_menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Action Menu Demo',
      home: QuickActionMenu( // Wrap your app or desired subtree
        child: MyHomePage(),
      ),
    );
  }
}
```

### 2\. Define your `QuickActionAnchor`

Wrap the widget you want to serve as the anchor for the context menu with `QuickActionAnchor`. Provide a unique `tag` for this anchor.

```dart
import 'package:flutter/material.dart';
import 'package:quick_action_menu/quick_action_menu.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Action Menu Demo')),
      body: Center(
        child: QuickActionAnchor(
          tag: 'myUniqueMessageAnchor', // Unique tag for this anchor
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: const Text(
              'Long press this text',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
```

You can optionally provide a `placeholderBuilder` to define what appears in place of the original anchor widget when it "flies out" to the overlay. If not provided, an empty `SizedBox` matching the original anchor's size will be shown.

```dart
QuickActionAnchor(
  tag: 'myUniqueMessageAnchor',
  placeholderBuilder: (context, heroSize) {
    return Container(
      width: heroSize.width,
      height: heroSize.height,
      color: Colors.blue.withOpacity(0.3), // Faded placeholder
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  },
  child: // Your original anchor widget
)
```

### 3\. Show the menu

To show the quick action menu, use `QuickActionMenu.of(context).showMenu()`. You need to provide the `tag` of your `QuickActionAnchor` and various optional parameters to customize the menu's appearance and behavior.

The `anchorWidget` parameter in `showMenu` is crucial. It represents the actual widget that will "fly" and be displayed within the overlay. This is typically a duplicate of your `QuickActionAnchor`'s `child` widget, potentially wrapped in a `Hero` widget for custom animations.

```dart
import 'package:flutter/material.dart';
import 'package:quick_action_menu/quick_action_menu.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart'; // Import if not already
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart'; // Import if not already

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Action Menu Demo')),
      body: Center(
        child: GestureDetector(
          onLongPress: () {
            final quickActionMenu = QuickActionMenu.of(context);
            const String anchorTag = 'myUniqueMessageAnchor';

            // Define the anchorWidget that will "fly" and be shown in the overlay.
            // This is typically a duplicate of the QuickActionAnchor's child.
            final Widget flyingAnchorWidget = Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue,
              child: const Text(
                'Long press this text',
                style: TextStyle(color: Colors.white),
              ),
            );

            // Show the menu using the tag and desired configuration parameters
            quickActionMenu.showMenu(
              tag: anchorTag,
              anchorWidget: flyingAnchorWidget, // The widget that will fly and appear in the overlay
              topMenuWidget: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(onPressed: () {}, child: const Text('Reply')),
                      TextButton(onPressed: () {}, child: const Text('Copy')),
                    ],
                  ),
                ),
              ),
              bottomMenuWidget: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.star), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () {}),
                    ],
                  ),
                ),
              ),
              // Customizations:
              padding: const EdgeInsets.all(16.0), // Safe area padding
              overlayBackgroundOpacity: 0.4,
              backdropBlurSigmaX: 5.0,
              backdropBlurSigmaY: 5.0,
              topMenuAlignment: OverlayMenuHorizontalAlignment.center,
              bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
              stickyMenuBehavior: StickyMenuBehavior.top, // Example: Top menu sticks on scroll
            );
          },
          child: QuickActionAnchor(
            tag: 'myUniqueMessageAnchor',
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue,
              child: const Text(
                'Long press this text',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### `showMenu` Parameters

| Parameter                    | Type                             | Description                                                                                                                                                          | Default Value         |
| :--------------------------- | :------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------- |
| `tag`                        | `Object`                         | **Required.** The unique tag of the `QuickActionAnchor` to which this menu should be attached.                                                                       |                       |
| `anchorWidget`               | `Widget`                         | **Required.** The widget that will be displayed as the animated anchor within the overlay. This should typically be a duplicate of your `QuickActionAnchor`'s child. |                       |
| `topMenuWidget`              | `Widget?`                        | Optional widget to display above the anchor.                                                                                                                         | `null`                |
| `bottomMenuWidget`           | `Widget?`                        | Optional widget to display below the anchor.                                                                                                                         | `null`                |
| `topMenuAlignment`           | `OverlayMenuHorizontalAlignment` | Horizontal alignment for the `topMenuWidget` relative to the anchor.                                                                                                 | `center`              |
| `bottomMenuAlignment`        | `OverlayMenuHorizontalAlignment` | Horizontal alignment for the `bottomMenuWidget` relative to the anchor.                                                                                              | `center`              |
| `overlayAnimationDuration`   | `Duration`                       | Duration for the overall overlay visibility (fade, blur) animations.                                                                                                 | `Durations.medium1`   |
| `overlayAnimationCurve`      | `Curve`                          | Curve for the overall overlay visibility animations.                                                                                                                 | `Curves.easeOutCubic` |
| `anchorFlyAnimationDuration` | `Duration`                       | Duration for the anchor's "fly" animation from its original position to its overlay position.                                                                        | `Durations.medium2`   |
| `anchorFlyAnimationCurve`    | `Curve`                          | Curve for the anchor's "fly" animation.                                                                                                                              | `Curves.easeOutSine`  |
| `topMenuScaleDuration`       | `Duration`                       | Duration for the `topMenuWidget` scale animation.                                                                                                                    | `Durations.medium2`   |
| `topMenuScaleCurve`          | `Curve`                          | Curve for the `topMenuWidget` scale animation.                                                                                                                       | `Curves.easeOutBack`  |
| `bottomMenuScaleDuration`    | `Duration`                       | Duration for the `bottomMenuWidget` scale animation.                                                                                                                 | `Durations.medium2`   |
| `bottomMenuScaleCurve`       | `Curve`                          | Curve for the `bottomMenuWidget` scale animation.                                                                                                                    | `Curves.easeOutBack`  |
| `overlayBackgroundColor`     | `Color`                          | The background color of the overlay.                                                                                                                                 | `Colors.black`        |
| `overlayBackgroundOpacity`   | `double`                         | The opacity of the overlay background color (0.0 to 1.0).                                                                                                            | `0.2`                 |
| `backdropBlurSigmaX`         | `double`                         | The sigmaX value for the backdrop blur effect.                                                                                                                       | `10.0`                |
| `backdropBlurSigmaY`         | `double`                         | The sigmaY value for the backdrop blur effect.                                                                                                                       | `10.0`                |
| `reverseScroll`              | `bool`                           | Determines if the internal `SingleChildScrollView` should scroll in reverse. Useful for chat-like interfaces.                                                        | `false`               |
| `padding`                    | `EdgeInsets`                     | General padding for the screen edges, defining a "safe area" where the menu should ideally stay.                                                                     | `EdgeInsets.zero`     |
| `stickyMenuBehavior`         | `StickyMenuBehavior`             | Defines how the top/bottom menus behave during scrolling (`none`, `top`, `bottom`, `both`).                                                                          | `none`                |

### Enums

#### `OverlayMenuHorizontalAlignment`

Defines horizontal alignment options for menu widgets relative to the anchor.

  - `left`
  - `center`
  - `right`

#### `StickyMenuBehavior`

Defines how menu widgets behave when the content inside the overlay scrolls.

  - `none`: Neither menu sticks.
  - `top`: The top menu sticks to the anchor's calculated position or the top of the scroll view.
  - `bottom`: The bottom menu sticks to the anchor's calculated position or the bottom of the scroll view.
  - `both`: Both menus stick to their respective ends or the anchor.

## Contribution

Contributions are welcome\! Please feel free to open an issue or submit a pull request.