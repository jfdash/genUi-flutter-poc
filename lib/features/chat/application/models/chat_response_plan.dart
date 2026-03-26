import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_response_renderer.dart';

sealed class ChatResponsePlan {
  const ChatResponsePlan();

  ChatResponseRenderer get renderer;
}

class ShowQuotesListPlan extends ChatResponsePlan {
  final bool pauseActiveQuoteFlow;

  const ShowQuotesListPlan({this.pauseActiveQuoteFlow = false});

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.native;
}

class StartQuoteFlowPlan extends ChatResponsePlan {
  final QuoteFlowConfig config;

  const StartQuoteFlowPlan(this.config);

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.genUiFlow;
}

class ResumeQuotePlan extends ChatResponsePlan {
  final bool pauseActiveQuoteFlow;

  const ResumeQuotePlan({this.pauseActiveQuoteFlow = false});

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.genUiFlow;
}

class ShowQuoteDetailsPlan extends ChatResponsePlan {
  final String? targetQuoteReference;
  final bool pauseActiveQuoteFlow;

  const ShowQuoteDetailsPlan({
    this.targetQuoteReference,
    this.pauseActiveQuoteFlow = false,
  });

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.native;
}

class AnswerWithModelPlan extends ChatResponsePlan {
  final String prompt;
  final bool pauseActiveQuoteFlow;

  const AnswerWithModelPlan({
    required this.prompt,
    this.pauseActiveQuoteFlow = false,
  });

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.modelText;
}

class UnsupportedProductPlan extends ChatResponsePlan {
  final String message;

  const UnsupportedProductPlan({required this.message});

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.native;
}

class ClarifyIntentPlan extends ChatResponsePlan {
  final String message;

  const ClarifyIntentPlan({required this.message});

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.native;
}

class FallbackInfoPlan extends ChatResponsePlan {
  final String message;
  final bool pauseActiveQuoteFlow;

  const FallbackInfoPlan({
    required this.message,
    this.pauseActiveQuoteFlow = false,
  });

  @override
  ChatResponseRenderer get renderer => ChatResponseRenderer.native;
}
