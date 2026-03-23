import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_step_definition.dart';

class QuoteFlowDefinition {
  final String summaryTitle;
  final String completionTitle;
  final List<QuoteStepDefinition> steps;
  final List<QuoteFieldDefinition> fieldDefinitions;

  const QuoteFlowDefinition({
    required this.summaryTitle,
    required this.completionTitle,
    required this.steps,
    required this.fieldDefinitions,
  });

  QuoteFieldDefinition? fieldById(String fieldId) {
    for (final field in fieldDefinitions) {
      if (field.id == fieldId) {
        return field;
      }
    }
    return null;
  }
}
