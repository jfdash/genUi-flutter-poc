// lib/features/quote/cubit/quote_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';
import 'package:gen_ui_poc/core/service/ai_service.dart';
import 'package:gen_ui_poc/features/quote/cubit/quote_state.dart';
import 'package:gen_ui_poc/features/quote/services/coverage_calculator.dart';

class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit({required CoverageCalculator calculator, required AIServiceEventDriven aiService})
    : super(QuoteState.initial());

  ///  Aggiorna campo generico da widget GenUI
  void updateField(String fieldId, dynamic value) {
    // Salva in rawFields
    final updatedRaw = Map<String, dynamic>.from(state.rawFields);
    updatedRaw[fieldId] = value;

    // Mappa a models
    final updatedState = _mapFieldsToModels(updatedRaw);

    emit(updatedState.copyWith(rawFields: updatedRaw));
  }

  ///  Mappa rawFields a VehicleData e DriverData
  QuoteState _mapFieldsToModels(Map<String, dynamic> fields) {
    VehicleDataModel vehicle = state.vehicleData;
    DriverDataModel driver = state.driverData;

    // Vehicle fields
    if (fields.containsKey('vehicle_brand')) {
      vehicle = vehicle.copyWith(brand: fields['vehicle_brand'] as String?);
    }
    if (fields.containsKey('vehicle_model')) {
      vehicle = vehicle.copyWith(model: fields['vehicle_model'] as String?);
    }
    if (fields.containsKey('vehicle_year')) {
      vehicle = vehicle.copyWith(year: fields['vehicle_year'] as int?);
    }
    if (fields.containsKey('vehicle_plate')) {
      vehicle = vehicle.copyWith(plate: fields['vehicle_plate'] as String?);
    }
    if (fields.containsKey('vehicle_fuel')) {
      vehicle = vehicle.copyWith(fuelType: _parseFuelType(fields['vehicle_fuel'] as String?));
    }
    if (fields.containsKey('vehicle_km')) {
      final km = fields['vehicle_km'];
      vehicle = vehicle.copyWith(annualKm: km is double ? km.toInt() : km as int?);
    }
    if (fields.containsKey('vehicle_usage')) {
      vehicle = vehicle.copyWith(usage: _parseUsage(fields['vehicle_usage'] as String?));
    }
    if (fields.containsKey('vehicle_value')) {
      final value = fields['vehicle_value'];
      vehicle = vehicle.copyWith(marketValue: value is double ? value.toInt() : value as int?);
    }
    if (fields.containsKey('vehicle_garage')) {
      final garageStr = fields['vehicle_garage'] as String?;
      vehicle = vehicle.copyWith(
        hasGarage:
            garageStr?.toLowerCase().contains('sì') == true ||
            garageStr?.toLowerCase().contains('si') == true,
      );
    }

    // Driver fields
    if (fields.containsKey('driver_first_name')) {
      driver = driver.copyWith(firstName: fields['driver_first_name'] as String?);
    }
    if (fields.containsKey('driver_last_name')) {
      driver = driver.copyWith(lastName: fields['driver_last_name'] as String?);
    }
    if (fields.containsKey('driver_age')) {
      final age = fields['driver_age'] as int?;
      if (age != null) {
        final birthYear = DateTime.now().year - age;
        driver = driver.copyWith(birthDate: DateTime(birthYear, 1, 1));
      }
    }
    if (fields.containsKey('driver_city')) {
      driver = driver.copyWith(city: fields['driver_city'] as String?);
    }
    if (fields.containsKey('driver_license_year')) {
      final year = fields['driver_license_year'] as int?;
      if (year != null) {
        driver = driver.copyWith(licenseDate: DateTime(year, 1, 1));
      }
    }
    if (fields.containsKey('driver_accidents')) {
      final accidentStr = fields['driver_accidents'] as String?;
      final hadAccidents =
          accidentStr?.toLowerCase().contains('sì') == true ||
          accidentStr?.toLowerCase().contains('si') == true;
      driver = driver.copyWith(hadAccidents: hadAccidents);
    }
    if (fields.containsKey('driver_accidents_count')) {
      driver = driver.copyWith(accidentsCount: fields['driver_accidents_count'] as int?);
    }

    // Calcola completamento
    final completion = (vehicle.completionPercentage + driver.completionPercentage) / 2;

    return state.copyWith(
      vehicleData: vehicle,
      driverData: driver,
      completionPercentage: completion,
    );
  }

  FuelType? _parseFuelType(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.contains('benzina') || lower.contains('gasoline')) return FuelType.gasoline;
    if (lower.contains('diesel')) return FuelType.diesel;
    if (lower.contains('ibrida') || lower.contains('hybrid')) return FuelType.hybrid;
    if (lower.contains('elettrica') || lower.contains('electric')) return FuelType.electric;
    if (lower.contains('gpl') || lower.contains('lpg')) return FuelType.lpg;
    return null;
  }

  VehicleUsage? _parseUsage(String? value) {
    if (value == null) return null;
    final lower = value.toLowerCase();
    if (lower.contains('privat') || lower.contains('personal')) return VehicleUsage.personal;
    if (lower.contains('lavoro') || lower.contains('work')) return VehicleUsage.work;
    if (lower.contains('misto') || lower.contains('mixed')) return VehicleUsage.mixed;
    return null;
  }

  /// Aggiorna direttamente VehicleData (per estrazione AI)
  void updateVehicleData(VehicleDataModel vehicle) {
    emit(state.copyWith(vehicleData: vehicle));
  }

  ///  Aggiorna direttamente DriverData (per estrazione AI)
  void updateDriverData(DriverDataModel driver) {
    emit(state.copyWith(driverData: driver));
  }

  /// Reset per nuova sessione
  void reset() {
    emit(QuoteState.initial());
  }
}
