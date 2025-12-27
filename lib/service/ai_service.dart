import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:http/http.dart' as http;

class AIService extends ChangeNotifier {
  GoogleGenerativeAiContentGenerator? _contentGenerator;
  GenUiConversation? _conversation;
  late final Catalog _catalog;
  bool _isInitialized = false;
  String? _error;

  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  GenUiConversation? get conversation => _conversation;

  AIService() {
    _initialize();
  }

  void _initialize() {
    try {
      final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
        _error = 'API Key non configurata. Controlla il file .env';
        _isInitialized = false;
        notifyListeners();
        return;
      }

      // Debug: Stampa la chiave (rimuovi in produzione!)
      debugPrint('Loaded API Key: $apiKey');

      // Crea il catalogo di widget che l'AI può usare
      // Aggiungiamo un widget semplice di test
      _catalog = Catalog([
        CatalogItem(
          name: 'text_message',
          dataSchema: S.object(
            properties: {'message': S.string(description: 'The text message to display')},
            required: ['message'],
          ),
          widgetBuilder: (CatalogItemContext context) {
            final data = context.data as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(data['message']?.toString() ?? '', style: const TextStyle(fontSize: 16)),
            );
          },
        ),
      ]);

      // Crea il content generator
      _contentGenerator = GoogleGenerativeAiContentGenerator(
        catalog: _catalog,
        systemInstruction: '''
Sei un assistente AI per un'app di assicurazioni italiana.

REGOLE:
1. Rispondi sempre in italiano
2. Sii cortese e professionale
3. Fai domande chiare per raccogliere informazioni
4. Quando hai abbastanza info, genera un riepilogo
5. Usa un linguaggio semplice e comprensibile

COMPITO:
Aiuta gli utenti a:
- Ottenere preventivi assicurativi
- Comprendere i tipi di polizze
- Rispondere a domande generali sulle assicurazioni
''',
        modelName: 'models/gemini-2.5-flash', // Modello corretto dalla lista API!
        apiKey: apiKey,
      );

      // Crea la conversazione con A2uiMessageProcessor e callbacks
      final processor = A2uiMessageProcessor(catalogs: [_catalog]);
      _conversation = GenUiConversation(
        contentGenerator: _contentGenerator!,
        a2uiMessageProcessor: processor,
        onTextResponse: _handleTextResponse,
        onError: _handleError,
      );

      _isInitialized = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Errore inizializzazione AI: $e';
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// Handler per le risposte di testo dall'AI
  void _handleTextResponse(String text) {
    _messages.add({'role': 'assistant', 'content': text, 'timestamp': DateTime.now()});
    _isLoading = false;
    notifyListeners();
  }

  /// Handler per gli errori
  void _handleError(ContentGeneratorError error) {
    _error = 'Errore AI: ${error.error}';
    _isLoading = false;
    notifyListeners();
  }

  /// Invia un messaggio e ricevi una risposta
  Future<void> sendMessage(String userMessage) async {
    if (!_isInitialized || _conversation == null) {
      _error = 'AI non inizializzata';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;

      // Aggiungi messaggio utente
      _messages.add({'role': 'user', 'content': userMessage, 'timestamp': DateTime.now()});
      notifyListeners();

      // Invia richiesta usando UserMessage.text()
      await _conversation!.sendRequest(UserMessage.text(userMessage));

      // La risposta arriverà tramite callback _handleTextResponse
    } catch (e) {
      _error = 'Errore durante la generazione: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reset della conversazione
  void resetConversation() {
    _messages.clear();
    _error = null;

    // Ricrea la conversazione
    if (_contentGenerator != null) {
      final processor = A2uiMessageProcessor(catalogs: [_catalog]);
      _conversation = GenUiConversation(
        contentGenerator: _contentGenerator!,
        a2uiMessageProcessor: processor,
        onTextResponse: _handleTextResponse,
        onError: _handleError,
      );
    }

    notifyListeners();
  }
}
