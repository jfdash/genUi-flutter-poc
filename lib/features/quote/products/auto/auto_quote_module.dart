import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_widget_type.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_flow_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_step_definition.dart';
import 'package:gen_ui_poc/features/quote/core/quote_product_module.dart';

class AutoQuoteModule implements QuoteProductModule {
  @override
  QuoteProduct get product => QuoteProduct.auto;

  @override
  String get displayName => 'Auto';

  @override
  bool get isFlowSupportedInChat => true;

  @override
  List<String> get requiredFieldIds => const [
    'vehicle_brand',
    'vehicle_model',
    'vehicle_year',
    'vehicle_km',
    'vehicle_fuel',
    'vehicle_usage',
    'driver_name',
    'driver_birth_date',
    'driver_city',
    'driver_license_year',
  ];

  @override
  QuoteFlowDefinition get flowDefinition => const QuoteFlowDefinition(
    summaryTitle: 'Preventivo Auto',
    completionTitle: 'Preventivo Completato!',
    fieldDefinitions: [
      QuoteFieldDefinition(
        id: 'vehicle_brand',
        widgetType: QuoteFieldWidgetType.textInput,
        label: 'Marca',
        hint: 'Es: Fiat, BMW, Audi',
      ),
      QuoteFieldDefinition(
        id: 'vehicle_model',
        widgetType: QuoteFieldWidgetType.textInput,
        label: 'Modello',
        hint: 'Es: Panda, Serie 3',
      ),
      QuoteFieldDefinition(
        id: 'vehicle_year',
        widgetType: QuoteFieldWidgetType.numberInput,
        label: 'Anno immatricolazione',
        minInt: 1990,
        maxInt: 2026,
      ),
      QuoteFieldDefinition(
        id: 'vehicle_km',
        widgetType: QuoteFieldWidgetType.slider,
        label: 'Km annui',
        minInt: 0,
        maxInt: 80000,
        suffix: ' km',
      ),
      QuoteFieldDefinition(
        id: 'vehicle_fuel',
        widgetType: QuoteFieldWidgetType.choiceChips,
        label: 'Alimentazione',
        options: ['Benzina', 'Diesel', 'Ibrida', 'Elettrica', 'GPL'],
      ),
      QuoteFieldDefinition(
        id: 'vehicle_usage',
        widgetType: QuoteFieldWidgetType.choiceChips,
        label: 'Utilizzo',
        options: ['Uso Privato', 'Uso Lavoro', 'Uso Misto'],
      ),
      QuoteFieldDefinition(
        id: 'vehicle_value',
        widgetType: QuoteFieldWidgetType.numberInput,
        label: 'Valore veicolo (€)',
        minInt: 1000,
        maxInt: 200000,
        required: false,
      ),
      QuoteFieldDefinition(
        id: 'driver_name',
        widgetType: QuoteFieldWidgetType.textInput,
        label: 'Nome e Cognome',
        hint: 'Es: Mario Rossi',
      ),
      QuoteFieldDefinition(
        id: 'driver_birth_date',
        widgetType: QuoteFieldWidgetType.dateInput,
        label: 'Data di nascita',
      ),
      QuoteFieldDefinition(
        id: 'driver_city',
        widgetType: QuoteFieldWidgetType.textInput,
        label: 'Città di residenza',
        hint: 'Es: Milano, Roma',
      ),
      QuoteFieldDefinition(
        id: 'driver_license_year',
        widgetType: QuoteFieldWidgetType.dateInput,
        label: 'Data rilascio patente',
      ),
    ],
    steps: [
      QuoteStepDefinition(
        id: 'vehicle_base',
        title: 'Step 1 - Veicolo Base',
        contextMessage:
            'Iniziamo dai dati principali del veicolo per preparare il preventivo.',
        fieldIds: ['vehicle_brand', 'vehicle_model', 'vehicle_year'],
        submitLabel: 'Continua',
      ),
      QuoteStepDefinition(
        id: 'vehicle_details',
        title: 'Step 2 - Dettagli Veicolo',
        contextMessage:
            'Perfetto. Ora raccogliamo i dettagli di utilizzo e alimentazione del veicolo.',
        fieldIds: [
          'vehicle_km',
          'vehicle_fuel',
          'vehicle_usage',
          'vehicle_value',
        ],
        submitLabel: 'Continua',
      ),
      QuoteStepDefinition(
        id: 'driver',
        title: 'Step 3 - Conducente',
        contextMessage:
            'Ci siamo. Mi servono ora le informazioni principali del conducente.',
        fieldIds: [
          'driver_name',
          'driver_birth_date',
          'driver_city',
          'driver_license_year',
        ],
        submitLabel: 'Completa',
      ),
    ],
  );

  @override
  String buildStartFlowInstruction(QuoteFlowConfig config) {
    final buffer = StringBuffer();
    buffer.write(
      'Istruzione interna: avvia adesso il quoteFlow e mostra immediatamente lo Step 1 del preventivo auto.',
    );

    if (config.focusCoverage != null) {
      buffer.write(
        " L'utente ha espresso interesse specifico per la copertura ${config.focusCoverage}.",
      );
    }

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

    if (config.focusCoverage != null) {
      buffer.writeln(
        'FOCUS COPERTURA: l\'utente ha chiesto attenzione specifica a ${config.focusCoverage}.',
      );
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
