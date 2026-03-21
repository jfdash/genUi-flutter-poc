// lib/core/ai/genui/event_driven_widgets.dart

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:provider/provider.dart';

import 'package:gen_ui_poc/core/event/event_aggregator.dart';
import 'package:gen_ui_poc/core/event/widget_event.dart';

/// Catalog di widget che emettono eventi automaticamente
class EventDrivenCatalog {
  static Catalog build() {
    return Catalog(catalogId: 'event_driven_catalog_1_0_0', [
      _textInput(),
      _numberInput(),
      _slider(),
      _choiceChips(),
      _dateInput(),
      _submitButton(),
      _infoCard(),
      _textMessage(),
    ]);
  }

  // ═══════════════════════════════════════════════════════════════
  // TEXT INPUT
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _textInput() {
    return CatalogItem(
      name: 'text_input',
      dataSchema: S.object(
        properties: {
          'id': S.string(description: 'Unique identifier for this field'),
          'label': S.string(description: 'Label displayed above the input'),
          'hint': S.string(description: 'Placeholder hint text'),
          'initial_value': S.string(description: 'Initial value'),
          'required': S.boolean(description: 'Whether the field is required'),
        },
        required: ['id', 'label'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return EventTextInput(
          key: ValueKey(json['id']),
          id: json['id'] as String? ?? 'unknown',
          label: json['label'] as String? ?? 'Campo',
          hint: json['hint'] as String?,
          initialValue: json['initial_value'] as String?,
          required: json['required'] as bool? ?? false,
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // NUMBER INPUT
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _numberInput() {
    return CatalogItem(
      name: 'number_input',
      dataSchema: S.object(
        properties: {
          'id': S.string(description: 'Unique identifier for this field'),
          'label': S.string(description: 'Label displayed above the input'),
          'min': S.integer(description: 'Minimum allowed value'),
          'max': S.integer(description: 'Maximum allowed value'),
          'initial_value': S.integer(description: 'Initial value'),
        },
        required: ['id', 'label'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return EventNumberInput(
          key: ValueKey(json['id']),
          id: json['id'] as String? ?? 'unknown',
          label: json['label'] as String? ?? 'Numero',
          min: (json['min'] as num?)?.toInt(), // ✅ Gestisce double
          max: (json['max'] as num?)?.toInt(), // ✅ Gestisce double
          initialValue: (json['initial_value'] as num?)?.toInt(), // ✅ FIX
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SLIDER
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _slider() {
    return CatalogItem(
      name: 'slider',
      dataSchema: S.object(
        properties: {
          'id': S.string(description: 'Unique identifier for this field'),
          'label': S.string(description: 'Label displayed above the slider'),
          'min': S.number(description: 'Minimum value'),
          'max': S.number(description: 'Maximum value'),
          'initial_value': S.number(description: 'Initial value'),
          'divisions': S.integer(description: 'Number of discrete divisions'),
          'suffix': S.string(description: 'Suffix to display after value (e.g. "km")'),
        },
        required: ['id', 'label', 'min', 'max'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return EventSlider(
          key: ValueKey(json['id']),
          id: json['id'] as String? ?? 'unknown',
          label: json['label'] as String? ?? 'Valore',
          min: (json['min'] as num?)?.toDouble() ?? 0,
          max: (json['max'] as num?)?.toDouble() ?? 100,
          initialValue: (json['initial_value'] as num?)?.toDouble(),
          divisions: (json['divisions'] as num?)?.toInt(),
          suffix: json['suffix'] as String?,
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CHOICE CHIPS
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _choiceChips() {
    return CatalogItem(
      name: 'choice_chips',
      dataSchema: S.object(
        properties: {
          'id': S.string(description: 'Unique identifier for this field'),
          'label': S.string(description: 'Label displayed above the chips'),
          'options': S.list(items: S.string(), description: 'List of options to choose from'),
          'initial_value': S.string(description: 'Initially selected value'),
          'multi_select': S.boolean(description: 'Allow multiple selections'),
        },
        required: ['id', 'label', 'options'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        final optionsList =
            (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

        return EventChoiceChips(
          key: ValueKey(json['id']),
          id: json['id'] as String? ?? 'unknown',
          label: json['label'] as String? ?? 'Scegli',
          options: optionsList,
          initialValue: json['initial_value'] as String?,
          multiSelect: json['multi_select'] as bool? ?? false,
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DATE INPUT
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _dateInput() {
    return CatalogItem(
      name: 'date_input',
      dataSchema: S.object(
        properties: {
          'id': S.string(description: 'Unique identifier for this field'),
          'label': S.string(description: 'Label displayed above the input'),
          'hint': S.string(description: 'Placeholder hint text'),
        },
        required: ['id', 'label'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return EventDateInput(
          key: ValueKey(json['id']),
          id: json['id'] as String? ?? 'unknown',
          label: json['label'] as String? ?? 'Data',
          hint: json['hint'] as String?,
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SUBMIT BUTTON
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _submitButton() {
    return CatalogItem(
      name: 'submit_button',
      dataSchema: S.object(
        properties: {
          'label': S.string(description: 'Button label text'),
          'icon': S.string(description: 'Optional icon name'),
        },
        required: ['label'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return EventSubmitButton(
          label: json['label'] as String? ?? 'Continua',
          icon: json['icon'] as String?,
          dispatchEvent: context.dispatchEvent,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INFO CARD
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _infoCard() {
    return CatalogItem(
      name: 'info_card',
      dataSchema: S.object(
        properties: {
          'title': S.string(description: 'Card title'),
          'message': S.string(description: 'Card message body'),
          'type': S.string(description: 'Card type: info, success, warning, error'),
        },
        required: ['title'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return InfoCard(
          title: json['title'] as String? ?? '',
          message: json['message'] as String?,
          type: json['type'] as String?,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TEXT MESSAGE
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _textMessage() {
    return CatalogItem(
      name: 'text_message',
      dataSchema: S.object(
        properties: {'message': S.string(description: 'Text message to display')},
        required: ['message'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return TextMessage(message: json['message'] as String? ?? '');
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WIDGET IMPLEMENTATIONS
// ═══════════════════════════════════════════════════════════════════

/// Helper per emettere eventi all'EventAggregator
void _emitToAggregator(BuildContext context, WidgetEvent event) {
  try {
    final aggregator = context.read<EventAggregator>();
    aggregator.handleEvent(event);
  } catch (e) {
    debugPrint('⚠️ EventAggregator not found in context: $e');
  }
}

// ─────────────────────────────────────────────────────────────────
// EVENT TEXT INPUT
// ─────────────────────────────────────────────────────────────────
class EventTextInput extends StatefulWidget {
  final String id;
  final String label;
  final String? hint;
  final String? initialValue;
  final bool required;
  final DispatchEventCallback dispatchEvent;

  const EventTextInput({
    super.key,
    required this.id,
    required this.label,
    this.hint,
    this.initialValue,
    this.required = false,
    required this.dispatchEvent,
  });

  @override
  State<EventTextInput> createState() => _EventTextInputState();
}

class _EventTextInputState extends State<EventTextInput> {
  late TextEditingController _controller;
  bool _isSubmitted = false;
  EventAggregator? _aggregator;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aggregator == null) {
      try {
        _aggregator = context.read<EventAggregator>();
        _aggregator!.registerField(widget.id);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _aggregator?.unregisterField(widget.id);
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSubmitted = true);

    // Emit to EventAggregator
    _emitToAggregator(
      context,
      WidgetEvent(
        fieldId: widget.id,
        value: _controller.text.trim(),
        type: WidgetEventType.submitted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSubmitted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isSubmitted ? Colors.green.shade300 : Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            _isSubmitted ? Icons.check_circle : Icons.edit,
            color: _isSubmitted ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !_isSubmitted,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: widget.hint,
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _onSubmit(),
            ),
          ),
          if (!_isSubmitted)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Color(0xFF4F46E5)),
              onPressed: _onSubmit,
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.grey),
              onPressed: () => setState(() => _isSubmitted = false),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EVENT NUMBER INPUT
// ─────────────────────────────────────────────────────────────────
class EventNumberInput extends StatefulWidget {
  final String id;
  final String label;
  final int? min;
  final int? max;
  final int? initialValue;
  final DispatchEventCallback dispatchEvent;

  const EventNumberInput({
    super.key,
    required this.id,
    required this.label,
    this.min,
    this.max,
    this.initialValue,
    required this.dispatchEvent,
  });

  @override
  State<EventNumberInput> createState() => _EventNumberInputState();
}

class _EventNumberInputState extends State<EventNumberInput> {
  late TextEditingController _controller;
  bool _isSubmitted = false;
  String? _error;
  EventAggregator? _aggregator;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue?.toString() ?? '');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aggregator == null) {
      try {
        _aggregator = context.read<EventAggregator>();
        _aggregator!.registerField(widget.id);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _aggregator?.unregisterField(widget.id);
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit() {
    final value = int.tryParse(_controller.text);

    if (value == null) {
      setState(() => _error = 'Inserisci un numero valido');
      return;
    }

    if (widget.min != null && value < widget.min!) {
      setState(() => _error = 'Minimo: ${widget.min}');
      return;
    }

    if (widget.max != null && value > widget.max!) {
      setState(() => _error = 'Massimo: ${widget.max}');
      return;
    }

    setState(() {
      _isSubmitted = true;
      _error = null;
    });

    _emitToAggregator(
      context,
      WidgetEvent(fieldId: widget.id, value: value, type: WidgetEventType.submitted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSubmitted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _error != null
              ? Colors.red.shade300
              : _isSubmitted
              ? Colors.green.shade300
              : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isSubmitted,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    hintText: _buildHint(),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _onSubmit(),
                ),
              ),
              if (!_isSubmitted)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline, color: Color(0xFF4F46E5)),
                  onPressed: _onSubmit,
                )
              else
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_error!, style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  String? _buildHint() {
    if (widget.min != null && widget.max != null) {
      return '${widget.min} - ${widget.max}';
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────
// EVENT SLIDER
// ─────────────────────────────────────────────────────────────────
class EventSlider extends StatefulWidget {
  final String id;
  final String label;
  final double min;
  final double max;
  final double? initialValue;
  final int? divisions;
  final String? suffix;
  final DispatchEventCallback dispatchEvent;

  const EventSlider({
    super.key,
    required this.id,
    required this.label,
    required this.min,
    required this.max,
    this.initialValue,
    this.divisions,
    this.suffix,
    required this.dispatchEvent,
  });

  @override
  State<EventSlider> createState() => _EventSliderState();
}

class _EventSliderState extends State<EventSlider> {
  late double _value;
  bool _isSubmitted = false;
  EventAggregator? _aggregator;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue ?? widget.min;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aggregator == null) {
      try {
        _aggregator = context.read<EventAggregator>();
        _aggregator!.registerField(widget.id);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _aggregator?.unregisterField(widget.id);
    super.dispose();
  }

  void _onSubmit() {
    setState(() => _isSubmitted = true);

    _emitToAggregator(
      context,
      WidgetEvent(fieldId: widget.id, value: _value, type: WidgetEventType.submitted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSubmitted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isSubmitted ? Colors.green.shade300 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${_value.toStringAsFixed(0)}${widget.suffix ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF4F46E5),
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: const Color(0xFF4F46E5),
            ),
            child: Slider(
              value: _value,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChanged: _isSubmitted ? null : (value) => setState(() => _value = value),
            ),
          ),
          if (!_isSubmitted)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _onSubmit,
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Conferma'),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EVENT CHOICE CHIPS
// ─────────────────────────────────────────────────────────────────
class EventChoiceChips extends StatefulWidget {
  final String id;
  final String label;
  final List<String> options;
  final String? initialValue;
  final bool multiSelect;
  final DispatchEventCallback dispatchEvent;

  const EventChoiceChips({
    super.key,
    required this.id,
    required this.label,
    required this.options,
    this.initialValue,
    this.multiSelect = false,
    required this.dispatchEvent,
  });

  @override
  State<EventChoiceChips> createState() => _EventChoiceChipsState();
}

class _EventChoiceChipsState extends State<EventChoiceChips> {
  String? _selectedValue;
  bool _isSubmitted = false;
  EventAggregator? _aggregator;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aggregator == null) {
      try {
        _aggregator = context.read<EventAggregator>();
        _aggregator!.registerField(widget.id);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _aggregator?.unregisterField(widget.id);
    super.dispose();
  }

  void _onSelect(String value) {
    if (_isSubmitted) return;

    setState(() {
      _selectedValue = value;
      _isSubmitted = true;
    });

    _emitToAggregator(
      context,
      WidgetEvent(fieldId: widget.id, value: value, type: WidgetEventType.submitted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSubmitted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isSubmitted ? Colors.green.shade300 : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (_isSubmitted)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.options.map((option) {
              final isSelected = _selectedValue == option;
              return ChoiceChip(
                label: Text(option),
                selected: isSelected,
                onSelected: _isSubmitted ? null : (_) => _onSelect(option),
                selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EVENT DATE INPUT
// ─────────────────────────────────────────────────────────────────
class EventDateInput extends StatefulWidget {
  final String id;
  final String label;
  final String? hint;
  final DispatchEventCallback dispatchEvent;

  const EventDateInput({
    super.key,
    required this.id,
    required this.label,
    this.hint,
    required this.dispatchEvent,
  });

  @override
  State<EventDateInput> createState() => _EventDateInputState();
}

class _EventDateInputState extends State<EventDateInput> {
  DateTime? _selectedDate;
  bool _isSubmitted = false;
  EventAggregator? _aggregator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_aggregator == null) {
      try {
        _aggregator = context.read<EventAggregator>();
        _aggregator!.registerField(widget.id);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _aggregator?.unregisterField(widget.id);
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _isSubmitted = true;
      });

      _emitToAggregator(
        context,
        WidgetEvent(
          fieldId: widget.id,
          value: date.toIso8601String(),
          type: WidgetEventType.submitted,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isSubmitted ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _isSubmitted ? Colors.green.shade300 : Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: _isSubmitted ? null : _pickDate,
        child: Row(
          children: [
            Icon(
              _isSubmitted ? Icons.check_circle : Icons.calendar_today,
              color: _isSubmitted ? Colors.green : const Color(0xFF4F46E5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : widget.hint ?? 'Seleziona data',
                    style: TextStyle(
                      fontSize: 16,
                      color: _selectedDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// EVENT SUBMIT BUTTON
// ─────────────────────────────────────────────────────────────────
class EventSubmitButton extends StatelessWidget {
  final String label;
  final String? icon;
  final DispatchEventCallback dispatchEvent;

  const EventSubmitButton({super.key, required this.label, this.icon, required this.dispatchEvent});

  @override
  Widget build(BuildContext context) {
    // Osserva l'aggregator per abilitare/disabilitare il bottone
    return Consumer<EventAggregator>(
      builder: (context, aggregator, _) {
        final enabled = aggregator.allPendingFieldsCompleted;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: enabled
                ? () {
                    aggregator.forceTrigger();
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// INFO CARD (no events, just display)
// ─────────────────────────────────────────────────────────────────
class InfoCard extends StatelessWidget {
  final String title;
  final String? message;
  final String? type;

  const InfoCard({super.key, required this.title, this.message, this.type});

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.$1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.$1.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(colors.$2, color: colors.$1),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.$1),
                ),
                if (message != null)
                  Text(message!, style: TextStyle(color: colors.$1.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, IconData) _getColors() {
    switch (type) {
      case 'success':
        return (Colors.green, Icons.check_circle);
      case 'warning':
        return (Colors.orange, Icons.warning);
      case 'error':
        return (Colors.red, Icons.error);
      default:
        return (const Color(0xFF4F46E5), Icons.info);
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// TEXT MESSAGE (no events, just display)
// ─────────────────────────────────────────────────────────────────
class TextMessage extends StatelessWidget {
  final String message;

  const TextMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(message, style: const TextStyle(fontSize: 15, height: 1.4)),
    );
  }
}
