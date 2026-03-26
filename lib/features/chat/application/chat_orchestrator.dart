import 'package:gen_ui_poc/features/chat/application/chat_policy.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_intent.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_mode.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_request.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_response_plan.dart';
import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';

class ChatOrchestrator {
  const ChatOrchestrator({ChatPolicy policy = const ChatPolicy()})
    : _policy = policy;

  final ChatPolicy _policy;

  ChatResponsePlan buildPlan({
    required ChatRequest request,
    required ChatMode currentMode,
    required bool hasInProgressQuoteFlow,
    required bool hasPausedQuoteFlow,
    required bool hasSavedQuotes,
    required bool isRequestedProductSupported,
  }) {
    final isQuoteFlowMode = currentMode == ChatMode.quoteFlow;
    final requestedProduct = request.product ?? QuoteProduct.auto;

    switch (request.intent) {
      case ChatIntent.listQuotes:
        return ShowQuotesListPlan(
          pauseActiveQuoteFlow:
              hasInProgressQuoteFlow && isQuoteFlowMode,
        );
      case ChatIntent.startQuote:
        if (!_policy.canStartQuote(
          product: requestedProduct,
          isSupportedInChat: isRequestedProductSupported,
        )) {
          return UnsupportedProductPlan(
            message:
                'I preventivi ${requestedProduct.name} non sono ancora disponibili in chat. Posso aiutarti con auto e viaggio.',
          );
        }
        return StartQuoteFlowPlan(
          QuoteFlowConfig(
            product: requestedProduct,
            focusCoverage: request.focusCoverage,
            quoteScope: request.quoteScope,
          ),
        );
      case ChatIntent.resumeQuote:
        if (_policy.canResume(hasPausedQuoteFlow: hasPausedQuoteFlow)) {
          return const ResumeQuotePlan();
        }
        return const FallbackInfoPlan(
          message:
              'Non ho un preventivo in pausa da riprendere. Posso mostrarti i preventivi salvati o avviarne uno nuovo.',
        );
      case ChatIntent.quoteDetails:
        if (_policy.canShowQuoteDetails(hasSavedQuotes: hasSavedQuotes)) {
          return ShowQuoteDetailsPlan(
            targetQuoteReference: request.targetQuoteReference,
            pauseActiveQuoteFlow: _policy.shouldPauseForQuoteDetails(
              hasInProgressQuoteFlow: hasInProgressQuoteFlow,
              isQuoteFlowMode: isQuoteFlowMode,
            ),
          );
        }
        return const FallbackInfoPlan(
          message:
              'Non ho ancora preventivi salvati da mostrarti. Posso aiutarti a crearne uno nuovo.',
        );
      case ChatIntent.insuranceFaq:
        if (request.originalText.trim().length <= 2) {
          return const ClarifyIntentPlan(
            message:
                'Puoi dirmi meglio cosa ti serve? Ad esempio: vedere i preventivi, crearne uno nuovo o chiedere una spiegazione su una copertura.',
          );
        }
        return AnswerWithModelPlan(
          prompt: request.originalText,
          pauseActiveQuoteFlow: _policy.shouldPauseForFaq(
            hasInProgressQuoteFlow: hasInProgressQuoteFlow,
            isQuoteFlowMode: isQuoteFlowMode,
          ),
        );
    }
  }
}
