import 'package:equatable/equatable.dart';
import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';


class QuoteState extends Equatable {
  final VehicleDataModel vehicleData;
  final DriverDataModel driverData;
  final List<CoverageSuggestion> coverageSuggestions;
  final Map<String, dynamic> rawFields;
  final bool isLoading;
  final bool isLoadingExplanations; 
  final String? error;
  final double completionPercentage;
  final bool suggestionsCalculated; 

  const QuoteState({
    required this.vehicleData,
    required this.driverData,
    this.coverageSuggestions = const [],
    this.rawFields = const {},
    this.isLoading = false,
    this.isLoadingExplanations = false,
    this.error,
    this.completionPercentage = 0.0,
    this.suggestionsCalculated = false,
  });

  factory QuoteState.initial() {
    return QuoteState(
      vehicleData: VehicleDataModel(),
      driverData: DriverDataModel(),
      rawFields: {},
    );
  }

  bool get isReadyForQuote {
    return vehicleData.isComplete && driverData.isComplete;
  }

  @override
  List<Object?> get props => [
        vehicleData,
        driverData,
        coverageSuggestions,
        rawFields,
        isLoading,
        isLoadingExplanations,
        error,
        completionPercentage,
        suggestionsCalculated,
  ];

  QuoteState copyWith({
    VehicleDataModel? vehicleData,
    DriverDataModel? driverData,
    List<CoverageSuggestion>? coverageSuggestions,
    Map<String, dynamic>? rawFields,
    bool? isLoading,
    bool? isLoadingExplanations,
    String? error,
    double? completionPercentage,
    bool? suggestionsCalculated,
  }) {
    return QuoteState(
      vehicleData: vehicleData ?? this.vehicleData,
      driverData: driverData ?? this.driverData,
      coverageSuggestions: coverageSuggestions ?? this.coverageSuggestions,
      rawFields: rawFields ?? this.rawFields,
      isLoading: isLoading ?? this.isLoading,
      isLoadingExplanations: isLoadingExplanations ?? this.isLoadingExplanations,
      error: error,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      suggestionsCalculated: suggestionsCalculated ?? this.suggestionsCalculated,
    );
  }
}