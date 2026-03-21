// lib/core/service/ai_service_event_driven.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gen_ui_poc/core/ai/genui/event_driven_widget.dart';
import 'package:gen_ui_poc/core/di/di.dart';
import 'package:gen_ui_poc/core/event/event_aggregator.dart';
import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';
import 'package:genui/genui.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:uuid/uuid.dart';

class AIServiceEventDriven extends ChangeNotifier {
  GoogleGenerativeAiContentGenerator? _contentGenerator;
  GenUiConversation? _conversation;
  late final Catalog _catalog;
  late final A2uiMessageProcessor _a2uiMessageProcessor;
  late final EventAggregator _eventAggregator;

  bool _isInitialized = false;
  String? _error;
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;

  // Quote completion tracking
  bool _quoteCompleted = false;
  CompletedQuote? _lastCompletedQuote;

  // Callback per notificare il completamento del preventivo
  void Function(CompletedQuote quote)? onQuoteCompleted;

  // Getters
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  GenUiConversation? get conversation => _conversation;
  A2uiMessageProcessor get messageProcessor => _a2uiMessageProcessor;
  EventAggregator get eventAggregator => _eventAggregator;
  bool get quoteCompleted => _quoteCompleted;
  CompletedQuote? get lastCompletedQuote => _lastCompletedQuote;

  AIServiceEventDriven() {
    _initialize();
  }

