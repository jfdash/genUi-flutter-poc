import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_flow_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';
import 'package:gen_ui_poc/features/quote/core/quote_product_module.dart';

class LifeQuoteModule implements QuoteProductModule {
  @override
  QuoteProduct get product => QuoteProduct.life;

  @override
  String get displayName => 'Vita';

  @override
  bool get isFlowSupportedInChat => false;

  @override
  List<String> get requiredFieldIds => const [];

  @override
  QuoteFlowDefinition get flowDefinition => const QuoteFlowDefinition(
    summaryTitle: 'Preventivo Vita',
    completionTitle: 'Preventivo Vita Completato!',
    steps: [],
    fieldDefinitions: [],
  );

  @override
  String buildStartFlowInstruction(QuoteFlowConfig config) {
    return 'Stub: preventivo vita non ancora implementato in chat.';
  }

  @override
  String buildFlowPromptDescription(QuoteFlowConfig config) {
    return 'Preventivo vita non ancora definito.';
  }
}
