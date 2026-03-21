// lib/core/events/widget_event.dart

class WidgetEvent {
  final String fieldId;
  final dynamic value;
  final WidgetEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  WidgetEvent({
    required this.fieldId,
    required this.value,
    this.type = WidgetEventType.valueChanged,
    this.metadata,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'field_id': fieldId,
    'value': value,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  String toString() => 'WidgetEvent($fieldId: $value, type: ${type.name})';
}

enum WidgetEventType { valueChanged, submitted, focused, blurred, validated, error }
