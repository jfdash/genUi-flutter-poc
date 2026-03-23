import 'package:flutter/material.dart';
import 'package:gen_ui_poc/core/ai/genui/event_driven_widget.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_flow_state.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_widget_type.dart';
import 'package:genui/genui.dart';

class ChatQuoteStepWidget extends StatelessWidget {
  const ChatQuoteStepWidget({super.key, required this.flowState});

  final QuoteFlowState flowState;

  @override
  Widget build(BuildContext context) {
    final step = flowState.currentStep;
    if (step == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE4F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.contextMessage,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 12),
          ...flowState.currentStepFields.map(_buildFieldWidget),
          EventSubmitButton(
            label: step.submitLabel,
            dispatchEvent: (UiEvent event) {},
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWidget(QuoteFieldDefinition field) {
    switch (field.widgetType) {
      case QuoteFieldWidgetType.textInput:
        return EventTextInput(
          id: field.id,
          label: field.label,
          hint: field.hint,
          required: field.required,
          dispatchEvent: (UiEvent event) {},
        );
      case QuoteFieldWidgetType.numberInput:
        return EventNumberInput(
          id: field.id,
          label: field.label,
          min: field.minInt,
          max: field.maxInt,
          dispatchEvent: (UiEvent event) {},
        );
      case QuoteFieldWidgetType.slider:
        return EventSlider(
          id: field.id,
          label: field.label,
          min: (field.minInt ?? 0).toDouble(),
          max: (field.maxInt ?? 100).toDouble(),
          suffix: field.suffix,
          dispatchEvent: (UiEvent event) {},
        );
      case QuoteFieldWidgetType.choiceChips:
        return EventChoiceChips(
          id: field.id,
          label: field.label,
          options: field.options,
          dispatchEvent: (UiEvent event) {},
        );
      case QuoteFieldWidgetType.dateInput:
        return EventDateInput(
          id: field.id,
          label: field.label,
          hint: field.hint,
          dispatchEvent: (UiEvent event) {},
        );
    }
  }
}
