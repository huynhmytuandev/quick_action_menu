// src/models/overlay_menu_config.dart
import 'package:flutter/material.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart'; // Assuming this enum exists
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart'; // New import

/// {@template overlay_menu_config}
/// Configuration class for an overlay menu in a Flutter application.
///
/// This class defines various properties and behaviors for an overlay menu,
/// including its alignment, animation durations and curves, background color
/// and opacity, and sticky menu behavior. It allows customization of the
/// overlay's appearance and interaction with the anchor widget.
///
/// The overlay can display widgets above and below the anchor, and provides
/// callbacks for when the anchor is extracted or the overlay is dismissed.
/// {@endtemplate}
class OverlayMenuConfig {
  /// {@macro overlay_menu_config}
  const OverlayMenuConfig({
    required this.anchorKey,
    required this.anchorWidget,
    required this.onAnchorExtracted,
    required this.onDismissed,
    this.topMenuWidget,
    this.bottomMenuWidget,
    this.padding = EdgeInsets.zero,
    this.topMenuAlignment = OverlayMenuHorizontalAlignment.center,
    this.bottomMenuAlignment = OverlayMenuHorizontalAlignment.center,
    this.duration = Durations.medium1,
    this.reverseDuration,
    this.overlayAnimationCurve = Curves.easeOutCubic,
    this.anchorFlyAnimationCurve = Curves.easeInOutCubic,
    this.anchorScaleAnimationCurve = Curves.decelerate,
    this.topMenuScaleCurve = Curves.easeOutCubic,
    this.bottomMenuScaleCurve = Curves.easeOutCubic,
    this.overlayBackgroundColor = Colors.black,
    this.overlayBackgroundOpacity = 0.2,
    this.backdropBlurSigmaX = 10.0,
    this.backdropBlurSigmaY = 10.0,
    this.reverseScroll = false, // Default to false
    this.stickyMenuBehavior = StickyMenuBehavior.none,
  });

  /// The GlobalKey of the widget that acts as the anchor for the menu.
  final GlobalKey anchorKey;

  /// The widget that will be shown as the anchor in the overlay.
  /// This can be the same as the original widget, or a scaled/transformed version.
  final Widget anchorWidget;

  /// General padding for the screen edges, defining a "safe area"
  /// where the menu should ideally stay.
  final EdgeInsets padding;

  /// The widget to display above the anchor.
  final Widget? topMenuWidget;

  /// The widget to display below the anchor.
  final Widget? bottomMenuWidget;

  /// Callback when the anchor is extracted.
  final VoidCallback? onAnchorExtracted;

  /// Callback when the overlay is dismissed (e.g., by tapping outside).
  final VoidCallback? onDismissed;

  /// Horizontal alignment for the top menu widget relative to the anchor.
  final OverlayMenuHorizontalAlignment topMenuAlignment;

  /// Horizontal alignment for the bottom menu widget relative to the anchor.
  final OverlayMenuHorizontalAlignment bottomMenuAlignment;

  /// The duration for all animations.
  final Duration duration;

  /// The duration for reversed animations.
  final Duration? reverseDuration;

  /// Curve for the overlay visibility animations.
  final Curve overlayAnimationCurve;

  /// Curve for the anchor fly animation.
  final Curve anchorFlyAnimationCurve;

  /// Curve for the anchor scale animation.
  final Curve anchorScaleAnimationCurve;

  /// Curve for the top menu scale animation.
  final Curve topMenuScaleCurve;

  /// Curve for the bottom menu scale animation.
  final Curve bottomMenuScaleCurve;

  /// The background color of the overlay.
  final Color overlayBackgroundColor;

  /// The opacity of the overlay background color (0.0 to 1.0).
  final double overlayBackgroundOpacity;

  /// The sigmaX value for the backdrop blur effect.
  final double backdropBlurSigmaX;

  /// The sigmaY value for the backdrop blur effect.
  final double backdropBlurSigmaY;

