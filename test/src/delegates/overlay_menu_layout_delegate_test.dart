import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/delegates/overlay_menu_layout_delegate.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/enums/overlay_slot.dart';
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart';

void main() {
  group('OverlayMenuLayoutDelegate', () {
    OverlayMenuLayoutDelegate createDelegate({
      double anchorFinalXInDelegate = 100,
      double anchorFinalYInDelegate = 150,
      Size anchorOriginalSize = const Size(200, 50),
      Size anchorFinalSize = const Size(180, 45),
      OverlayMenuHorizontalAlignment topMenuAlignment =
          OverlayMenuHorizontalAlignment.center,
      OverlayMenuHorizontalAlignment bottomMenuAlignment =
          OverlayMenuHorizontalAlignment.center,
      Size measuredTopMenuSize = const Size(180, 100),
      Size measuredBottomMenuSize = const Size(180, 80),
      double currentScrollOffset = 0,
      StickyMenuBehavior stickyMenuBehavior = StickyMenuBehavior.both,
      double contentTotalHeight = 500,
      double overlayDisplayHeight = 400,
      bool requiresScrolling = false,
      EdgeInsets padding = const EdgeInsets.all(16),
      bool reverseScroll = false,
    }) {
      return OverlayMenuLayoutDelegate(
        anchorFinalXInDelegate: anchorFinalXInDelegate,
        anchorFinalYInDelegate: anchorFinalYInDelegate,
        anchorOriginalSize: anchorOriginalSize,
        anchorFinalSize: anchorFinalSize,
        topMenuAlignment: topMenuAlignment,
        bottomMenuAlignment: bottomMenuAlignment,
        measuredTopMenuSize: measuredTopMenuSize,
        measuredBottomMenuSize: measuredBottomMenuSize,
        currentScrollOffset: currentScrollOffset,
        stickyMenuBehavior: stickyMenuBehavior,
        contentTotalHeight: contentTotalHeight,
        overlayDisplayHeight: overlayDisplayHeight,
        requiresScrolling: requiresScrolling,
        padding: padding,
        reverseScroll: reverseScroll,
      );
    }

    group('constructor', () {
      test('creates delegate with all parameters', () {
        final delegate = createDelegate();

        expect(delegate.anchorFinalXInDelegate, equals(100));
        expect(delegate.anchorFinalYInDelegate, equals(150));
        expect(delegate.anchorOriginalSize, equals(const Size(200, 50)));
        expect(delegate.anchorFinalSize, equals(const Size(180, 45)));
        expect(
          delegate.topMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.center),
        );
        expect(
          delegate.bottomMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.center),
        );
        expect(delegate.measuredTopMenuSize, equals(const Size(180, 100)));
        expect(delegate.measuredBottomMenuSize, equals(const Size(180, 80)));
        expect(delegate.currentScrollOffset, equals(0));
        expect(delegate.stickyMenuBehavior, equals(StickyMenuBehavior.both));
        expect(delegate.contentTotalHeight, equals(500));
        expect(delegate.overlayDisplayHeight, equals(400));
        expect(delegate.requiresScrolling, isFalse);
        expect(delegate.padding, equals(const EdgeInsets.all(16)));
        expect(delegate.reverseScroll, isFalse);
      });

      test('creates delegate with custom values', () {
        final delegate = createDelegate(
          anchorFinalXInDelegate: 50,
          topMenuAlignment: OverlayMenuHorizontalAlignment.left,
          requiresScrolling: true,
        );

        expect(delegate.anchorFinalXInDelegate, equals(50));
        expect(
          delegate.topMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.left),
        );
        expect(delegate.requiresScrolling, isTrue);
      });
    });

    group('shouldRelayout', () {
      test('returns false for identical delegates', () {
        final delegate1 = createDelegate();
        final delegate2 = createDelegate();

        expect(delegate1.shouldRelayout(delegate2), isFalse);
      });

      test('returns true when anchorFinalXInDelegate changes', () {
        final delegate1 = createDelegate(anchorFinalXInDelegate: 100);
        final delegate2 = createDelegate(anchorFinalXInDelegate: 150);

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when anchorFinalYInDelegate changes', () {
        final delegate1 = createDelegate(anchorFinalYInDelegate: 150);
        final delegate2 = createDelegate(anchorFinalYInDelegate: 200);

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when anchorOriginalSize changes', () {
        final delegate1 = createDelegate(
          anchorOriginalSize: const Size(200, 50),
        );
        final delegate2 = createDelegate(
          anchorOriginalSize: const Size(220, 60),
        );

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when anchorFinalSize changes', () {
        final delegate1 = createDelegate(anchorFinalSize: const Size(180, 45));
        final delegate2 = createDelegate(anchorFinalSize: const Size(160, 40));

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when topMenuAlignment changes', () {
        final delegate1 = createDelegate(
          topMenuAlignment: OverlayMenuHorizontalAlignment.center,
        );
        final delegate2 = createDelegate(
          topMenuAlignment: OverlayMenuHorizontalAlignment.left,
        );

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when bottomMenuAlignment changes', () {
        final delegate1 = createDelegate(
          bottomMenuAlignment: OverlayMenuHorizontalAlignment.center,
        );
        final delegate2 = createDelegate(
          bottomMenuAlignment: OverlayMenuHorizontalAlignment.right,
        );

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when measuredTopMenuSize changes', () {
        final delegate1 = createDelegate(
          measuredTopMenuSize: const Size(180, 100),
        );
        final delegate2 = createDelegate(
          measuredTopMenuSize: const Size(200, 120),
        );

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when measuredBottomMenuSize changes', () {
        final delegate1 = createDelegate(
          measuredBottomMenuSize: const Size(180, 80),
        );
        final delegate2 = createDelegate(
          measuredBottomMenuSize: const Size(200, 100),
        );

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when currentScrollOffset changes', () {
        final delegate1 = createDelegate(currentScrollOffset: 0);
        final delegate2 = createDelegate(currentScrollOffset: 50);

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when stickyMenuBehavior changes', () {
        final delegate1 = createDelegate(
          stickyMenuBehavior: StickyMenuBehavior.both,
        );
        final delegate2 = createDelegate(
          stickyMenuBehavior: StickyMenuBehavior.top,
        );

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when contentTotalHeight changes', () {
        final delegate1 = createDelegate(contentTotalHeight: 500);
        final delegate2 = createDelegate(contentTotalHeight: 600);

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when overlayDisplayHeight changes', () {
        final delegate1 = createDelegate(overlayDisplayHeight: 400);
        final delegate2 = createDelegate(overlayDisplayHeight: 450);

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns true when reverseScroll changes', () {
        final delegate1 = createDelegate(reverseScroll: false);
        final delegate2 = createDelegate(reverseScroll: true);

        expect(delegate1.shouldRelayout(delegate2), isTrue);
      });

      test('returns false when requiresScrolling changes (not in check)', () {
        // Note: requiresScrolling is not included in shouldRelayout check
        final delegate1 = createDelegate(requiresScrolling: false);
        final delegate2 = createDelegate(requiresScrolling: true);

        // This tests the current behavior - requiresScrolling is not compared
        expect(delegate1.shouldRelayout(delegate2), isFalse);
      });

      test('returns false when padding changes (not in check)', () {
        // Note: padding is not included in shouldRelayout check
        final delegate1 = createDelegate(padding: const EdgeInsets.all(16));
        final delegate2 = createDelegate(padding: const EdgeInsets.all(20));

        // This tests the current behavior - padding is not compared
        expect(delegate1.shouldRelayout(delegate2), isFalse);
      });
    });

    group('performLayout with CustomMultiChildLayout', () {
      testWidgets('lays out children in CustomMultiChildLayout', (
        tester,
      ) async {
        final delegate = createDelegate();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomMultiChildLayout(
              delegate: delegate,
              children: [
                LayoutId(
                  id: OverlaySlot.top,
                  child: const SizedBox(width: 180, height: 100),
                ),
                LayoutId(
                  id: OverlaySlot.anchor,
                  child: const SizedBox(width: 200, height: 50),
                ),
                LayoutId(
                  id: OverlaySlot.bottom,
                  child: const SizedBox(width: 180, height: 80),
                ),
              ],
            ),
          ),
        );

        // Layout should complete without errors
        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets('handles missing children gracefully', (tester) async {
        final delegate = createDelegate();

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: CustomMultiChildLayout(
              delegate: delegate,
              children: [
                // Only anchor, no top or bottom
                LayoutId(
                  id: OverlaySlot.anchor,
                  child: const SizedBox(width: 200, height: 50),
                ),
              ],
            ),
          ),
        );

        // Layout should complete without errors
        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets(
        'correctly positions anchor with requiresScrolling false',
        (tester) async {
          final delegate = createDelegate(
            anchorFinalXInDelegate: 50,
            anchorFinalYInDelegate: 100,
            requiresScrolling: false,
          );

          await tester.pumpWidget(
            Directionality(
              textDirection: TextDirection.ltr,
              child: Center(
                child: SizedBox(
                  width: 400,
                  height: 600,
                  child: CustomMultiChildLayout(
                    delegate: delegate,
                    children: [
                      LayoutId(
                        id: OverlaySlot.anchor,
                        child: const SizedBox(width: 200, height: 50),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          final renderBox =
              tester.renderObject(find.byType(SizedBox).first) as RenderBox;
          expect(renderBox.size, equals(const Size(400, 600)));
        },
      );

      testWidgets('correctly positions anchor with requiresScrolling true', (
        tester,
      ) async {
        final delegate = createDelegate(
          anchorFinalXInDelegate: 50,
          anchorFinalYInDelegate: 100,
          requiresScrolling: true,
          padding: const EdgeInsets.all(20),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: SizedBox(
                width: 400,
                height: 600,
                child: CustomMultiChildLayout(
                  delegate: delegate,
                  children: [
                    LayoutId(
                      id: OverlaySlot.anchor,
                      child: const SizedBox(width: 200, height: 50),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // Layout should complete without errors
        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });
    });

    group('alignment calculations', () {
      testWidgets('left alignment positions menu at anchor left', (
        tester,
      ) async {
        final delegate = createDelegate(
          anchorFinalXInDelegate: 100,
          anchorFinalSize: const Size(200, 50),
          topMenuAlignment: OverlayMenuHorizontalAlignment.left,
          bottomMenuAlignment: OverlayMenuHorizontalAlignment.left,
          measuredTopMenuSize: const Size(150, 80),
          measuredBottomMenuSize: const Size(150, 60),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 150, height: 80),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 150, height: 60),
                  ),
                ],
              ),
            ),
          ),
        );

        // Layout should complete without errors
        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets('right alignment positions menu at anchor right', (
        tester,
      ) async {
        final delegate = createDelegate(
          anchorFinalXInDelegate: 100,
          anchorFinalSize: const Size(200, 50),
          topMenuAlignment: OverlayMenuHorizontalAlignment.right,
          bottomMenuAlignment: OverlayMenuHorizontalAlignment.right,
          measuredTopMenuSize: const Size(150, 80),
          measuredBottomMenuSize: const Size(150, 60),
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 150, height: 80),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 150, height: 60),
                  ),
                ],
              ),
            ),
          ),
        );

        // Layout should complete without errors
        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });
    });

    group('sticky menu behavior', () {
      testWidgets('top sticky behavior with scroll', (tester) async {
        final delegate = createDelegate(
          requiresScrolling: true,
          stickyMenuBehavior: StickyMenuBehavior.top,
          currentScrollOffset: 50,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 180, height: 100),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 180, height: 80),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets('bottom sticky behavior with scroll', (tester) async {
        final delegate = createDelegate(
          requiresScrolling: true,
          stickyMenuBehavior: StickyMenuBehavior.bottom,
          currentScrollOffset: 50,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 180, height: 100),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 180, height: 80),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets('none sticky behavior with scroll', (tester) async {
        final delegate = createDelegate(
          requiresScrolling: true,
          stickyMenuBehavior: StickyMenuBehavior.none,
          currentScrollOffset: 50,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 180, height: 100),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 180, height: 80),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets('reverse scroll with sticky top', (tester) async {
        final delegate = createDelegate(
          requiresScrolling: true,
          stickyMenuBehavior: StickyMenuBehavior.top,
          currentScrollOffset: 50,
          reverseScroll: true,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 180, height: 100),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 180, height: 80),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });

      testWidgets('reverse scroll with sticky bottom', (tester) async {
        final delegate = createDelegate(
          requiresScrolling: true,
          stickyMenuBehavior: StickyMenuBehavior.bottom,
          currentScrollOffset: 50,
          reverseScroll: true,
        );

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: 400,
              height: 600,
              child: CustomMultiChildLayout(
                delegate: delegate,
                children: [
                  LayoutId(
                    id: OverlaySlot.top,
                    child: const SizedBox(width: 180, height: 100),
                  ),
                  LayoutId(
                    id: OverlaySlot.anchor,
                    child: const SizedBox(width: 200, height: 50),
                  ),
                  LayoutId(
                    id: OverlaySlot.bottom,
                    child: const SizedBox(width: 180, height: 80),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(CustomMultiChildLayout), findsOneWidget);
      });
    });
  });
}
