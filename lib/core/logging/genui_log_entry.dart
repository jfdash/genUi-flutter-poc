import 'package:flutter/material.dart';

import 'package:gen_ui_poc/core/logging/genui_logger.dart';

class GenUiLogEntry {
  const GenUiLogEntry({
    required this.timestamp,
    required this.scope,
    required this.message,
    this.data,
  });

  final DateTime timestamp;
  final GenUiLogScope scope;
  final String message;
  final Map<String, Object?>? data;

  Color get color {
    switch (scope) {
      case GenUiLogScope.lifecycle:
        return const Color(0xFF6B7280);
      case GenUiLogScope.input:
        return const Color(0xFF0EA5E9);
      case GenUiLogScope.intent:
        return const Color(0xFF8B5CF6);
      case GenUiLogScope.plan:
        return const Color(0xFF2563EB);
      case GenUiLogScope.mode:
        return const Color(0xFFF59E0B);
      case GenUiLogScope.flow:
        return const Color(0xFF22C55E);
      case GenUiLogScope.genui:
        return const Color(0xFF06B6D4);
      case GenUiLogScope.surface:
        return const Color(0xFF14B8A6);
      case GenUiLogScope.event:
        return const Color(0xFFFB923C);
      case GenUiLogScope.data:
        return const Color(0xFF6366F1);
      case GenUiLogScope.success:
        return const Color(0xFF16A34A);
      case GenUiLogScope.warning:
        return const Color(0xFFEAB308);
      case GenUiLogScope.error:
        return const Color(0xFFDC2626);
    }
  }

  String get scopeLabel => scope.name.toUpperCase();
}
