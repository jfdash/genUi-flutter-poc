enum ChatMode { general, quoteFlow }

enum ChatIntent { startQuote, listQuotes, generalQuestion }

class ChatIntentRouter {
  static ChatIntent detect(String input, {required ChatMode currentMode}) {
    final normalized = _normalize(input);

    if (_isListQuotesRequest(normalized)) {
      return ChatIntent.listQuotes;
    }

    if (_isStartQuoteRequest(normalized)) {
      return ChatIntent.startQuote;
    }

    if (currentMode == ChatMode.quoteFlow &&
        _looksLikeQuoteContinuation(normalized)) {
      return ChatIntent.startQuote;
    }

    return ChatIntent.generalQuestion;
  }

  static String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9àèéìòù\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _isListQuotesRequest(String normalized) {
    const patterns = [
      'miei preventivi',
      'i miei preventivi',
      'mostrami i preventivi',
      'mostra i preventivi',
      'quali sono i miei preventivi',
      'quali preventivi ho',
      'preventivi salvati',
      'preventivi che ho',
      'preventivi presenti',
      'lista preventivi',
      'elenco preventivi',
    ];

    return patterns.any(normalized.contains);
  }

  static bool _isStartQuoteRequest(String normalized) {
    const patterns = [
      'nuovo preventivo',
      'fammi un preventivo',
      'fai un preventivo',
      'voglio un preventivo',
      'crea un preventivo',
      'apri un preventivo',
      'aprire un preventivo',
      'aprirne una',
      'aprirne uno',
      'aprine una',
      'aprine uno',
      'posso aprirne una',
      'posso aprirne uno',
      'posso farne uno',
      'facciamone uno',
      'facciamolo',
      'avvia il preventivo',
      'avviamo il preventivo',
      'procedi con il preventivo',
      'vai con il preventivo',
      'preventivo auto',
      'iniziamo',
      'inizia',
      'partiamo',
      'preventivo',
    ];

    return patterns.any(normalized.contains);
  }

  static bool _looksLikeQuoteContinuation(String normalized) {
    const patterns = [
      'continua',
      'prosegui',
      'riprendi',
      'torna al preventivo',
      'completa',
      'procedi',
      'vai avanti',
    ];

    return patterns.any(normalized.contains);
  }
}