  /// Determines if the [SingleChildScrollView] should scroll in reverse.
  /// When true, the scroll view starts at the end of its scroll extent.
  final bool reverseScroll;

  /// Defines how menus behave when the content scrolls.
  /// [StickyMenuBehavior.none] (default) means menus scroll with content.
  /// [StickyMenuBehavior.top] makes the top menu stick to its calculated
  /// position relative to the scrollable viewport's top.
  /// [StickyMenuBehavior.bottom] makes the bottom menu stick to its calculated
  /// position relative to the scrollable viewport's bottom.
  /// [StickyMenuBehavior.both] applies sticky behavior to both.
  final StickyMenuBehavior stickyMenuBehavior;

  /// Creates a copy of this [OverlayMenuConfig] with the given fields
  /// replaced with new values.
  ///
  /// This is useful for testing and creating variations of a config.
  OverlayMenuConfig copyWith({
    GlobalKey? anchorKey,
    Widget? anchorWidget,
    VoidCallback? onAnchorExtracted,
    VoidCallback? onDismissed,
    Widget? topMenuWidget,
    Widget? bottomMenuWidget,
    EdgeInsets? padding,
    OverlayMenuHorizontalAlignment? topMenuAlignment,
    OverlayMenuHorizontalAlignment? bottomMenuAlignment,
    Duration? duration,
    Duration? reverseDuration,
    Curve? overlayAnimationCurve,
    Curve? anchorFlyAnimationCurve,
    Curve? anchorScaleAnimationCurve,
    Curve? topMenuScaleCurve,
    Curve? bottomMenuScaleCurve,
    Color? overlayBackgroundColor,
    double? overlayBackgroundOpacity,
    double? backdropBlurSigmaX,
    double? backdropBlurSigmaY,
    bool? reverseScroll,
    StickyMenuBehavior? stickyMenuBehavior,
  }) {
    return OverlayMenuConfig(
      anchorKey: anchorKey ?? this.anchorKey,
      anchorWidget: anchorWidget ?? this.anchorWidget,
      onAnchorExtracted: onAnchorExtracted ?? this.onAnchorExtracted,
      onDismissed: onDismissed ?? this.onDismissed,
      topMenuWidget: topMenuWidget ?? this.topMenuWidget,
      bottomMenuWidget: bottomMenuWidget ?? this.bottomMenuWidget,
      padding: padding ?? this.padding,
      topMenuAlignment: topMenuAlignment ?? this.topMenuAlignment,
      bottomMenuAlignment: bottomMenuAlignment ?? this.bottomMenuAlignment,
      duration: duration ?? this.duration,
      reverseDuration: reverseDuration ?? this.reverseDuration,
      overlayAnimationCurve:
          overlayAnimationCurve ?? this.overlayAnimationCurve,
      anchorFlyAnimationCurve:
          anchorFlyAnimationCurve ?? this.anchorFlyAnimationCurve,
      anchorScaleAnimationCurve:
          anchorScaleAnimationCurve ?? this.anchorScaleAnimationCurve,
      topMenuScaleCurve: topMenuScaleCurve ?? this.topMenuScaleCurve,
      bottomMenuScaleCurve: bottomMenuScaleCurve ?? this.bottomMenuScaleCurve,
      overlayBackgroundColor:
          overlayBackgroundColor ?? this.overlayBackgroundColor,
      overlayBackgroundOpacity:
          overlayBackgroundOpacity ?? this.overlayBackgroundOpacity,
      backdropBlurSigmaX: backdropBlurSigmaX ?? this.backdropBlurSigmaX,
      backdropBlurSigmaY: backdropBlurSigmaY ?? this.backdropBlurSigmaY,
      reverseScroll: reverseScroll ?? this.reverseScroll,
      stickyMenuBehavior: stickyMenuBehavior ?? this.stickyMenuBehavior,
    );
  }
}
