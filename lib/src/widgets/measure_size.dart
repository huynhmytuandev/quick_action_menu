import 'package:flutter/widgets.dart';

/// A callback to be invoked when the size of the observed widget changes.
typedef ResizeCallback = void Function(Size newSize);

/// {@template measure_size}
/// A widget that calls a callback when the size of its [child] changes.
/// {@endtemplate}
class MeasureSize extends StatefulWidget {
  /// Creates a [MeasureSize].
  const MeasureSize({
    required this.onResized,
    required this.child,
    super.key,
  });

  /// The child widget to measure.
  final Widget child;

  /// The callback to be invoked when the size of the observed widget changes.
  final ResizeCallback onResized;

  @override
  State<MeasureSize> createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  Size? _oldSize;

  // GlobalKey to get the RenderBox of the child
  final GlobalKey _childKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Schedule initial measurement after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndNotify();
    });
  }

  @override
  void didUpdateWidget(covariant MeasureSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureAndNotify();
    });
  }

  void _measureAndNotify() {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null && renderBox.hasSize) {
      final newSize = renderBox.size;
      if (newSize != _oldSize) {
        widget.onResized(newSize);
        _oldSize = newSize;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(key: _childKey, child: widget.child);
  }
}
