import 'package:flutter/widgets.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/enums/overlay_slot.dart';
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart';

/// {@template overlay_menu_layout_delegate}
/// A [MultiChildLayoutDelegate] that handles the layout of the overlay menu
/// components: top menu, anchor, and bottom menu.
///
/// This delegate positions each component according to the calculated
/// positions, handles sticky menu behavior during scrolling, and manages
/// alignment of menu widgets relative to the anchor.
/// {@endtemplate}
class OverlayMenuLayoutDelegate extends MultiChildLayoutDelegate {
  /// {@macro overlay_menu_layout_delegate}
  OverlayMenuLayoutDelegate({
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

  /// The final X position of the anchor within the overlay content.
  final double anchorFinalXInDelegate;

  /// The final Y position of the anchor within the overlay content.
  final double anchorFinalYInDelegate;

  /// The original size of the anchor before any scaling.
  final Size anchorOriginalSize;

  /// The final size of the anchor after scaling to fit within bounds.
  final Size anchorFinalSize;

  /// The horizontal alignment of the top menu relative to the anchor.
  final OverlayMenuHorizontalAlignment topMenuAlignment;

  /// The horizontal alignment of the bottom menu relative to the anchor.
  final OverlayMenuHorizontalAlignment bottomMenuAlignment;

  /// The measured size of the top menu widget.
  final Size measuredTopMenuSize;

  /// The measured size of the bottom menu widget.
  final Size measuredBottomMenuSize;

  /// The current scroll offset of the scrollable content.
  final double currentScrollOffset;

  /// The sticky behavior for menus during scrolling.
  final StickyMenuBehavior stickyMenuBehavior;

  /// The total height of all content (top + anchor + bottom).
  final double contentTotalHeight;

  /// The display height of the overlay viewport.
  final double overlayDisplayHeight;

  /// Whether the content requires scrolling.
  final bool requiresScrolling;

  /// The padding/safe area insets.
  final EdgeInsets padding;

  /// Whether the scroll direction is reversed.
  final bool reverseScroll;

  @override
  void performLayout(Size size) {
    _layoutAnchor();
    _layoutTopMenu();
    _layoutBottomMenu();
  }

  void _layoutAnchor() {
    if (!hasChild(OverlaySlot.anchor)) return;

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

  void _layoutTopMenu() {
    if (!hasChild(OverlaySlot.top)) return;

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

  void _layoutBottomMenu() {
    if (!hasChild(OverlaySlot.bottom)) return;

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
        bottomY = contentTotalHeight - bottomChildSize.height - padding.bottom;
      }
    }
    positionChild(OverlaySlot.bottom, Offset(bottomX, bottomY));
  }

  /// Calculates the aligned X position for a child widget.
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
  bool shouldRelayout(covariant OverlayMenuLayoutDelegate oldDelegate) {
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
