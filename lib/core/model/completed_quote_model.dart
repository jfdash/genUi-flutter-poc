import 'dart:convert';

import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';

class CompletedQuote {
  final String id;
  final VehicleDataModel vehicle;
  final DriverDataModel driver;
  final List<CoverageSuggestion> coverages;
  final double totalPrice;
  final double essentialPrice;
  final DateTime createdAt;

  CompletedQuote({
    required this.id,
    required this.vehicle,
    required this.driver,
    required this.coverages,
    required this.totalPrice,
    required this.essentialPrice,
    required this.createdAt,
  });

  String get vehicleLabel {
    final brand = vehicle.brand ?? 'N/D';
    final model = vehicle.model ?? '';
    final year = vehicle.year?.toString() ?? '';
    return '$brand $model $year'.trim();
  }

  String get driverLabel {
    final first = driver.firstName ?? '';
    final last = driver.lastName ?? '';
    return '$first $last'.trim();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'vehicle': vehicle.toJson(),
    'driver': driver.toJson(),
    'coverages': coverages.map((c) => c.toJson()).toList(),
    'totalPrice': totalPrice,
    'essentialPrice': essentialPrice,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CompletedQuote.fromJson(Map<String, dynamic> json) {
    return CompletedQuote(
      id: json['id'] as String,
      vehicle: VehicleDataModel.fromJson(json['vehicle'] as Map<String, dynamic>),
      driver: DriverDataModel.fromJson(json['driver'] as Map<String, dynamic>),
      coverages: (json['coverages'] as List)
          .map((c) => CoverageSuggestion.fromJson(c as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      essentialPrice: (json['essentialPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Serializza a stringa JSON per Hive storage
  String toJsonString() => jsonEncode(toJson());

  factory CompletedQuote.fromJsonString(String jsonString) {
    return CompletedQuote.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
