import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart';
import 'package:quick_action_menu/src/models/menu_position_result.dart';
import 'package:quick_action_menu/src/models/overlay_menu_config.dart';
import 'package:quick_action_menu/src/utils/menu_overlay_calculator.dart';
import 'package:quick_action_menu/src/widgets/measure_size.dart';

/// Defines the slots for layout within the CustomMultiChildLayout.
enum OverlaySlot { top, anchor, bottom }

/// A widget that displays a quick action menu as an overlay relative to an anchor widget.
class OverlayMenuWidget extends StatefulWidget {
  const OverlayMenuWidget({required this.config, super.key});
  final OverlayMenuConfig config;

  @override
  State<OverlayMenuWidget> createState() => OverlayMenuWidgetState();
}

/// The [State] for [OverlayMenuWidget], managing the overlay display.
class OverlayMenuWidgetState extends State<OverlayMenuWidget>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _overlayVisibilityController;
  late final AnimationController _anchorFlyAnimationController;
  late final AnimationController _topMenuScaleController;
  late final AnimationController _bottomMenuScaleController;

  late final Animation<double> _topMenuScaleAnimation;
  late final Animation<double> _bottomMenuScaleAnimation;
  late Animation<Offset> _anchorFlyOffsetAnimation;
  late Animation<double> _anchorScaleAnimation;

  Size? _measuredTopMenuSize;
  Size? _measuredBottomMenuSize;
  Rect? _originalAnchorRect;

  MenuPositionResult? _positionResult;

  final GlobalKey _contentAnchorGlobalKey = GlobalKey();

  final _isAnchorOffstageNotifier = ValueNotifier<bool>(true);
  final _isFlyingAnchorVisibleNotifier = ValueNotifier<bool>(false);
  final _currentScrollOffsetNotifier = ValueNotifier<double>(0);

  final Completer<void> _dismissCompleter = Completer<void>();

  /// Exposes a method to programmatically dismiss the overlay.
  /// Returns a Future that completes when the dismissal animation is done.
  Future<void> dismiss() {
    _reverseAnimateAndDissmiss();
    return _dismissCompleter.future;
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController()
      ..addListener(() {
        _currentScrollOffsetNotifier.value = _scrollController.offset;
      });

    _overlayVisibilityController = AnimationController(
      vsync: this,
      duration: widget.config.duration,
      reverseDuration: widget.config.reverseDuration,
    );
    _anchorFlyAnimationController = AnimationController(
      vsync: this,
      duration: widget.config.duration,
      reverseDuration: widget.config.reverseDuration,
    );
    _topMenuScaleController = AnimationController(
      vsync: this,
      duration: widget.config.duration,
      reverseDuration: widget.config.reverseDuration,
    );
    _bottomMenuScaleController = AnimationController(
      vsync: this,
      duration: widget.config.duration,
      reverseDuration: widget.config.reverseDuration,
    );

    _topMenuScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _topMenuScaleController,
        curve: widget.config.topMenuScaleCurve,
      ),
    );
    _bottomMenuScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _bottomMenuScaleController,
        curve: widget.config.bottomMenuScaleCurve,
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _calculateInitialLayout(),
    );

    _anchorFlyAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        _isFlyingAnchorVisibleNotifier.value = true;
        _isAnchorOffstageNotifier.value = true;
      } else if (status == AnimationStatus.completed) {
        _isFlyingAnchorVisibleNotifier.value = false;
        _isAnchorOffstageNotifier.value = false;
      } else if (status == AnimationStatus.reverse) {
        _isFlyingAnchorVisibleNotifier.value = true;
        _isAnchorOffstageNotifier.value = true;
      } else if (status == AnimationStatus.dismissed) {
        _isFlyingAnchorVisibleNotifier.value = false;
        _isAnchorOffstageNotifier.value = false;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _overlayVisibilityController.dispose();
    _anchorFlyAnimationController.dispose();
    _topMenuScaleController.dispose();
    _bottomMenuScaleController.dispose();
    _isAnchorOffstageNotifier.dispose();
    _isFlyingAnchorVisibleNotifier.dispose();
    _currentScrollOffsetNotifier.dispose();
    if (!_dismissCompleter.isCompleted) {
      _dismissCompleter.complete();
    }
    super.dispose();
  }

  /// Calculates the initial global position and size of the anchor widget.
  void _calculateInitialLayout() {
    final renderBox =
        widget.config.anchorKey.currentContext?.findRenderObject()
            as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;

    final anchorRect = renderBox.localToGlobal(Offset.zero) & renderBox.size;

    setState(() {
      _originalAnchorRect = anchorRect;
    });

    // Notify when anchor has been measured and its position captured.
    //
    // Using post-frame callback to ensure the ovelay is fully visible
    // before calling the callback.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.config.onAnchorExtracted?.call();
    });
  }

  /// Callback when the top menu widget's size is measured.
  void _onTopMenuMeasured(Size size) {
    if (_measuredTopMenuSize == null || _measuredTopMenuSize != size) {
      setState(() {
        _measuredTopMenuSize = size;
      });
      _computeMenuLayout();
    }
  }

  /// Callback when the bottom menu widget's size is measured.
  void _onBottomMenuMeasured(Size size) {
    if (_measuredBottomMenuSize == null || _measuredBottomMenuSize != size) {
      setState(() {
        _measuredBottomMenuSize = size;
      });
      _computeMenuLayout();
    }
  }

  /// Computes the final layout positions for the overlay and its components
  /// and starts the "fly-in" animations.
  void _computeMenuLayout() {
    if (_originalAnchorRect == null) return;
    if (widget.config.topMenuWidget != null && _measuredTopMenuSize == null) {
      return;
    }
    if (widget.config.bottomMenuWidget != null &&
        _measuredBottomMenuSize == null) {
      return;
    }

    final screenSize = MediaQuery.of(context).size;

    final result =
        MenuPositionCalculator(
          screenSize: screenSize,
          padding: widget.config.padding,
          topWidgetAlign: widget.config.topMenuAlignment,
          bottomWidgetAlign: widget.config.bottomMenuAlignment,
        ).calculate(
          anchorRect: _originalAnchorRect!,
          topWidgetSize: _measuredTopMenuSize ?? Size.zero,
          bottomWidgetSize: _measuredBottomMenuSize ?? Size.zero,
        );

    if (result == _positionResult) {
      return;
    }

    setState(() {
      // Initial state for the anchor fly animation
      _positionResult = result;
      _anchorFlyOffsetAnimation =
          Tween<Offset>(
            begin: _originalAnchorRect!.topLeft,
            end: _originalAnchorRect!.topLeft,
          ).animate(
            CurvedAnimation(
              parent: _anchorFlyAnimationController,
              curve: widget.config.anchorFlyAnimationCurve,
            ),
          );

      _anchorScaleAnimation =
          Tween<double>(
            begin: 1,
            end: result.scaledAnchorSize.width / _originalAnchorRect!.width,
          ).animate(
            CurvedAnimation(
              parent: _anchorFlyAnimationController,
              curve: widget.config.anchorScaleAnimationCurve,
            ),
          );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_positionResult?.requiresScrolling ?? false) {
        if (_scrollController.hasClients) {
          _currentScrollOffsetNotifier.value = _scrollController.offset;
        }
      }
      // Re-calculate the fly offset after the menu first appears
      final endFlyOffset = _calculateAnchorCurrentPosition();

      setState(() {
        // Set up the initial "fly-in" animation for the anchor.
        _anchorFlyOffsetAnimation =
            Tween<Offset>(
              begin: _originalAnchorRect!.topLeft,
              end: endFlyOffset,
            ).animate(
              CurvedAnimation(
                parent: _anchorFlyAnimationController,
                curve: widget.config.anchorFlyAnimationCurve,
              ),
            );
      });

      _overlayVisibilityController.forward();
      _topMenuScaleController.forward();
      _bottomMenuScaleController.forward();
      _anchorFlyAnimationController.forward();
    });
  }

  /// Dismisses the overlay with reverse animations.
  Future<void> _reverseAnimateAndDissmiss() async {
    final endFlyOffset = _calculateAnchorCurrentPosition();
    setState(() {
      _anchorFlyOffsetAnimation =
          Tween<Offset>(
            begin: _originalAnchorRect?.topLeft ?? Offset.zero,
            end: endFlyOffset,
          ).animate(
            CurvedAnimation(
              parent: _anchorFlyAnimationController,
              curve: widget.config.anchorFlyAnimationCurve,
            ),
          );
    });
    await Future.wait([
      _overlayVisibilityController.reverse(),
      _topMenuScaleController.reverse(),
      _bottomMenuScaleController.reverse(),
      _anchorFlyAnimationController.reverse(),
    ]);

    if (!_dismissCompleter.isCompleted) {
      _dismissCompleter.complete();
    }
    widget.config.onDismissed?.call();
  }

  Offset _calculateAnchorCurrentPosition() {
    final contentAnchorRenderBox =
        _contentAnchorGlobalKey.currentContext?.findRenderObject()
            as RenderBox?;

    Offset contentAnchorPosition;
    if (contentAnchorRenderBox != null) {
      contentAnchorPosition = contentAnchorRenderBox.localToGlobal(Offset.zero);
    } else {
      contentAnchorPosition = _originalAnchorRect!.topLeft; // Fallback
    }
    return contentAnchorPosition;
  }

  @override
  Widget build(BuildContext context) {
    final requiresScrolling = _positionResult?.requiresScrolling ?? false;
    final overlayDisplayRect = _positionResult?.overlayDisplayRect ?? Rect.zero;
    final contentTotalSize = _positionResult?.contentTotalSize ?? Size.zero;

    final anchorFinalPositionInLayout =
        _positionResult?.anchorOffsetInOverlayContent ?? Offset.zero;

    final originalAnchorSize = _originalAnchorRect?.size ?? Size.zero;
    final scaledAnchorSize = _positionResult?.scaledAnchorSize ?? Size.zero;
    final measuredTopMenuSize = _measuredTopMenuSize ?? Size.zero;
    final measuredBottomMenuSize = _measuredBottomMenuSize ?? Size.zero;

    final scrollPhysics = requiresScrolling
        ? null
        : const NeverScrollableScrollPhysics();

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if ((widget.config.topMenuWidget != null ||
                  widget.config.bottomMenuWidget != null) &&
                  _measuredBottomMenuSize == null)
            Positioned(
              top: -1000, // Offscreen position
              left: -1000,
              child: _MenuMeasurementWidgets(
                topMenuWidget: widget.config.topMenuWidget,
                bottomMenuWidget: widget.config.bottomMenuWidget,
                onTopMenuMeasured: _onTopMenuMeasured,
                onBottomMenuMeasured: _onBottomMenuMeasured,
              ),
          ),
          if (_positionResult != null) ...[
            // 1. Background dismissal area with blur and color overlay.
            _MenuBackgroundOverlay(
              overlayVisibilityAnimation: _overlayVisibilityController,
              onDismiss: _reverseAnimateAndDissmiss,
              backgroundColor: widget.config.overlayBackgroundColor,
              backgroundOpacity: widget.config.overlayBackgroundOpacity,
              blurSigmaX: widget.config.backdropBlurSigmaX,
              blurSigmaY: widget.config.backdropBlurSigmaY,
            ),
            // 2. The flying anchor animation.
            _FlyingAnchorAnimation(
              isVisibleNotifier: _isFlyingAnchorVisibleNotifier,
              anchorFlyAnimationController: _anchorFlyAnimationController,
              anchorFlyOffsetAnimation: _anchorFlyOffsetAnimation,
              anchorScaleAnimation: _anchorScaleAnimation,
              originalAnchorSize: originalAnchorSize,
              scaledAnchorSize: scaledAnchorSize,
              anchorWidget: widget.config.anchorWidget,
            ),
            // 3. Render the actual overlay content once position is calculated.
            // Positioned menu content including scrollability
            // and sticky behavior.
            Positioned.fromRect(
              rect: overlayDisplayRect,
              child: GestureDetector(
                onTap: _reverseAnimateAndDissmiss,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  controller: _scrollController,
                  reverse: widget.config.reverseScroll,
                  physics: scrollPhysics,
                  child: SizedBox.fromSize(
                    size: contentTotalSize,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _currentScrollOffsetNotifier,
                      builder: (context, scrollOffset, _) {
                        return CustomMultiChildLayout(
                          delegate: _OverlayMenuLayoutDelegate(
                            anchorFinalXInDelegate:
                                anchorFinalPositionInLayout.dx,
                            anchorFinalYInDelegate:
                                anchorFinalPositionInLayout.dy,
                            anchorOriginalSize: originalAnchorSize,
                            anchorFinalSize: scaledAnchorSize,
                            topMenuAlignment: widget.config.topMenuAlignment,
                            bottomMenuAlignment:
                                widget.config.bottomMenuAlignment,
                            measuredTopMenuSize: measuredTopMenuSize,
                            measuredBottomMenuSize: measuredBottomMenuSize,
                            currentScrollOffset: scrollOffset,
                            requiresScrolling: requiresScrolling,
                            padding: widget.config.padding,
                            stickyMenuBehavior:
                                widget.config.stickyMenuBehavior,
                            contentTotalHeight: contentTotalSize.height,
                            overlayDisplayHeight: overlayDisplayRect.height,
                            reverseScroll: widget.config.reverseScroll,
                          ),
                          children: [
                            // The content anchor
                            LayoutId(
                              id: OverlaySlot.anchor,
                              child: ValueListenableBuilder<bool>(
                                key: _contentAnchorGlobalKey,
                                valueListenable: _isAnchorOffstageNotifier,
                                builder: (context, isOffstage, child) {
                                  return Offstage(
                                    offstage: isOffstage,
                                    child: child,
                                  );
                                },
                                child: AnimatedBuilder(
                                  animation: _anchorFlyAnimationController,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      alignment: Alignment.topLeft,
                                      scale: _anchorScaleAnimation.value,
                                      child: child,
                                    );
                                  },
                                  child: widget.config.anchorWidget,
                                ),
                              ),
                            ),
                            // Top menu widget
                            if (widget.config.topMenuWidget != null)
                              LayoutId(
                                id: OverlaySlot.top,
                                child: ScaleTransition(
                                  scale: _topMenuScaleAnimation,
                                  alignment: Alignment.bottomCenter,
                                  child: widget.config.topMenuWidget,
                                ),
                              ),
                            // Bottom menu widget
                            if (widget.config.bottomMenuWidget != null)
                              LayoutId(
                                id: OverlaySlot.bottom,
                                child: ScaleTransition(
                                  scale: _bottomMenuScaleAnimation,
                                  alignment: Alignment.topCenter,
                                  child: widget.config.bottomMenuWidget,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A hidden widget responsible for measuring the sizes of the top and
/// bottom menus.
class _MenuMeasurementWidgets extends StatelessWidget {
  const _MenuMeasurementWidgets({
    required this.topMenuWidget,
    required this.bottomMenuWidget,
    required this.onTopMenuMeasured,
    required this.onBottomMenuMeasured,
  });

  final Widget? topMenuWidget;
  final Widget? bottomMenuWidget;
  final ValueChanged<Size> onTopMenuMeasured;
  final ValueChanged<Size> onBottomMenuMeasured;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: OverflowBox(
        minWidth: 0,
        maxWidth: double.infinity,
        minHeight: 0,
        maxHeight: double.infinity,
        alignment: Alignment.topLeft,
        child: IgnorePointer(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (topMenuWidget != null)
                MeasureSize(
                  onResized: onTopMenuMeasured,
                  child: topMenuWidget!,
                ),
              if (bottomMenuWidget != null)
                MeasureSize(
                  onResized: onBottomMenuMeasured,
                  child: bottomMenuWidget!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The background overlay for the menu, handling blur, color,
/// and dismissal taps.
class _MenuBackgroundOverlay extends StatelessWidget {
  const _MenuBackgroundOverlay({
    required this.overlayVisibilityAnimation,
    required this.onDismiss,
    required this.backgroundColor,
    required this.backgroundOpacity,
    required this.blurSigmaX,
    required this.blurSigmaY,
  });

  final Animation<double> overlayVisibilityAnimation;
  final VoidCallback onDismiss;
  final Color backgroundColor;
  final double backgroundOpacity;
  final double blurSigmaX;
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

/// Handles the animated "flying" representation of the anchor widget.
class _FlyingAnchorAnimation extends StatelessWidget {
  const _FlyingAnchorAnimation({
    required this.isVisibleNotifier,
    required this.anchorFlyAnimationController,
    required this.anchorFlyOffsetAnimation,
    required this.anchorScaleAnimation,
    required this.originalAnchorSize,
    required this.scaledAnchorSize,
    required this.anchorWidget,
  });

  final ValueNotifier<bool> isVisibleNotifier;
  final AnimationController anchorFlyAnimationController;
  final Animation<Offset> anchorFlyOffsetAnimation;
  final Animation<double> anchorScaleAnimation;
  final Size originalAnchorSize;
  final Size scaledAnchorSize;
  final Widget anchorWidget;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isVisibleNotifier,
      builder: (context, isVisible, child) {
        if (!isVisible) {
          return const SizedBox.shrink(); // Hide when not visible
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

// Keep _OverlayMenuLayoutDelegate in the same file as OverlayMenuWidget
// as they are tightly coupled.
class _OverlayMenuLayoutDelegate extends MultiChildLayoutDelegate {
  _OverlayMenuLayoutDelegate({
    required this.anchorFinalXInDelegate,
    required this.anchorFinalYInDelegate,
    required this.anchorOriginalSize,
    required this.anchorFinalSize,
    required this.topMenuAlignment,
    required this.bottomMenuAlignment,
    required this.measuredTopMenuSize,
    required this.measuredBottomMenuSize,
    required this.currentScrollOffset,
    required this.stickyMenuBehavior,
    required this.contentTotalHeight,
    required this.overlayDisplayHeight,
    required this.requiresScrolling,
    required this.padding,
    required this.reverseScroll,
  });

  final double anchorFinalXInDelegate;
  final double anchorFinalYInDelegate;
  final Size anchorOriginalSize;
  final Size anchorFinalSize;
  final OverlayMenuHorizontalAlignment topMenuAlignment;
  final OverlayMenuHorizontalAlignment bottomMenuAlignment;
  final Size measuredTopMenuSize;
  final Size measuredBottomMenuSize;
  final StickyMenuBehavior stickyMenuBehavior;
  final double contentTotalHeight;
  final double overlayDisplayHeight;
  // -- Scrolling layout values
  final bool requiresScrolling;
  final EdgeInsets padding;
  final double currentScrollOffset;
  final bool reverseScroll;

  @override
  void performLayout(Size size) {
    if (hasChild(OverlaySlot.anchor)) {
      layoutChild(
        OverlaySlot.anchor,
        BoxConstraints.tight(anchorOriginalSize),
      );

      var anchorY = anchorFinalYInDelegate;
      if (requiresScrolling) {
        anchorY += padding.top;
      }

      positionChild(
        OverlaySlot.anchor,
        Offset(anchorFinalXInDelegate, anchorY),
      );
    }

    if (hasChild(OverlaySlot.top)) {
      final topConstraints = BoxConstraints.tight(measuredTopMenuSize);
      final topChildSize = layoutChild(OverlaySlot.top, topConstraints);
      final topX = _calculateAlignedX(
        anchorFinalXInDelegate,
        anchorFinalSize.width,
        topChildSize.width,
        topMenuAlignment,
      );

      var topY = anchorFinalYInDelegate - topChildSize.height;

      if (requiresScrolling) {
        if (stickyMenuBehavior == StickyMenuBehavior.top ||
            stickyMenuBehavior == StickyMenuBehavior.both) {
          if (!reverseScroll) {
            topY = currentScrollOffset + padding.top;
          } else {
            topY =
                contentTotalHeight -
                overlayDisplayHeight -
                currentScrollOffset +
                padding.top;
          }
        } else {
          topY = padding.top;
        }
      }

      positionChild(OverlaySlot.top, Offset(topX, topY));
    }

    if (hasChild(OverlaySlot.bottom)) {
      final bottomConstraints = BoxConstraints.tight(measuredBottomMenuSize);
      final bottomChildSize = layoutChild(
        OverlaySlot.bottom,
        bottomConstraints,
      );
      final bottomX = _calculateAlignedX(
        anchorFinalXInDelegate,
        anchorFinalSize.width,
        bottomChildSize.width,
        bottomMenuAlignment,
      );
      var bottomY = anchorFinalYInDelegate + anchorFinalSize.height;

      if (requiresScrolling) {
        if (stickyMenuBehavior == StickyMenuBehavior.bottom ||
            stickyMenuBehavior == StickyMenuBehavior.both) {
          if (!reverseScroll) {
            bottomY =
                currentScrollOffset +
                overlayDisplayHeight -
                bottomChildSize.height -
                padding.bottom;
          } else {
            bottomY =
                contentTotalHeight -
                bottomChildSize.height -
                currentScrollOffset -
                padding.bottom;
          }
        } else {
          bottomY =
              contentTotalHeight - bottomChildSize.height - padding.bottom;
        }
      }
      positionChild(OverlaySlot.bottom, Offset(bottomX, bottomY));
    }
  }

  double _calculateAlignedX(
    double anchorX,
    double anchorWidth,
    double childWidth,
    OverlayMenuHorizontalAlignment alignment,
  ) {
    switch (alignment) {
      case OverlayMenuHorizontalAlignment.left:
        return anchorX;
      case OverlayMenuHorizontalAlignment.center:
        return anchorX + (anchorWidth - childWidth) / 2;
      case OverlayMenuHorizontalAlignment.right:
        return anchorX + anchorWidth - childWidth;
    }
  }

  @override
  bool shouldRelayout(covariant _OverlayMenuLayoutDelegate oldDelegate) {
    return anchorFinalXInDelegate != oldDelegate.anchorFinalXInDelegate ||
        anchorFinalYInDelegate != oldDelegate.anchorFinalYInDelegate ||
        anchorOriginalSize != oldDelegate.anchorOriginalSize ||
        anchorFinalSize != oldDelegate.anchorFinalSize ||
        topMenuAlignment != oldDelegate.topMenuAlignment ||
        bottomMenuAlignment != oldDelegate.bottomMenuAlignment ||
        measuredTopMenuSize != oldDelegate.measuredTopMenuSize ||
        measuredBottomMenuSize != oldDelegate.measuredBottomMenuSize ||
        currentScrollOffset != oldDelegate.currentScrollOffset ||
        stickyMenuBehavior != oldDelegate.stickyMenuBehavior ||
        contentTotalHeight != oldDelegate.contentTotalHeight ||
        overlayDisplayHeight != oldDelegate.overlayDisplayHeight ||
        reverseScroll != oldDelegate.reverseScroll;
  }
}
