import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quick_action_menu/src/enums/menu_overlay_horizontal_alignment.dart';
import 'package:quick_action_menu/src/enums/sticky_menu_behavior.dart';
import 'package:quick_action_menu/src/models/overlay_menu_config.dart';

void main() {
  group('OverlayMenuConfig', () {
    final testAnchorKey = GlobalKey();

    OverlayMenuConfig createConfig({
      GlobalKey? anchorKey,
      Widget? anchorWidget,
      Widget? topMenuWidget,
      Widget? bottomMenuWidget,
      VoidCallback? onAnchorExtracted,
      VoidCallback? onDismissed,
      EdgeInsets? padding,
      OverlayMenuHorizontalAlignment? topMenuAlignment,
      OverlayMenuHorizontalAlignment? bottomMenuAlignment,
      Duration? duration,
      Duration? reverseDuration,
      Curve? overlayAnimationCurve,
      Curve? anchorFlyAnimationCurve,
      Curve? anchorScaleAnimationCurve,
      Curve? topMenuScaleCurve,
      Curve? bottomMenuScaleCurve,
      Color? overlayBackgroundColor,
      double? overlayBackgroundOpacity,
      double? backdropBlurSigmaX,
      double? backdropBlurSigmaY,
      bool? reverseScroll,
      StickyMenuBehavior? stickyMenuBehavior,
    }) {
      return OverlayMenuConfig(
        anchorKey: anchorKey ?? testAnchorKey,
        anchorWidget: anchorWidget ?? const SizedBox(width: 100, height: 50),
        topMenuWidget: topMenuWidget,
        bottomMenuWidget: bottomMenuWidget,
        onAnchorExtracted: onAnchorExtracted,
        onDismissed: onDismissed,
        padding: padding ?? EdgeInsets.zero,
        topMenuAlignment:
            topMenuAlignment ?? OverlayMenuHorizontalAlignment.center,
        bottomMenuAlignment:
            bottomMenuAlignment ?? OverlayMenuHorizontalAlignment.center,
        duration: duration ?? Durations.medium1,
        reverseDuration: reverseDuration,
        overlayAnimationCurve: overlayAnimationCurve ?? Curves.easeOutCubic,
        anchorFlyAnimationCurve:
            anchorFlyAnimationCurve ?? Curves.easeInOutCubic,
        anchorScaleAnimationCurve:
            anchorScaleAnimationCurve ?? Curves.decelerate,
        topMenuScaleCurve: topMenuScaleCurve ?? Curves.easeOutCubic,
        bottomMenuScaleCurve: bottomMenuScaleCurve ?? Curves.easeOutCubic,
        overlayBackgroundColor: overlayBackgroundColor ?? Colors.black,
        overlayBackgroundOpacity: overlayBackgroundOpacity ?? 0.2,
        backdropBlurSigmaX: backdropBlurSigmaX ?? 10.0,
        backdropBlurSigmaY: backdropBlurSigmaY ?? 10.0,
        reverseScroll: reverseScroll ?? false,
        stickyMenuBehavior: stickyMenuBehavior ?? StickyMenuBehavior.none,
      );
    }

    group('constructor', () {
      test('creates config with required parameters', () {
        final config = createConfig();

        expect(config.anchorKey, equals(testAnchorKey));
        expect(config.anchorWidget, isA<SizedBox>());
      });

      test('uses default values for optional parameters', () {
        final config = createConfig();

        expect(config.padding, equals(EdgeInsets.zero));
        expect(
          config.topMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.center),
        );
        expect(
          config.bottomMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.center),
        );
        expect(config.duration, equals(Durations.medium1));
        expect(config.reverseDuration, isNull);
        expect(config.overlayAnimationCurve, equals(Curves.easeOutCubic));
        expect(config.anchorFlyAnimationCurve, equals(Curves.easeInOutCubic));
        expect(config.anchorScaleAnimationCurve, equals(Curves.decelerate));
        expect(config.topMenuScaleCurve, equals(Curves.easeOutCubic));
        expect(config.bottomMenuScaleCurve, equals(Curves.easeOutCubic));
        expect(config.overlayBackgroundColor, equals(Colors.black));
        expect(config.overlayBackgroundOpacity, equals(0.2));
        expect(config.backdropBlurSigmaX, equals(10.0));
        expect(config.backdropBlurSigmaY, equals(10.0));
        expect(config.reverseScroll, isFalse);
        expect(config.stickyMenuBehavior, equals(StickyMenuBehavior.none));
      });

      test('creates config with custom values', () {
        final config = createConfig(
          padding: const EdgeInsets.all(20),
          topMenuAlignment: OverlayMenuHorizontalAlignment.left,
          bottomMenuAlignment: OverlayMenuHorizontalAlignment.right,
          duration: const Duration(milliseconds: 500),
          overlayBackgroundColor: Colors.blue,
          overlayBackgroundOpacity: 0.5,
          backdropBlurSigmaX: 15.0,
          backdropBlurSigmaY: 15.0,
          reverseScroll: true,
          stickyMenuBehavior: StickyMenuBehavior.both,
        );

        expect(config.padding, equals(const EdgeInsets.all(20)));
        expect(
          config.topMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.left),
        );
        expect(
          config.bottomMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.right),
        );
        expect(config.duration, equals(const Duration(milliseconds: 500)));
        expect(config.overlayBackgroundColor, equals(Colors.blue));
        expect(config.overlayBackgroundOpacity, equals(0.5));
        expect(config.backdropBlurSigmaX, equals(15.0));
        expect(config.backdropBlurSigmaY, equals(15.0));
        expect(config.reverseScroll, isTrue);
        expect(config.stickyMenuBehavior, equals(StickyMenuBehavior.both));
      });

      test('creates config with menu widgets', () {
        const topMenu = Text('Top Menu');
        const bottomMenu = Text('Bottom Menu');

        final config = createConfig(
          topMenuWidget: topMenu,
          bottomMenuWidget: bottomMenu,
        );

        expect(config.topMenuWidget, equals(topMenu));
        expect(config.bottomMenuWidget, equals(bottomMenu));
      });
    });

    group('copyWith', () {
      test('returns config with same values when no parameters provided', () {
        final config = createConfig();
        final copiedConfig = config.copyWith();

        expect(copiedConfig.anchorKey, equals(config.anchorKey));
        expect(copiedConfig.padding, equals(config.padding));
        expect(copiedConfig.topMenuAlignment, equals(config.topMenuAlignment));
        expect(
          copiedConfig.bottomMenuAlignment,
          equals(config.bottomMenuAlignment),
        );
        expect(copiedConfig.duration, equals(config.duration));
        expect(
          copiedConfig.overlayBackgroundColor,
          equals(config.overlayBackgroundColor),
        );
        expect(
          copiedConfig.overlayBackgroundOpacity,
          equals(config.overlayBackgroundOpacity),
        );
        expect(
          copiedConfig.backdropBlurSigmaX,
          equals(config.backdropBlurSigmaX),
        );
        expect(
          copiedConfig.backdropBlurSigmaY,
          equals(config.backdropBlurSigmaY),
        );
        expect(copiedConfig.reverseScroll, equals(config.reverseScroll));
        expect(
          copiedConfig.stickyMenuBehavior,
          equals(config.stickyMenuBehavior),
        );
      });

      test('returns config with updated padding', () {
        final config = createConfig();
        final copiedConfig = config.copyWith(
          padding: const EdgeInsets.all(32),
        );

        expect(copiedConfig.padding, equals(const EdgeInsets.all(32)));
        expect(copiedConfig.anchorKey, equals(config.anchorKey));
      });

      test('returns config with updated alignments', () {
        final config = createConfig();
        final copiedConfig = config.copyWith(
          topMenuAlignment: OverlayMenuHorizontalAlignment.left,
          bottomMenuAlignment: OverlayMenuHorizontalAlignment.right,
        );

        expect(
          copiedConfig.topMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.left),
        );
        expect(
          copiedConfig.bottomMenuAlignment,
          equals(OverlayMenuHorizontalAlignment.right),
        );
      });

      test('returns config with updated duration', () {
        final config = createConfig();
        final copiedConfig = config.copyWith(
          duration: const Duration(seconds: 1),
          reverseDuration: const Duration(milliseconds: 500),
        );

        expect(copiedConfig.duration, equals(const Duration(seconds: 1)));
        expect(
          copiedConfig.reverseDuration,
          equals(const Duration(milliseconds: 500)),
        );
      });

      test('returns config with updated curves', () {
        final config = createConfig();
        final copiedConfig = config.copyWith(
          overlayAnimationCurve: Curves.linear,
          anchorFlyAnimationCurve: Curves.bounceIn,
          anchorScaleAnimationCurve: Curves.elasticOut,
          topMenuScaleCurve: Curves.fastOutSlowIn,
          bottomMenuScaleCurve: Curves.slowMiddle,
        );

        expect(copiedConfig.overlayAnimationCurve, equals(Curves.linear));
        expect(copiedConfig.anchorFlyAnimationCurve, equals(Curves.bounceIn));
        expect(
          copiedConfig.anchorScaleAnimationCurve,
          equals(Curves.elasticOut),
        );
        expect(copiedConfig.topMenuScaleCurve, equals(Curves.fastOutSlowIn));
        expect(copiedConfig.bottomMenuScaleCurve, equals(Curves.slowMiddle));
      });

      test('returns config with updated background options', () {
        final config = createConfig();
        final copiedConfig = config.copyWith(
          overlayBackgroundColor: Colors.red,
          overlayBackgroundOpacity: 0.8,
          backdropBlurSigmaX: 20.0,
          backdropBlurSigmaY: 25.0,
        );

        expect(copiedConfig.overlayBackgroundColor, equals(Colors.red));
        expect(copiedConfig.overlayBackgroundOpacity, equals(0.8));
        expect(copiedConfig.backdropBlurSigmaX, equals(20.0));
        expect(copiedConfig.backdropBlurSigmaY, equals(25.0));
      });

      test('returns config with updated scroll and sticky behavior', () {
        final config = createConfig();
        final copiedConfig = config.copyWith(
          reverseScroll: true,
          stickyMenuBehavior: StickyMenuBehavior.top,
        );

        expect(copiedConfig.reverseScroll, isTrue);
        expect(copiedConfig.stickyMenuBehavior, equals(StickyMenuBehavior.top));
      });

      test('returns config with updated widgets', () {
        final config = createConfig();
        const newAnchor = ColoredBox(color: Colors.green);
        const newTop = Text('New Top');
        const newBottom = Text('New Bottom');

        final copiedConfig = config.copyWith(
          anchorWidget: newAnchor,
          topMenuWidget: newTop,
          bottomMenuWidget: newBottom,
        );

        expect(copiedConfig.anchorWidget, equals(newAnchor));
        expect(copiedConfig.topMenuWidget, equals(newTop));
        expect(copiedConfig.bottomMenuWidget, equals(newBottom));
      });

      test('returns config with updated callbacks', () {
        var extracted = false;
        var dismissed = false;

        final config = createConfig();
        final copiedConfig = config.copyWith(
          onAnchorExtracted: () => extracted = true,
          onDismissed: () => dismissed = true,
        );

        copiedConfig.onAnchorExtracted?.call();
        copiedConfig.onDismissed?.call();

        expect(extracted, isTrue);
        expect(dismissed, isTrue);
      });

      test('returns config with new anchorKey', () {
        final config = createConfig();
        final newKey = GlobalKey();

        final copiedConfig = config.copyWith(anchorKey: newKey);

        expect(copiedConfig.anchorKey, equals(newKey));
        expect(copiedConfig.anchorKey, isNot(equals(config.anchorKey)));
      });
    });

    group('StickyMenuBehavior enum', () {
      test('has all expected values', () {
        expect(StickyMenuBehavior.values.length, equals(4));
        expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.none));
        expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.top));
        expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.bottom));
        expect(StickyMenuBehavior.values, contains(StickyMenuBehavior.both));
      });
    });

    group('OverlayMenuHorizontalAlignment enum', () {
      test('has all expected values', () {
        expect(OverlayMenuHorizontalAlignment.values.length, equals(3));
        expect(
          OverlayMenuHorizontalAlignment.values,
          contains(OverlayMenuHorizontalAlignment.left),
        );
        expect(
          OverlayMenuHorizontalAlignment.values,
          contains(OverlayMenuHorizontalAlignment.center),
        );
        expect(
          OverlayMenuHorizontalAlignment.values,
          contains(OverlayMenuHorizontalAlignment.right),
        );
      });
    });
  });
}
