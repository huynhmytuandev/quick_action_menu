import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/widgets/measure_size.dart';

void main() {
  group('MeasureSize', () {
    testWidgets('calls onResized with initial size', (tester) async {
      Size? measuredSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (size) {
                  measuredSize = size;
                },
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for post frame callback
      await tester.pump();

      expect(measuredSize, isNotNull);
      expect(measuredSize, equals(const Size(100, 50)));
    });

    testWidgets('calls onResized when child size changes', (tester) async {
      final sizes = <Size>[];
      var childWidth = 100.0;
      var childHeight = 50.0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MeasureSize(
                      onResized: sizes.add,
                      child: Container(
                        width: childWidth,
                        height: childHeight,
                        color: Colors.blue,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          childWidth = 200;
                          childHeight = 100;
                        });
                      },
                      child: const Text('Resize'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      // Wait for initial measurement
      await tester.pump();
      expect(sizes.length, equals(1));
      expect(sizes.first, equals(const Size(100, 50)));

      // Tap button to resize
      await tester.tap(find.text('Resize'));
      await tester.pump();

      // Should have been called with new size
      expect(sizes.length, equals(2));
      expect(sizes.last, equals(const Size(200, 100)));
    });

    testWidgets('does not call onResized if size unchanged', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (_) {
                  callCount++;
                },
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(callCount, equals(1));

      // Rebuild without size change
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (_) {
                  callCount++;
                },
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // Should not call again if size is the same
      expect(callCount, equals(1));
    });

    testWidgets('wraps child in SizedBox with key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MeasureSize(
            onResized: (_) {},
            child: const Text('Hello'),
          ),
        ),
      );

      // Find the SizedBox wrapper
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.key, isNotNull);
    });

    testWidgets('works with flexible child', (tester) async {
      Size? measuredSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: MeasureSize(
                onResized: (size) {
                  measuredSize = size;
                },
                child: const Placeholder(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(measuredSize, isNotNull);
      expect(measuredSize, equals(const Size(300, 200)));
    });

    testWidgets('handles very small sizes', (tester) async {
      Size? measuredSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (size) {
                  measuredSize = size;
                },
                child: Container(
                  width: 1,
                  height: 1,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(measuredSize, equals(const Size(1, 1)));
    });

    testWidgets('handles zero size', (tester) async {
      Size? measuredSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (size) {
                  measuredSize = size;
                },
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(measuredSize, equals(Size.zero));
    });

    testWidgets('works with complex child widgets', (tester) async {
      Size? measuredSize;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (size) {
                  measuredSize = size;
                },
                child: const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Title'),
                        SizedBox(height: 8),
                        Text('Description'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(measuredSize, isNotNull);
      expect(measuredSize!.width, greaterThan(0));
      expect(measuredSize!.height, greaterThan(0));
    });

    testWidgets('calls onResized on didUpdateWidget', (tester) async {
      var callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                onResized: (_) {
                  callCount++;
                },
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      final initialCount = callCount;

      // Update the widget (even without size change, didUpdateWidget triggers)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: MeasureSize(
                // Different callback instance but same behavior
                onResized: (_) {
                  callCount++;
                },
                child: Container(
                  width: 100,
                  height: 50,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump();

      // didUpdateWidget was called, but size hasn't changed so callback
      // should not fire again
      expect(callCount, equals(initialCount));
    });
  });
}
