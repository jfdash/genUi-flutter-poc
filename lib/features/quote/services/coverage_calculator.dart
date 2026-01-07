import 'package:gen_ui_poc/core/model/cover_suggestion_model.dart';
import 'package:gen_ui_poc/core/model/driver_data_model.dart';
import 'package:gen_ui_poc/core/model/vehicle_data_model.dart';

class CoverageCalculator {
  
  List<CoverageSuggestion> calculateSuggestions({
    required VehicleDataModel vehicle,
    required DriverDataModel driver,
  }) {
    final suggestions = <CoverageSuggestion>[];
    
    // Calcola fattori di rischio
    final riskFactors = _calculateRiskFactors(vehicle, driver);
    
    // 1. RC Auto (sempre obbligatoria)
    suggestions.add(_calculateRCAuto(vehicle, driver, riskFactors));
    
    // 2. Furto e Incendio
    suggestions.add(_calculateTheft(vehicle, driver, riskFactors));
    
    // 3. Kasko
    suggestions.add(_calculateKasko(vehicle, driver, riskFactors));
    
    // 4. Cristalli
    suggestions.add(_calculateGlass(vehicle, driver, riskFactors));
    
    // 5. Assistenza Stradale
    suggestions.add(_calculateRoadside(vehicle, driver, riskFactors));
    
    return suggestions;
  }

  /// ✅ Calcola fattori di rischio (deterministici)
  RiskFactors _calculateRiskFactors(VehicleDataModel vehicle, DriverDataModel driver) {
    // Rischio furto
    double theftRisk = 0.0;
    
    // Città ad alto rischio
    final highRiskCities = ['milano', 'roma', 'napoli', 'torino', 'bari', 'catania'];
    if (driver.city != null && highRiskCities.contains(driver.city!.toLowerCase())) {
      theftRisk += 0.4;
    }
    
    // No garage
    if (vehicle.hasGarage != true) {
      theftRisk += 0.3;
    }
    
    // Auto di valore
    if (vehicle.estimatedValue > 20000) {
      theftRisk += 0.2;
    }
    
    // Brand premium
    final premiumBrands = ['bmw', 'mercedes', 'audi', 'tesla', 'porsche', 'lexus'];
    if (vehicle.brand != null && premiumBrands.contains(vehicle.brand!.toLowerCase())) {
      theftRisk += 0.1;
    }
    
    // Rischio incidenti
    double accidentRisk = 0.0;
    
    // Età conducente
    if (driver.age != null) {
      if (driver.age! < 25) accidentRisk += 0.3;
      else if (driver.age! > 70) accidentRisk += 0.2;
    }
    
    // Esperienza
    if (driver.yearsOfExperience != null && driver.yearsOfExperience! < 2) {
      accidentRisk += 0.3;
    }
    
    // Storico sinistri
    if (driver.hadAccidents == true) {
      accidentRisk += 0.2 + (driver.accidentsCount ?? 1) * 0.1;
    }
    
    // Km annui elevati
    if (vehicle.annualKm != null && vehicle.annualKm! > 30000) {
      accidentRisk += 0.1;
    }
    
    // Rischio conducente (combinato)
    double driverRisk = (accidentRisk * 0.7) + (theftRisk * 0.3);
    
    return RiskFactors(
      theftRisk: theftRisk.clamp(0.0, 1.0),
      accidentRisk: accidentRisk.clamp(0.0, 1.0),
      driverRisk: driverRisk.clamp(0.0, 1.0),
      details: {
        'city': driver.city,
        'garage': vehicle.hasGarage,
        'vehicle_value': vehicle.estimatedValue,
        'driver_age': driver.age,
        'experience': driver.yearsOfExperience,
        'accidents': driver.hadAccidents,
      },
    );
  }

  /// RC Auto (obbligatoria)
  CoverageSuggestion _calculateRCAuto(
    VehicleDataModel vehicle,
    DriverDataModel driver,
    RiskFactors risk,
  ) {
    double basePrice = 350.0;
    
    // Fattori età
    if (driver.age != null) {
      if (driver.age! < 25) {
        basePrice *= 1.5;
      } else if (driver.age! > 70) {
        basePrice *= 1.3;
      } else if (driver.age! >= 30 && driver.age! <= 60) {
        basePrice *= 0.9; // Sconto fascia media
      }
    }
    
    // Fattore esperienza
    if (driver.yearsOfExperience != null) {
      if (driver.yearsOfExperience! < 2) {
        basePrice *= 1.4;
      } else if (driver.yearsOfExperience! > 10) {
        basePrice *= 0.85;
      }
    }
    
    // Fattore sinistri
    if (driver.hadAccidents == true && driver.accidentsCount != null) {
      basePrice *= (1 + (driver.accidentsCount! * 0.2));
    }
    
    // Fattore veicolo
    if (vehicle.estimatedValue > 30000) {
      basePrice *= 1.2;
    }
    
    // Potenza (approssimata da valore)
    if (vehicle.estimatedValue > 50000) {
      basePrice *= 1.3;
    }
    
    return CoverageSuggestion(
      type: CoverageType.rcAuto,
      title: 'RC Auto',
      description: 'Responsabilità civile obbligatoria per legge',
      annualPrice: basePrice.roundToDouble(),
      level: SuggestionLevel.essential,
      riskFactors: risk,
      // reason, pros, cons → generati da AI dopo
    );
  }

