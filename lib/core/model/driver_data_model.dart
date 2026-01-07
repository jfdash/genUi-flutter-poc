class DriverDataModel {
  final String? firstName;
  final String? lastName;
  final DateTime? birthDate;
  final String? city;
  final DateTime? licenseDate;
  final bool? hadAccidents;
  final int? accidentsCount;

  DriverDataModel ({
    this.firstName,
    this.lastName,
    this.birthDate,
    this.city,
    this.licenseDate,
    this.hadAccidents,
    this.accidentsCount,
  });

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  int? get yearsOfExperience {
    if (licenseDate == null) return null;
    final now = DateTime.now();
    return now.year - licenseDate!.year;
  }

  String get riskCategory {
    if (age == null) return 'unknown';
    
    int riskScore = 0;
    
    if (age! < 25) {
      riskScore += 3;
    } else if (age! < 30) { 
      riskScore += 1; 
      } else if (age! > 65) { 
        riskScore += 2;
        }
    
    if (yearsOfExperience != null) {
      if (yearsOfExperience! < 2) {
        riskScore += 3;
      } else if (yearsOfExperience! < 5) {riskScore += 1;}
    }
    
    if (hadAccidents == true) {
      riskScore += (accidentsCount ?? 1) * 2;
    }
    
    if (riskScore >= 6) return 'high';
    if (riskScore >= 3) return 'medium';
    return 'low';
  }

  double get completionPercentage {
    int total = 7;
    int filled = 0;
    if (firstName != null) filled++;
    if (lastName != null) filled++;
    if (birthDate != null) filled++;
    if (city != null) filled++;
    if (licenseDate != null) filled++;
    if (hadAccidents != null) filled++;
    if (hadAccidents == true && accidentsCount != null) filled++;
    return filled / total;
  }

  bool get isComplete => completionPercentage >= 0.7;

  DriverDataModel copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthDate,
    String? city,
    DateTime? licenseDate,
    bool? hadAccidents,
    int? accidentsCount,
  }) {
    return DriverDataModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      birthDate: birthDate ?? this.birthDate,
      city: city ?? this.city,
      licenseDate: licenseDate ?? this.licenseDate,
      hadAccidents: hadAccidents ?? this.hadAccidents,
      accidentsCount: accidentsCount ?? this.accidentsCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'firstName': firstName,
    'lastName': lastName,
    'birthDate': birthDate?.toIso8601String(),
    'city': city,
    'licenseDate': licenseDate?.toIso8601String(),
    'hadAccidents': hadAccidents,
    'accidentsCount': accidentsCount,
  };

  factory DriverDataModel.fromJson(Map<String, dynamic> json) {
    return DriverDataModel(
      firstName: json['firstName'],
      lastName: json['lastName'],
      birthDate: json['birthDate'] != null 
          ? DateTime.parse(json['birthDate']) 
          : null,
      city: json['city'],
      licenseDate: json['licenseDate'] != null 
          ? DateTime.parse(json['licenseDate']) 
          : null,
      hadAccidents: json['hadAccidents'],
      accidentsCount: json['accidentsCount'],
    );
  }
}