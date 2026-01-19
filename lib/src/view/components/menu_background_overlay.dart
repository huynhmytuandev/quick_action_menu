import 'dart:ui';

import 'package:flutter/material.dart';

/// {@template menu_background_overlay}
/// The background overlay for the menu, handling blur, color,
/// and dismissal taps.
///
/// This widget provides a semi-transparent backdrop with optional blur
/// effect that dismisses the menu when tapped.
/// {@endtemplate}
class MenuBackgroundOverlay extends StatelessWidget {
  /// {@macro menu_background_overlay}
  const MenuBackgroundOverlay({
    required this.overlayVisibilityAnimation,
    required this.onDismiss,
    required this.backgroundColor,
    required this.backgroundOpacity,
    required this.blurSigmaX,
    required this.blurSigmaY,
    super.key,
  });

  /// The animation controlling the overlay visibility.
  final Animation<double> overlayVisibilityAnimation;

  /// Callback when the overlay is tapped to dismiss.
  final VoidCallback onDismiss;

  /// The background color of the overlay.
  final Color backgroundColor;

  /// The opacity of the background color (0.0 to 1.0).
  final double backgroundOpacity;

  /// The horizontal blur sigma value.
  final double blurSigmaX;

  /// The vertical blur sigma value.
  final double blurSigmaY;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: AnimatedBuilder(
        animation: overlayVisibilityAnimation,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: overlayVisibilityAnimation.value * blurSigmaX,
              sigmaY: overlayVisibilityAnimation.value * blurSigmaY,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: backgroundColor.withValues(
                alpha: overlayVisibilityAnimation.value * backgroundOpacity,
              ),
            ),
          );
        },
      ),
    );
  }
}
