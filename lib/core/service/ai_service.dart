// lib/service/ai_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:gen_ui_poc/core/ai/genui/insurance_catalog_widget.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';

class AIService extends ChangeNotifier {
  GoogleGenerativeAiContentGenerator? _contentGenerator;
  GenUiConversation? _conversation;
  late final Catalog _catalog;

  GenUiConversation? get conversation => _conversation;

  bool _isInitialized = false;
  String? _error;

  Timer? _debounceTimer;

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;

  AIService() {
    _initialize();
  }

  void _initialize() {
    try {
      final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty) {
        _error = 'API Key non configurata. Controlla .env';
        _isInitialized = false;
        notifyListeners();
        return;
      }

      _catalog = InsuranceCatalog.build();

      // Utilizziamo Flash-Lite che ha limiti RPM leggermente più alti (10 RPM)
      _contentGenerator = GoogleGenerativeAiContentGenerator(
        catalog: _catalog,
        systemInstruction: _getQuoteSystemInstruction(),
        modelName: 'models/gemini-2.5-flash',
        apiKey: apiKey,
      );

      final processor = A2uiMessageProcessor(catalogs: [_catalog]);

      _conversation = GenUiConversation(
        contentGenerator: _contentGenerator!,
        a2uiMessageProcessor: processor,
        onTextResponse: _handleTextResponse,
        onSurfaceAdded: (update) => _handleUpdate('Added: ${update.surfaceId}'),
        onSurfaceUpdated: (update) => _handleUpdate('Updated: ${update.surfaceId}'),
        onError: (error) {
          debugPrint('❌ Conversation error: ${error.error}');
          // Gestione specifica per Quota Exceeded
          if (error.error.toString().contains('429') || error.error.toString().contains('quota')) {
            _error = "Limite messaggi raggiunto. Attendi 30 secondi.";
          } else {
            _error = error.error.toString();
          }
          _isLoading = false;
          notifyListeners();
        },
      );

      _isInitialized = true;
      _error = null;
      notifyListeners();
      debugPrint('✅ AIService initialized');
    } catch (e) {
      _error = 'Errore inizializzazione: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

  // --- LOGICA CORE ---

  void _handleTextResponse(String text) {
    _messages.add({'role': 'assistant', 'content': text, 'timestamp': DateTime.now()});
    _isLoading = false;
    notifyListeners();
  }

  void _handleUpdate(String info) {
    debugPrint('🎨 Surface Update: $info');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String userMessage) async {
    // Cancella ogni timer precedente se l'utente scrive ancora
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    if (!_isInitialized || _conversation == null || _isLoading) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        _isLoading = true;
        _error = null;

        _messages.add({'role': 'user', 'content': userMessage, 'timestamp': DateTime.now()});
        notifyListeners();

        await _conversation!.sendRequest(UserMessage.text(userMessage));
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // --- LOGICA SPIEGAZIONI (BATCH OPTIMIZED) ---

  /// ✅ Genera spiegazioni per TUTTE le coperture in un'unica chiamata (Batching)
  /// Risolve il problema del "Quota Exceeded" causato dai cicli for.
  Future<List<CoverageSuggestion>> enrichSuggestionsWithExplanations({
    required List<CoverageSuggestion> suggestions,
    required VehicleDataModel vehicle,
    required DriverDataModel driver,
  }) async {
    if (!_isInitialized || _contentGenerator == null || suggestions.isEmpty) {
      return suggestions;
    }

    try {
      debugPrint('🤖 Batch Enrichment: Richiedo spiegazioni per ${suggestions.length} voci');

      final prompt = _buildBatchPrompt(suggestions, vehicle, driver);

      // Utilizziamo un completer per trasformare lo stream in una risposta singola
      final completer = Completer<String>();
      String fullResponse = "";

      // Creiamo una conversazione temporanea "muta" (senza UI update) per il calcolo
      final tempConv = GenUiConversation(
        contentGenerator: _contentGenerator!,
        a2uiMessageProcessor: A2uiMessageProcessor(catalogs: [_catalog]),
        onTextResponse: (text) => fullResponse += text,
      );

      await tempConv.sendRequest(UserMessage.text(prompt));

      // Attendiamo un tempo tecnico per il completamento dello stream (Gemini Flash è quasi istantaneo)
      await Future.delayed(const Duration(milliseconds: 2500));

      final Map<String, dynamic> explanations = _parseBatchJson(fullResponse);

      // Mappiamo i risultati JSON sugli oggetti originali
      return suggestions.map((s) {
        final data = explanations[s.type.toString()] ?? {};
        return s.copyWith(
          reason: data['reason'] as String?,
          pros: data['pros'] != null ? List<String>.from(data['pros']) : null,
          cons: data['cons'] != null ? List<String>.from(data['cons']) : null,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Errore arricchimento batch: $e');
      return suggestions;
    }
  }

  String _buildBatchPrompt(
    List<CoverageSuggestion> suggestions,
    VehicleDataModel vehicle,
    DriverDataModel driver,
  ) {
    final listStr = suggestions.map((s) => "- ${s.type}: ${s.title} (${s.levelLabel})").join("\n");

    return '''
Analizza queste coperture per un'auto ${vehicle.brand} ${vehicle.model} del ${vehicle.year} a ${driver.city}.
Genera spiegazioni personalizzate in formato JSON.

COPERTURE:
$listStr

RISPONDI SOLO IN JSON:
{
  "TIPO_COPERTURA": {
    "reason": "Spiegazione breve legata al profilo",
    "pros": ["Vantaggio 1", "Vantaggio 2"],
    "cons": ["Nota di attenzione"]
  }
}
''';
  }

  Map<String, dynamic> _parseBatchJson(String text) {
    try {
      String clean = text.trim();
      if (clean.contains('```json')) {
        clean = clean.split('```json').last.split('```').first;
      }
      return jsonDecode(clean) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  // --- ISTRUZIONI SISTEMA ---

  String _getQuoteSystemInstruction() {
    return '''
Sei un assistente AI per preventivi assicurativi auto in Italia.
Usa i widget del catalogo per raccogliere i dati mancanti.
Sii sintetico, professionale e amichevole.
Se l'utente fornisce dati parziali (es. "Ho una Yaris"), chiedi il resto (anno, km) usando i widget appropriati.
Non generare widget per dati che hai già ricevuto.
''';
  }

  void reset() {
    _messages.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
