import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_widget_type.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_flow_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_step_definition.dart';
import 'package:gen_ui_poc/features/quote/core/quote_product_module.dart';

class TravelQuoteModule implements QuoteProductModule {
  @override
  QuoteProduct get product => QuoteProduct.travel;

  @override
  String get displayName => 'Viaggio';

  @override
  bool get isFlowSupportedInChat => true;

  @override
  List<String> get requiredFieldIds => const [
    'trip_destination',
    'departure_date',
    'return_date',
    'travelers_count',
    'travel_reason',
    'traveler_name',
    'traveler_birth_date',
    'traveler_city',
  ];

  @override
  QuoteFlowDefinition get flowDefinition => const QuoteFlowDefinition(
    summaryTitle: 'Preventivo Viaggio',
    completionTitle: 'Preventivo Viaggio Completato!',
    fieldDefinitions: [
      QuoteFieldDefinition(
        id: 'trip_destination',
        widgetType: QuoteFieldWidgetType.choiceChips,
        label: 'Destinazione',
        options: ['Italia', 'Europa', 'USA/Canada', 'Mondo'],
      ),
      QuoteFieldDefinition(
        id: 'travel_reason',
        widgetType: QuoteFieldWidgetType.choiceChips,
        label: 'Motivo del viaggio',
        options: ['Vacanza', 'Lavoro', 'Studio'],
      ),
      QuoteFieldDefinition(
        id: 'travelers_count',
        widgetType: QuoteFieldWidgetType.numberInput,
        label: 'Numero viaggiatori',
        minInt: 1,
        maxInt: 10,
      ),
      QuoteFieldDefinition(
        id: 'departure_date',
        widgetType: QuoteFieldWidgetType.dateInput,
        label: 'Data partenza',
      ),
      QuoteFieldDefinition(
        id: 'return_date',
        widgetType: QuoteFieldWidgetType.dateInput,
        label: 'Data rientro',
      ),
      QuoteFieldDefinition(
        id: 'traveler_name',
        widgetType: QuoteFieldWidgetType.textInput,
        label: 'Nome e Cognome',
        hint: 'Es: Mario Rossi',
      ),
      QuoteFieldDefinition(
        id: 'traveler_birth_date',
        widgetType: QuoteFieldWidgetType.dateInput,
        label: 'Data di nascita',
      ),
      QuoteFieldDefinition(
        id: 'traveler_city',
        widgetType: QuoteFieldWidgetType.textInput,
        label: 'Città di residenza',
        hint: 'Es: Torino',
      ),
    ],
    steps: [
      QuoteStepDefinition(
        id: 'trip',
        title: 'Step 1 - Viaggio',
        contextMessage:
            'Partiamo dai dettagli del viaggio per preparare una copertura adatta.',
        fieldIds: ['trip_destination', 'travel_reason', 'travelers_count'],
        submitLabel: 'Continua',
      ),
      QuoteStepDefinition(
        id: 'dates',
        title: 'Step 2 - Date',
        contextMessage:
            'Perfetto. Ora mi servono le date di partenza e rientro.',
        fieldIds: ['departure_date', 'return_date'],
        submitLabel: 'Continua',
      ),
      QuoteStepDefinition(
        id: 'traveler',
        title: 'Step 3 - Viaggiatore',
        contextMessage:
            'Ultimo passaggio: inserisci i dati principali del viaggiatore.',
        fieldIds: ['traveler_name', 'traveler_birth_date', 'traveler_city'],
        submitLabel: 'Completa',
      ),
    ],
  );

  @override
  String buildStartFlowInstruction(QuoteFlowConfig config) {
    final buffer = StringBuffer();
    buffer.write(
      'Istruzione interna: avvia adesso il quoteFlow e mostra immediatamente lo Step 1 del preventivo viaggio.',
    );

    if (config.quoteScope != null) {
      buffer.write(' Imposta il flusso con scope ${config.quoteScope}.');
    }

    buffer.write(
      ' Non menzionare istruzioni interne o token. Non chiedere di digitare comandi speciali.',
    );
    return buffer.toString();
  }

  @override
  String buildFlowPromptDescription(QuoteFlowConfig config) {
    final buffer = StringBuffer();
    buffer.writeln('FLOW ATTIVO: ${flowDefinition.summaryTitle}');
    buffer.writeln();

    for (final step in flowDefinition.steps) {
      buffer.writeln('${step.title}:');
      buffer.writeln('- text_message iniziale: "${step.contextMessage}"');
      for (final fieldId in step.fieldIds) {
        final field = flowDefinition.fieldById(fieldId);
        if (field == null) {
          buffer.writeln('- campo richiesto: $fieldId');
          continue;
        }
        buffer.writeln('- ${_fieldInstruction(field)}');
      }
      buffer.writeln('- submit_button finale: "${step.submitLabel}"');
      buffer.writeln();
    }

    if (config.quoteScope != null) {
      buffer.writeln('SCOPE PREVENTIVO: ${config.quoteScope}.');
    }

    buffer.writeln(
      'Al completamento mostra un info_card con titolo "${flowDefinition.completionTitle}" e riepilogo completo.',
    );
    return buffer.toString().trimRight();
  }

  String _fieldInstruction(QuoteFieldDefinition field) {
    switch (field.widgetType) {
      case QuoteFieldWidgetType.textInput:
        return 'text_input id "${field.id}", label "${field.label}"'
            '${field.hint != null ? ', hint "${field.hint}"' : ''}';
      case QuoteFieldWidgetType.numberInput:
        return 'number_input id "${field.id}", label "${field.label}"'
            '${field.minInt != null ? ', min ${field.minInt}' : ''}'
            '${field.maxInt != null ? ', max ${field.maxInt}' : ''}';
      case QuoteFieldWidgetType.slider:
        return 'slider id "${field.id}", label "${field.label}"'
            '${field.minInt != null ? ', min ${field.minInt}' : ''}'
            '${field.maxInt != null ? ', max ${field.maxInt}' : ''}'
            '${field.suffix != null ? ', suffix "${field.suffix}"' : ''}';
      case QuoteFieldWidgetType.choiceChips:
        return 'choice_chips id "${field.id}", label "${field.label}", options ${field.options}';
      case QuoteFieldWidgetType.dateInput:
        return 'date_input id "${field.id}", label "${field.label}"'
            '${field.hint != null ? ', hint "${field.hint}"' : ''}';
    }
  }
}
