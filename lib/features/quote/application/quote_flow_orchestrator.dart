import 'package:gen_ui_poc/core/model/completed_quote_model.dart';
import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';
import 'package:gen_ui_poc/core/service/quote_storage_repository.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_completion_result.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_draft.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_flow_state.dart';
import 'package:gen_ui_poc/features/quote/application/models/quote_flow_status.dart';
import 'package:gen_ui_poc/features/chat/application/models/quote_flow_config.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_field_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_flow_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_step_definition.dart';
import 'package:gen_ui_poc/features/quote/core/models/quote_product.dart';
import 'package:gen_ui_poc/features/quote/core/quote_product_registry.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';
import 'package:uuid/uuid.dart';

class QuoteFlowOrchestrator {
  QuoteFlowOrchestrator({
    required QuoteProductRegistry productRegistry,
    required QuoteStorageRepository quoteStorageRepository,
    required CoverageCalculator coverageCalculator,
  }) : _productRegistry = productRegistry,
       _quoteStorageRepository = quoteStorageRepository,
       _coverageCalculator = coverageCalculator;

  final QuoteProductRegistry _productRegistry;
  final QuoteStorageRepository _quoteStorageRepository;
  final CoverageCalculator _coverageCalculator;

  QuoteFlowState createFlowState({
    required QuoteFlowConfig config,
    required Map<String, dynamic> collectedData,
    QuoteFlowStatus status = QuoteFlowStatus.active,
  }) {
    final draft = QuoteDraft.fromCollectedData(
      config: config,
      collectedData: collectedData,
    );
    final module = _productRegistry.getModule(config.product);
    final requiredFieldIds = module?.requiredFieldIds ?? const <String>[];
    final flowDefinition = module?.flowDefinition;
    final missingFieldIds = requiredFieldIds
        .where((fieldId) => !draft.contains(fieldId))
        .toList();

    QuoteStepDefinition? currentStep;
    final currentStepFields = <QuoteFieldDefinition>[];
    final completedStepIds = <String>[];
    var currentStepIndex = -1;
    if (flowDefinition != null) {
      for (var i = 0; i < flowDefinition.steps.length; i++) {
        final step = flowDefinition.steps[i];
        final stepRequiredFieldIds = step.fieldIds.where((fieldId) {
          final field = flowDefinition.fieldById(fieldId);
          return field?.required ?? true;
        });
        final isStepIncomplete = stepRequiredFieldIds.any(
          (fieldId) => !draft.contains(fieldId),
        );
        if (isStepIncomplete) {
          currentStep = step;
          currentStepIndex = i;
          for (final fieldId in step.fieldIds) {
            final field = flowDefinition.fieldById(fieldId);
            if (field != null) {
              currentStepFields.add(field);
            }
          }
          break;
        }
        completedStepIds.add(step.id);
      }
      if (currentStep == null && flowDefinition.steps.isNotEmpty) {
        currentStepIndex = flowDefinition.steps.length - 1;
      }
    }

    return QuoteFlowState(
      draft: draft,
      flowDefinition:
          flowDefinition ??
          const QuoteFlowDefinition(
            summaryTitle: 'Flow',
            completionTitle: 'Completato',
            steps: [],
            fieldDefinitions: [],
          ),
      requiredFieldIds: requiredFieldIds,
      missingFieldIds: missingFieldIds,
      status: status,
      currentStepIndex: currentStepIndex,
      completedStepIds: completedStepIds,
      currentStep: currentStep,
      currentStepFields: currentStepFields,
    );
  }

  Future<QuoteCompletionResult> completeQuote({
    required QuoteFlowState flowState,
  }) async {
    switch (flowState.draft.config.product) {
      case QuoteProduct.auto:
        return _completeAutoQuote(flowState.draft);
      case QuoteProduct.life:
        return const QuoteCompletionResult.failure(
          'Il preventivo vita non e ancora implementato.',
        );
      case QuoteProduct.travel:
        return _completeTravelQuote(flowState.draft);
    }
  }

