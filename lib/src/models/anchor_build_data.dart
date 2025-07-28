import 'package:flutter/widgets.dart';

/// Store all the data needed to build an anchor widget.
class AnchorBuildData {
  /// Creates an [AnchorBuildData].
  const AnchorBuildData({
    required this.key,
    required this.onExtractedChanged,
  });

  /// The [GlobalKey] for the anchor widget.
  final GlobalKey key;

  /// The callback for the anchor widget's extracted state.
  ///
  /// It is called when the anchor widget is extracted.
  final ValueChanged<bool> onExtractedChanged;
}
