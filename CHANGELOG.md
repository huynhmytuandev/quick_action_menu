# Changelog

## [1.0.0] - 2026-01-19

### Added

- **QuickActionMenu** - Main widget that wraps content and manages overlay state
- **QuickActionAnchor** - Anchor widget that marks elements as menu triggers
- **OverlayMenuConfig** - Configuration class for customizing menu appearance and behavior
- **Flying anchor animation** - Smooth animation of anchor widget to overlay position
- **Sticky menu behavior** - Top, bottom, or both menus can stick during scrolling
- **Backdrop blur effect** - Configurable blur and color overlay behind menus
- **Horizontal alignment options** - Left, center, or right alignment for top/bottom menus
- **Customizable animations** - Separate curves for overlay, anchor fly, anchor scale, and menu scale animations
- **Reverse scroll support** - Option to start scroll view at the end of content
- **Safe area padding** - Configurable padding to keep menus within screen bounds
- **Menu visibility notifier** - ValueNotifier to observe menu open/close state
- **Programmatic control** - Methods to show and dismiss menus programmatically

## [1.0.0+1] - 2026-01-20

### Fixed

- Fix the demo GIF paths in README.md

## [1.0.1] - 2026-01-21

### Added
- Added example for programmatic control of the menu in the demo app