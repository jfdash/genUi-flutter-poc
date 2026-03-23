import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

class QuoteFlowConfig {
  final QuoteProduct product;
  final String? focusCoverage;
  final String? quoteScope;

  const QuoteFlowConfig({
    required this.product,
    this.focusCoverage,
    this.quoteScope,
  });
}