  void _initialize() {
    try {
      final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _error = 'API Key non configurata';
        _isInitialized = false;
        notifyListeners();
        return;
      }

      // ═══════════════════════════════════════════════════════════
      // 1. EVENT AGGREGATOR - Cuore del sistema event-driven
      // ═══════════════════════════════════════════════════════════
      _eventAggregator = EventAggregator(onReadyForAI: _onEventContextReady);

      // ═══════════════════════════════════════════════════════════
      // 2. CATALOGS - Solo Event-Driven Custom + layout base
      // ═══════════════════════════════════════════════════════════
      // NOTA: NON includere CoreCatalogItems perché i widget core (Button, ecc.)
      // usano dispatchEvent(UserActionEvent) che bypassa il nostro EventAggregator
      // e triggera direttamente GenUI → sendRequest → AI, causando avanzamenti
      // involontari del form.
      final coreCatalog = CoreCatalogItems.asCatalog();
      final eventDrivenCatalog = EventDrivenCatalog.build();

      // Prendiamo solo i widget di layout dal core (Column, Row, ecc.)
      // escludendo quelli interattivi che dispatchano eventi autonomamente
      final safeCoreName = {'Column', 'Row', 'Text', 'Divider', 'Icon', 'Image'};
      final safeCoreItems = coreCatalog.items
          .where((item) => safeCoreName.contains(item.name))
          .toList();

      _catalog = Catalog(catalogId: 'event_driven_merged_1_0_0', [
        ...safeCoreItems,
        ...eventDrivenCatalog.items,
      ]);

      debugPrint('Catalog: ${_catalog.items.length} widgets');

      // ═══════════════════════════════════════════════════════════
      // 3. MESSAGE PROCESSOR
      // ═══════════════════════════════════════════════════════════
      _a2uiMessageProcessor = A2uiMessageProcessor(catalogs: [_catalog]);

      // ═══════════════════════════════════════════════════════════
      // 4. CONTENT GENERATOR con System Instruction Event-Driven
      // ═══════════════════════════════════════════════════════════
      _contentGenerator = GoogleGenerativeAiContentGenerator(
        catalog: _catalog,
        systemInstruction: _getEventDrivenSystemInstruction(),
        modelName: 'models/gemini-2.5-flash',
        apiKey: apiKey,
      );

      // ═══════════════════════════════════════════════════════════
      // 5. CONVERSATION
      // ═══════════════════════════════════════════════════════════
      _createConversation();

      _isInitialized = true;
      _error = null;
      notifyListeners();
      debugPrint(' AIServiceEventDriven initialized');
    } catch (e, stack) {
      _error = 'Errore: $e';
      _isInitialized = false;
      debugPrint(' Init error: $e\n$stack');
      notifyListeners();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CONVERSATION FACTORY — usata da _initialize() e reset()
  // ═══════════════════════════════════════════════════════════════
  void _createConversation() {
    _conversation = GenUiConversation(
      contentGenerator: _contentGenerator!,
      a2uiMessageProcessor: _a2uiMessageProcessor,
      onSurfaceAdded: (update) {
        debugPrint(' SURFACE ADDED: ${update.surfaceId}');

        // Rimuovi i widget precedenti per mantenere solo l'ultimo
        _messages.removeWhere((m) => m['role'] == 'assistant_widget');

        _messages.add({
          'role': 'assistant_widget',
          'surfaceId': update.surfaceId,
          'timestamp': DateTime.now(),
        });
        _isLoading = false;
        notifyListeners();
      },
      onSurfaceUpdated: (update) {
        debugPrint(' SURFACE UPDATED: ${update.surfaceId}');
        _isLoading = false;
        notifyListeners();
      },
      onTextResponse: (text) {
        // Testo puro (senza widget)
        if (text.trim().isNotEmpty) {
          _messages.add({'role': 'assistant', 'content': text, 'timestamp': DateTime.now()});
          _isLoading = false;
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint(' Error: ${error.error}');
        _error = error.error.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // EVENT CALLBACK - Chiamato automaticamente dall'EventAggregator
  // ═══════════════════════════════════════════════════════════════
  void _onEventContextReady(EventContext context) {
    debugPrint('🚀 ═══════════════════════════════════════════');
    debugPrint('🚀 AI TRIGGERED BY EVENTS');
    debugPrint('🚀 ${context.toPromptString()}');
    debugPrint('🚀 ═══════════════════════════════════════════');

    // Controlla se abbiamo tutti i dati necessari (Step 3 completato → genera quote)
    // Fallback: dopo 3 trigger (1 per step) completa comunque
    if (_hasAllRequiredData(context.collectedData) || _eventAggregator.triggerCount >= 3) {
      _completeQuote(context.collectedData);
      // Stop: preventivo completato, non inviare altre richieste all'AI
      return;
    }

    // Costruisci un messaggio automatico con il contesto
    final autoMessage = _buildContextMessage(context);

    // Invia all'AI
    _sendInternalMessage(autoMessage);
  }

  String _buildContextMessage(EventContext context) {
    final buffer = StringBuffer();

    buffer.writeln('[DATI INSERITI DALL\'UTENTE]');
    context.collectedData.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln();
    buffer.writeln('Procedi con i prossimi campi da raccogliere.');

    return buffer.toString();
  }

  // ═══════════════════════════════════════════════════════════════
  // PUBLIC METHODS
  // ═══════════════════════════════════════════════════════════════

  void addMessage(String role, String content) {
    _messages.add({'role': role, 'content': content, 'timestamp': DateTime.now()});
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (_conversation == null) return;

    _messages.add({'role': 'user', 'content': text, 'timestamp': DateTime.now()});

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📤 User message: $text');
      await _conversation!.sendRequest(UserMessage.text(text));
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Messaggio interno (non mostrato nella UI come messaggio utente)
  Future<void> _sendInternalMessage(String text) async {
    if (_conversation == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🤖 Internal message: $text');
      await _conversation!.sendRequest(UserMessage.text(text));
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _messages.clear();
    _eventAggregator.reset();
    _error = null;
    _isLoading = false;
    _quoteCompleted = false;
    _lastCompletedQuote = null;

    // Ricrea content generator + conversation per azzerare lo storico AI
    final apiKey = dotenv.env['GOOGLE_AI_API_KEY'];
    if (apiKey != null && apiKey.isNotEmpty) {
      _contentGenerator = GoogleGenerativeAiContentGenerator(
        catalog: _catalog,
        systemInstruction: _getEventDrivenSystemInstruction(),
        modelName: 'models/gemini-2.5-flash',
        apiKey: apiKey,
      );
      _createConversation();
    }

    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // QUOTE COMPLETION LOGIC
  // ═══════════════════════════════════════════════════════════════

  bool _hasAllRequiredData(Map<String, dynamic> data) {
    // Step 1: vehicle base
    final hasVehicleBase =
        data.containsKey('vehicle_brand') &&
        data.containsKey('vehicle_model') &&
        data.containsKey('vehicle_year');

    // Step 2: vehicle details
    final hasVehicleDetails =
        data.containsKey('vehicle_km') ||
        data.containsKey('vehicle_fuel') ||
        data.containsKey('vehicle_usage');

    // Step 3: driver
    final hasDriver =
        data.containsKey('driver_name') ||
        data.containsKey('driver_birth_date') ||
        data.containsKey('driver_city');

    return hasVehicleBase && hasVehicleDetails && hasDriver;
  }

  void _completeQuote(Map<String, dynamic> data) {
    if (_quoteCompleted) return;

    debugPrint('✅ ═══════════════════════════════════════════');
    debugPrint('✅ QUOTE COMPLETION DETECTED');
    debugPrint('✅ Data keys: ${data.keys.toList()}');
    debugPrint('✅ ═══════════════════════════════════════════');

    _quoteCompleted = true;
    CompletedQuote? quote;

    try {
      // Estrai i dati del veicolo
      final vehicle = VehicleDataModel(
        brand: data['vehicle_brand']?.toString(),
        model: data['vehicle_model']?.toString(),
        year: _parseInt(data['vehicle_year']),
        annualKm: _parseInt(data['vehicle_km']),
        fuelType: _parseFuelType(data['vehicle_fuel']?.toString()),
        usage: _parseUsage(data['vehicle_usage']?.toString()),
        marketValue: _parseInt(data['vehicle_value']),
      );

      // Estrai i dati del conducente
      final driverName = data['driver_name']?.toString() ?? '';
      final nameParts = driverName.split(' ');
      final driver = DriverDataModel(
        firstName: nameParts.isNotEmpty ? nameParts.first : null,
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        birthDate: _parseDate(data['driver_birth_date']?.toString()),
        city: data['driver_city']?.toString(),
        licenseDate: _parseDate(data['driver_license_year']?.toString()),
      );

      // Calcola le coperture
      final calculator = CoverageCalculator();
      final coverages = calculator.calculateSuggestions(vehicle: vehicle, driver: driver);

      final totalPrice = coverages.fold<double>(0, (sum, c) => sum + c.annualPrice);
      final essentialPrice = coverages
          .where((c) => c.level == SuggestionLevel.essential)
          .fold<double>(0, (sum, c) => sum + c.annualPrice);

      quote = CompletedQuote(
        id: const Uuid().v4(),
        vehicle: vehicle,
        driver: driver,
        coverages: coverages,
        totalPrice: totalPrice,
        essentialPrice: essentialPrice,
        createdAt: DateTime.now(),
      );

      // Salva nello storage
      quoteStorageRepository.saveQuote(quote);
      debugPrint('✅ Quote saved: ${quote.id} - €${quote.totalPrice}');
    } catch (e, stack) {
      debugPrint('❌ Quote completion error: $e\n$stack');
    }

    // Notifica SEMPRE il listener esterno, anche se la creazione ha avuto errori parziali
    if (quote != null) {
      _lastCompletedQuote = quote;
      notifyListeners();
      onQuoteCompleted?.call(quote);
    } else {
      debugPrint('❌ Quote is null, cannot navigate to confirmation');
      _quoteCompleted = false; // Permetti un nuovo tentativo
    }
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), ''));
  }

  FuelType? _parseFuelType(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.contains('benzina') || lower.contains('gasoline')) return FuelType.gasoline;
    if (lower.contains('diesel') || lower.contains('gasolio')) return FuelType.diesel;
    if (lower.contains('ibrid') || lower.contains('hybrid')) return FuelType.hybrid;
    if (lower.contains('elettric') || lower.contains('electric')) return FuelType.electric;
    if (lower.contains('gpl') || lower.contains('lpg')) return FuelType.lpg;
    return null;
  }

  VehicleUsage? _parseUsage(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.contains('privat') || lower.contains('personal')) return VehicleUsage.personal;
    if (lower.contains('lavor') || lower.contains('work')) return VehicleUsage.work;
    if (lower.contains('mist') || lower.contains('mixed')) return VehicleUsage.mixed;
    return null;
  }

  DateTime? _parseDate(String? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      // Prova formato dd/MM/yyyy
      final parts = value.split(RegExp(r'[/\-.]'));
      if (parts.length == 3) {
        try {
          return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } catch (_) {}
      }
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SYSTEM INSTRUCTION - Ottimizzato per Event-Driven
  // ═══════════════════════════════════════════════════════════════
  String _getEventDrivenSystemInstruction() {
    return '''
Sei un assistente assicurativo AI per preventivi auto. Rispondi SEMPRE in italiano.

⚡ IMPORTANTE: I widget che generi EMETTONO EVENTI AUTOMATICAMENTE.
Quando l'utente compila i campi, riceverai un messaggio con i dati raccolti.
NON devi chiedere conferma - i dati arrivano automaticamente!

WIDGET DISPONIBILI (usa i tool/function call per generarli):

1. text_input: Campo testo con id, label, hint
2. number_input: Campo numerico con id, label, min, max
3. slider: Cursore per valori range con id, label, min, max, suffix
4. choice_chips: Selezione singola con id, label, options (array di stringhe)
5. date_input: Selettore data con id, label
6. submit_button: Bottone invio con label
7. text_message: Testo semplice con message
8. info_card: Card informativa con title, message, type (info/success/warning)

FLUSSO PREVENTIVO AUTO (4 step):

STEP 1 - VEICOLO BASE:
Genera un form con Column contenente:
- text_message di benvenuto
- text_input con id "vehicle_brand", label "Marca", hint "Es: Fiat, BMW, Audi"
- text_input con id "vehicle_model", label "Modello", hint "Es: Panda, Serie 3"  
- number_input con id "vehicle_year", label "Anno immatricolazione", min 1990, max 2026
- submit_button con label "Continua"

STEP 2 - VEICOLO DETTAGLI (dopo aver ricevuto i dati Step 1):
- text_message di progresso
- slider con id "vehicle_km", label "Km annui", min 0, max 80000, suffix " km"
- choice_chips con id "vehicle_fuel", label "Alimentazione", options ["Benzina", "Diesel", "Ibrida", "Elettrica", "GPL"]
- choice_chips con id "vehicle_usage", label "Utilizzo", options ["Uso Privato", "Uso Lavoro", "Uso Misto"]
- number_input con id "vehicle_value", label "Valore veicolo (€)", min 1000, max 200000
- submit_button con label "Continua"

STEP 3 - CONDUCENTE (dopo aver ricevuto i dati Step 2):
- text_message di progresso
- text_input con id "driver_name", label "Nome e Cognome", hint "Es: Mario Rossi"
- date_input con id "driver_birth_date", label "Data di nascita"
- text_input con id "driver_city", label "Città di residenza", hint "Es: Milano, Roma"
- date_input con id "driver_license_year", label "Data rilascio patente"
- submit_button con label "Completa"

STEP 4 - RIEPILOGO (dopo aver ricevuto i dati Step 3):
- info_card type "success" con titolo "Preventivo Completato!" e riepilogo di TUTTI i dati raccolti
- text_message con messaggio di conferma

REGOLE FONDAMENTALI:
- Usa Column per raggruppare widget verticalmente
- Inizia SEMPRE ogni step con un text_message di contesto
- OGNI step (1, 2, 3) DEVE terminare con un submit_button - l'utente preme il bottone per inviare i dati
- NON generare mai solo testo - usa SEMPRE i widget tramite tool call
- Quando ricevi "[DATI INSERITI DALL\'UTENTE]", procedi allo step successivo
- NON ripetere campi già compilati
- Alla fine (Step 4) mostra info_card type="success" con riepilogo completo

Rispondi alla prima richiesta dell'utente con lo Step 1.
''';
  }

  @override
  void dispose() {
    _a2uiMessageProcessor.dispose();
    _eventAggregator.dispose();
    super.dispose();
  }
}
