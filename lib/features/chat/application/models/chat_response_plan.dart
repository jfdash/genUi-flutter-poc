import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';

sealed class ChatResponsePlan {
  const ChatResponsePlan();
}

class ShowQuotesListPlan extends ChatResponsePlan {
  final bool pauseInProgressQuoteFlow;

  const ShowQuotesListPlan({this.pauseInProgressQuoteFlow = false});
}

class StartQuoteFlowPlan extends ChatResponsePlan {
  final QuoteFlowConfig config;

  const StartQuoteFlowPlan(this.config);
}

class AnswerWithModelPlan extends ChatResponsePlan {
  final String prompt;
  final bool pauseInProgressQuoteFlow;

  const AnswerWithModelPlan({
    required this.prompt,
    this.pauseInProgressQuoteFlow = false,
  });
}
