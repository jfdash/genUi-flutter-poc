import 'package:gen_ui_poc/features/chat/application/models/chat_intent.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_request.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

class ChatRequestNormalizer {
  ChatRequest normalize({
    required String originalText,
    required ChatIntent intent,
  }) {
    final normalized = _normalize(originalText);

    return ChatRequest(
      intent: intent,
      originalText: originalText,
      product: _extractProduct(normalized, intent),
      focusCoverage: _extractFocusCoverage(normalized),
      quoteScope: _extractQuoteScope(normalized),
      targetQuoteReference: _extractTargetQuoteReference(normalized, intent),
      confidence: 1,
    );
  }

  String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9àèéìòù\\s]'), ' ')
        .replaceAll(RegExp(r'\\s+'), ' ');
  }

  QuoteProduct? _extractProduct(String normalized, ChatIntent intent) {
    if (intent != ChatIntent.startQuote) {
      return null;
    }

    if (normalized.contains('vita')) {
      return QuoteProduct.life;
    }
    if (normalized.contains('viaggio') || normalized.contains('travel')) {
      return QuoteProduct.travel;
    }
    return QuoteProduct.auto;
  }

  String? _extractFocusCoverage(String normalized) {
    if (normalized.contains('kasko')) {
      return 'kasko';
    }
    if (normalized.contains('furto') || normalized.contains('incendio')) {
      return 'furto_incendio';
    }
    if (normalized.contains('cristalli')) {
      return 'cristalli';
    }
    if (normalized.contains('assistenza')) {
      return 'assistenza_stradale';
    }
    return null;
  }

  String? _extractQuoteScope(String normalized) {
    if (normalized.contains('solo')) {
      return 'single_coverage';
    }
    if (normalized.contains('confront') || normalized.contains('senza')) {
      return 'comparison';
    }
    return 'package';
  }

  String? _extractTargetQuoteReference(String normalized, ChatIntent intent) {
    if (intent != ChatIntent.quoteDetails) {
      return null;
    }

    if (normalized.contains('ultimo') ||
        normalized.contains('ultima') ||
        normalized.contains('recente') ||
        normalized.contains('piu recente')) {
      return 'latest';
    }

    return 'latest';
  }
}
