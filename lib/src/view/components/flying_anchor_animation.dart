import 'package:flutter/material.dart';

/// {@template flying_anchor_animation}
/// Handles the animated "flying" representation of the anchor widget.
///
/// This widget displays the anchor during its fly-in and fly-out animations,
/// showing it moving from its original position to the overlay position
/// and back.
/// {@endtemplate}
class FlyingAnchorAnimation extends StatelessWidget {
  /// {@macro flying_anchor_animation}
  const FlyingAnchorAnimation({
    required this.isVisibleNotifier,
    required this.anchorFlyAnimationController,
    required this.anchorFlyOffsetAnimation,
    required this.anchorScaleAnimation,
    required this.originalAnchorSize,
    required this.scaledAnchorSize,
    required this.anchorWidget,
    super.key,
  });

  /// Notifier that controls visibility of the flying anchor.
  final ValueNotifier<bool> isVisibleNotifier;

  /// The animation controller for the fly animation.
  final AnimationController anchorFlyAnimationController;

  /// The animation for the anchor's position offset.
  final Animation<Offset> anchorFlyOffsetAnimation;

  /// The animation for the anchor's scale.
  final Animation<double> anchorScaleAnimation;

  /// The original size of the anchor before scaling.
  final Size originalAnchorSize;

  /// The final size of the anchor after scaling.
  final Size scaledAnchorSize;

  /// The anchor widget to display.
  final Widget anchorWidget;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isVisibleNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink();
        }
        return AnimatedBuilder(
          animation: anchorFlyAnimationController,
          builder: (context, child) {
            final currentGlobalAnchorPosition = anchorFlyOffsetAnimation.value;
            final scale = anchorScaleAnimation.value;

            return Positioned(
              left: currentGlobalAnchorPosition.dx,
              top: currentGlobalAnchorPosition.dy,
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topLeft,
                child: SizedBox.fromSize(
                  size: originalAnchorSize,
                  child: anchorWidget,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
