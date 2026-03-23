import 'package:gen_ui_poc/features/chat/application/models/chat_intent.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_mode.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_request.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_response_plan.dart';
import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

class ChatOrchestrator {
  const ChatOrchestrator();

  ChatResponsePlan buildPlan({
    required ChatRequest request,
    required ChatMode currentMode,
    required bool hasInProgressQuoteFlow,
  }) {
    switch (request.intent) {
      case ChatIntent.listQuotes:
        return ShowQuotesListPlan(
          pauseInProgressQuoteFlow:
              currentMode == ChatMode.quoteFlow && hasInProgressQuoteFlow,
        );
      case ChatIntent.startQuote:
        return StartQuoteFlowPlan(
          QuoteFlowConfig(
            product: request.product ?? QuoteProduct.auto,
            focusCoverage: request.focusCoverage,
            quoteScope: request.quoteScope,
          ),
        );
      case ChatIntent.insuranceFaq:
        return AnswerWithModelPlan(
          prompt: request.originalText,
          pauseInProgressQuoteFlow:
              currentMode == ChatMode.quoteFlow && hasInProgressQuoteFlow,
        );
    }
  }
}
