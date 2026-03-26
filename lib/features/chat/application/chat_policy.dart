import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

class ChatPolicy {
  const ChatPolicy();

  bool canStartQuote({
    required QuoteProduct product,
    required bool isSupportedInChat,
  }) {
    return isSupportedInChat;
  }

  bool canResume({required bool hasPausedQuoteFlow}) {
    return hasPausedQuoteFlow;
  }

  bool canShowQuoteDetails({required bool hasSavedQuotes}) {
    return hasSavedQuotes;
  }

  bool shouldPauseForFaq({
    required bool hasInProgressQuoteFlow,
    required bool isQuoteFlowMode,
  }) {
    return hasInProgressQuoteFlow && isQuoteFlowMode;
  }

  bool shouldPauseForQuoteDetails({
    required bool hasInProgressQuoteFlow,
    required bool isQuoteFlowMode,
  }) {
    return hasInProgressQuoteFlow && isQuoteFlowMode;
  }
}
