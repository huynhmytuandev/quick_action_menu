// src/view/quick_action_menu.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart';
import 'package:quick_action_menu/src/models/anchor_build_data.dart';
import 'package:quick_action_menu/src/models/overlay_menu_config.dart';
import 'package:quick_action_menu/src/view/overlay_menu_widget.dart';

part 'quick_action_anchor.dart';

/// A widget that manages and displays a quick action menu overlay
/// for its descendant widgets.
class QuickActionMenu extends StatefulWidget {
  /// Creates a [QuickActionMenu].
  const QuickActionMenu({required this.child, super.key});

  /// The widget tree that contains the anchor widgets for the menu.
  final Widget child;

  /// Retrieves the [QuickActionMenuState] from the nearest ancestor
  /// [QuickActionMenu] in the widget tree.
  static QuickActionMenuState of(BuildContext context) {
    final state = context.findAncestorStateOfType<QuickActionMenuState>();
    if (state == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'QuickActionMenu.of() called with a context that '
          'does not contain a QuickActionMenu.',
        ),
        ErrorDescription(
          'The context used by QuickActionMenu.of() must be '
          'that of a widget that contains a QuickActionMenu.',
        ),
        ErrorHint(
          'This usually happens when the context provided is from '
          'the same widget that created the QuickActionMenu.\n'
          'Or QuickActionMenu is not in the widget tree.',
        ),
      ]);
    }
    return state;
  }

  @override
  State<QuickActionMenu> createState() => QuickActionMenuState();
}

/// The [State] for [QuickActionMenu], managing anchor registration
/// and overlay display.
class QuickActionMenuState extends State<QuickActionMenu> {
  final _menuAnchorRegistry = <Object, AnchorBuildData>{};
  OverlayEntry? _currentOverlayEntry;
  GlobalKey<OverlayMenuWidgetState>? _currentOverlayMenuKey;
  Object? _currentActiveAnchorTag;
  final ValueNotifier<bool> _menuVisibilityNotifier = ValueNotifier(false);

  /// Wheather a menu is currently being displayed.
  bool get isMenuDisplayed => _menuVisibilityNotifier.value;

  /// Registers an anchor widget with the host [QuickActionMenu].
  void _registerMenuAnchor(
    Object tag,
    AnchorBuildData data,
  ) {
    _menuAnchorRegistry[tag] = data;
  }

  /// Unregisters an anchor widget identified by its [tag].
  ///
  /// Internal use between [QuickActionAnchor] and [QuickActionMenu].
  void _unregisterMenuAnchor(Object tag) {
    _menuAnchorRegistry.remove(tag);
    if (_currentActiveAnchorTag == tag) {
      if (_currentOverlayMenuKey != null) {
        _currentOverlayMenuKey?.currentState?.dismiss();
      }
      _currentActiveAnchorTag = null;
    }
  }

  /// Hides the currently displayed quick action menu, if any.
  Future<void> hideMenu() async {
    if (_currentOverlayEntry != null && _currentOverlayMenuKey != null) {
      await _currentOverlayMenuKey!.currentState?.dismiss();
    }
  }

