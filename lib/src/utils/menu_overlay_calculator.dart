import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/models/menu_position_result.dart';

/// {@template menu_position_calculator}
/// A calculator for the position of the overlay menu.
/// {@endtemplate}
class MenuPositionCalculator {
  /// {@macro menu_position_calculator}
  const MenuPositionCalculator({
    required this.screenSize,
    required this.padding,
    required this.topWidgetAlign,
    required this.bottomWidgetAlign,
  });

  /// The total size of the screen or the available area where the menu
  /// can be displayed.
  final Size screenSize;

  /// General padding for the screen edges, defining a "safe area"
  /// where the menu should ideally stay.
  final EdgeInsets padding;

  /// The horizontal alignment of the top menu widget relative to the
  /// anchor and bottom widget.
  final OverlayMenuHorizontalAlignment topWidgetAlign;

  /// The horizontal alignment of the bottom menu widget relative to the
  /// anchor and top widget.
  final OverlayMenuHorizontalAlignment bottomWidgetAlign;

  /// Calculates the position and sizing information for the overlay menu.
  ///
  /// This method determines the optimal screen placement for the menu,
  /// considering the anchor widget's position, the sizes of the top and
  /// bottom menu widgets, screen boundaries, and padding. It also
  /// indicates whether the menu content requires scrolling.
  ///
  /// Parameters:
  ///   - [anchorRect]: The global [Rect] of the original anchor widget
  ///     on the screen.
  ///   - [topWidgetSize]: The [Size] of the custom widget that appears
  ///     above the duplicated anchor.
  ///   - [bottomWidgetSize]: The [Size] of the custom widget that appears
  ///     below the duplicated anchor.
  ///
  /// Returns a [MenuPositionResult] containing all calculated
  /// layout properties.
  MenuPositionResult calculate({
    required Rect anchorRect,
    Size topWidgetSize = Size.zero,
    Size bottomWidgetSize = Size.zero,
  }) {
    // 1. Determine available screen safe area
    final safeScreenWidth = screenSize.width - padding.horizontal;
    final safeScreenHeight = screenSize.height - padding.vertical;

    // 2. Calculate scaled anchor size based on horizontal safe width
    final anchorOriginalWidth = anchorRect.width;
    final anchorOriginalHeight = anchorRect.height;
    var scaledAnchorSize = anchorRect.size;

    if (anchorOriginalWidth > safeScreenWidth) {
      // If original anchor width overflows, scale it down proportionally
      final scaleFactor = safeScreenWidth / anchorOriginalWidth;
      scaledAnchorSize = Size(
        safeScreenWidth,
        anchorOriginalHeight * scaleFactor,
      );
    }

    // 3. Extract heights (using scaled anchor height) and calculate
    // total content height
    final topHeight = topWidgetSize.height;
    final bottomHeight = bottomWidgetSize.height;
    var overlayContentHeight =
        topHeight + scaledAnchorSize.height + bottomHeight;

    // 4. Extract widths (using scaled anchor width) and determine the overall
    // width of the overlay
    final scaledAnchorWidth = scaledAnchorSize.width;
    final topWidth = topWidgetSize.width;
    final bottomWidth = bottomWidgetSize.width;

    // Initialize overlayContentWidth to the maximum of component widths
    var overlayContentWidth = [
      scaledAnchorWidth, // Use scaled width
      topWidth,
      bottomWidth,
    ].reduce(math.max);

    // Adjust overlayContentWidth if top and bottom widgets have different
    // non-center alignments. This accounts for horizontal spread.
    if (topWidgetAlign != bottomWidgetAlign &&
        topWidgetAlign != OverlayMenuHorizontalAlignment.center &&
        bottomWidgetAlign != OverlayMenuHorizontalAlignment.center) {
      final extraTopWidth = (topWidth - scaledAnchorWidth).clamp(
        0.0,
        double.infinity,
      );
      final extraBottomWidth = (bottomWidth - scaledAnchorWidth).clamp(
        0.0,
        double.infinity,
      );
      overlayContentWidth =
          scaledAnchorWidth + math.max(extraTopWidth, extraBottomWidth);
    }

    // 5. Check if the menu content requires scrolling
    final requiresScrolling = overlayContentHeight > safeScreenHeight;

    // Ensure overlayContentWidth never exceeds safeScreenWidth
    overlayContentWidth = overlayContentWidth.clamp(0.0, safeScreenWidth);

    Offset overlayGlobalOrigin;
    double overlayDisplayHeight;

    // Calculate anchor's final resting X position within the overlay's width.
    final anchorFinalXInOverlay = resolveAnchorX(
      scaledAnchorWidth, // Use scaled width
      topWidth,
      bottomWidth,
      overlayContentWidth,
    );

    // Calculate anchor's final resting Y position within the overlay's height.
    final anchorFinalYInOverlay = topHeight;

    // 6. Positioning logic based on whether scrolling is required
    if (requiresScrolling) {
      // If menu is too tall, it will be scrollable,
      // take all height of the screen
      overlayGlobalOrigin = Offset(
        anchorRect.left.clamp(
          padding.left,
          screenSize.width - padding.right - overlayContentWidth,
        ),
        0, // Position at the top of the screen
      );
      overlayDisplayHeight = screenSize.height;
      // Add padding to the content height
      overlayContentHeight += padding.vertical;
    } else {
      // If the menu fits on screen, find the optimal vertical position.
      overlayDisplayHeight =
          overlayContentHeight; // Actual height it will take.

      // Calculate the ideal top Y for the overlay, with top widget
      // above anchor.
      final idealOverlayTopY = anchorRect.top - topHeight;

      // Define the min and max possible Y positions for the overlay's top-left
      // corner to ensure the entire menu fits within the screen's padded area.
      final minOverlayY = padding.top;
      final maxOverlayY =
          screenSize.height - padding.bottom - overlayContentHeight;

      // Clamp the overlay's Y position within safe vertical boundaries.
      overlayGlobalOrigin = Offset(
        anchorRect.left.clamp(
          padding.left,
          screenSize.width - padding.right - overlayContentWidth,
        ),
        idealOverlayTopY.clamp(minOverlayY, maxOverlayY),
      );
    }

    // Create the final result object with all calculated properties.
    return MenuPositionResult(
      scaledAnchorSize: scaledAnchorSize,
      overlayDisplayRect:
          overlayGlobalOrigin & Size(overlayContentWidth, overlayDisplayHeight),
      requiresScrolling: requiresScrolling,
      contentTotalSize: Size(overlayContentWidth, overlayContentHeight),
      anchorOffsetInOverlayContent: Offset(
        anchorFinalXInOverlay,
        anchorFinalYInOverlay,
      ),
    );
  }