  Future<QuoteCompletionResult> _completeAutoQuote(QuoteDraft draft) async {
    try {
      final vehicle = VehicleDataModel(
        brand: draft['vehicle_brand']?.toString(),
        model: draft['vehicle_model']?.toString(),
        year: _parseInt(draft['vehicle_year']),
        annualKm: _parseInt(draft['vehicle_km']),
        fuelType: _parseFuelType(draft['vehicle_fuel']?.toString()),
        usage: _parseUsage(draft['vehicle_usage']?.toString()),
        marketValue: _parseInt(draft['vehicle_value']),
      );

      final driverName = draft['driver_name']?.toString() ?? '';
      final nameParts = driverName
          .split(' ')
          .where((part) => part.trim().isNotEmpty)
          .toList();

      final driver = DriverDataModel(
        firstName: nameParts.isNotEmpty ? nameParts.first : null,
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        birthDate: _parseDate(draft['driver_birth_date']?.toString()),
        city: draft['driver_city']?.toString(),
        licenseDate: _parseDate(draft['driver_license_year']?.toString()),
      );

      final coverages = _coverageCalculator.calculateSuggestions(
        vehicle: vehicle,
        driver: driver,
      );

      final totalPrice = coverages.fold<double>(
        0,
        (sum, c) => sum + c.annualPrice,
      );
      final essentialPrice = coverages
          .where((c) => c.level == SuggestionLevel.essential)
          .fold<double>(0, (sum, c) => sum + c.annualPrice);

      final quote = CompletedQuote(
        id: const Uuid().v4(),
        vehicle: vehicle,
        driver: driver,
        coverages: coverages,
        totalPrice: totalPrice,
        essentialPrice: essentialPrice,
        createdAt: DateTime.now(),
      );

      await _quoteStorageRepository.saveQuote(quote);
      return QuoteCompletionResult.success(quote);
    } catch (e) {
      return QuoteCompletionResult.failure(e.toString());
    }
  }

  Future<QuoteCompletionResult> _completeTravelQuote(QuoteDraft draft) async {
    try {
      final departureDate = _parseDate(draft['departure_date']?.toString());
      final returnDate = _parseDate(draft['return_date']?.toString());
      if (departureDate == null || returnDate == null) {
        return const QuoteCompletionResult.failure(
          'Le date del viaggio non sono valide.',
        );
      }

      final durationDays = returnDate.difference(departureDate).inDays + 1;
      if (durationDays <= 0) {
        return const QuoteCompletionResult.failure(
          'La data di rientro deve essere successiva alla partenza.',
        );
      }

      final destination = draft['trip_destination']?.toString() ?? 'Viaggio';
      final travelReason = draft['travel_reason']?.toString() ?? 'Vacanza';
      final travelerCount = _parseInt(draft['travelers_count']) ?? 1;
      final travelerName = draft['traveler_name']?.toString() ?? '';
      final nameParts = travelerName
          .split(' ')
          .where((part) => part.trim().isNotEmpty)
          .toList();
      final birthDate = _parseDate(draft['traveler_birth_date']?.toString());
      final residenceCity = draft['traveler_city']?.toString();

      final vehicle = VehicleDataModel(
        brand: 'Viaggio',
        model: destination,
        year: departureDate.year,
        annualKm: durationDays,
        usage: _parseTravelUsage(travelReason),
        marketValue: _estimateTravelInsuredValue(
          destination: destination,
          travelersCount: travelerCount,
          durationDays: durationDays,
        ),
      );

      final driver = DriverDataModel(
        firstName: nameParts.isNotEmpty ? nameParts.first : travelerName,
        lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null,
        birthDate: birthDate,
        city: residenceCity,
      );

      final coverages = _buildTravelCoverages(
        destination: destination,
        travelersCount: travelerCount,
        durationDays: durationDays,
        travelerAge: driver.age,
      );

      final totalPrice = coverages.fold<double>(
        0,
        (sum, c) => sum + c.annualPrice,
      );
      final essentialPrice = coverages
          .where((c) => c.level == SuggestionLevel.essential)
          .fold<double>(0, (sum, c) => sum + c.annualPrice);

      final quote = CompletedQuote(
        id: const Uuid().v4(),
        vehicle: vehicle,
        driver: driver,
        coverages: coverages,
        totalPrice: totalPrice,
        essentialPrice: essentialPrice,
        createdAt: DateTime.now(),
      );

      await _quoteStorageRepository.saveQuote(quote);
      return QuoteCompletionResult.success(quote);
    } catch (e) {
      return QuoteCompletionResult.failure(e.toString());
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
    if (lower.contains('benzina') || lower.contains('gasoline')) {
      return FuelType.gasoline;
    }
    if (lower.contains('diesel') || lower.contains('gasolio')) {
      return FuelType.diesel;
    }
    if (lower.contains('ibrid') || lower.contains('hybrid')) {
      return FuelType.hybrid;
    }
    if (lower.contains('elettric') || lower.contains('electric')) {
      return FuelType.electric;
    }
    if (lower.contains('gpl') || lower.contains('lpg')) {
      return FuelType.lpg;
    }
    return null;
  }

  VehicleUsage? _parseUsage(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.contains('privat') || lower.contains('personal')) {
      return VehicleUsage.personal;
    }
    if (lower.contains('lavor') || lower.contains('work')) {
      return VehicleUsage.work;
    }
    if (lower.contains('mist') || lower.contains('mixed')) {
      return VehicleUsage.mixed;
    }
    return null;
  }

