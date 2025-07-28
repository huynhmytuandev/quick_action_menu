import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart'; //
import 'package:quick_action_menu/src/utils/menu_overlay_calculator.dart'; //

void main() {
  group('MenuPositionCalculator', () {
    // Helper function to create a calculator with common defaults
    MenuPositionCalculator createCalculator({
      Size screenSize = const Size(400, 800),
      EdgeInsets padding = EdgeInsets.zero,
      OverlayMenuHorizontalAlignment topWidgetAlign =
          OverlayMenuHorizontalAlignment.center,
      OverlayMenuHorizontalAlignment bottomWidgetAlign =
          OverlayMenuHorizontalAlignment.center,
    }) {
      return MenuPositionCalculator(
        screenSize: screenSize,
        padding: padding,
        topWidgetAlign: topWidgetAlign,
        bottomWidgetAlign: bottomWidgetAlign,
      );
    }

    // Helper to compare Rects with a small tolerance for doubles
    void expectRectEquals(
      Rect actual,
      Rect expected, {
      double tolerance = 1e-9,
    }) {
      expect(actual.left, closeTo(expected.left, tolerance));
      expect(actual.top, closeTo(expected.top, tolerance));
      expect(actual.width, closeTo(expected.width, tolerance));
      expect(actual.height, closeTo(expected.height, tolerance));
    }

    // Helper to compare Sizes with a small tolerance
    void expectSizeEquals(
      Size actual,
      Size expected, {
      double tolerance = 1e-9,
    }) {
      expect(actual.width, closeTo(expected.width, tolerance));
      expect(actual.height, closeTo(expected.height, tolerance));
    }

    // Helper to compare Offsets with a small tolerance
    void expectOffsetEquals(
      Offset actual,
      Offset expected, {
      double tolerance = 1e-9,
    }) {
      expect(actual.dx, closeTo(expected.dx, tolerance));
      expect(actual.dy, closeTo(expected.dy, tolerance));
    }

    test(
      'should calculate position correctly when menus fit on screen without padding',
      () {
        final calculator = createCalculator();
        const anchorRect = Rect.fromLTWH(100, 300, 50, 50);
        const topMenuSize = Size(100, 40);
        const bottomMenuSize = Size(120, 60);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: topMenuSize,
          bottomWidgetSize: bottomMenuSize,
        );

        // Expected values:
        // scaledAnchorSize: 50x50 (no scaling needed)
        // contentTotalHeight: 40 (top) + 50 (anchor) + 60 (bottom) = 150
        // overlayContentWidth: max(50, 100, 120) = 120
        // requiresScrolling: false (150 < 800)
        // anchorFinalXInOverlay: (120 - 50) / 2 = 35 (center aligned to max width)
        // anchorFinalYInOverlay: 40 (top menu height)
        // idealOverlayTopY: 300 (anchor.top) - 40 (topMenuHeight) = 260
        // overlayGlobalOrigin: (100 (anchor.left), 260 (ideal clamped))
        // overlayDisplayRect: Rect.fromLTWH(100, 260, 120, 150)

        expectSizeEquals(result.scaledAnchorSize, const Size(50, 50));
        expectOffsetEquals(
          result.anchorOffsetInOverlayContent,
          const Offset(35, 40),
        );
        expect(result.requiresScrolling, isFalse);
        expectSizeEquals(result.contentTotalSize, const Size(120, 150));
        expectRectEquals(
          result.overlayDisplayRect,
          const Rect.fromLTWH(100, 260, 120, 150),
        );
      },
    );

    test(
      'should handle anchor scaling when anchor width exceeds safe screen width',
      () {
        final calculator = createCalculator(
          screenSize: const Size(200, 800),
        ); // Narrow screen
        const anchorRect = Rect.fromLTWH(
          50,
          300,
          150,
          50,
        ); // Anchor wider than screen
        const topMenuSize = Size(50, 40);
        const bottomMenuSize = Size(50, 60);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: topMenuSize,
          bottomWidgetSize: bottomMenuSize,
        );

        // Expected values:
        // safeScreenWidth: 200
        // anchorOriginalWidth: 150, scaledAnchorSize: 150 (not > 200) - wait, if anchorOriginalWidth > safeScreenWidth, scale it down. Here it is not.
        // Let's re-evaluate logic: anchorOriginalWidth is 150, safeScreenWidth is 200. No scaling should occur.
        // If anchor was 250, safe 200, then scaledAnchorWidth would be 200.
        // Re-testing with anchorRect width = 250 to ensure scaling.

        const anchorRect2 = Rect.fromLTWH(
          50,
          300,
          250,
          50,
        ); // Anchor wider than safeScreen
        final result2 = calculator.calculate(
          anchorRect: anchorRect2,
          topWidgetSize: topMenuSize,
          bottomWidgetSize: bottomMenuSize,
        );

        // scaledAnchorSize: (safeScreenWidth / originalWidth) * originalHeight
        // scaleFactor = 200 / 250 = 0.8
        // scaledAnchorWidth = 200
        // scaledAnchorHeight = 50 * 0.8 = 40
        expectSizeEquals(result2.scaledAnchorSize, const Size(200, 40));
        expect(
          result2.requiresScrolling,
          isFalse,
        ); // Total height: 40 (top) + 40 (anchor) + 60 (bottom) = 140. 140 < 800
        expectSizeEquals(
          result2.contentTotalSize,
          const Size(200, 140),
        ); // Max width among 200, 50, 50 is 200
        // Anchor X in overlay: (overlayContentWidth - scaledAnchorWidth) / 2 = (200 - 200) / 2 = 0
        expectOffsetEquals(
          result2.anchorOffsetInOverlayContent,
          const Offset(0, 40),
        );
        // Overlay global origin: clamped anchor.left (50) becomes 0 (padding.left). Top: idealOverlayTopY = 300 - 40 = 260.
        expectRectEquals(
          result2.overlayDisplayRect,
          const Rect.fromLTWH(0, 260, 200, 140),
        );
      },
    );

    test('should position overlay with padding', () {
      final calculator = createCalculator(
        padding: const EdgeInsets.all(20),
      );
      const anchorRect = Rect.fromLTWH(
        50,
        100,
        50,
        50,
      ); // Anchor close to top-left padding
      const topMenuSize = Size(100, 40);
      const bottomMenuSize = Size(120, 60);

      final result = calculator.calculate(
        anchorRect: anchorRect,
        topWidgetSize: topMenuSize,
        bottomWidgetSize: bottomMenuSize,
      );

      // Expected values:
      // safeScreenWidth: 400 - 40 = 360
      // safeScreenHeight: 800 - 40 = 760
      // contentTotalHeight: 150
      // overlayContentWidth: 120
      // requiresScrolling: false
      // idealOverlayTopY: 100 (anchor.top) - 40 (topMenuHeight) = 60
      // minOverlayY: 20 (padding.top)
      // maxOverlayY: 800 - 20 (padding.bottom) - 150 (contentTotalHeight) = 630
      // Clamped idealOverlayTopY (60) within [20, 630] -> 60
      // Clamped anchor.left (50) within [20, 400-20-120=260] -> 50

      expectRectEquals(
        result.overlayDisplayRect,
        const Rect.fromLTWH(50, 60, 120, 150),
      );
      expect(result.requiresScrolling, isFalse);
    });

    test(
      'should indicate requiresScrolling and position at top when content is too tall',
      () {
        final calculator = createCalculator(
          screenSize: const Size(400, 400), // Smaller screen height
          padding: const EdgeInsets.all(20),
        );
        const anchorRect = Rect.fromLTWH(100, 100, 50, 50);
        const topMenuSize = Size(100, 150); // Large top menu
        const bottomMenuSize = Size(120, 200); // Large bottom menu

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: topMenuSize,
          bottomWidgetSize: bottomMenuSize,
        );

        // Expected values:
        // safeScreenWidth: 400 - 40 = 360
        // safeScreenHeight: 400 - 40 = 360
        // contentTotalHeight: 150 (top) + 50 (anchor) + 200 (bottom) = 400
        // overlayContentWidth: max(50, 100, 120) = 120
        // requiresScrolling: true (400 > 360)
        // overlayGlobalOrigin: (clamped anchor.left, padding.top) = (100, 20)
        // overlayDisplayHeight: safeScreenHeight = 360

        expect(result.requiresScrolling, isTrue);
        expectSizeEquals(result.contentTotalSize, const Size(120, 400));
        expectRectEquals(
          result.overlayDisplayRect,
          const Rect.fromLTWH(100, 20, 120, 360),
        );
      },
    );

    group('resolveAnchorX', () {
      test('should center anchor when all are center aligned or default', () {
        final calculator = createCalculator();
        // Anchor 50, Top 100, Bottom 120. Overall width 120.
        // Anchor should be at (120 - 50) / 2 = 35.
        expect(
          calculator.resolveAnchorX(50, 100, 120, 120),
          closeTo(35, 1e-9),
        );
      });

      test('should align anchor left when top/bottom are left aligned', () {
        final calculator = createCalculator(
          topWidgetAlign: OverlayMenuHorizontalAlignment.left,
          bottomWidgetAlign: OverlayMenuHorizontalAlignment.left,
        );
        // Anchor 50, Top 100, Bottom 120. Overall width 120.
        // Left alignment means anchor.left == 0 relative to component's left.
        // Here, it means anchor aligns with the left edge of the largest component,
        // so anchor's X relative to overlay starts at 0.
        expect(
          calculator.resolveAnchorX(50, 100, 120, 120),
          closeTo(0, 1e-9),
        );
      });

      test('should align anchor right when top/bottom are right aligned', () {
        final calculator = createCalculator(
          topWidgetAlign: OverlayMenuHorizontalAlignment.right,
          bottomWidgetAlign: OverlayMenuHorizontalAlignment.right,
        );
        // Anchor 50, Top 100, Bottom 120. Overall width 120.
        // Right alignment for Top (100): xFromTop = 100 - 50 = 50
        // Right alignment for Bottom (120): xFromBottom = 120 - 50 = 70
        // max(50, 70) = 70.
        expect(
          calculator.resolveAnchorX(50, 100, 120, 120),
          closeTo(70, 1e-9),
        );
      });

      test('should handle mixed alignments correctly for anchor X', () {
        // Scenario 1: Top left, Bottom center
        // Anchor 50, Top 100 (left aligned), Bottom 120 (center aligned).
        // xFromTop = 0 (left align)
        // xFromBottom = (120 - 50) / 2 = 35 (center align)
        // max(0, 35) = 35
        final calculator1 = createCalculator(
          topWidgetAlign: OverlayMenuHorizontalAlignment.left,
        );
        expect(
          calculator1.resolveAnchorX(50, 100, 120, 120),
          closeTo(35, 1e-9),
        );

        // Scenario 2: Top center, Bottom right
        // Anchor 50, Top 100 (center aligned), Bottom 120 (right aligned).
        // xFromTop = (100 - 50) / 2 = 25 (center align)
        // xFromBottom = (120 - 50) = 70 (right align)
        // max(25, 70) = 70
        final calculator2 = createCalculator(
          bottomWidgetAlign: OverlayMenuHorizontalAlignment.right,
        );
        expect(
          calculator2.resolveAnchorX(50, 100, 120, 120),
          closeTo(70, 1e-9),
        );

        // Scenario 3: Top right, Bottom left
        // Anchor 50, Top 100 (right aligned), Bottom 120 (left aligned).
        // xFromTop = (100 - 50) = 50 (right align)
        // xFromBottom = 0 (left align)
        // max(50, 0) = 50
        final calculator3 = createCalculator(
          topWidgetAlign: OverlayMenuHorizontalAlignment.right,
          bottomWidgetAlign: OverlayMenuHorizontalAlignment.left,
        );
        expect(
          calculator3.resolveAnchorX(50, 100, 120, 120),
          closeTo(50, 1e-9),
        );
      });

      test(
        'should calculate overlayContentWidth correctly with horizontal spread',
        () {
          // Top right (100 width), Bottom left (120 width), Anchor (50 width)
          // extraTopWidth = (100 - 50) = 50
          // extraBottomWidth = (120 - 50) = 70
          // overlayContentWidth = scaledAnchorWidth + max(extraTopWidth, extraBottomWidth)
          // = 50 + max(50, 70) = 50 + 70 = 120
          final calculator = createCalculator(
            topWidgetAlign: OverlayMenuHorizontalAlignment.right,
            bottomWidgetAlign: OverlayMenuHorizontalAlignment.left,
          );

          final result = calculator.calculate(
            anchorRect: const Rect.fromLTWH(100, 100, 50, 50),
            topWidgetSize: const Size(100, 40),
            bottomWidgetSize: const Size(120, 60),
          );

          // This test primarily checks overlayContentWidth logic.
          // It's covered by the total result check, but this is explicit.
          expectSizeEquals(
            result.contentTotalSize,
            const Size(120, 150),
          ); // Width should be 120
        },
      );
    });

    test('should handle zero sized menu widgets', () {
      final calculator = createCalculator();
      const anchorRect = Rect.fromLTWH(100, 300, 50, 50);

      // Only anchor
      final result1 = calculator.calculate(anchorRect: anchorRect);
      expectSizeEquals(result1.scaledAnchorSize, const Size(50, 50));
      expectOffsetEquals(
        result1.anchorOffsetInOverlayContent,
        const Offset(0, 0),
      );
      expect(result1.requiresScrolling, isFalse);
      expectSizeEquals(result1.contentTotalSize, const Size(50, 50));
      expectRectEquals(
        result1.overlayDisplayRect,
        const Rect.fromLTWH(100, 300, 50, 50),
      );

      // Only top menu
      final result2 = calculator.calculate(
        anchorRect: anchorRect,
        topWidgetSize: const Size(100, 40),
      );
      expectSizeEquals(result2.scaledAnchorSize, const Size(50, 50));
      expectOffsetEquals(
        result2.anchorOffsetInOverlayContent,
        const Offset(25, 40),
      ); // (100-50)/2 = 25
      expect(result2.requiresScrolling, isFalse);
      expectSizeEquals(result2.contentTotalSize, const Size(100, 90));
      expectRectEquals(
        result2.overlayDisplayRect,
        const Rect.fromLTWH(100, 260, 100, 90),
      ); // 300-40=260

      // Only bottom menu
      final result3 = calculator.calculate(
        anchorRect: anchorRect,
        bottomWidgetSize: const Size(120, 60),
      );
      expectSizeEquals(result3.scaledAnchorSize, const Size(50, 50));
      expectOffsetEquals(
        result3.anchorOffsetInOverlayContent,
        const Offset(35, 0),
      ); // (120-50)/2 = 35
      expect(result3.requiresScrolling, isFalse);
      expectSizeEquals(result3.contentTotalSize, const Size(120, 110));
      expectRectEquals(
        result3.overlayDisplayRect,
        const Rect.fromLTWH(100, 300, 120, 110),
      );
    });

    test('should clamp overlayGlobalOrigin X to screen bounds with padding', () {
      final calculator = createCalculator(
        padding: const EdgeInsets.all(20),
      );

      // Anchor far left, menu wider than available left space
      const anchorRectLeft = Rect.fromLTWH(10, 300, 50, 50);
      const topMenuSize = Size(150, 40); // Will make overall width 150
      const bottomMenuSize = Size(120, 60);

      final resultLeft = calculator.calculate(
        anchorRect: anchorRectLeft,
        topWidgetSize: topMenuSize,
        bottomWidgetSize: bottomMenuSize,
      );

      // safeScreenWidth: 360
      // overlayContentWidth: 150
      // anchorRectLeft.left: 10
      // clamped anchor.left: math.max(padding.left, anchorRectLeft.left)
      // = math.max(20, 10) = 20
      // This clamping applies before the max_x_position check, so the overall left will be 20.
      expect(resultLeft.overlayDisplayRect.left, closeTo(20, 1e-9));

      // Anchor far right, menu wider than available right space
      const anchorRectRight = Rect.fromLTWH(380, 300, 50, 50);
      final resultRight = calculator.calculate(
        anchorRect: anchorRectRight,
        topWidgetSize: topMenuSize,
        bottomWidgetSize: bottomMenuSize,
      );
      // Expected right edge of overlay is screen.width - padding.right
      // -> overlayGlobalOrigin.left = screenSize.width - padding.right - overlayContentWidth
      // -> 400 - 20 - 150 = 230
      expect(resultRight.overlayDisplayRect.left, closeTo(230, 1e-9));
    });

    test(
      'should ensure overlayContentWidth does not exceed safeScreenWidth',
      () {
        final calculator = createCalculator(
          screenSize: const Size(200, 800), // Narrow screen
          padding: const EdgeInsets.all(10),
        );
        const anchorRect = Rect.fromLTWH(50, 300, 50, 50);
        const topMenuSize = Size(300, 40); // Wider than safeScreenWidth
        const bottomMenuSize = Size(250, 60);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: topMenuSize,
          bottomWidgetSize: bottomMenuSize,
        );

        // safeScreenWidth: 200 - 20 = 180
        // initial overlayContentWidth: max(50, 300, 250) = 300
        // clamped overlayContentWidth: 300.clamp(0, 180) = 180
        expect(result.overlayDisplayRect.width, closeTo(180, 1e-9));
        expect(result.contentTotalSize.width, closeTo(180, 1e-9));
      },
    );
  });
}
