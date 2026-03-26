// lib/core/service/ai_service_event_driven.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gen_ui_poc/core/ai/genui/genui_chat_adapter.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/core/logging/genui_logger.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/features/chat/application/chat_intent_detector.dart';
import 'package:gen_ui_poc/features/chat/application/chat_orchestrator.dart';
import 'package:gen_ui_poc/features/chat/application/chat_request_normalizer.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_mode.dart';
import 'package:gen_ui_poc/features/chat/application/models/chat_response_plan.dart';
import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_completion_result.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_flow_state.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_flow_status.dart';
import 'package:gen_ui_poc/features/quote/application/quote_flow_orchestrator.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_widget_type.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';
import 'package:gen_ui_poc/features/quote/core/quote_product_registry.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';
import 'package:genui/genui.dart';

class AIServiceEventDriven extends ChangeNotifier {
  static const _quoteSurfaceId = 'auto_quote_flow';
  static const _quoteSubmitAction = 'quote_step_submit';

  GenUiChatAdapter? _genUiAdapter;

  bool _isInitialized = false;
  String? _error;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _pendingGenUiTurn = false;
  bool _surfaceReceivedInPendingTurn = false;
  int _invalidQuoteSurfaceRetryCount = 0;

  bool _quoteCompleted = false;
  CompletedQuote? _lastCompletedQuote;
  Map<String, Object?>? _lastSurfaceSnapshot;
  ChatMode _chatMode = ChatMode.general;
  final ChatIntentDetector _intentDetector = ChatIntentDetector();
  final ChatRequestNormalizer _requestNormalizer = ChatRequestNormalizer();
  final ChatOrchestrator _chatOrchestrator = const ChatOrchestrator();
  final QuoteProductRegistry _productRegistry = QuoteProductRegistry();
  QuoteFlowConfig _activeQuoteConfig = const QuoteFlowConfig(
    product: QuoteProduct.auto,
  );
  QuoteFlowState? _activeFlowState;
  late final QuoteFlowOrchestrator _quoteFlowOrchestrator;

  void Function(CompletedQuote quote)? onQuoteCompleted;

  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  GenUiHost? get host => _genUiAdapter?.host;
  A2uiMessageProcessor? get messageProcessor => _genUiAdapter?.messageProcessor;
  bool get quoteCompleted => _quoteCompleted;
  CompletedQuote? get lastCompletedQuote => _lastCompletedQuote;
  Map<String, Object?>? get lastSurfaceSnapshot => _lastSurfaceSnapshot;
  ChatMode get chatMode => _chatMode;
  int get activeFieldCount =>
      _chatMode == ChatMode.quoteFlow
          ? _activeFlowState?.draft.collectedData.length ?? 0
          : 0;
  String get welcomeMessage =>
      'Ciao! Posso aiutarti a vedere i tuoi preventivi, crearne uno nuovo '
      'o spiegarti le coperture assicurative.\n\n'
      'Prova con "mostrami i miei preventivi", "voglio un nuovo preventivo auto" '
      'oppure "mi serve un preventivo viaggio".';

  AIServiceEventDriven() {
    _initialize();
  }

