import 'package:flutter/material.dart';
import 'package:quick_action_menu/src/widgets/measure_size.dart';

/// {@template menu_measurement_widgets}
/// A hidden widget responsible for measuring the sizes of the top and
/// bottom menu widgets.
///
/// This widget renders the menus offscreen to measure their intrinsic sizes
/// before the actual layout is calculated.
/// {@endtemplate}
class MenuMeasurementWidgets extends StatelessWidget {
  /// {@macro menu_measurement_widgets}
  const MenuMeasurementWidgets({
    required this.topMenuWidget,
    required this.bottomMenuWidget,
    required this.onTopMenuMeasured,
    required this.onBottomMenuMeasured,
    super.key,
  });

  /// The top menu widget to measure.
  final Widget? topMenuWidget;

  /// The bottom menu widget to measure.
  final Widget? bottomMenuWidget;

  /// Callback when the top menu size is measured.
  final ValueChanged<Size> onTopMenuMeasured;

  /// Callback when the bottom menu size is measured.
  final ValueChanged<Size> onBottomMenuMeasured;

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (topMenuWidget != null)
              MeasureSize(
                onResized: onTopMenuMeasured,
                child: topMenuWidget!,
              ),
            if (bottomMenuWidget != null)
              MeasureSize(
                onResized: onBottomMenuMeasured,
                child: bottomMenuWidget!,
              ),
          ],
        ),
      ),
    );
  }
}
