
class VehicleDataModel {
  final String? brand;
  final String? model;
  final int? year;
  final String? plate;
  final FuelType? fuelType;
  final int? annualKm;
  final VehicleUsage? usage;
  final int? marketValue;
  final bool? hasGarage; 

  VehicleDataModel({
    this.brand,
    this.model,
    this.year,
    this.plate,
    this.fuelType,
    this.annualKm,
    this.usage,
    this.marketValue,
    this.hasGarage,
  });

  int get estimatedValue {
    if (marketValue != null) return marketValue!;
    if (year == null) return 10000;
    
    final age = DateTime.now().year - year!;
    final baseValue = 20000;
    final depreciation = age * 1500;
    return (baseValue - depreciation).clamp(2000, 50000);
  }

  double get completionPercentage {
    int total = 9;
    int filled = 0;
    if (brand != null) filled++;
    if (model != null) filled++;
    if (year != null) filled++;
    if (plate != null) filled++;
    if (fuelType != null) filled++;
    if (annualKm != null) filled++;
    if (usage != null) filled++;
    if (marketValue != null) filled++;
    if (hasGarage != null) filled++;
    return filled / total;
  }

  bool get isComplete => completionPercentage >= 0.7;

  VehicleDataModel copyWith({
    String? brand,
    String? model,
    int? year,
    String? plate,
    FuelType? fuelType,
    int? annualKm,
    VehicleUsage? usage,
    int? marketValue,
    bool? hasGarage,
  }) {
    return VehicleDataModel(
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plate: plate ?? this.plate,
      fuelType: fuelType ?? this.fuelType,
      annualKm: annualKm ?? this.annualKm,
      usage: usage ?? this.usage,
      marketValue: marketValue ?? this.marketValue,
      hasGarage: hasGarage ?? this.hasGarage,
    );
  }

  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'year': year,
    'plate': plate,
    'fuelType': fuelType?.name,
    'annualKm': annualKm,
    'usage': usage?.name,
    'marketValue': marketValue,
    'hasGarage': hasGarage,
  };

  factory VehicleDataModel.fromJson(Map<String, dynamic> json) {
    return VehicleDataModel(
      brand: json['brand'],
      model: json['model'],
      year: json['year'],
      plate: json['plate'],
      fuelType: json['fuelType'] != null 
          ? FuelType.values.byName(json['fuelType']) 
          : null,
      annualKm: json['annualKm'],
      usage: json['usage'] != null 
          ? VehicleUsage.values.byName(json['usage']) 
          : null,
      marketValue: json['marketValue'],
      hasGarage: json['hasGarage'],
    );
  }
}

enum FuelType {
  gasoline,
  diesel,
  hybrid,
  electric,
  lpg;

  String get displayName {
    switch (this) {
      case FuelType.gasoline:
        return 'Benzina';
      case FuelType.diesel:
        return 'Diesel';
      case FuelType.hybrid:
        return 'Ibrida';
      case FuelType.electric:
        return 'Elettrica';
      case FuelType.lpg:
        return 'GPL';
    }
  }
}

enum VehicleUsage {
  personal,
  work,
  mixed;

  String get displayName {
    switch (this) {
      case VehicleUsage.personal:
        return 'Uso Privato';
      case VehicleUsage.work:
        return 'Uso Lavoro';
      case VehicleUsage.mixed:
        return 'Uso Misto';
    }
  }
}