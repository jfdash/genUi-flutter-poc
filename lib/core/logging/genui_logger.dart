import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gen_ui_poc/core/logging/genui_log_store.dart';

const bool _genUiAnsiLogs = bool.fromEnvironment(
  'GENUI_LOG_ANSI',
  defaultValue: false,
);

enum GenUiLogScope {
  lifecycle,
  input,
  intent,
  plan,
  mode,
  flow,
  genui,
  surface,
  event,
  data,
  success,
  warning,
  error,
}

class GenUiLogger {
  static const _reset = '\x1B[0m';
  static const _dim = '\x1B[2m';

  static void lifecycle(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.lifecycle, message, data: data);
  }

  static void input(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.input, message, data: data);
  }

  static void intent(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.intent, message, data: data);
  }

  static void plan(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.plan, message, data: data);
  }

  static void mode(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.mode, message, data: data);
  }

  static void flow(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.flow, message, data: data);
  }

  static void genui(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.genui, message, data: data);
  }

  static void surface(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.surface, message, data: data);
  }

  static void event(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.event, message, data: data);
  }

  static void data(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.data, message, data: data);
  }

  static void success(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.success, message, data: data);
  }

  static void warning(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.warning, message, data: data);
  }

  static void error(String message, {Map<String, Object?>? data}) {
    _log(GenUiLogScope.error, message, data: data);
  }

  static void _log(
    GenUiLogScope scope,
    String message, {
    Map<String, Object?>? data,
  }) {
    if (!kDebugMode) {
      return;
    }

    final color = _colorFor(scope);
    final timestamp = DateTime.now().toIso8601String();
    final scopeLabel = scope.name.toUpperCase().padRight(9);
    final scopeToken = '[GENUI][$scopeLabel][$timestamp]';
    final prefix = _genUiAnsiLogs ? '$color$scopeToken$_reset' : scopeToken;
    final dataPrefix = _genUiAnsiLogs ? '$color$_dim  ' : '  ';
    final dataSuffix = _genUiAnsiLogs ? _reset : '';
    final sanitizedData = data == null ? null : _sanitize(data);

    GenUiLogStore.instance.add(scope, message, data: sanitizedData);

    debugPrint('$prefix $message');

    if (sanitizedData != null && sanitizedData.isNotEmpty) {
      final encoder = const JsonEncoder.withIndent('  ');
      final payload = encoder.convert(sanitizedData).trimRight();
      for (final line in payload.split('\n')) {
        debugPrint('$dataPrefix$line$dataSuffix');
      }
    }
  }

  static Map<String, Object?> _sanitize(Map<String, Object?> data) {
    return data.map((key, value) => MapEntry(key, _normalizeValue(value)));
  }

  static Object? _normalizeValue(Object? value) {
    if (value == null ||
        value is num ||
        value is bool ||
        value is String) {
      return value;
    }
    if (value is Enum) {
      return value.name;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    if (value is Iterable) {
      return value.map(_normalizeValue).toList(growable: false);
    }
    if (value is Map) {
      return value.map(
        (key, nestedValue) => MapEntry(
          key.toString(),
          _normalizeValue(nestedValue),
        ),
      );
    }
    return value.toString();
  }

  static String _colorFor(GenUiLogScope scope) {
    switch (scope) {
      case GenUiLogScope.lifecycle:
        return '\x1B[38;5;244m';
      case GenUiLogScope.input:
        return '\x1B[38;5;45m';
      case GenUiLogScope.intent:
        return '\x1B[38;5;141m';
      case GenUiLogScope.plan:
        return '\x1B[38;5;75m';
      case GenUiLogScope.mode:
        return '\x1B[38;5;220m';
      case GenUiLogScope.flow:
        return '\x1B[38;5;118m';
      case GenUiLogScope.genui:
        return '\x1B[38;5;81m';
      case GenUiLogScope.surface:
        return '\x1B[38;5;87m';
      case GenUiLogScope.event:
        return '\x1B[38;5;214m';
      case GenUiLogScope.data:
        return '\x1B[38;5;111m';
      case GenUiLogScope.success:
        return '\x1B[38;5;46m';
      case GenUiLogScope.warning:
        return '\x1B[38;5;226m';
      case GenUiLogScope.error:
        return '\x1B[38;5;196m';
    }
  }
}