  void _initialize() {
    try {
      GenUiLogger.lifecycle('Initializing AIServiceEventDriven');
      _quoteFlowOrchestrator = QuoteFlowOrchestrator(
        productRegistry: _productRegistry,
        quoteStorageRepository: quoteStorageRepository,
        coverageCalculator: CoverageCalculator(),
      );

      final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _error = 'API Key non configurata';
        _isInitialized = false;
        GenUiLogger.error('Initialization failed: missing GOOGLE_AI_API_KEY');
        notifyListeners();
        return;
      }

      _genUiAdapter = GenUiChatAdapter(
        apiKey: apiKey,
        systemInstruction: _getEventDrivenSystemInstruction(),
        onSurfaceAdded: _handleSurfaceAdded,
        onSurfaceUpdated: _handleSurfaceUpdated,
        onTextResponse: _handleTextResponse,
        onUserInteraction: _handleUserInteraction,
        onError: _handleGenUiError,
      );

      _isInitialized = true;
      _error = null;
      GenUiLogger.success(
        'AIServiceEventDriven initialized',
        data: {
          'chatMode': _chatMode,
          'activeProduct': _activeQuoteConfig.product,
        },
      );
      notifyListeners();
    } catch (e, stack) {
      _error = 'Errore: $e';
      _isInitialized = false;
      GenUiLogger.error(
        'Initialization failed',
        data: {
          'error': e.toString(),
          'stackTrace': stack.toString(),
        },
      );
      debugPrint('Init error: $e\n$stack');
      notifyListeners();
    }
  }

  void _handleSurfaceAdded(SurfaceAdded update) {
    if (!_acceptSurfaceUpdate(update.definition)) {
      return;
    }

    _surfaceReceivedInPendingTurn = true;
    _messages.removeWhere((m) => m['role'] == 'assistant_widget');
    _messages.add({
      'role': 'assistant_widget',
      'surfaceId': update.surfaceId,
      'timestamp': DateTime.now(),
    });
    _lastSurfaceSnapshot = _buildSurfaceSnapshot(
      surfaceId: update.surfaceId,
      definition: update.definition,
    );
    GenUiLogger.surface(
      'Surface added',
      data: {
        'surfaceId': update.surfaceId,
        'rootComponentId': update.definition.rootComponentId,
        'componentCount': update.definition.components.length,
        'chatMode': _chatMode,
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  void _handleSurfaceUpdated(SurfaceUpdated update) {
    if (!_acceptSurfaceUpdate(update.definition)) {
      return;
    }

    _surfaceReceivedInPendingTurn = true;
    _lastSurfaceSnapshot = _buildSurfaceSnapshot(
      surfaceId: update.surfaceId,
      definition: update.definition,
    );
    GenUiLogger.surface(
      'Surface updated',
      data: {
        'surfaceId': update.surfaceId,
        'rootComponentId': update.definition.rootComponentId,
        'componentCount': update.definition.components.length,
        'chatMode': _chatMode,
      },
    );
    _isLoading = false;
    notifyListeners();
  }

  void _handleTextResponse(String text) {
    if (text.trim().isEmpty) {
      GenUiLogger.warning('Ignored empty text response');
      _pendingGenUiTurn = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_shouldSuppressInternalQuoteFlowText(text)) {
      GenUiLogger.genui(
        'Suppressed internal quote-flow text response',
        data: {'preview': _truncate(text)},
      );
      _pendingGenUiTurn = false;
      _surfaceReceivedInPendingTurn = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_pendingGenUiTurn && _surfaceReceivedInPendingTurn) {
      GenUiLogger.genui(
        'Ignored text response because surface already rendered',
        data: {'preview': _truncate(text)},
      );
      _pendingGenUiTurn = false;
      _surfaceReceivedInPendingTurn = false;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _messages.add({
      'role': 'assistant',
      'content': text,
      'timestamp': DateTime.now(),
    });
    GenUiLogger.genui(
      'Assistant text response accepted',
      data: {'preview': _truncate(text)},
    );
    _isLoading = false;
    _pendingGenUiTurn = false;
    _surfaceReceivedInPendingTurn = false;
    notifyListeners();
  }

  void _handleGenUiError(ContentGeneratorError error) {
    _error = error.error.toString();
    GenUiLogger.error(
      'GenUI runtime error',
      data: {'error': error.error.toString()},
    );
    _isLoading = false;
    _pendingGenUiTurn = false;
    _surfaceReceivedInPendingTurn = false;
    notifyListeners();
  }

  Future<void> _handleUserInteraction(UserUiInteractionMessage message) async {
    final payload = _parseUiInteraction(message.text);
    if (payload == null) {
      GenUiLogger.warning(
        'Discarded UI interaction with invalid payload',
        data: {'raw': _truncate(message.text)},
      );
      return;
    }

    final actionName = payload['name'] as String?;
    GenUiLogger.event(
      'Received UI interaction',
      data: {
        'actionName': actionName,
        'surfaceId': payload['surfaceId'],
        'chatMode': _chatMode,
      },
    );
    if (actionName != _quoteSubmitAction) {
      await _sendUiInteractionMessage(message);
      return;
    }

    final context = (payload['context'] as Map?)?.cast<String, dynamic>() ?? const {};
    final stepId = context['step_id'] as String?;
    final surfaceId = payload['surfaceId'] as String? ?? _quoteSurfaceId;

    if (_chatMode != ChatMode.quoteFlow || stepId == null) {
      await _sendUiInteractionMessage(message);
      return;
    }

    final collectedData = _extractCollectedDataFromSurface(surfaceId);
    GenUiLogger.data(
      'Collected draft data from surface',
      data: {
        'surfaceId': surfaceId,
        'stepId': stepId,
        'collectedData': collectedData,
      },
    );
    final flowState = _quoteFlowOrchestrator.createFlowState(
      config: _activeQuoteConfig,
      collectedData: collectedData,
      status: QuoteFlowStatus.active,
    );
    _activeFlowState = flowState;
    notifyListeners();

    if (flowState.canComplete) {
      await _completeQuote(flowState);
      return;
    }

    await _sendUiInteractionMessage(message);
  }

  void addMessage(String role, String content) {
    _messages.add({
      'role': role,
      'content': content,
      'timestamp': DateTime.now(),
    });
    notifyListeners();
  }

  void addStructuredMessage(String role, Map<String, dynamic> data) {
    _messages.add({'role': role, ...data, 'timestamp': DateTime.now()});
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_genUiAdapter == null) return;

    GenUiLogger.input(
      'User message received',
      data: {
        'text': text,
        'chatMode': _chatMode,
        'hasActiveFlow': _activeFlowState?.status == QuoteFlowStatus.active,
        'hasPausedFlow': _activeFlowState?.isPaused ?? false,
      },
    );

    _messages.add({
      'role': 'user',
      'content': text,
      'timestamp': DateTime.now(),
    });
    _error = null;
    notifyListeners();

    final intent = _intentDetector.detect(text);
    final request = _requestNormalizer.normalize(
      originalText: text,
      intent: intent,
    );
    GenUiLogger.intent(
      'Intent detected and request normalized',
      data: {
        'intent': intent,
        'product': request.product,
        'focusCoverage': request.focusCoverage,
        'quoteScope': request.quoteScope,
        'targetQuoteReference': request.targetQuoteReference,
        'confidence': request.confidence,
      },
    );

    final requestedProduct = request.product ?? QuoteProduct.auto;
    final requestedProductModule = _productRegistry.getModule(requestedProduct);

    final plan = _chatOrchestrator.buildPlan(
      request: request,
      currentMode: _chatMode,
      hasInProgressQuoteFlow:
          _activeFlowState != null &&
          _activeFlowState!.status == QuoteFlowStatus.active,
      hasPausedQuoteFlow: _activeFlowState?.isPaused ?? false,
      hasSavedQuotes: quoteStorageRepository.count > 0,
      isRequestedProductSupported:
          requestedProductModule?.isFlowSupportedInChat ?? false,
    );
    GenUiLogger.plan(
      'Built response plan',
      data: {
        'plan': _describePlan(plan),
        'renderer': plan.renderer,
        'currentMode': _chatMode,
        'hasInProgressQuoteFlow':
            _activeFlowState != null &&
            _activeFlowState!.status == QuoteFlowStatus.active,
        'hasPausedQuoteFlow': _activeFlowState?.isPaused ?? false,
      },
    );

    await _handleResponsePlan(plan);
  }

  Future<void> _handleResponsePlan(ChatResponsePlan plan) async {
    GenUiLogger.plan(
      'Handling response plan',
      data: {
        'plan': _describePlan(plan),
        'renderer': plan.renderer,
      },
    );
    switch (plan) {
      case ShowQuotesListPlan():
        if (plan.pauseActiveQuoteFlow) {
          _pauseActiveQuoteFlow();
          addMessage(
            'assistant',
            'Ho messo in pausa il flusso preventivo e ti mostro i preventivi salvati.',
          );
        }
        _showSavedQuotes();
      case StartQuoteFlowPlan():
        await _startQuoteFlow(plan.config);
      case ResumeQuotePlan():
        if (plan.pauseActiveQuoteFlow) {
          _pauseActiveQuoteFlow();
        }
        await _resumePausedQuoteFlow();
      case ShowQuoteDetailsPlan():
        if (plan.pauseActiveQuoteFlow) {
          _pauseActiveQuoteFlow();
          addMessage(
            'assistant',
            'Ho messo in pausa il flusso preventivo e apro il dettaglio del preventivo salvato.',
          );
        }
        _showQuoteDetails(plan.targetQuoteReference);
      case AnswerWithModelPlan():
        if (plan.pauseActiveQuoteFlow) {
          _pauseActiveQuoteFlow();
          addMessage(
            'assistant',
            'Ho messo in pausa il flusso preventivo per rispondere alla tua richiesta.',
          );
        }
        await _sendConversationMessage(plan.prompt);
      case UnsupportedProductPlan():
        _addFallbackMessage(plan.message);
      case ClarifyIntentPlan():
        _addFallbackMessage(plan.message);
      case FallbackInfoPlan():
        if (plan.pauseActiveQuoteFlow) {
          _pauseActiveQuoteFlow();
        }
        _addFallbackMessage(plan.message);
    }
  }

  Future<void> _sendConversationMessage(String text) async {
    if (_genUiAdapter == null) return;

    GenUiLogger.genui(
      'Sending conversation message to GenUI runtime',
      data: {
        'chatMode': _chatMode,
        'preview': _truncate(text),
      },
    );
    _isLoading = true;
    _error = null;
    _pendingGenUiTurn = true;
    _surfaceReceivedInPendingTurn = false;
    notifyListeners();

    try {
      await _genUiAdapter!.sendText(text);
    } catch (e) {
      _error = e.toString();
      GenUiLogger.error(
        'Failed to send conversation message',
        data: {'error': e.toString()},
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _sendUiInteractionMessage(UserUiInteractionMessage message) async {
    if (_genUiAdapter == null) return;

    GenUiLogger.event(
      'Forwarding UI interaction to GenUI runtime',
      data: {'payload': _truncate(message.text)},
    );
    _isLoading = true;
    _error = null;
    _pendingGenUiTurn = true;
    _surfaceReceivedInPendingTurn = false;
    notifyListeners();

    try {
      await _genUiAdapter!.sendUiInteraction(message);
    } catch (e) {
      _error = e.toString();
      GenUiLogger.error(
        'Failed to send UI interaction',
        data: {'error': e.toString()},
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _startQuoteFlow(QuoteFlowConfig config) async {
    final productModule = _productRegistry.getModule(config.product);
    if (productModule == null) {
      GenUiLogger.warning(
        'Requested quote flow for unknown product module',
        data: {'product': config.product},
      );
      addMessage(
        'assistant',
        'Questo prodotto non è ancora disponibile in chat. Per ora posso aiutarti con i preventivi auto.',
      );
      return;
    }
    if (!productModule.isFlowSupportedInChat) {
      GenUiLogger.warning(
        'Requested quote flow for unsupported chat product',
        data: {'product': config.product},
      );
      addMessage(
        'assistant',
        productModule.unavailableInChatMessage,
      );
      return;
    }

    _activeQuoteConfig = config;
    _chatMode = ChatMode.quoteFlow;
    _quoteCompleted = false;
    _lastCompletedQuote = null;

    _restartConversation();
    _messages.removeWhere((message) => message['role'] == 'assistant_widget');
    GenUiLogger.mode(
      'Switched to quoteFlow mode',
      data: {
        'product': config.product,
        'focusCoverage': config.focusCoverage,
        'quoteScope': config.quoteScope,
      },
    );
    notifyListeners();

    final initialFlowState = _quoteFlowOrchestrator.createFlowState(
      config: config,
      collectedData: const {},
      status: QuoteFlowStatus.active,
    );
    _activeFlowState = initialFlowState;
    await _requestQuoteStepFromGenUi(initialFlowState, isInitialRender: true);
  }

  void _showSavedQuotes() {
    _chatMode = ChatMode.general;
    _messages.removeWhere((message) => message['role'] == 'assistant_widget');
    _lastSurfaceSnapshot = null;
    _restartConversation();

    final quotes = quoteStorageRepository.getAllQuotes();
    GenUiLogger.data(
      'Loaded saved quotes',
      data: {'count': quotes.length},
    );
    if (quotes.isEmpty) {
      addStructuredMessage('assistant_quotes_empty', {});
      return;
    }

    addStructuredMessage('assistant_quotes_list', {'quotes': quotes});
  }

  void _showQuoteDetails(String? targetQuoteReference) {
    final quote = switch (targetQuoteReference) {
      'latest' || null => quoteStorageRepository.getLatestQuote(),
      _ => quoteStorageRepository.getLatestQuote(),
    };

    if (quote == null) {
      _addFallbackMessage(
        'Non ho trovato un preventivo da aprire. Posso mostrarti l’elenco dei preventivi salvati.',
      );
      return;
    }

    addMessage(
      'assistant',
      'Ti apro il dettaglio del preventivo ${quote.id.substring(0, 8).toUpperCase()}.',
    );
    navigatorRepository.pushToRoute<void>(
      '/confirmation',
      params: {'quote': quote},
    );
    GenUiLogger.success(
      'Opened quote details',
      data: {
        'quoteId': quote.id,
        'targetQuoteReference': targetQuoteReference ?? 'latest',
      },
    );
  }

  void _addFallbackMessage(String message) {
    _chatMode = ChatMode.general;
    _messages.removeWhere((entry) => entry['role'] == 'assistant_widget');
    _lastSurfaceSnapshot = null;
    addMessage('assistant', message);
    GenUiLogger.warning(
      'Fallback response delivered',
      data: {
        'message': message,
        'chatMode': _chatMode,
      },
    );
  }

  void _pauseActiveQuoteFlow() {
    if (_activeFlowState == null) {
      GenUiLogger.warning('Pause requested without active flow state');
      return;
    }

    _activeFlowState = _activeFlowState!.copyWith(
      status: QuoteFlowStatus.paused,
    );
    _chatMode = ChatMode.general;
    _messages.removeWhere((message) => message['role'] == 'assistant_widget');
    _lastSurfaceSnapshot = null;
    _restartConversation();
    GenUiLogger.mode(
      'Paused active quote flow',
      data: {
        'product': _activeFlowState?.draft.config.product,
        'completedStepIds': _activeFlowState?.completedStepIds,
      },
    );
  }

  Future<void> _resumePausedQuoteFlow() async {
    final pausedState = _activeFlowState;
    if (pausedState == null || !pausedState.isPaused) {
      GenUiLogger.warning('Resume requested without paused flow');
      return;
    }

    _chatMode = ChatMode.quoteFlow;
    _activeQuoteConfig = pausedState.draft.config;
    final module = _productRegistry.getModule(_activeQuoteConfig.product);
    if (module != null && !module.supportsResumeInChat) {
      _addFallbackMessage(
        'Il prodotto ${module.displayName.toLowerCase()} non supporta ancora la ripresa del flusso in chat.',
      );
      return;
    }
    _restartConversation();
    _activeFlowState = pausedState.copyWith(status: QuoteFlowStatus.active);
    GenUiLogger.mode(
      'Resumed quote flow',
      data: {
        'product': _activeQuoteConfig.product,
        'currentStep': _activeFlowState?.currentStep?.id,
      },
    );
    await _requestQuoteStepFromGenUi(_activeFlowState!);
  }

  void _restartConversation() {
    GenUiLogger.lifecycle(
      'Restarting GenUI conversation runtime',
      data: {
        'chatMode': _chatMode,
        'activeProduct': _activeQuoteConfig.product,
      },
    );
    _error = null;
    _isLoading = false;
    _pendingGenUiTurn = false;
    _surfaceReceivedInPendingTurn = false;
    _invalidQuoteSurfaceRetryCount = 0;
    if (_chatMode != ChatMode.quoteFlow) {
      _lastSurfaceSnapshot = null;
    }
    _genUiAdapter?.restart(
      systemInstruction: _getEventDrivenSystemInstruction(),
    );
  }

  void reset() {
    GenUiLogger.lifecycle('Resetting AI service state');
    _messages.clear();
    _chatMode = ChatMode.general;
    _activeFlowState = null;
    _quoteCompleted = false;
    _lastCompletedQuote = null;
    _lastSurfaceSnapshot = null;
    _restartConversation();
    notifyListeners();
  }

  Future<void> _completeQuote(QuoteFlowState flowState) async {
    if (_quoteCompleted) return;

    _quoteCompleted = true;
    GenUiLogger.flow(
      'Completing quote flow',
      data: {
        'product': flowState.draft.config.product,
        'missingFieldIds': flowState.missingFieldIds,
        'completedStepIds': flowState.completedStepIds,
      },
    );
    QuoteCompletionResult result = const QuoteCompletionResult.failure(
      'Completamento non riuscito',
    );
    try {
      result = await _quoteFlowOrchestrator.completeQuote(flowState: flowState);
    } catch (e, stack) {
      GenUiLogger.error(
        'Quote completion threw exception',
        data: {
          'error': e.toString(),
          'stackTrace': stack.toString(),
        },
      );
      debugPrint('Quote completion error: $e\n$stack');
    }

    if (result.quote != null) {
      _activeFlowState = flowState.copyWith(status: QuoteFlowStatus.completed);
      _lastCompletedQuote = result.quote;
      _chatMode = ChatMode.general;
      GenUiLogger.success(
        'Quote completed successfully',
        data: {
          'quoteId': result.quote!.id,
          'totalPrice': result.quote!.totalPrice,
          'essentialPrice': result.quote!.essentialPrice,
          'product': flowState.draft.config.product,
        },
      );
      notifyListeners();
      await _requestQuoteSummaryFromGenUi(result.quote!);
      onQuoteCompleted?.call(result.quote!);
    } else {
      _quoteCompleted = false;
      _error = result.error;
      GenUiLogger.error(
        'Quote completion failed',
        data: {'error': result.error},
      );
      notifyListeners();
    }
  }

  String _getEventDrivenSystemInstruction() {
    if (_chatMode != ChatMode.quoteFlow) {
      return '''
Sei un assistente assicurativo AI. Rispondi SEMPRE in italiano.

Modalita corrente: chat generale.
- rispondi in testo semplice
- non avviare wizard o flow preventivo se non ricevi una istruzione interna esplicita
- non creare surface GenUI per richieste informative o FAQ
- se l'utente chiede spiegazioni su coperture, rispondi in modo chiaro e sintetico
- non mostrare istruzioni interne
''';
    }

    final module = _productRegistry.getModule(_activeQuoteConfig.product);
    final flowPrompt =
        module?.buildFlowPromptDescription(_activeQuoteConfig) ??
        'Nessun flow disponibile per il prodotto corrente.';

    return '''
Sei un assistente assicurativo AI. Rispondi SEMPRE in italiano.

Puoi rispondere in testo semplice oppure costruire interfacce con i widget del catalogo GenUI.
Quando lavori nel flusso preventivo:
- usa SEMPRE e solo la surface con id "$_quoteSurfaceId"
- aggiorna la stessa surface step dopo step, non crearne di nuove
- usa i widget core di GenUI: Column, Text, TextField, MultipleChoice, Slider, DateTimeInput, Button, Divider
- salva i valori nel data model sotto il path "/draft/<field_id>"
- per MultipleChoice a selezione singola salva l'array su "/draft/<field_id>_selection"
- il Button finale di ogni step deve dispatchare l'azione "$_quoteSubmitAction"
- nel context del Button invia almeno il valore letterale "step_id"
- non produrre testo puro insieme alla surface dello step
- non mostrare istruzioni interne

Quando ricevi un submit di step, aggiorna la surface "$_quoteSurfaceId" mostrando SOLO lo step successivo.
Quando ricevi un'istruzione interna di riepilogo finale, aggiorna la stessa surface "$_quoteSurfaceId" con un unico widget quote_compact_summary.

Widget custom disponibili fuori dal wizard o per il riepilogo finale:
- info_card
- comparison_card
- pros_cons_card
- quote_compact_summary

FLOW CORRENTE:
$flowPrompt
''';
  }

  Future<void> _requestQuoteStepFromGenUi(
    QuoteFlowState flowState, {
    bool isInitialRender = false,
  }) async {
    _activeFlowState = flowState;
    _invalidQuoteSurfaceRetryCount = 0;
    GenUiLogger.flow(
      'Requesting quote step render',
      data: {
        'product': flowState.draft.config.product,
        'stepId': flowState.currentStep?.id,
        'stepTitle': flowState.currentStep?.title,
        'isInitialRender': isInitialRender,
        'missingFieldIds': flowState.missingFieldIds,
      },
    );
    await _sendConversationMessage(
      _buildQuoteStepInstruction(flowState, isInitialRender: isInitialRender),
    );
  }

  String _buildQuoteStepInstruction(
    QuoteFlowState flowState, {
    bool isInitialRender = false,
  }) {
    final step = flowState.currentStep;
    if (step == null) {
      return '''
ISTRUZIONE INTERNA:
Non ci sono altri step da mostrare.
''';
    }

    final buffer = StringBuffer();
    buffer.writeln('ISTRUZIONE INTERNA QUOTEFLOW:');
    buffer.writeln(
      isInitialRender
          ? 'Crea adesso la surface "$_quoteSurfaceId" per lo step "${step.title}".'
          : 'Aggiorna la surface "$_quoteSurfaceId" per lo step "${step.title}".',
    );
    buffer.writeln('Renderizza SOLO lo step corrente del prodotto ${flowState.draft.config.product.name}.');
    buffer.writeln('Usa una Column con ordine: testo contesto, campi dello step, bottone finale.');
    buffer.writeln('Testo iniziale: "${step.contextMessage}"');
    buffer.writeln(
      'Il Button finale deve avere action name "$_quoteSubmitAction" e context esatto con una entry: '
      '{"key":"step_id","value":{"literalString":"${step.id}"}}.',
    );
    buffer.writeln('Campi da mostrare con relativi widget e path:');
    for (final field in flowState.currentStepFields) {
      if (flowState.draft.contains(field.id)) {
        continue;
      }
      buffer.writeln('- ${_buildNativeFieldInstruction(field)}');
    }
    buffer.writeln('Usa un solo Button finale con testo "${step.submitLabel}" e action "$_quoteSubmitAction".');
    buffer.writeln('Non aggiungere altri step, altri bottoni o testo puro fuori dalla surface.');
    return buffer.toString().trimRight();
  }

  String _buildNativeFieldInstruction(QuoteFieldDefinition field) {
    final path = _pathForField(field.id, field.widgetType);
    switch (field.widgetType) {
      case QuoteFieldWidgetType.textInput:
      case QuoteFieldWidgetType.numberInput:
        return 'TextField con label "${field.label}", text path "$path"'
            '${field.widgetType == QuoteFieldWidgetType.numberInput ? ', textFieldType "number"' : ''}';
      case QuoteFieldWidgetType.slider:
        return 'Slider con value path "$path", min ${field.minInt ?? 0}, max ${field.maxInt ?? 100} e Text descrittivo "${field.label}"';
      case QuoteFieldWidgetType.choiceChips:
        return 'MultipleChoice single-select con selections path "$path", opzioni ${field.options} e label "${field.label}"';
      case QuoteFieldWidgetType.dateInput:
        return 'DateTimeInput con value path "$path", enableDate true, enableTime false e Text descrittivo "${field.label}"';
    }
  }

  String _pathForField(String fieldId, QuoteFieldWidgetType widgetType) {
    if (widgetType == QuoteFieldWidgetType.choiceChips) {
      return '/draft/${fieldId}_selection';
    }
    return '/draft/$fieldId';
  }

  bool _acceptSurfaceUpdate(UiDefinition definition) {
    final flowState = _activeFlowState;
    if (_chatMode != ChatMode.quoteFlow || flowState?.currentStep == null) {
      return true;
    }

    final validationError = _validateQuoteStepSurface(
      definition: definition,
      flowState: flowState!,
    );
    if (validationError == null) {
      _invalidQuoteSurfaceRetryCount = 0;
      GenUiLogger.surface(
        'Validated quote-flow surface',
        data: {
          'stepId': flowState!.currentStep?.id,
          'componentCount': definition.components.length,
        },
      );
      return true;
    }

    GenUiLogger.warning(
      'Invalid quote-flow surface detected',
      data: {
        'stepId': flowState.currentStep?.id,
        'validationError': validationError,
        'retryCount': _invalidQuoteSurfaceRetryCount,
      },
    );
    if (_invalidQuoteSurfaceRetryCount < 1) {
      _invalidQuoteSurfaceRetryCount++;
      unawaited(_requestQuoteStepCorrection(flowState!, validationError));
      return false;
    }

    _error = 'Surface genUi non valida per lo step corrente: $validationError';
    GenUiLogger.error(
      'Surface rejected after retry',
      data: {
        'stepId': flowState.currentStep?.id,
        'validationError': validationError,
      },
    );
    _isLoading = false;
    _pendingGenUiTurn = false;
    _surfaceReceivedInPendingTurn = false;
    notifyListeners();
    return false;
  }

  Future<void> _requestQuoteStepCorrection(
    QuoteFlowState flowState,
    String validationError,
  ) async {
    GenUiLogger.warning(
      'Requesting quote step correction from GenUI',
      data: {
        'stepId': flowState.currentStep?.id,
        'validationError': validationError,
      },
    );
    _messages.removeWhere((message) => message['role'] == 'assistant_widget');
    _isLoading = true;
    _error = null;
    notifyListeners();

    final correctionPrompt = StringBuffer()
      ..writeln(_buildQuoteStepInstruction(flowState))
      ..writeln()
      ..writeln('CORREZIONE OBBLIGATORIA:')
      ..writeln('- La surface precedente non e valida: $validationError')
      ..writeln('- Rigenera da zero la stessa surface con tutti i campi dello step corrente e un solo Button finale valido.')
      ..writeln('- Il Button finale deve essere visibile nel tree renderizzato e usare action name "$_quoteSubmitAction".');

    await _sendConversationMessage(correctionPrompt.toString().trimRight());
  }

  String? _validateQuoteStepSurface({
    required UiDefinition definition,
    required QuoteFlowState flowState,
  }) {
    final allowedPaths = flowState.currentStepFields
        .map((field) => _pathForField(field.id, field.widgetType))
        .toSet();
    final visibleComponents = _visibleComponents(definition);

    var submitButtons = 0;
    for (final component in visibleComponents) {
      final type = component.type;
      final payload = component.componentProperties[type];

      if (type == 'Button') {
        if (payload is! Map<String, Object?>) {
          return 'payload non valido per Button';
        }
        final action = payload['action'];
        if (action is! Map<String, Object?> || action['name'] != _quoteSubmitAction) {
          return 'Button finale senza action $_quoteSubmitAction';
        }
        submitButtons++;
        continue;
      }

      final boundPath = _extractBoundPath(type, payload);
      if (boundPath == null) {
        continue;
      }
      if (!allowedPaths.contains(boundPath)) {
        return 'path "$boundPath" non previsto nello step ${flowState.currentStep!.id}';
      }
    }

    if (submitButtons != 1) {
      return 'Button finali attesi: 1, trovati: $submitButtons';
    }

    return null;
  }

  Iterable<Component> _visibleComponents(UiDefinition definition) sync* {
    final rootId = definition.rootComponentId;
    if (rootId == null) {
      return;
    }

    final visited = <String>{};
    final queue = <String>[rootId];

    while (queue.isNotEmpty) {
      final componentId = queue.removeAt(0);
      if (!visited.add(componentId)) {
        continue;
      }

      final component = definition.components[componentId];
      if (component == null) {
        continue;
      }

      yield component;
      queue.addAll(_childComponentIds(component));
    }
  }

  Iterable<String> _childComponentIds(Component component) sync* {
    final type = component.type;
    final payload = component.componentProperties[type];
    if (payload is! Map<String, Object?>) {
      return;
    }

    switch (type) {
      case 'Column':
      case 'Row':
        final children = payload['children'];
        if (children is Map<String, Object?>) {
          final explicitList = children['explicitList'];
          if (explicitList is List) {
            for (final childId in explicitList.whereType<String>()) {
              yield childId;
            }
          }
        }
      case 'Card':
      case 'Button':
        final child = payload['child'];
        if (child is String) {
          yield child;
        }
    }
  }

  String? _extractBoundPath(String type, Object? payload) {
    if (payload is! Map<String, Object?>) {
      return null;
    }

    switch (type) {
      case 'TextField':
        return _extractPath(payload['text']);
      case 'Slider':
        return _extractPath(payload['value']);
      case 'DateTimeInput':
        return _extractPath(payload['value']);
      case 'MultipleChoice':
        return _extractPath(payload['selections']);
      default:
        return null;
    }
  }

  String? _extractPath(Object? ref) {
    if (ref is! Map<String, Object?>) {
      return null;
    }
    return ref['path'] as String?;
  }

  Future<void> _requestQuoteSummaryFromGenUi(CompletedQuote quote) async {
    GenUiLogger.flow(
      'Requesting final quote summary render',
      data: {
        'quoteId': quote.id,
        'coverages': quote.coverages.length,
      },
    );
    await _sendConversationMessage(_buildQuoteSummaryInstruction(quote));
  }

  String _buildQuoteSummaryInstruction(CompletedQuote quote) {
    final vehicle = quote.vehicleLabel.isEmpty ? 'preventivo assicurativo' : quote.vehicleLabel;
    final driver = quote.driverLabel.isEmpty ? 'profilo cliente disponibile' : quote.driverLabel;
    return '''
ISTRUZIONE INTERNA:
Aggiorna la surface "$_quoteSurfaceId" con un unico widget quote_compact_summary.

Valori da usare:
- quote_id: "${quote.id}"
- title: "Preventivo pronto"
- subtitle: "$vehicle per $driver"
- annual_price: ${quote.totalPrice.toStringAsFixed(0)}
- essential_price: ${quote.essentialPrice.toStringAsFixed(0)}
- coverage_count: ${quote.coverages.length}
- cta_label: "Apri dettaglio"

Non aggiungere testo puro o altri widget.
''';
  }

  Map<String, Object?> _buildSurfaceSnapshot({
    required String surfaceId,
    required UiDefinition definition,
  }) {
    final componentTypes = definition.components.entries
        .map((entry) => '${entry.key}:${entry.value.type}')
        .toList(growable: false);
    return {
      'surfaceId': surfaceId,
      'rootComponentId': definition.rootComponentId,
      'componentCount': definition.components.length,
      'componentTypes': componentTypes,
      'chatMode': _chatMode.name,
      'product':
          _activeFlowState?.draft.config.product.name ??
          _activeQuoteConfig.product.name,
    };
  }

  Map<String, dynamic> _extractCollectedDataFromSurface(String surfaceId) {
    final dataModel = _genUiAdapter?.messageProcessor?.dataModelForSurface(surfaceId);
    final rawDraft = (dataModel?.data['draft'] as Map?)?.cast<String, dynamic>() ?? const {};
    return _normalizeCollectedData(rawDraft);
  }

  Map<String, dynamic> _normalizeCollectedData(Map<String, dynamic> rawDraft) {
    final normalized = <String, dynamic>{};
    rawDraft.forEach((key, value) {
      if (key.endsWith('_selection') && value is List && value.isNotEmpty) {
        normalized[key.replaceFirst('_selection', '')] = value.first;
        return;
      }

      if (value is double && value == value.roundToDouble()) {
        normalized[key] = value.toInt();
        return;
      }

      normalized[key] = value;
    });
    return normalized;
  }

  Map<String, dynamic>? _parseUiInteraction(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final userAction = decoded['userAction'];
      if (userAction is! Map<String, dynamic>) {
        return null;
      }
      return userAction;
    } catch (_) {
      return null;
    }
  }

  bool _shouldSuppressInternalQuoteFlowText(String text) {
    final normalized = text.trim();
    if (normalized.startsWith('A user interface is shown with the following content:')) {
      return true;
    }
    if (normalized.contains('"surfaceId"') &&
        normalized.contains('"rootComponentId"') &&
        normalized.contains('"components"')) {
      return true;
    }
    if (normalized.startsWith('ISTRUZIONE INTERNA')) {
      return true;
    }

    return false;
  }

  String _describePlan(ChatResponsePlan plan) {
    return switch (plan) {
      ShowQuotesListPlan() => 'ShowQuotesListPlan',
      StartQuoteFlowPlan(config: final config) =>
        'StartQuoteFlowPlan(${config.product.name})',
      ResumeQuotePlan() => 'ResumeQuotePlan',
      ShowQuoteDetailsPlan() => 'ShowQuoteDetailsPlan',
      AnswerWithModelPlan() => 'AnswerWithModelPlan',
      UnsupportedProductPlan() => 'UnsupportedProductPlan',
      ClarifyIntentPlan() => 'ClarifyIntentPlan',
      FallbackInfoPlan() => 'FallbackInfoPlan',
    };
  }

  String _truncate(String value, {int maxLength = 240}) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= maxLength) {
      return normalized;
    }
    return '${normalized.substring(0, maxLength)}...';
  }

  @override
  void dispose() {
    _genUiAdapter?.dispose();
    super.dispose();
  }
}
