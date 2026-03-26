// lib/core/ai/genui/event_driven_widgets.dart

import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/theme/app_theme.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:provider/provider.dart';

import 'package:gen_ui_poc/core/event/event_aggregator.dart';
import 'package:gen_ui_poc/core/event/widget_event.dart';

/// Catalog di widget che emettono eventi automaticamente
class EventDrivenCatalog {
  static Catalog build() {
    return Catalog([
      _textInput(),
      _numberInput(),
      _slider(),
      _choiceChips(),
      _dateInput(),
      _submitButton(),
      _infoCard(),
      _comparisonCard(),
      _prosConsCard(),
      _quoteCompactSummary(),
      _textMessage(),
    ], catalogId: 'event_driven_catalog_1_0_0');
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
          label: json['label'] as String? ?? 'Valore numerico',
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
          label: json['label'] as String? ?? 'Seleziona',
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
  // COMPARISON CARD
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _comparisonCard() {
    return CatalogItem(
      name: 'comparison_card',
      dataSchema: S.object(
        properties: {
          'title': S.string(description: 'Section title'),
          'left_title': S.string(description: 'Left column title'),
          'left_body': S.string(description: 'Left column body'),
          'right_title': S.string(description: 'Right column title'),
          'right_body': S.string(description: 'Right column body'),
          'footer': S.string(description: 'Optional footer summary'),
        },
        required: ['title', 'left_title', 'left_body', 'right_title', 'right_body'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return ComparisonCard(
          title: json['title'] as String? ?? '',
          leftTitle: json['left_title'] as String? ?? '',
          leftBody: json['left_body'] as String? ?? '',
          rightTitle: json['right_title'] as String? ?? '',
          rightBody: json['right_body'] as String? ?? '',
          footer: json['footer'] as String?,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PROS CONS CARD
  // ═══════════════════════════════════════════════════════════════
  static CatalogItem _prosConsCard() {
    return CatalogItem(
      name: 'pros_cons_card',
      dataSchema: S.object(
        properties: {
          'title': S.string(description: 'Card title'),
          'pros_title': S.string(description: 'Pros section title'),
          'pros': S.list(items: S.string(), description: 'Pros list'),
          'cons_title': S.string(description: 'Cons section title'),
          'cons': S.list(items: S.string(), description: 'Cons list'),
          'recommended_for': S.string(description: 'Suggested use case'),
        },
        required: ['title', 'pros', 'cons'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return ProsConsCard(
          title: json['title'] as String? ?? '',
          prosTitle: json['pros_title'] as String? ?? 'Pro',
          pros:
              (json['pros'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          consTitle: json['cons_title'] as String? ?? 'Contro',
          cons:
              (json['cons'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          recommendedFor: json['recommended_for'] as String?,
        );
      },
    );
  }

  static CatalogItem _quoteCompactSummary() {
    return CatalogItem(
      name: 'quote_compact_summary',
      dataSchema: S.object(
        properties: {
          'quote_id': S.string(description: 'Saved quote identifier'),
          'title': S.string(description: 'Main summary title'),
          'subtitle': S.string(description: 'Short summary subtitle'),
          'annual_price': S.number(description: 'Annual premium'),
          'essential_price': S.number(description: 'Essential-only annual premium'),
          'coverage_count': S.integer(description: 'Coverage count'),
          'cta_label': S.string(description: 'Detail button label'),
        },
        required: ['quote_id', 'title', 'annual_price', 'cta_label'],
      ),
      widgetBuilder: (CatalogItemContext context) {
        final json = context.data as Map<String, Object?>;
        return QuoteCompactSummaryCard(
          quoteId: json['quote_id'] as String? ?? '',
          title: json['title'] as String? ?? 'Preventivo pronto',
          subtitle: json['subtitle'] as String?,
          annualPrice: (json['annual_price'] as num?)?.toDouble() ?? 0,
          essentialPrice: (json['essential_price'] as num?)?.toDouble(),
          coverageCount: (json['coverage_count'] as num?)?.toInt(),
          ctaLabel: json['cta_label'] as String? ?? 'Apri dettaglio',
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

BoxDecoration _monoCardDecoration({
  Color color = Colors.white,
  bool withBorder = true,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(18),
    border: withBorder ? Border.all(color: AppTheme.border) : null,
  );
}

Widget _monoMetaLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w700,
        color: AppTheme.textSecondary,
      ),
    ),
  );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _monoMetaLabel('EventTextInput'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: _monoCardDecoration(
              color: _isSubmitted ? AppTheme.surfaceMuted : const Color(0xFFF1F1F1),
              withBorder: false,
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isSubmitted,
                    decoration: InputDecoration(
                      hintText: widget.hint ?? widget.label,
                      hintStyle: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    onSubmitted: (_) => _onSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isSubmitted ? () => setState(() => _isSubmitted = false) : _onSubmit,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      _isSubmitted ? Icons.edit_outlined : Icons.arrow_forward_rounded,
                      size: 22,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _monoMetaLabel('EventNumberInput'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: _monoCardDecoration(
              color: _isSubmitted ? AppTheme.surfaceMuted : const Color(0xFFF1F1F1),
              withBorder: _error != null,
            ).copyWith(
              border: _error != null
                  ? Border.all(color: const Color(0xFFD84B3E))
                  : null,
            ),
            child: Row(
              children: [
                const Icon(Icons.calculate_outlined, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isSubmitted,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: widget.label,
                      hintStyle: const TextStyle(
                        color: AppTheme.textTertiary,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    onSubmitted: (_) => _onSubmit(),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.min != null)
                      Text(
                        'MIN: ${widget.min}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    if (widget.max != null)
                      Text(
                        'MAX: ${widget.max}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isSubmitted ? null : _onSubmit,
                  borderRadius: BorderRadius.circular(10),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Color(0xFFD84B3E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
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
      padding: const EdgeInsets.all(16),
      decoration: _monoCardDecoration(color: const Color(0xFFF7F7F4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _monoMetaLabel('EventSlider'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayValueText(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _isSubmitted ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.action,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Applica'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.textPrimary,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.textPrimary,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: _value,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChanged: _isSubmitted ? null : (value) => setState(() => _value = value),
            ),
          ),
        ],
      ),
    );
  }

  String _displayValueText() {
    final normalizedValue = _value.toStringAsFixed(0);
    if (widget.suffix != null && widget.suffix!.trim().isNotEmpty) {
      return '$normalizedValue${widget.suffix}';
    }
    if (widget.min == 0 && widget.max == 100) {
      return '$normalizedValue%';
    }
    return normalizedValue;
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
      padding: const EdgeInsets.all(16),
      decoration: _monoCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _monoMetaLabel('EventChoiceChips'),
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
                color: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return AppTheme.action;
                  }
                  return const Color(0xFFF1F1F1);
                }),
                showCheckmark: false,
                pressElevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                  side: BorderSide(
                    color: isSelected ? AppTheme.action : Colors.transparent,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
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
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MonoDatePickerSheet(
        initialDate: _selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      ),
    );

    if (!mounted || date == null) {
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _monoMetaLabel('EventDateInput'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: _monoCardDecoration(color: const Color(0xFFF1F1F1), withBorder: false),
            child: InkWell(
              onTap: _isSubmitted ? null : _pickDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : widget.hint ?? widget.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _selectedDate != null
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonoDatePickerSheet extends StatefulWidget {
  const _MonoDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_MonoDatePickerSheet> createState() => _MonoDatePickerSheetState();
}

class _MonoDatePickerSheetState extends State<_MonoDatePickerSheet> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  static const _monthNames = [
    'Gennaio',
    'Febbraio',
    'Marzo',
    'Aprile',
    'Maggio',
    'Giugno',
    'Luglio',
    'Agosto',
    'Settembre',
    'Ottobre',
    'Novembre',
    'Dicembre',
  ];

  static const _weekdays = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();
    final availableYears = List.generate(
      widget.lastDate.year - widget.firstDate.year + 1,
      (index) => widget.firstDate.year + index,
    );

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _HeaderDropdown<int>(
                  value: _visibleMonth.month,
                  items: List.generate(12, (index) => index + 1),
                  labelBuilder: (month) => _monthNames[month - 1],
                  onChanged: (month) {
                    if (month == null) return;
                    setState(() {
                      _visibleMonth = DateTime(_visibleMonth.year, month);
                    });
                  },
                ),
                const SizedBox(width: 12),
                _HeaderDropdown<int>(
                  value: _visibleMonth.year,
                  items: availableYears,
                  labelBuilder: (year) => '$year',
                  onChanged: (year) {
                    if (year == null) return;
                    setState(() {
                      _visibleMonth = DateTime(year, _visibleMonth.month);
                    });
                  },
                ),
                const Spacer(),
                IconButton(
                  onPressed: _canGoPreviousMonth() ? _goPreviousMonth : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                IconButton(
                  onPressed: _canGoNextMonth() ? _goNextMonth : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: _weekdays
                  .map(
                    (day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 46,
              ),
              itemBuilder: (context, index) {
                final day = days[index];
                if (day == null) {
                  return const SizedBox.shrink();
                }
                final isSelected = _isSameDate(day, _selectedDate);
                final isEnabled = _isDateAllowed(day);
                return Center(
                  child: GestureDetector(
                    onTap: isEnabled
                        ? () => setState(() => _selectedDate = day)
                        : null,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : isEnabled
                              ? AppTheme.textPrimary
                              : AppTheme.textTertiary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      backgroundColor: AppTheme.surfaceMuted,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Annulla',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(_selectedDate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Seleziona',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _buildCalendarDays() {
    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_visibleMonth.year, _visibleMonth.month);
    final leadingEmpty = (firstOfMonth.weekday + 6) % 7;
    final totalSlots = ((leadingEmpty + daysInMonth) / 7).ceil() * 7;

    return List.generate(totalSlots, (index) {
      final dayNumber = index - leadingEmpty + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return null;
      }
      return DateTime(_visibleMonth.year, _visibleMonth.month, dayNumber);
    });
  }

  bool _canGoPreviousMonth() {
    final previous = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    return !previous.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month));
  }

  bool _canGoNextMonth() {
    final next = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    return !next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month));
  }

  void _goPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _goNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  bool _isDateAllowed(DateTime date) {
    return !date.isBefore(DateUtils.dateOnly(widget.firstDate)) &&
        !date.isAfter(DateUtils.dateOnly(widget.lastDate));
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _HeaderDropdown<T> extends StatelessWidget {
  const _HeaderDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
          dropdownColor: Colors.white,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelBuilder(item)),
                ),
              )
              .toList(),
          onChanged: onChanged,
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
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.action,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.border,
              disabledForegroundColor: const Color(0xFFA8A39A),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.$1.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border(
          left: BorderSide(color: colors.$1, width: 2.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(colors.$2, color: colors.$1, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.$1,
                    fontSize: 14,
                  ),
                ),
                if (message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      message!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
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
        return (AppTheme.success, Icons.check_circle);
      case 'warning':
        return (const Color(0xFFF08A24), Icons.warning_amber_rounded);
      case 'error':
        return (const Color(0xFFD84B3E), Icons.report_gmailerrorred_rounded);
      default:
        return (AppTheme.textPrimary, Icons.info);
    }
  }
}

class QuoteCompactSummaryCard extends StatelessWidget {
  const QuoteCompactSummaryCard({
    super.key,
    required this.quoteId,
    required this.title,
    required this.annualPrice,
    required this.ctaLabel,
    this.subtitle,
    this.essentialPrice,
    this.coverageCount,
  });

  final String quoteId;
  final String title;
  final String? subtitle;
  final double annualPrice;
  final double? essentialPrice;
  final int? coverageCount;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.45,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              _QuoteMetric(
                label: 'PREMIO ANNUO',
                value: '€ ${annualPrice.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 12),
              if (essentialPrice != null)
                Expanded(
                  child: _QuoteMetric(
                    label: 'ESSENZIALI',
                    value: '€ ${essentialPrice!.toStringAsFixed(0)}',
                  ),
                ),
            ],
          ),
          if (coverageCount != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.surfaceMuted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '$coverageCount coperture incluse',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openDetail(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.action,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(ctaLabel),
            ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final CompletedQuote? quote = quoteStorageRepository.getQuoteById(quoteId);
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dettaglio preventivo non disponibile')),
      );
      return;
    }

    context.push('/confirmation', extra: quote);
  }
}

class _QuoteMetric extends StatelessWidget {
  const _QuoteMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3EE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class ComparisonCard extends StatelessWidget {
  const ComparisonCard({
    super.key,
    required this.title,
    required this.leftTitle,
    required this.leftBody,
    required this.rightTitle,
    required this.rightBody,
    this.footer,
  });

  final String title;
  final String leftTitle;
  final String leftBody;
  final String rightTitle;
  final String rightBody;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.6,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ComparisonColumn(
                  title: leftTitle,
                  body: leftBody,
                  accentColor: AppTheme.textPrimary,
                ),
              ),
              Container(width: 1, height: 168, color: AppTheme.border),
              Expanded(
                child: _ComparisonColumn(
                  title: rightTitle,
                  body: rightBody,
                  accentColor: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (footer != null && footer!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              footer!,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ComparisonColumn extends StatelessWidget {
  const _ComparisonColumn({
    required this.title,
    required this.body,
    required this.accentColor,
  });

  final String title;
  final String body;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class ProsConsCard extends StatelessWidget {
  const ProsConsCard({
    super.key,
    required this.title,
    required this.prosTitle,
    required this.pros,
    required this.consTitle,
    required this.cons,
    this.recommendedFor,
  });

  final String title;
  final String prosTitle;
  final List<String> pros;
  final String consTitle;
  final List<String> cons;
  final String? recommendedFor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          _BulletSection(
            title: prosTitle,
            items: pros,
            icon: Icons.add_circle_outline,
            iconColor: AppTheme.success,
          ),
          const SizedBox(height: 12),
          _BulletSection(
            title: consTitle,
            items: cons,
            icon: Icons.remove_circle_outline,
            iconColor: const Color(0xFFD84B3E),
          ),
          if (recommendedFor != null && recommendedFor!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
              ),
              child: Text(
                recommendedFor!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.items,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final List<String> items;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          height: 1.55,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