  /// Resolves the horizontal (X) position of the anchor widget relative to the
  /// left edge of the overall overlay, considering the horizontal alignments
  /// of the top and bottom menu widgets.
  @visibleForTesting
  double resolveAnchorX(
    double scaledAnchorWidth,
    double topWidth,
    double bottomWidth,
    double overlayContentWidth,
  ) {
    double xFromTop = 0;
    if (topWidth > 0) {
      if (topWidgetAlign == OverlayMenuHorizontalAlignment.right) {
        xFromTop = topWidth - scaledAnchorWidth;
      } else if (topWidgetAlign == OverlayMenuHorizontalAlignment.center) {
        xFromTop = (topWidth - scaledAnchorWidth) / 2;
      }
    }

    double xFromBottom = 0;
    if (bottomWidth > 0) {
      if (bottomWidgetAlign == OverlayMenuHorizontalAlignment.right) {
        xFromBottom = bottomWidth - scaledAnchorWidth;
      } else if (bottomWidgetAlign == OverlayMenuHorizontalAlignment.center) {
        xFromBottom = (bottomWidth - scaledAnchorWidth) / 2;
      }
    }

    // The anchor's X should be the maximum of these offsets to ensure
    // it accommodates the left-most edge requirements of all components
    // when aligned.
    return math.max(0, math.max(xFromTop, xFromBottom));
  }
}
