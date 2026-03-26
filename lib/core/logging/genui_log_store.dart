import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:gen_ui_poc/core/logging/genui_log_entry.dart';
import 'package:gen_ui_poc/core/logging/genui_logger.dart';

class GenUiLogStore extends ChangeNotifier {
  GenUiLogStore._();

  static final GenUiLogStore instance = GenUiLogStore._();

  static const int _maxEntries = 400;

  final List<GenUiLogEntry> _entries = [];
  bool _notifyScheduled = false;

  List<GenUiLogEntry> get entries => List.unmodifiable(_entries);

  void add(
    GenUiLogScope scope,
    String message, {
    Map<String, Object?>? data,
  }) {
    _entries.insert(
      0,
      GenUiLogEntry(
        timestamp: DateTime.now(),
        scope: scope,
        message: message,
        data: data == null ? null : Map<String, Object?>.from(data),
      ),
    );
    if (_entries.length > _maxEntries) {
      _entries.removeRange(_maxEntries, _entries.length);
    }
    _scheduleNotify();
  }

  void clear() {
    _entries.clear();
    _scheduleNotify();
  }

  void _scheduleNotify() {
    if (_notifyScheduled) {
      return;
    }
    _notifyScheduled = true;

    final binding = SchedulerBinding.instance;
    final phase = binding.schedulerPhase;

    void flush() {
      _notifyScheduled = false;
      notifyListeners();
    }

    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      scheduleMicrotask(flush);
      return;
    }

    binding.addPostFrameCallback((_) => flush());
  }
}
