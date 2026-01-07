import 'package:flutter/material.dart';

class CoverageSuggestion {
  final CoverageType type;
  final String title;
  final String description;
  final double annualPrice;
  final SuggestionLevel level;
  final String? reason; 
  final List<String>? pros; 
  final List<String>? cons; 
  final RiskFactors? riskFactors; 

  const CoverageSuggestion({
    required this.type,
    required this.title,
    required this.description,
    required this.annualPrice,
    required this.level,
    this.reason,
    this.pros,
    this.cons,
    this.riskFactors,
  });

  
  CoverageSuggestion copyWith({
    CoverageType? type,
    String? title,
    String? description,
    double? annualPrice,
    SuggestionLevel? level,
    String? reason,
    List<String>? pros,
    List<String>? cons,
    RiskFactors? riskFactors,
  }) {
    return CoverageSuggestion(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      annualPrice: annualPrice ?? this.annualPrice,
      level: level ?? this.level,
      reason: reason ?? this.reason,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      riskFactors: riskFactors ?? this.riskFactors,
    );
  }

  String get levelEmoji {
    switch (level) {
      case SuggestionLevel.essential:
        return '🔥';
      case SuggestionLevel.recommended:
        return '💎';
      case SuggestionLevel.optional:
        return '💡';
      case SuggestionLevel.notRecommended:
        return '❌';
    }
  }

  String get levelLabel {
    switch (level) {
      case SuggestionLevel.essential:
        return 'ESSENZIALE';
      case SuggestionLevel.recommended:
        return 'CONSIGLIATO';
      case SuggestionLevel.optional:
        return 'OPZIONALE';
      case SuggestionLevel.notRecommended:
        return 'NON CONSIGLIATO';
    }
  }

  Color get levelColor {
    switch (level) {
      case SuggestionLevel.essential:
        return const Color(0xFFDC2626);
      case SuggestionLevel.recommended:
        return const Color(0xFF059669);
      case SuggestionLevel.optional:
        return const Color(0xFF3B82F6);
      case SuggestionLevel.notRecommended:
        return const Color(0xFF6B7280);
    }
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'description': description,
        'annualPrice': annualPrice,
        'level': level.name,
        'reason': reason,
        'pros': pros,
        'cons': cons,
        'riskFactors': riskFactors?.toJson(),
      };

  factory CoverageSuggestion.fromJson(Map<String, dynamic> json) {
    return CoverageSuggestion(
      type: CoverageType.values.byName(json['type']),
      title: json['title'],
      description: json['description'],
      annualPrice: (json['annualPrice'] as num).toDouble(),
      level: SuggestionLevel.values.byName(json['level']),
      reason: json['reason'],
      pros: json['pros'] != null ? List<String>.from(json['pros']) : null,
      cons: json['cons'] != null ? List<String>.from(json['cons']) : null,
      riskFactors: json['riskFactors'] != null
          ? RiskFactors.fromJson(json['riskFactors'])
          : null,
    );
  }
}

enum SuggestionLevel {
  essential,
  recommended,
  optional,
  notRecommended,
}

enum CoverageType {
  rcAuto,
  theft,
  fire,
  kasko,
  glass,
  roadside,
  legal,
  driver,
  natural,
  vandalism,
  collision;

  String get displayName {
    switch (this) {
      case CoverageType.rcAuto:
        return 'RC Auto';
      case CoverageType.theft:
        return 'Furto e Incendio';
      case CoverageType.fire:
        return 'Incendio';
      case CoverageType.kasko:
        return 'Kasko';
      case CoverageType.glass:
        return 'Cristalli';
      case CoverageType.roadside:
        return 'Assistenza Stradale';
      case CoverageType.legal:
        return 'Tutela Legale';
      case CoverageType.driver:
        return 'Infortuni Conducente';
      case CoverageType.natural:
        return 'Eventi Naturali';
      case CoverageType.vandalism:
        return 'Atti Vandalici';
      case CoverageType.collision:
        return 'Collisione Animali';
    }
  }
}

class RiskFactors {
  final double theftRisk; 
  final double accidentRisk; 
  final double driverRisk; 
  final Map<String, dynamic> details;

  const RiskFactors({
    required this.theftRisk,
    required this.accidentRisk,
    required this.driverRisk,
    this.details = const {},
  });

  Map<String, dynamic> toJson() => {
        'theftRisk': theftRisk,
        'accidentRisk': accidentRisk,
        'driverRisk': driverRisk,
        'details': details,
      };

  factory RiskFactors.fromJson(Map<String, dynamic> json) {
    return RiskFactors(
      theftRisk: (json['theftRisk'] as num).toDouble(),
      accidentRisk: (json['accidentRisk'] as num).toDouble(),
      driverRisk: (json['driverRisk'] as num).toDouble(),
      details: json['details'] ?? {},
    );
  }
}