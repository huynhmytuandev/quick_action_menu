import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/utils/menu_overlay_calculator.dart';

void main() {
  group('MenuPositionCalculator', () {
    const screenSize = Size(400, 800);
    const defaultPadding = EdgeInsets.all(16);

    MenuPositionCalculator createCalculator({
      Size size = screenSize,
      EdgeInsets padding = defaultPadding,
      OverlayMenuHorizontalAlignment topAlign =
          OverlayMenuHorizontalAlignment.center,
      OverlayMenuHorizontalAlignment bottomAlign =
          OverlayMenuHorizontalAlignment.center,
    }) {
      return MenuPositionCalculator(
        screenSize: size,
        padding: padding,
        topWidgetAlign: topAlign,
        bottomWidgetAlign: bottomAlign,
      );
    }

    group('calculate', () {
      test('returns correct result for centered anchor', () {
        final calculator = createCalculator();
        const anchorRect = Rect.fromLTWH(100, 300, 200, 50);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: const Size(150, 40),
          bottomWidgetSize: const Size(150, 40),
        );

        expect(result.scaledAnchorSize, equals(const Size(200, 50)));
        expect(result.requiresScrolling, isFalse);
      });

      test('scales anchor when it exceeds safe width', () {
        final calculator = createCalculator();
        // Anchor wider than safe area (400 - 32 = 368)
        const anchorRect = Rect.fromLTWH(0, 300, 500, 100);

        final result = calculator.calculate(anchorRect: anchorRect);

        expect(result.scaledAnchorSize.width, lessThanOrEqualTo(368));
        // Height should be proportionally scaled
        expect(
          result.scaledAnchorSize.height,
          lessThan(100),
        );
      });

      test('sets requiresScrolling when content exceeds safe height', () {
        final calculator = createCalculator();
        const anchorRect = Rect.fromLTWH(100, 300, 200, 50);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: const Size(150, 400),
          bottomWidgetSize: const Size(150, 400),
        );

        // Total height: 400 + 50 + 400 = 850
        // Safe height: 800 - 32 = 768
        expect(result.requiresScrolling, isTrue);
      });

      test('does not require scrolling when content fits', () {
        final calculator = createCalculator();
        const anchorRect = Rect.fromLTWH(100, 300, 200, 50);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: const Size(150, 100),
          bottomWidgetSize: const Size(150, 100),
        );

        // Total height: 100 + 50 + 100 = 250
        // Safe height: 800 - 32 = 768
        expect(result.requiresScrolling, isFalse);
      });

      test('handles zero-sized menus', () {
        final calculator = createCalculator();
        const anchorRect = Rect.fromLTWH(100, 300, 200, 50);

        final result = calculator.calculate(anchorRect: anchorRect);

        expect(result.scaledAnchorSize, equals(const Size(200, 50)));
        expect(result.contentTotalSize.height, equals(50));
      });

      test('clamps overlay position within screen bounds', () {
        final calculator = createCalculator();
        // Anchor near top-left corner
        const anchorRect = Rect.fromLTWH(0, 10, 200, 50);

        final result = calculator.calculate(
          anchorRect: anchorRect,
          topWidgetSize: const Size(150, 100),
        );

        // Overlay should be clamped to at least padding.left
        expect(result.overlayDisplayRect.left, greaterThanOrEqualTo(16));
      });
    });

    group('resolveAnchorX', () {
      test('returns 0 for left alignment', () {
        final calculator = createCalculator(
          topAlign: OverlayMenuHorizontalAlignment.left,
          bottomAlign: OverlayMenuHorizontalAlignment.left,
        );

        final x = calculator.resolveAnchorX(
          200, // scaledAnchorWidth
          150, // topWidth
          150, // bottomWidth
          200, // overlayContentWidth
        );

        expect(x, equals(0));
      });

      test('returns centered position for center alignment', () {
        // Using default center alignment
        final calculator = createCalculator();

        final x = calculator.resolveAnchorX(
          100, // scaledAnchorWidth
          200, // topWidth (wider than anchor)
          200, // bottomWidth
          200, // overlayContentWidth
        );

        // (200 - 100) / 2 = 50
        expect(x, equals(50));
      });

      test('returns right-aligned position for right alignment', () {
        final calculator = createCalculator(
          topAlign: OverlayMenuHorizontalAlignment.right,
          bottomAlign: OverlayMenuHorizontalAlignment.right,
        );

        final x = calculator.resolveAnchorX(
          100, // scaledAnchorWidth
          200, // topWidth (wider than anchor)
          200, // bottomWidth
          200, // overlayContentWidth
        );

        // 200 - 100 = 100
        expect(x, equals(100));
      });

      test('handles mixed alignments', () {
        final calculator = createCalculator(
          topAlign: OverlayMenuHorizontalAlignment.left,
          bottomAlign: OverlayMenuHorizontalAlignment.right,
        );

        final x = calculator.resolveAnchorX(
          100, // scaledAnchorWidth
          150, // topWidth
          150, // bottomWidth
          200, // overlayContentWidth
        );

        // Max of left (0) and right (150 - 100 = 50)
        expect(x, equals(50));
      });
    });
  });
}
