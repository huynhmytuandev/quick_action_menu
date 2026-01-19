import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:quick_action_menu/src/models/menu_position_result.dart';

/// {@template quick_action_logger}
/// A utility class for structured logging in the quick_action_menu package.
///
/// This logger integrates with Dart DevTools and provides structured logging
/// for debugging menu positioning, animations, and state changes.
///
/// Logging is disabled in release mode by default.
/// {@endtemplate}
class QuickActionLogger {
  QuickActionLogger._();

  /// Whether logging is enabled. Defaults to true in debug mode only.
  static bool enabled = kDebugMode;

  /// The name used for log entries.
  static const String _logName = 'quick_action_menu';

  /// Logs a general message.
  ///
  /// [message] The message to log.
  /// [tag] An optional tag to categorize the log entry.
  static void log(String message, {String? tag}) {
    if (!enabled) return;

    final formattedMessage = tag != null ? '[$tag] $message' : message;
    developer.log(
      formattedMessage,
      name: _logName,
    );
  }

  /// Logs a warning message.
  ///
  /// [message] The warning message to log.
  /// [tag] An optional tag to categorize the log entry.
  static void warn(String message, {String? tag}) {
    if (!enabled) return;

    final formattedMessage = tag != null ? '[$tag] ⚠️ $message' : '⚠️ $message';
    developer.log(
      formattedMessage,
      name: _logName,
      level: 900, // Warning level
    );
  }

  /// Logs an error message with optional error and stack trace.
  ///
  /// [message] The error message to log.
  /// [error] The error object, if any.
  /// [stackTrace] The stack trace, if any.
  /// [tag] An optional tag to categorize the log entry.
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (!enabled) return;

    final formattedMessage = tag != null ? '[$tag] ❌ $message' : '❌ $message';
    developer.log(
      formattedMessage,
      name: _logName,
      level: 1000, // Severe level
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs menu position calculation results.
  ///
  /// [result] The calculated [MenuPositionResult].
  /// [tag] An optional tag to identify which menu this is for.
  static void logPosition(MenuPositionResult result, {String? tag}) {
    if (!enabled) return;

    final buffer = StringBuffer()
      ..writeln('📐 Menu Position Calculated${tag != null ? ' [$tag]' : ''}:')
      ..writeln('  Overlay Rect: ${result.overlayDisplayRect}')
      ..writeln('  Anchor Size: ${result.scaledAnchorSize}')
      ..writeln('  Anchor Offset: ${result.anchorOffsetInOverlayContent}')
      ..writeln('  Content Size: ${result.contentTotalSize}')
      ..writeln('  Requires Scrolling: ${result.requiresScrolling}');

    developer.log(
      buffer.toString(),
      name: _logName,
    );
  }

  /// Logs animation status changes.
  ///
  /// [animationName] The name of the animation.
  /// [status] The animation status description.
  static void logAnimation(String animationName, String status) {
    if (!enabled) return;

    developer.log(
      '🎬 Animation [$animationName]: $status',
      name: _logName,
    );
  }

  /// Logs anchor registration events.
  ///
  /// [tag] The anchor tag.
  /// [registered] Whether the anchor was registered or unregistered.
  static void logAnchorRegistration(Object tag, {required bool registered}) {
    if (!enabled) return;

    final action = registered ? 'registered' : 'unregistered';
    developer.log(
      '⚓ Anchor $action: $tag',
      name: _logName,
    );
  }

  /// Logs menu visibility changes.
  ///
  /// [visible] Whether the menu is now visible.
  /// [tag] The anchor tag associated with the menu.
  static void logMenuVisibility({required bool visible, Object? tag}) {
    if (!enabled) return;

    final visibility = visible ? 'shown' : 'hidden';
    final tagInfo = tag != null ? ' for anchor: $tag' : '';
    developer.log(
      '👁️ Menu $visibility$tagInfo',
      name: _logName,
    );
  }
}
