import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_flow_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

abstract class QuoteProductModule {
  QuoteProduct get product;
  String get displayName;
  bool get isFlowSupportedInChat;
  List<String> get requiredFieldIds;
  QuoteFlowDefinition get flowDefinition;

  String buildStartFlowInstruction(QuoteFlowConfig config);
  String buildFlowPromptDescription(QuoteFlowConfig config);
}
