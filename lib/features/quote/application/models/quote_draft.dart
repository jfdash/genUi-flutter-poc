import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';

class QuoteDraft {
  final QuoteFlowConfig config;
  final Map<String, dynamic> collectedData;

  const QuoteDraft({required this.config, required this.collectedData});

  factory QuoteDraft.fromCollectedData({
    required QuoteFlowConfig config,
    required Map<String, dynamic> collectedData,
  }) {
    return QuoteDraft(
      config: config,
      collectedData: Map.unmodifiable(Map<String, dynamic>.from(collectedData)),
    );
  }

  dynamic operator [](String key) => collectedData[key];

  bool contains(String key) => collectedData.containsKey(key);
}
