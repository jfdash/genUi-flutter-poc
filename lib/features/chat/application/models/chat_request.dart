import 'package:gen_ui_poc/features/chat/application/models/chat_intent.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

class ChatRequest {
  final ChatIntent intent;
  final QuoteProduct? product;
  final String? focusCoverage;
  final String? quoteScope;
  final String? targetQuoteReference;
  final double confidence;
  final String originalText;

  const ChatRequest({
    required this.intent,
    required this.originalText,
    this.product,
    this.focusCoverage,
    this.quoteScope,
    this.targetQuoteReference,
    this.confidence = 1,
  });
}
