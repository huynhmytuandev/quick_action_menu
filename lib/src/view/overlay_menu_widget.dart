import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show SchedulerBinding;
import 'package:quick_action_menu/src/delegates/overlay_menu_layout_delegate.dart';
import 'package:quick_action_menu/src/enums/overlay_slot.dart';
import 'package:quick_action_menu/src/models/menu_position_result.dart';
import 'package:quick_action_menu/src/models/overlay_menu_config.dart';
import 'package:quick_action_menu/src/utils/menu_overlay_calculator.dart';
import 'package:quick_action_menu/src/view/components/flying_anchor_animation.dart';
import 'package:quick_action_menu/src/view/components/menu_background_overlay.dart';
import 'package:quick_action_menu/src/view/components/menu_measurement_widgets.dart';

/// A widget that displays a quick action menu as an overlay relative to
/// an anchor widget.
class OverlayMenuWidget extends StatefulWidget {
  /// Creates an [OverlayMenuWidget] with the given [config].
  const OverlayMenuWidget({required this.config, super.key});

  /// The configuration for this overlay menu.
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

    _safeSetState(() {
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
      _safeSetState(() {
        _measuredTopMenuSize = size;
      });
      _computeMenuLayout();
    }
  }

  /// Callback when the bottom menu widget's size is measured.
  void _onBottomMenuMeasured(Size size) {
    if (_measuredBottomMenuSize == null || _measuredBottomMenuSize != size) {
      _safeSetState(() {
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

    _safeSetState(() {
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

      _safeSetState(() {
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
    if (mounted) {
      
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
      _safeSetState(() {});
    }
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

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
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
              child: MenuMeasurementWidgets(
                topMenuWidget: widget.config.topMenuWidget,
                bottomMenuWidget: widget.config.bottomMenuWidget,
                onTopMenuMeasured: _onTopMenuMeasured,
                onBottomMenuMeasured: _onBottomMenuMeasured,
              ),
          ),
          if (_positionResult != null) ...[
            // 1. Background dismissal area with blur and color overlay.
            MenuBackgroundOverlay(
              overlayVisibilityAnimation: _overlayVisibilityController,
              onDismiss: _reverseAnimateAndDissmiss,
              backgroundColor: widget.config.overlayBackgroundColor,
              backgroundOpacity: widget.config.overlayBackgroundOpacity,
              blurSigmaX: widget.config.backdropBlurSigmaX,
              blurSigmaY: widget.config.backdropBlurSigmaY,
            ),
            // 2. The flying anchor animation.
            FlyingAnchorAnimation(
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
                          delegate: OverlayMenuLayoutDelegate(
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