  /// Furto e Incendio
  CoverageSuggestion _calculateTheft(
    VehicleDataModel vehicle,
    DriverDataModel driver,
    RiskFactors risk,
  ) {
    double basePrice = 120.0;
    
    // Prezzo scala con valore veicolo
    if (vehicle.estimatedValue > 15000) {
      basePrice = vehicle.estimatedValue * 0.01; // 1% del valore
    }
    
    // Maggiorazione città alto rischio
    if (risk.theftRisk > 0.5) {
      basePrice *= 1.5;
    }
    
    // Sconto se ha garage
    if (vehicle.hasGarage == true) {
      basePrice *= 0.7;
    }
    
    // Determina livello suggerimento
    SuggestionLevel level;
    if (risk.theftRisk > 0.7) {
      level = SuggestionLevel.essential;
    } else if (risk.theftRisk > 0.4 || vehicle.estimatedValue > 20000) {
      level = SuggestionLevel.recommended;
    } else {
      level = SuggestionLevel.optional;
    }
    
    return CoverageSuggestion(
      type: CoverageType.theft,
      title: 'Furto e Incendio',
      description: 'Copre furto totale, tentato furto e incendio',
      annualPrice: basePrice.roundToDouble(),
      level: level,
      riskFactors: risk,
    );
  }

  /// Kasko
  CoverageSuggestion _calculateKasko(
    VehicleDataModel vehicle,
    DriverDataModel driver,
    RiskFactors risk,
  ) {
    final vehicleAge = vehicle.year != null 
        ? DateTime.now().year - vehicle.year! 
        : 10;
    
    double basePrice = vehicle.estimatedValue * 0.03; // 3% del valore
    
    // Maggiorazione per conducente alto rischio
    if (risk.driverRisk > 0.6) {
      basePrice *= 1.3;
    }
    
    // Sconto per conducente basso rischio
    if (risk.driverRisk < 0.3) {
      basePrice *= 0.8;
    }
    
    // Determina livello
    SuggestionLevel level;
    
    if (vehicleAge > 8 || vehicle.estimatedValue < 10000) {
      // Auto vecchia o basso valore → non conviene
      level = SuggestionLevel.notRecommended;
      basePrice = 300.0; // Prezzo minimo
    } else if (vehicle.estimatedValue > 25000 && vehicleAge <= 5) {
      // Auto nuova e costosa → essenziale/raccomandato
      level = vehicle.estimatedValue > 40000 
          ? SuggestionLevel.essential 
          : SuggestionLevel.recommended;
    } else {
      level = SuggestionLevel.optional;
    }
    
    return CoverageSuggestion(
      type: CoverageType.kasko,
      title: 'Kasko',
      description: 'Copre danni all\'auto anche per colpa propria',
      annualPrice: basePrice.roundToDouble(),
      level: level,
      riskFactors: risk,
    );
  }

  /// Cristalli
  CoverageSuggestion _calculateGlass(
    VehicleDataModel vehicle,
    DriverDataModel driver,
    RiskFactors risk,
  ) {
    double basePrice = 50.0;
    
    // Maggiorazione per km elevati (maggiore esposizione)
    if (vehicle.annualKm != null && vehicle.annualKm! > 20000) {
      basePrice = 70.0;
    }
    
    // Sempre raccomandato (evento frequente, costo basso)
    return CoverageSuggestion(
      type: CoverageType.glass,
      title: 'Cristalli',
      description: 'Copre rottura vetri e parabrezza',
      annualPrice: basePrice,
      level: SuggestionLevel.recommended,
      riskFactors: risk,
    );
  }

  /// Assistenza Stradale
  CoverageSuggestion _calculateRoadside(
    VehicleDataModel vehicle,
    DriverDataModel driver,
    RiskFactors risk,
  ) {
    double basePrice = 80.0;
    SuggestionLevel level = SuggestionLevel.optional;
    
    // Essenziale per veicoli elettrici/ibridi
    if (vehicle.fuelType == FuelType.electric || 
        vehicle.fuelType == FuelType.hybrid) {
      basePrice = 120.0;
      level = SuggestionLevel.essential;
    }
    
    // Raccomandato per km elevati
    if (vehicle.annualKm != null && vehicle.annualKm! > 25000) {
      level = SuggestionLevel.recommended;
    }
    
    // Raccomandato per veicoli vecchi
    final vehicleAge = vehicle.year != null 
        ? DateTime.now().year - vehicle.year! 
        : 0;
    if (vehicleAge > 10) {
      level = SuggestionLevel.recommended;
      basePrice = 100.0;
    }
    
    return CoverageSuggestion(
      type: CoverageType.roadside,
      title: 'Assistenza Stradale',
      description: 'Soccorso h24, traino, auto sostitutiva',
      annualPrice: basePrice,
      level: level,
      riskFactors: risk,
    );
  }
}