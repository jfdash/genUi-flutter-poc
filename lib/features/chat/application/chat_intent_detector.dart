import 'package:gen_ui_poc/features/chat/application/models/chat_intent.dart';

class ChatIntentDetector {
  ChatIntent detect(String input) {
    final normalized = _normalize(input);

    if (_isListQuotesRequest(normalized)) {
      return ChatIntent.listQuotes;
    }

    if (_isQuoteDetailsRequest(normalized)) {
      return ChatIntent.quoteDetails;
    }

    if (_isResumeQuoteRequest(normalized)) {
      return ChatIntent.resumeQuote;
    }

    if (_isStartQuoteRequest(normalized)) {
      return ChatIntent.startQuote;
    }

    return ChatIntent.insuranceFaq;
  }

  bool looksLikeContinuation(String input) {
    return _looksLikeQuoteContinuation(_normalize(input));
  }

  String _normalize(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9àèéìòù\\s]'), ' ')
        .replaceAll(RegExp(r'\\s+'), ' ');
  }

  bool _isListQuotesRequest(String normalized) {
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

  bool _isStartQuoteRequest(String normalized) {
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
      'preventivo viaggio',
      'assicurazione viaggio',
      'polizza viaggio',
      'travel insurance',
      'preventivo kasko',
      'polizza kasko',
      'iniziamo',
      'inizia',
      'partiamo',
      'preventivo',
    ];

    return patterns.any(normalized.contains);
  }

  bool _isResumeQuoteRequest(String normalized) {
    const patterns = [
      'continua',
      'prosegui',
      'riprendi',
      'torna al preventivo',
      'completa il preventivo',
      'riprendi il preventivo',
      'continua il preventivo',
      'vai avanti',
    ];

    return patterns.any(normalized.contains);
  }

  bool _isQuoteDetailsRequest(String normalized) {
    const patterns = [
      'mostrami l ultimo preventivo',
      'fammi vedere l ultimo preventivo',
      'apri l ultimo preventivo',
      'dettaglio preventivo',
      'dettagli preventivo',
      'vedi preventivo',
      'apri preventivo',
      'mostra il preventivo',
      'mostrami il preventivo',
      'ultimo preventivo',
      'preventivo piu recente',
    ];

    return patterns.any(normalized.contains);
  }

  bool _looksLikeQuoteContinuation(String normalized) {
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
