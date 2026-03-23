import 'package:gen_ui_poc/features/quote/application/models/quote_draft.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_flow_status.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_flow_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_step_definition.dart';

class QuoteFlowState {
  final QuoteDraft draft;
  final QuoteFlowDefinition flowDefinition;
  final List<String> requiredFieldIds;
  final List<String> missingFieldIds;
  final QuoteFlowStatus status;
  final int currentStepIndex;
  final List<String> completedStepIds;
  final QuoteStepDefinition? currentStep;
  final List<QuoteFieldDefinition> currentStepFields;

  const QuoteFlowState({
    required this.draft,
    required this.flowDefinition,
    required this.requiredFieldIds,
    required this.missingFieldIds,
    required this.status,
    required this.currentStepIndex,
    required this.completedStepIds,
    required this.currentStep,
    required this.currentStepFields,
  });

  bool get canComplete => missingFieldIds.isEmpty;
  bool get isPaused => status == QuoteFlowStatus.paused;

  QuoteFlowState copyWith({QuoteFlowStatus? status}) {
    return QuoteFlowState(
      draft: draft,
      flowDefinition: flowDefinition,
      requiredFieldIds: requiredFieldIds,
      missingFieldIds: missingFieldIds,
      status: status ?? this.status,
      currentStepIndex: currentStepIndex,
      completedStepIds: completedStepIds,
      currentStep: currentStep,
      currentStepFields: currentStepFields,
    );
  }
}
