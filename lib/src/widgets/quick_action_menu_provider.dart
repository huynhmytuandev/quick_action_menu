import 'package:flutter/material.dart';
import 'package:quick_action_menu/src/widgets/quick_action_menu.dart';

/// Provides access to QuickActionMenuState across different context trees,
/// including overlay contexts.
class QuickActionMenuProvider extends InheritedWidget {
  /// Creates a [QuickActionMenuProvider].
  const QuickActionMenuProvider({
    required this.state,
    required super.child,
    super.key,
  });

  /// The [QuickActionMenuState] provided by this widget.
  final QuickActionMenuState state;

  /// Retrieves the [QuickActionMenuState] from the nearest ancestor
  /// [QuickActionMenuProvider] in the widget tree, if any.
  static QuickActionMenuState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<QuickActionMenuProvider>()
        ?.state;
  }

  /// Retrieves the [QuickActionMenuState] from the nearest ancestor
  /// [QuickActionMenuProvider] in the widget tree.
  static QuickActionMenuState of(BuildContext context) {
    final state = maybeOf(context);
    if (state == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'QuickActionMenuProvider.of() called with a context that '
          'does not contain a QuickActionMenuProvider.',
        ),
        ErrorDescription(
          'The context used must be that of a widget that is a descendant '
          'of a QuickActionMenuProvider.',
        ),
        ErrorHint(
          'This usually happens when the overlay context cannot find the '
          'QuickActionMenu in its widget tree.',
        ),
      ]);
    }
    return state;
  }

  @override
  bool updateShouldNotify(QuickActionMenuProvider oldWidget) {
    return state != oldWidget.state;
  }
}
