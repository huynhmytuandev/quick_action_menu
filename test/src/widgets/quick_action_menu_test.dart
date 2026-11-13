import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/quick_action_menu.dart';

void main() {
  group('QuickActionMenu duplicate key regression tests', () {
    testWidgets(
      'does not throw duplicate GlobalKey when anchor child has a GlobalKey',
      (tester) async {
        final anchorChildKey = GlobalKey();
        late QuickActionMenuState menuState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickActionMenu(
                child: Builder(
                  builder: (context) {
                    menuState = QuickActionMenu.of(context);
                    return Center(
                      child: QuickActionAnchor(
                        tag: 'anchor_1',
                        child: Container(
                          key: anchorChildKey,
                          width: 100,
                          height: 40,
                          color: Colors.blue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        menuState.showMenu(
          tag: 'anchor_1',
          topMenuWidget: const SizedBox(width: 80, height: 30),
          bottomMenuWidget: const SizedBox(width: 80, height: 30),
        );

        await tester.pump();
        expect(find.byKey(anchorChildKey), findsOneWidget);
        await tester.pump();
        expect(find.byKey(anchorChildKey), findsOneWidget);
        await tester.pumpAndSettle();
        expect(find.byKey(anchorChildKey), findsOneWidget);

        final hideFuture = menuState.hideMenu();
        await tester.pump();
        expect(find.byKey(anchorChildKey), findsOneWidget);
        await tester.pumpAndSettle();
        await hideFuture;
        expect(find.byKey(anchorChildKey), findsOneWidget);

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'does not throw duplicate GlobalKey when topMenuWidget has a GlobalKey '
      'and bottomMenuWidget is null',
      (tester) async {
        final topMenuKey = GlobalKey();
        late QuickActionMenuState menuState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickActionMenu(
                child: Builder(
                  builder: (context) {
                    menuState = QuickActionMenu.of(context);
                    return const Center(
                      child: QuickActionAnchor(
                        tag: 'anchor_1',
                        child: SizedBox(width: 100, height: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        menuState.showMenu(
          tag: 'anchor_1',
          topMenuWidget: SizedBox(key: topMenuKey, width: 80, height: 30),
        );

        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        final hideFuture = menuState.hideMenu();
        await tester.pump();
        await tester.pumpAndSettle();
        await hideFuture;

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'does not throw duplicate GlobalKey when both top and bottom menus '
      'have GlobalKeys',
      (tester) async {
        final topMenuKey = GlobalKey();
        final bottomMenuKey = GlobalKey();
        late QuickActionMenuState menuState;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickActionMenu(
                child: Builder(
                  builder: (context) {
                    menuState = QuickActionMenu.of(context);
                    return const Center(
                      child: QuickActionAnchor(
                        tag: 'anchor_1',
                        child: SizedBox(width: 100, height: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        menuState.showMenu(
          tag: 'anchor_1',
          topMenuWidget: SizedBox(key: topMenuKey, width: 80, height: 30),
          bottomMenuWidget: SizedBox(key: bottomMenuKey, width: 80, height: 30),
        );

        await tester.pump();
        await tester.pump();
        await tester.pumpAndSettle();

        final hideFuture = menuState.hideMenu();
        await tester.pump();
        await tester.pumpAndSettle();
        await hideFuture;

        expect(tester.takeException(), isNull);
      },
    );
  });
}
