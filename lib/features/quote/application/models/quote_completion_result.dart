import 'package:gen_ui_poc/core/model/completed_quote_model.dart';

class QuoteCompletionResult {
  final CompletedQuote? quote;
  final String? error;

  const QuoteCompletionResult._({required this.quote, required this.error});

  const QuoteCompletionResult.success(CompletedQuote quote)
    : this._(quote: quote, error: null);

  const QuoteCompletionResult.failure(String error)
    : this._(quote: null, error: error);

  bool get isSuccess => quote != null;
}