  /// Shows the quick action menu with the given [tag].
  ///
  /// - [tag]: The tag for the menu.
  /// - [topMenuWidget]: The widget to display above the anchor.
  /// - [bottomMenuWidget]: The widget to display below the anchor.
  /// - [topMenuAlignment]: The horizontal alignment of the top menu widget.
  /// - [bottomMenuAlignment]: The horizontal alignment of the bottom menu
  /// widget.
  /// - [duration]: The duration of the overlay animation.
  /// - [reverseDuration]: The duration of the reversed animation.
  /// - [bottomMenuScaleCurve]: The curve of the bottom menu scale animation.
  /// - [overlayBackgroundColor]: The background color of the overlay.
  /// - [overlayBackgroundOpacity]: The opacity of the overlay background.
  /// - [backdropBlurSigmaX]: The sigmaX value for the backdrop blur effect.
  /// - [backdropBlurSigmaY]: The sigmaY value for the backdrop blur effect.
  /// - [reverseScroll]: Whether to reverse the scroll direction.
  /// - [padding]: General padding for the screen edges, defining a "safe area"
  /// where the menu should ideally stay.
  /// needs to scroll. This might differ from the general [padding].
  /// - [stickyMenuBehavior]: The sticky menu behavior for the menu. This will
  /// be use to determine the menu's sticky behavior when scrolling.
  ///
  void showMenu({
    required Object tag,
    Widget? topMenuWidget,
    Widget? bottomMenuWidget,
    OverlayMenuHorizontalAlignment topMenuAlignment =
        OverlayMenuHorizontalAlignment.center,
    OverlayMenuHorizontalAlignment bottomMenuAlignment =
        OverlayMenuHorizontalAlignment.center,
    Duration duration = Durations.short4,
    Duration? reverseDuration,
    Curve overlayAnimationCurve = Curves.easeOutCubic,
    Curve anchorFlyAnimationCurve = Curves.easeOutSine,
    Curve topMenuScaleCurve = Curves.easeOutCubic,
    Curve bottomMenuScaleCurve = Curves.easeOutCubic,
    Color overlayBackgroundColor = Colors.black,
    double overlayBackgroundOpacity = 0.2,
    double backdropBlurSigmaX = 10.0,
    double backdropBlurSigmaY = 10.0,
    bool reverseScroll = false,
    EdgeInsets padding = EdgeInsets.zero,
    StickyMenuBehavior stickyMenuBehavior = StickyMenuBehavior.none,
  }) {
    final anchorData = _menuAnchorRegistry[tag];
    if (anchorData == null) {
      debugPrint('QuickActionMenu: No anchor found for tag: $tag');
      return;
    }

    final anchorKey = anchorData.key;

    final anchorContext = anchorKey.currentContext;
    if (anchorContext == null) {
      debugPrint('QuickActionMenu: Anchor context is null for tag: $tag');
      return;
    }

    final anchorWidget = (anchorContext.widget as KeyedSubtree).child;

    if (_currentOverlayEntry != null) {
      if (_currentOverlayMenuKey != null) {
        _currentOverlayMenuKey!.currentState?.dismiss();
      } else {
        _removeCurrentOverlayEntry();
      }
    }
    _currentActiveAnchorTag = tag;
    _currentOverlayMenuKey = GlobalKey<OverlayMenuWidgetState>();
    _currentOverlayEntry = OverlayEntry(
      builder: (context) {
        return OverlayMenuWidget(
          key: _currentOverlayMenuKey,
          config: OverlayMenuConfig(
            anchorKey: anchorKey,
            duration: duration,
            reverseDuration: reverseDuration,
            topMenuWidget: topMenuWidget,
            bottomMenuWidget: bottomMenuWidget,
            reverseScroll: reverseScroll,
            anchorWidget: anchorWidget,
            topMenuAlignment: topMenuAlignment,
            bottomMenuAlignment: bottomMenuAlignment,
            onAnchorExtracted: _onAnchorExtracted,
            onDismissed: _removeCurrentOverlayEntry,
            overlayAnimationCurve: overlayAnimationCurve,
            anchorFlyAnimationCurve: anchorFlyAnimationCurve,
            topMenuScaleCurve: topMenuScaleCurve,
            bottomMenuScaleCurve: bottomMenuScaleCurve,
            overlayBackgroundColor: overlayBackgroundColor,
            stickyMenuBehavior: stickyMenuBehavior,
            padding: padding,
          ),
        );
      },
    );

    Overlay.of(context).insert(_currentOverlayEntry!);
    _menuVisibilityNotifier.value = true;
  }

  void _onAnchorExtracted() {
    final activeAnchorTag = _currentActiveAnchorTag;
    if (activeAnchorTag != null) {
      _menuAnchorRegistry[activeAnchorTag]?.onExtractedChanged(true);
    }
  }

  void _removeCurrentOverlayEntry() {
    if (_currentOverlayEntry != null && _currentOverlayEntry!.mounted) {
      _currentOverlayEntry!.remove();
      _menuVisibilityNotifier.value = false;
    }
    _currentOverlayEntry = null;
    _currentOverlayMenuKey = null;

    final activeAnchorTag = _currentActiveAnchorTag;
    _currentActiveAnchorTag = null;
    if (activeAnchorTag != null) {
      _menuAnchorRegistry[activeAnchorTag]?.onExtractedChanged(false);
    }
  }

  @override
  void dispose() {
    _removeCurrentOverlayEntry();
    _menuVisibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _menuVisibilityNotifier,
      builder: (context, isMenuDisplayed, child) {
        return PopScope(
          canPop: !isMenuDisplayed,
          onPopInvokedWithResult: (didPop, result) async {
            if (isMenuDisplayed) {
              await hideMenu();
              return;
            }
            if (!didPop) {
              Navigator.of(context).pop(result);
            }
            return;
          },
          child: widget.child,
        );
      }
    );
  }
}
