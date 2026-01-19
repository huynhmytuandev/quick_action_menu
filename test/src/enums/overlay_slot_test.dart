import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/enums/overlay_slot.dart';

void main() {
  group('OverlaySlot', () {
    test('has all expected values', () {
      expect(OverlaySlot.values.length, equals(3));
    });

    test('contains top slot', () {
      expect(OverlaySlot.values, contains(OverlaySlot.top));
    });

    test('contains anchor slot', () {
      expect(OverlaySlot.values, contains(OverlaySlot.anchor));
    });

    test('contains bottom slot', () {
      expect(OverlaySlot.values, contains(OverlaySlot.bottom));
    });

    test('values are in expected order', () {
      expect(OverlaySlot.values[0], equals(OverlaySlot.top));
      expect(OverlaySlot.values[1], equals(OverlaySlot.anchor));
      expect(OverlaySlot.values[2], equals(OverlaySlot.bottom));
    });

    test('can be used as layout IDs', () {
      // Verify enum values can be compared for equality (used as layout IDs)
      const slot1 = OverlaySlot.top;
      const slot2 = OverlaySlot.top;
      const slot3 = OverlaySlot.bottom;

      expect(slot1, equals(slot2));
      expect(slot1, isNot(equals(slot3)));
    });
  });
}
