// lib/core/ai/genui/insurance_catalog.dart
import 'package:gen_ui_poc/core/ai/genui/widgets/choice_chips_widget.dart';
import 'package:gen_ui_poc/core/ai/genui/widgets/info_card_widget.dart';
import 'package:gen_ui_poc/core/ai/genui/widgets/number_input_widget.dart';
import 'package:gen_ui_poc/core/ai/genui/widgets/progress_bar_indicator_widget.dart';
import 'package:gen_ui_poc/core/ai/genui/widgets/slider_widget.dart';
import 'package:gen_ui_poc/core/ai/genui/widgets/text_input_widget.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_state.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_cubit.dart';

class InsuranceCatalog {
  static Catalog build() {
    return Catalog([
      // ============================================
      // TEXT INPUT
      // ============================================
      CatalogItem(
        name: 'text_input',
        dataSchema: S.object(
          properties: {
            'id': S.string(description: 'Campo ID univoco (es: vehicle_brand, driver_city)'),
            'label': S.string(description: 'Etichetta del campo'),
            'hint': S.string(description: 'Testo placeholder'),
            'value': S.string(description: 'Valore iniziale'),
            'icon': S.string(description: 'Nome icona: car, pin, person, city, calendar'),
            'required': S.boolean(description: 'Campo obbligatorio'),
            'validation_pattern': S.string(description: 'Regex per validazione'),
          },
          required: ['id', 'label'],
        ),
        widgetBuilder: (CatalogItemContext context) {
          final data = context.data as Map<String, dynamic>;
          
          // ✅ Usa BlocBuilder per accedere al Cubit
          return BlocBuilder<QuoteCubit, QuoteState>(
            builder: (builderContext, state) {
              return TextInputWidget(
                id: data['id'] as String,
                label: data['label'] as String,
                hint: data['hint'] as String?,
                value: data['value'] as String?,
                icon: data['icon'] as String?,
                required: data['required'] as bool? ?? false,
                validationPattern: data['validation_pattern'] as String?,
                onChanged: (value) {
                  // ✅ Chiama metodo Cubit
                  builderContext.read<QuoteCubit>().updateField(
                    data['id'] as String,
                    value,
                  );
                },
              );
            },
          );
        },
      ),

      // ============================================
      // NUMBER INPUT
      // ============================================
      CatalogItem(
        name: 'number_input',
        dataSchema: S.object(
          properties: {
            'id': S.string(description: 'Campo ID univoco'),
            'label': S.string(description: 'Etichetta'),
            'hint': S.string(description: 'Testo placeholder'),
            'value': S.number(description: 'Valore iniziale'),
            'min': S.number(description: 'Valore minimo'),
            'max': S.number(description: 'Valore massimo'),
          },
          required: ['id', 'label'],
        ),
        widgetBuilder: (CatalogItemContext context) {
          final data = context.data as Map<String, dynamic>;
          
          return BlocBuilder<QuoteCubit, QuoteState>(
            builder: (builderContext, state) {
              return NumberInputWidget(
                id: data['id'] as String,
                label: data['label'] as String,
                hint: data['hint'] as String?,
                value: (data['value'] as num?)?.toInt(),
                min: (data['min'] as num?)?.toInt(),
                max: (data['max'] as num?)?.toInt(),
                onChanged: (value) {
                  builderContext.read<QuoteCubit>().updateField(
                    data['id'] as String,
                    value,
                  );
                },
              );
            },
          );
        },
      ),

      // ============================================
      // SLIDER
      // ============================================
      CatalogItem(
        name: 'slider',
        dataSchema: S.object(
          properties: {
            'id': S.string(description: 'Campo ID univoco'),
            'label': S.string(description: 'Etichetta'),
            'value': S.number(description: 'Valore corrente'),
            'min': S.number(description: 'Valore minimo'),
            'max': S.number(description: 'Valore massimo'),
            'step': S.number(description: 'Step incremento'),
            'unit': S.string(description: 'Unità di misura (es: km, €)'),
          },
          required: ['id', 'label', 'min', 'max'],
        ),
        widgetBuilder: (CatalogItemContext context) {
          final data = context.data as Map<String, dynamic>;
          final min = (data['min'] as num).toDouble();
          final max = (data['max'] as num).toDouble();
          final value = (data['value'] as num?)?.toDouble() ?? min;
          final step = (data['step'] as num?)?.toDouble() ?? 1.0;

          return BlocBuilder<QuoteCubit, QuoteState>(
            builder: (builderContext, state) {
              return SliderWidget(
                id: data['id'] as String,
                label: data['label'] as String,
                value: value,
                min: min,
                max: max,
                step: step,
                unit: data['unit'] as String?,
                onChanged: (value) {
                  builderContext.read<QuoteCubit>().updateField(
                    data['id'] as String,
                    value,
                  );
                },
              );
            },
          );
        },
      ),

      // ============================================
      // CHOICE CHIPS
      // ============================================
      CatalogItem(
        name: 'choice_chips',
        dataSchema: S.object(
          properties: {
            'id': S.string(description: 'Campo ID univoco'),
            'label': S.string(description: 'Etichetta'),
            'options': S.list(
              items: S.string(),
              description: 'Lista opzioni disponibili',
            ),
            'value': S.string(description: 'Valore selezionato'),
          },
          required: ['id', 'label', 'options'],
        ),
        widgetBuilder: (CatalogItemContext context) {
          final data = context.data as Map<String, dynamic>;
          
          return BlocBuilder<QuoteCubit, QuoteState>(
            builder: (builderContext, state) {
              return ChoiceChipsWidget(
                id: data['id'] as String,
                label: data['label'] as String,
                options: (data['options'] as List).cast<String>(),
                value: data['value'] as String?,
                onChanged: (value) {
                  builderContext.read<QuoteCubit>().updateField(
                    data['id'] as String,
                    value,
                  );
                },
              );
            },
          );
        },
      ),

      // ============================================
      // INFO CARD
      // ============================================
      CatalogItem(
        name: 'info_card',
        dataSchema: S.object(
          properties: {
            'message': S.string(description: 'Messaggio da mostrare'),
            'type': S.string(
              description: 'Tipo: info, success, warning, error',
              enumValues: ['info', 'success', 'warning', 'error'],
            ),
            'title': S.string(description: 'Titolo opzionale'),
          },
          required: ['message'],
        ),
        widgetBuilder: (CatalogItemContext context) {
          final data = context.data as Map<String, dynamic>;
          return InfoCardWidget(
            message: data['message'] as String,
            type: data['type'] as String? ?? 'info',
            title: data['title'] as String?,
          );
        },
      ),

      // ============================================
      // PROGRESS BAR
      // ============================================
      CatalogItem(
        name: 'progress_bar',
        dataSchema: S.object(
          properties: {
            'label': S.string(description: 'Etichetta'),
            'value': S.number(description: 'Valore 0-1'),
            'show_percentage': S.boolean(description: 'Mostra percentuale'),
          },
          required: ['value'],
        ),
        widgetBuilder: (CatalogItemContext context) {
          final data = context.data as Map<String, dynamic>;
          return ProgressBarWidget(
            label: data['label'] as String?,
            value: (data['value'] as num).toDouble(),
            showPercentage: data['show_percentage'] as bool? ?? true,
          );
        },
      ),
    ]);
  }
}