  VehicleUsage _parseTravelUsage(String value) {
    final lower = value.toLowerCase();
    if (lower.contains('lavor')) {
      return VehicleUsage.work;
    }
    if (lower.contains('studio')) {
      return VehicleUsage.mixed;
    }
    return VehicleUsage.personal;
  }

  DateTime? _parseDate(String? value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      final parts = value.split(RegExp(r'[/\-.]'));
      if (parts.length == 3) {
        try {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  int _estimateTravelInsuredValue({
    required String destination,
    required int travelersCount,
    required int durationDays,
  }) {
    var base = 800;
    final lower = destination.toLowerCase();
    if (lower.contains('usa') || lower.contains('canada')) {
      base = 1400;
    } else if (lower.contains('mondo')) {
      base = 1600;
    } else if (lower.contains('europa')) {
      base = 950;
    }

    return base * travelersCount + (durationDays * 25);
  }

  List<CoverageSuggestion> _buildTravelCoverages({
    required String destination,
    required int travelersCount,
    required int durationDays,
    required int? travelerAge,
  }) {
    final destinationMultiplier = _destinationMultiplier(destination);
    final ageMultiplier =
        travelerAge != null && travelerAge >= 65
            ? 1.35
            : travelerAge != null && travelerAge < 25
            ? 1.15
            : 1.0;
    final travelerMultiplier = 1 + ((travelersCount - 1) * 0.45);
    final durationMultiplier = 1 + ((durationDays.clamp(1, 45) - 1) * 0.03);

    double price(double base) =>
        base * destinationMultiplier * ageMultiplier * travelerMultiplier * durationMultiplier;

    return [
      CoverageSuggestion(
        type: CoverageType.driver,
        title: 'Spese mediche',
        description: 'Copertura sanitaria durante il viaggio.',
        annualPrice: price(32),
        level: SuggestionLevel.essential,
      ),
      CoverageSuggestion(
        type: CoverageType.roadside,
        title: 'Assistenza h24',
        description: 'Supporto operativo e centrale assistenza in viaggio.',
        annualPrice: price(14),
        level: SuggestionLevel.essential,
      ),
      CoverageSuggestion(
        type: CoverageType.theft,
        title: 'Bagaglio',
        description: 'Tutela bagagli e oggetti personali.',
        annualPrice: price(11),
        level: SuggestionLevel.recommended,
      ),
      CoverageSuggestion(
        type: CoverageType.legal,
        title: 'Annullamento viaggio',
        description: 'Rimborso in caso di annullamento prima della partenza.',
        annualPrice: price(16),
        level: SuggestionLevel.recommended,
      ),
    ];
  }

  double _destinationMultiplier(String destination) {
    final lower = destination.toLowerCase();
    if (lower.contains('usa') || lower.contains('canada')) {
      return 1.7;
    }
    if (lower.contains('mondo')) {
      return 1.9;
    }
    if (lower.contains('europa')) {
      return 1.2;
    }
    return 1.0;
  }
}
