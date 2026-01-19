import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart';

void main() {
  group('StickyMenuBehavior', () {
    test('has all expected values', () {
      expect(StickyMenuBehavior.values.length, equals(4));
    });

    test('contains none behavior', () {
      expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.none));
    });

    test('contains top behavior', () {
      expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.top));
    });

    test('contains bottom behavior', () {
      expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.bottom));
    });

    test('contains both behavior', () {
      expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.both));
    });

    test('values are in expected order', () {
      expect(StickyMenuBehavior.values[0], equals(StickyMenuBehavior.none));
      expect(StickyMenuBehavior.values[1], equals(StickyMenuBehavior.top));
      expect(StickyMenuBehavior.values[2], equals(StickyMenuBehavior.bottom));
      expect(StickyMenuBehavior.values[3], equals(StickyMenuBehavior.both));
    });

    test('can be compared for equality', () {
      const behavior1 = StickyMenuBehavior.top;
      const behavior2 = StickyMenuBehavior.top;
      const behavior3 = StickyMenuBehavior.bottom;

      expect(behavior1, equals(behavior2));
      expect(behavior1, isNot(equals(behavior3)));
    });

    group('isTop helper', () {
      test('returns true for top and both', () {
        expect(
          StickyMenuBehavior.top == StickyMenuBehavior.top ||
              StickyMenuBehavior.top == StickyMenuBehavior.both,
          isTrue,
        );
        expect(
          StickyMenuBehavior.both == StickyMenuBehavior.top ||
              StickyMenuBehavior.both == StickyMenuBehavior.both,
          isTrue,
        );
      });

      test('returns false for none and bottom', () {
        expect(
          StickyMenuBehavior.none == StickyMenuBehavior.top ||
              StickyMenuBehavior.none == StickyMenuBehavior.both,
          isFalse,
        );
        expect(
          StickyMenuBehavior.bottom == StickyMenuBehavior.top ||
              StickyMenuBehavior.bottom == StickyMenuBehavior.both,
          isFalse,
        );
      });
    });

    group('isBottom helper', () {
      test('returns true for bottom and both', () {
        expect(
          StickyMenuBehavior.bottom == StickyMenuBehavior.bottom ||
              StickyMenuBehavior.bottom == StickyMenuBehavior.both,
          isTrue,
        );
        expect(
          StickyMenuBehavior.both == StickyMenuBehavior.bottom ||
              StickyMenuBehavior.both == StickyMenuBehavior.both,
          isTrue,
        );
      });

      test('returns false for none and top', () {
        expect(
          StickyMenuBehavior.none == StickyMenuBehavior.bottom ||
              StickyMenuBehavior.none == StickyMenuBehavior.both,
          isFalse,
        );
        expect(
          StickyMenuBehavior.top == StickyMenuBehavior.bottom ||
              StickyMenuBehavior.top == StickyMenuBehavior.both,
          isFalse,
        );
      });
    });
  });
}
