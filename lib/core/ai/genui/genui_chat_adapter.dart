import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gen_ui_poc/core/ai/genui/event_driven_widget.dart';
import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';

class GenUiChatAdapter {
  GenUiChatAdapter({
    required this.apiKey,
    required String systemInstruction,
    this.onSurfaceAdded,
    this.onSurfaceUpdated,
    this.onSurfaceDeleted,
    this.onTextResponse,
    this.onUserInteraction,
    this.onError,
  }) {
    _catalog = _buildCatalog();
    _createRuntime(systemInstruction);
  }

  final String apiKey;
  final ValueChanged<SurfaceAdded>? onSurfaceAdded;
  final ValueChanged<SurfaceUpdated>? onSurfaceUpdated;
  final ValueChanged<SurfaceRemoved>? onSurfaceDeleted;
  final ValueChanged<String>? onTextResponse;
  final ValueChanged<UserUiInteractionMessage>? onUserInteraction;
  final ValueChanged<ContentGeneratorError>? onError;

  late final Catalog _catalog;

  GoogleGenerativeAiContentGenerator? _contentGenerator;
  A2uiMessageProcessor? _messageProcessor;
  final List<ChatMessage> _history = [];

  StreamSubscription<A2uiMessage>? _a2uiSubscription;
  StreamSubscription<GenUiUpdate>? _surfaceUpdateSubscription;
  StreamSubscription<String>? _textResponseSubscription;
  StreamSubscription<ContentGeneratorError>? _errorSubscription;
  StreamSubscription<UserUiInteractionMessage>? _userInteractionSubscription;

  Catalog get catalog => _catalog;
  A2uiMessageProcessor? get messageProcessor => _messageProcessor;
  GenUiHost? get host => _messageProcessor;

  Future<void> sendText(String text) async {
    await _sendMessage(UserMessage.text(text));
  }

  Future<void> sendUiInteraction(UserUiInteractionMessage message) async {
    await _sendMessage(message);
  }

  void restart({required String systemInstruction}) {
    _disposeRuntime();
    _history.clear();
    _createRuntime(systemInstruction);
  }

  void dispose() {
    _disposeRuntime();
  }

  Catalog _buildCatalog() {
    final coreCatalog = CoreCatalogItems.asCatalog();
    final eventDrivenCatalog = EventDrivenCatalog.build();
    const customAllowedNames = {
      'info_card',
      'comparison_card',
      'pros_cons_card',
      'quote_compact_summary',
    };

    final itemsByName = <String, CatalogItem>{
      for (final item in coreCatalog.items) item.name: item,
    };
    for (final item in eventDrivenCatalog.items) {
      if (customAllowedNames.contains(item.name)) {
        itemsByName[item.name] = item;
      }
    }

    final catalog = Catalog(
      itemsByName.values.toList(),
      catalogId: 'genui_native_merged_1_0_0',
    );

    debugPrint('Catalog: ${catalog.items.length} widgets');
    return catalog;
  }

  void _createRuntime(String systemInstruction) {
    final messageProcessor = A2uiMessageProcessor(catalogs: [_catalog]);
    final contentGenerator = GoogleGenerativeAiContentGenerator(
      catalog: _catalog,
      systemInstruction: systemInstruction,
      modelName: 'models/gemini-2.5-flash',
      apiKey: apiKey,
    );

    _messageProcessor = messageProcessor;
    _contentGenerator = contentGenerator;

    _a2uiSubscription = contentGenerator.a2uiMessageStream.listen(
      messageProcessor.handleMessage,
    );
    _surfaceUpdateSubscription = messageProcessor.surfaceUpdates.listen(
      _handleSurfaceUpdate,
    );
    _textResponseSubscription = contentGenerator.textResponseStream.listen(
      _handleTextResponse,
    );
    _errorSubscription = contentGenerator.errorStream.listen(_handleError);
    _userInteractionSubscription = messageProcessor.onSubmit.listen(
      onUserInteraction,
    );
  }

  Future<void> _sendMessage(ChatMessage message) async {
    final contentGenerator = _contentGenerator;
    final messageProcessor = _messageProcessor;
    if (contentGenerator == null || messageProcessor == null) {
      return;
    }

    if (message is! UserUiInteractionMessage) {
      _history.add(message);
    }

    final clientCapabilities = A2UiClientCapabilities(
      supportedCatalogIds: messageProcessor.catalogs
          .map((c) => c.catalogId)
          .whereType<String>()
          .toList(),
    );

    await contentGenerator.sendRequest(
      message,
      history: _history,
      clientCapabilities: clientCapabilities,
    );
  }

  void _handleSurfaceUpdate(GenUiUpdate update) {
    switch (update) {
      case SurfaceAdded():
        _history.add(
          AiUiMessage(
            definition: update.definition,
            surfaceId: update.surfaceId,
          ),
        );
        onSurfaceAdded?.call(update);
      case SurfaceUpdated():
        final index = _history.lastIndexWhere(
          (m) => m is AiUiMessage && m.surfaceId == update.surfaceId,
        );
        final message = AiUiMessage(
          definition: update.definition,
          surfaceId: update.surfaceId,
        );
        if (index == -1) {
          _history.add(message);
        } else {
          _history[index] = message;
        }
        onSurfaceUpdated?.call(update);
      case SurfaceRemoved():
        _history.removeWhere(
          (m) => m is AiUiMessage && m.surfaceId == update.surfaceId,
        );
        onSurfaceDeleted?.call(update);
    }
  }

  void _handleTextResponse(String text) {
    _history.add(AiTextMessage.text(text));
    onTextResponse?.call(text);
  }

  void _handleError(ContentGeneratorError error) {
    _history.add(AiTextMessage.text('An error occurred: ${error.error}'));
    onError?.call(error);
  }

  void _disposeRuntime() {
    _a2uiSubscription?.cancel();
    _surfaceUpdateSubscription?.cancel();
    _textResponseSubscription?.cancel();
    _errorSubscription?.cancel();
    _userInteractionSubscription?.cancel();
    _contentGenerator?.dispose();
    _messageProcessor?.dispose();
    _contentGenerator = null;
    _messageProcessor = null;
  }
}
