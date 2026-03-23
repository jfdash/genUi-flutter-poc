class QuoteStepDefinition {
  final String id;
  final String title;
  final String contextMessage;
  final List<String> fieldIds;
  final String submitLabel;

  const QuoteStepDefinition({
    required this.id,
    required this.title,
    required this.contextMessage,
    required this.fieldIds,
    required this.submitLabel,
  });
}
