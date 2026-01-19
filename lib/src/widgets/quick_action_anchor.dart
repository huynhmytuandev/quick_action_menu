import 'package:flutter/material.dart';
import 'package:quick_action_menu/src/models/anchor_build_data.dart';
import 'package:quick_action_menu/src/widgets/quick_action_menu.dart';

/// Signature for a function that builds a placeholder widget for the anchor.
typedef QuickActionAnchorPlaceholderBuilder =
    Widget Function(
      BuildContext context,
      Size heroSize,
    );

/// Signature for a function that builds the child widget based on
/// extracted state.
///
/// The [isExtracted] parameter indicates:
/// - `true`: Anchor is currently extracted and shown in overlay
/// - `false`: Anchor is currently in place (not extracted)
typedef QuickActionAnchorChildBuilder =
    Widget Function(
      BuildContext context,
      // To make it clean and more simple for users
      // ignore: avoid_positional_boolean_parameters
      bool isExtracted,
      Widget? child,
    );

/// {@template quick_action_anchor}
/// A widget that serves as an anchor point for a [QuickActionMenu] overlay.
/// It provides a builder for its child and a builder for a placeholder
/// to the [QuickActionMenu].
///
/// Either [child] or [childBuilder] must be provided, but not both.
/// If [childBuilder] is provided, it will be called with the current
/// extraction state, allowing dynamic content based on whether the
/// anchor is currently extracted.
/// {@endtemplate}
class QuickActionAnchor extends StatefulWidget {
  /// {@macro quick_action_anchor}
  const QuickActionAnchor({
    required this.tag,
    this.child,
    this.childBuilder,
    this.placeholderBuilder,
    super.key,
  }) : assert(
         (child != null) | (childBuilder != null),
         'One of child or childBuilder must be provided',
       );

  /// The child widget that will be shown as the anchor in the overlay.
  final Widget? child;

  /// Builder for the child widget based on extraction state.
  ///
  /// If provided, this takes precedence over [child].
  /// The builder receives the current extraction state:
  /// - `true`: Currently extracted and shown in overlay
  /// - `false`: Currently in place not extracted
  final QuickActionAnchorChildBuilder? childBuilder;

  /// The tag for the anchor widget.
  final Object tag;

  /// The builder for the placeholder widget.
  ///
  /// This will be used to show when the anchor is extracted.
  ///
  /// If not provide it will be show a empty [SizedBox].
  final QuickActionAnchorPlaceholderBuilder? placeholderBuilder;

  @override
  State<QuickActionAnchor> createState() => _QuickActionAnchorState();
}

/// The [State] for [QuickActionAnchor], managing its registration
/// with the nearest [QuickActionMenu] and providing an internal [GlobalKey].
class _QuickActionAnchorState extends State<QuickActionAnchor> {
  QuickActionMenuState? _quickActionMenuState;
  Size? _placeholderSize;
  late final _extractionNotifier = ValueNotifier<bool>(false);
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if widget is still mounted before registering
      if (!mounted) return;

      try {
        _quickActionMenuState = QuickActionMenu.of(context);
        _quickActionMenuState?.registerMenuAnchor(
          widget.tag,
          AnchorBuildData(
            key: _key,
            onExtractedChanged: _onExtractedChanged,
          ),
        );
        // QuickActionMenu.of throws FlutterError when ancestor not found.
        // ignore: avoid_catching_errors
      } on FlutterError catch (e) {
        debugPrint(
          'QuickActionAnchor: Failed to register with QuickActionMenu: $e',
        );
      }
    });
  }

  void _onExtractedChanged(bool isExtracted) {
    if (!mounted) return;

    if (isExtracted) {
      final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.attached && renderBox.hasSize) {
        _placeholderSize = renderBox.size;
        _extractionNotifier.value = true;
        _safeSetState(() {}); // Update placeholder size
      } else {
        debugPrint('QuickActionAnchor: Could not get size from RenderBox');
      }
    } else {
      _placeholderSize = null;
      _extractionNotifier.value = false;
      _safeSetState(() {}); // Update placeholder visibility
    }
  }

  @override
  void didUpdateWidget(covariant QuickActionAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle tag changes
    if (oldWidget.tag != widget.tag) {
      _quickActionMenuState?.unregisterMenuAnchor(oldWidget.tag);

      try {
        final currentQuickActionMenuState = QuickActionMenu.of(context);
        _quickActionMenuState = currentQuickActionMenuState;
        _quickActionMenuState?.registerMenuAnchor(
          widget.tag,
          AnchorBuildData(
            key: _key,
            onExtractedChanged: _onExtractedChanged,
          ),
        );
        // QuickActionMenu.of throws FlutterError when ancestor not found.
        // ignore: avoid_catching_errors
      } on FlutterError catch (e) {
        debugPrint(
          'QuickActionAnchor: Failed to re-register with QuickActionMenu: $e',
        );
      }
    }

    // Handle builder/child changes - if the type of content changed, rebuild
    if ((oldWidget.child != null) != (widget.child != null) ||
        (oldWidget.childBuilder != null) != (widget.childBuilder != null)) {
      // Content type changed, trigger rebuild
      _safeSetState(() {});
    }
  }

  @override
  void dispose() {
    _quickActionMenuState?.unregisterMenuAnchor(widget.tag);
    _quickActionMenuState = null;
    _extractionNotifier.dispose();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = _placeholderSize != null;

    if (showPlaceholder && widget.placeholderBuilder != null) {
      return widget.placeholderBuilder!(context, _placeholderSize!);
    }

    return SizedBox(
      width: _placeholderSize?.width,
      height: _placeholderSize?.height,
      child: Offstage(
        offstage: showPlaceholder,
        child: TickerMode(
          enabled: !showPlaceholder,
          child: KeyedSubtree(
            key: _key,
            child: Builder(
              builder: (context) {
                if (widget.childBuilder case final childBuilder? when mounted) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: _extractionNotifier,
                    builder: (context, isExtracted, _) {
                      return childBuilder(
                        context,
                        isExtracted,
                        widget.child,
                      );
                    },
                  );
                } else if (widget.child case final child?) {
                  return child;
                }
                return ErrorWidget(
                  'QuickActionAnchor: one of child or childBuilder '
                  ' must be provided',
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
