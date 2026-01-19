import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/models/menu_position_result.dart';

void main() {
  group('MenuPositionResult', () {
    const defaultResult = MenuPositionResult(
      overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
      scaledAnchorSize: Size(180, 50),
      anchorOffsetInOverlayContent: Offset(10, 40),
      requiresScrolling: false,
      contentTotalSize: Size(200, 290),
    );

    group('constructor', () {
      test('creates instance with all required fields', () {
        expect(defaultResult.overlayDisplayRect.left, equals(50));
        expect(defaultResult.overlayDisplayRect.top, equals(100));
        expect(defaultResult.overlayDisplayRect.width, equals(200));
        expect(defaultResult.overlayDisplayRect.height, equals(300));
        expect(defaultResult.scaledAnchorSize, equals(const Size(180, 50)));
        expect(
          defaultResult.anchorOffsetInOverlayContent,
          equals(const Offset(10, 40)),
        );
        expect(defaultResult.requiresScrolling, isFalse);
        expect(defaultResult.contentTotalSize, equals(const Size(200, 290)));
      });
    });

    group('equality', () {
      test('equals itself', () {
        expect(defaultResult == defaultResult, isTrue);
      });

      test('equals identical instance', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(180, 50),
          anchorOffsetInOverlayContent: Offset(10, 40),
          requiresScrolling: false,
          contentTotalSize: Size(200, 290),
        );

        expect(defaultResult == other, isTrue);
      });

      test('not equals when scaledAnchorSize differs', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(190, 50), // Different
          anchorOffsetInOverlayContent: Offset(10, 40),
          requiresScrolling: false,
          contentTotalSize: Size(200, 290),
        );

        expect(defaultResult == other, isFalse);
      });

      test('not equals when anchorOffsetInOverlayContent differs', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(180, 50),
          anchorOffsetInOverlayContent: Offset(20, 40), // Different
          requiresScrolling: false,
          contentTotalSize: Size(200, 290),
        );

        expect(defaultResult == other, isFalse);
      });

      test('not equals when requiresScrolling differs', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(180, 50),
          anchorOffsetInOverlayContent: Offset(10, 40),
          requiresScrolling: true, // Different
          contentTotalSize: Size(200, 290),
        );

        expect(defaultResult == other, isFalse);
      });

      test('not equals when contentTotalSize differs', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(180, 50),
          anchorOffsetInOverlayContent: Offset(10, 40),
          requiresScrolling: false,
          contentTotalSize: Size(200, 300), // Different
        );

        expect(defaultResult == other, isFalse);
      });

      test('not equals different type', () {
        // Using Object to test equality with different type
        const Object other = 'not a MenuPositionResult';
        expect(defaultResult == other, isFalse);
      });
    });

    group('hashCode', () {
      test('equal objects have same hashCode', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(180, 50),
          anchorOffsetInOverlayContent: Offset(10, 40),
          requiresScrolling: false,
          contentTotalSize: Size(200, 290),
        );

        expect(defaultResult.hashCode, equals(other.hashCode));
      });

      test('different objects likely have different hashCode', () {
        const other = MenuPositionResult(
          overlayDisplayRect: Rect.fromLTWH(50, 100, 200, 300),
          scaledAnchorSize: Size(180, 60), // Different
          anchorOffsetInOverlayContent: Offset(10, 40),
          requiresScrolling: false,
          contentTotalSize: Size(200, 290),
        );

        // Note: Hash collisions are possible but unlikely for these values
        expect(defaultResult.hashCode, isNot(equals(other.hashCode)));
      });
    });
  });
}
