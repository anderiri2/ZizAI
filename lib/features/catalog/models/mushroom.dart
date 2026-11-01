import 'package:flutter/material.dart';
import '../../../core/theme/autumn_theme.dart';

enum EdibilityLevel {
  excellent,
  good,
  caution,
  nonEdible,
  toxic,
  deadly;

  static EdibilityLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'excellent':
        return EdibilityLevel.excellent;
      case 'good':
        return EdibilityLevel.good;
      case 'caution':
        return EdibilityLevel.caution;
      case 'non_edible':
      case 'nonedible':
        return EdibilityLevel.nonEdible;
      case 'toxic':
        return EdibilityLevel.toxic;
      case 'deadly':
        return EdibilityLevel.deadly;
      default:
        return EdibilityLevel.nonEdible;
    }
  }

  String get displayLabel {
    switch (this) {
      case EdibilityLevel.excellent:
        return 'Excelente comestible';
      case EdibilityLevel.good:
        return 'Buen comestible';
      case EdibilityLevel.caution:
        return 'Comestible con precaución';
      case EdibilityLevel.nonEdible:
        return 'Sin valor culinario';
      case EdibilityLevel.toxic:
        return 'Tóxica';
      case EdibilityLevel.deadly:
        return 'Mortal';
    }
  }

  String get labelEs => displayLabel;

  String get shortLabel {
    switch (this) {
      case EdibilityLevel.excellent:
        return 'Excelente';
      case EdibilityLevel.good:
        return 'Comestible';
      case EdibilityLevel.caution:
        return 'Con precaución';
      case EdibilityLevel.nonEdible:
        return 'Sin valor';
      case EdibilityLevel.toxic:
        return 'Tóxica';
      case EdibilityLevel.deadly:
        return 'Mortal';
    }
  }

  Color get badgeColor {
    switch (this) {
      case EdibilityLevel.excellent:
        return AutumnColors.edibilityExcellent;
      case EdibilityLevel.good:
        return AutumnColors.edibilityGood;
      case EdibilityLevel.caution:
        return AutumnColors.edibilityCaution;
      case EdibilityLevel.nonEdible:
        return AutumnColors.edibilityNonEdible;
      case EdibilityLevel.toxic:
        return AutumnColors.edibilityToxic;
      case EdibilityLevel.deadly:
        return AutumnColors.edibilityDeadly;
    }
  }

  IconData get icon {
    switch (this) {
      case EdibilityLevel.excellent:
        return Icons.workspace_premium_rounded;
      case EdibilityLevel.good:
        return Icons.restaurant_rounded;
      case EdibilityLevel.caution:
        return Icons.warning_amber_rounded;
      case EdibilityLevel.nonEdible:
        return Icons.block_rounded;
      case EdibilityLevel.toxic:
        return Icons.flash_on_rounded;
      case EdibilityLevel.deadly:
        return Icons.dangerous_rounded;
    }
  }

  bool get isEdibleGroup =>
      this == EdibilityLevel.excellent ||
      this == EdibilityLevel.good ||
      this == EdibilityLevel.caution;

  bool get isDangerousGroup =>
      this == EdibilityLevel.toxic || this == EdibilityLevel.deadly;
}

class MushroomMorphology {
  final String cap;
  final String hymenium;
  final String stem;
  final String flesh;

  const MushroomMorphology({
    required this.cap,
    required this.hymenium,
    required this.stem,
    required this.flesh,
  });

  factory MushroomMorphology.fromJson(Map<String, dynamic> json) {
    return MushroomMorphology(
      cap: json['cap'] as String? ?? '',
      hymenium: json['hymenium'] as String? ?? '',
      stem: json['stem'] as String? ?? '',
      flesh: json['flesh'] as String? ?? '',
    );
  }
}

class MushroomConfusion {
  final String mushroomId;
  final String scientificName;
  final String commonName;
  final EdibilityLevel riskLevel;
  final String difference;

  const MushroomConfusion({
    required this.mushroomId,
    required this.scientificName,
    required this.commonName,
    required this.riskLevel,
    required this.difference,
  });

  factory MushroomConfusion.fromJson(Map<String, dynamic> json) {
    return MushroomConfusion(
      mushroomId:
          json['mushroomId'] as String? ?? json['targetId'] as String? ?? '',
      scientificName: json['scientificName'] as String? ?? '',
      commonName:
          json['commonName'] as String? ?? json['speciesName'] as String? ?? '',
      riskLevel: EdibilityLevel.fromString(
        json['riskLevel'] as String? ?? json['edibilityWarning'] as String? ?? '',
      ),
      difference:
          json['difference'] as String? ?? json['differences'] as String? ?? '',
    );
  }

  String get targetId => mushroomId;
  String get speciesName =>
      scientificName.isNotEmpty ? '$commonName ($scientificName)' : commonName;
  String get edibilityWarning => riskLevel.displayLabel;
}

class Mushroom {
  final String id;
  final String scientificName;
  final String spanishName;
  final String basqueName;
  final String family;
  final EdibilityLevel edibility;
  final String edibilityLabel;
  final String season;
  final String habitat;
  final String summary;
  final MushroomMorphology morphology;
  final List<MushroomConfusion> confusions;
  final List<String> images;

  const Mushroom({
    required this.id,
    required this.scientificName,
    required this.spanishName,
    required this.basqueName,
    required this.family,
    required this.edibility,
    required this.edibilityLabel,
    required this.season,
    required this.habitat,
    required this.summary,
    required this.morphology,
    required this.confusions,
    required this.images,
  });

  String get primaryImage =>
      images.isNotEmpty ? images.first : 'assets/images/logo_perretxikotan.png';

  String get primaryImageAsset => primaryImage;
  String get commonNameEs => spanishName;
  String get nameEu => basqueName;
  String get capDescription => morphology.cap;
  String get hymeniumDescription => morphology.hymenium;

  factory Mushroom.fromJson(Map<String, dynamic> json) {
    final edibility = EdibilityLevel.fromString(
      json['edibility'] as String? ?? 'non_edible',
    );
    final morphMap = (json['morphology'] as Map<String, dynamic>?) ??
        <String, dynamic>{
          'cap': json['capDescription'] as String? ?? '',
          'hymenium': json['hymeniumDescription'] as String? ?? '',
          'stem': json['stipeDescription'] as String? ?? '',
          'flesh': json['fleshDescription'] as String? ?? '',
        };
    return Mushroom(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String? ?? '',
      spanishName:
          json['spanishName'] as String? ?? json['commonNameEs'] as String? ?? '',
      basqueName:
          json['basqueName'] as String? ?? json['nameEu'] as String? ?? '',
      family: json['family'] as String? ?? '',
      edibility: edibility,
      edibilityLabel: json['edibilityLabel'] as String? ??
          json['edibilityDetail'] as String? ??
          edibility.displayLabel,
      season: json['season'] as String? ?? '',
      habitat: json['habitat'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      morphology: MushroomMorphology.fromJson(morphMap),
      confusions: ((json['confusions'] as List<dynamic>?) ?? const [])
          .map((e) => MushroomConfusion.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: ((json['images'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
