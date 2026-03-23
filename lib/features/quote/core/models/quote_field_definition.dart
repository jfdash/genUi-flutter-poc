import 'package:gen_ui_poc/features/quote/core/models/quote_field_widget_type.dart';

class QuoteFieldDefinition {
  final String id;
  final QuoteFieldWidgetType widgetType;
  final String label;
  final String? hint;
  final int? minInt;
  final int? maxInt;
  final String? suffix;
  final List<String> options;
  final bool required;

  const QuoteFieldDefinition({
    required this.id,
    required this.widgetType,
    required this.label,
    this.hint,
    this.minInt,
    this.maxInt,
    this.suffix,
    this.options = const [],
    this.required = true,
  });
}
