part of 'quick_action_menu.dart';

/// Signature for a function that builds a placeholder widget for the anchor.
typedef QuickActionAnchorPlaceholderBuilder =
    Widget Function(
      BuildContext context,
      Size heroSize,
    );

/// {@template quick_action_anchor}
/// A widget that serves as an anchor point for a [QuickActionMenu] overlay.
/// It provides a builder for its child and a builder for a placeholder
/// to the [QuickActionMenu].
/// {@endtemplate}
class QuickActionAnchor extends StatefulWidget {
  /// {@macro quick_action_anchor}
  const QuickActionAnchor({
    required this.tag,
    required this.child,
    this.placeholderBuilder,
    super.key,
  });

  /// The child widget that will be shown as the anchor in the overlay.
  final Widget child;

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
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _quickActionMenuState = QuickActionMenu.of(context);
      _quickActionMenuState?._registerMenuAnchor(
        widget.tag,
        AnchorBuildData(
          key: _key,
          onExtractedChanged: _onExtractedChanged,
        ),
      );
    });
    super.initState();
  }

  void _onExtractedChanged(bool isExtracted) {
    if (isExtracted) {
      final box = _key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          _placeholderSize = box.size;
        });
      }
    } else {
      setState(() {
        _placeholderSize = null;
      });
    }
  }

  @override
  void didUpdateWidget(covariant QuickActionAnchor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentQuickActionMenuState = QuickActionMenu.of(context);

    if (oldWidget.tag != widget.tag) {
      _quickActionMenuState?._unregisterMenuAnchor(oldWidget.tag);
      _quickActionMenuState = currentQuickActionMenuState;
      _quickActionMenuState?._registerMenuAnchor(
        widget.tag,
        AnchorBuildData(
          key: _key,
          onExtractedChanged: _onExtractedChanged,
        ),
      );
    }
  }

  @override
  void dispose() {
    _quickActionMenuState?._unregisterMenuAnchor(widget.tag);
    _quickActionMenuState = null;
    super.dispose();
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
          child: KeyedSubtree(key: _key, child: widget.child),
        ),
      ),
    );
  }
}
