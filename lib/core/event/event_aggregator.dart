// lib/core/events/event_aggregator.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'widget_event.dart';

/// Aggrega eventi dai widget e triggera l'AI quando appropriato
class EventAggregator extends ChangeNotifier {
  final Map<String, dynamic> _collectedData = {};
  final List<WidgetEvent> _eventHistory = [];

  Timer? _debounceTimer;

  // Callback per triggerare l'AI
  final void Function(EventContext context)? onReadyForAI;

  int _submittedFieldsCount = 0;

  /// Chiavi già inviate nell'ultimo trigger - previene re-trigger con dati vecchi
  Set<String> _lastTriggerKeys = {};

  /// Campi registrati dai widget attivi nello step corrente
  final Set<String> _registeredFields = {};

  /// Numero di volte che l'AI è stata triggerata (= step completati)
  int _triggerCount = 0;
  int get triggerCount => _triggerCount;

  EventAggregator({this.onReadyForAI});

  /// Registra un campo attivo (chiamato dai widget in didChangeDependencies)
  void registerField(String fieldId) {
    _registeredFields.add(fieldId);
  }

  /// Rimuovi un campo (chiamato dai widget in dispose)
  void unregisterField(String fieldId) {
    _registeredFields.remove(fieldId);
  }

  /// True se tutti i campi registrati (non ancora triggerati) hanno un valore
  bool get allPendingFieldsCompleted {
    final pendingFields = _registeredFields.difference(_lastTriggerKeys);
    return pendingFields.isNotEmpty && pendingFields.every((f) => _collectedData.containsKey(f));
  }

  /// Dati raccolti finora
  Map<String, dynamic> get collectedData => Map.unmodifiable(_collectedData);

  /// Storia degli eventi
  List<WidgetEvent> get eventHistory => List.unmodifiable(_eventHistory);

  /// Chiamato dai widget quando l'utente interagisce.
  /// I dati vengono salvati ma l'AI NON viene triggerata automaticamente.
  /// Solo il submit_button tramite forceTrigger() avvia l'AI.
  void handleEvent(WidgetEvent event) {
    debugPrint('Event received: ${event.fieldId} = ${event.value}');

    _eventHistory.add(event);
    _collectedData[event.fieldId] = event.value;

    if (event.type == WidgetEventType.submitted) {
      _submittedFieldsCount++;
      debugPrint('Field submitted: $_submittedFieldsCount (waiting for explicit submit)');
    }

    notifyListeners();
  }

  /// Forza il trigger dell'AI (es. bottone "Continua").
  /// Triggera SOLO se ci sono nuovi campi E tutti i campi registrati sono compilati.
  void forceTrigger() {
    final currentKeys = _collectedData.keys.toSet();
    final newKeys = currentKeys.difference(_lastTriggerKeys);

    if (newKeys.isEmpty) {
      debugPrint('⛔ forceTrigger ignored: no new fields since last trigger');
      return;
    }

    // Verifica che tutti i campi registrati nello step corrente siano compilati
    final pendingFields = _registeredFields.difference(_lastTriggerKeys);
    if (pendingFields.isNotEmpty && !pendingFields.every((f) => _collectedData.containsKey(f))) {
      final missing = pendingFields.difference(_collectedData.keys.toSet());
      debugPrint('⛔ forceTrigger ignored: campi mancanti: $missing');
      return;
    }

    _triggerAI();
  }

  void _triggerAI() {
    _debounceTimer?.cancel();

    if (_collectedData.isEmpty) return;

    // Salva snapshot delle chiavi inviate
    _lastTriggerKeys = _collectedData.keys.toSet();
    _triggerCount++;

    final context = EventContext(
      collectedData: Map.from(_collectedData),
      eventHistory: List.from(_eventHistory),
      timestamp: DateTime.now(),
    );

    debugPrint(' Triggering AI with context: ${context.toPromptString()}');
    onReadyForAI?.call(context);
  }

  /// Reset per nuova conversazione
  void reset() {
    _collectedData.clear();
    _eventHistory.clear();
    _submittedFieldsCount = 0;
    _lastTriggerKeys = {};
    _registeredFields.clear();
    _triggerCount = 0;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Contesto completo da passare all'AI
class EventContext {
  final Map<String, dynamic> collectedData;
  final List<WidgetEvent> eventHistory;
  final DateTime timestamp;

  EventContext({required this.collectedData, required this.eventHistory, required this.timestamp});

  /// Genera una stringa leggibile per il prompt AI
  String toPromptString() {
    final buffer = StringBuffer();

    buffer.writeln('DATI RACCOLTI FINORA:');
    collectedData.forEach((key, value) {
      buffer.writeln('- $key: $value');
    });

    buffer.writeln('\nULTIMI EVENTI:');
    final recentEvents = eventHistory.reversed.take(5);
    for (final event in recentEvents) {
      buffer.writeln('- ${event.fieldId}: ${event.value} (${event.type.name})');
    }

    return buffer.toString();
  }
}
