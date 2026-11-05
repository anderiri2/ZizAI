import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
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

  String labelFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        switch (this) {
          case EdibilityLevel.excellent:
            return 'Jangarri bikaina';
          case EdibilityLevel.good:
            return 'Jangarri ona';
          case EdibilityLevel.caution:
            return 'Jangarria kontuz';
          case EdibilityLevel.nonEdible:
            return 'Balio kulinariorik gabea';
          case EdibilityLevel.toxic:
            return 'Toxikoa';
          case EdibilityLevel.deadly:
            return 'Hilgarria';
        }
      case AppLanguage.es:
        return displayLabel;
      case AppLanguage.en:
        switch (this) {
          case EdibilityLevel.excellent:
            return 'Choice edible';
          case EdibilityLevel.good:
            return 'Good edible';
          case EdibilityLevel.caution:
            return 'Edible with caution';
          case EdibilityLevel.nonEdible:
            return 'Inedible';
          case EdibilityLevel.toxic:
            return 'Toxic';
          case EdibilityLevel.deadly:
            return 'Deadly poisonous';
        }
    }
  }

  String shortLabelFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        switch (this) {
          case EdibilityLevel.excellent:
            return 'Bikaina';
          case EdibilityLevel.good:
            return 'Jangarria';
          case EdibilityLevel.caution:
            return 'Kontuz';
          case EdibilityLevel.nonEdible:
            return 'Ez jangarria';
          case EdibilityLevel.toxic:
            return 'Toxikoa';
          case EdibilityLevel.deadly:
            return 'Hilgarria';
        }
      case AppLanguage.es:
        return shortLabel;
      case AppLanguage.en:
        switch (this) {
          case EdibilityLevel.excellent:
            return 'Choice';
          case EdibilityLevel.good:
            return 'Edible';
          case EdibilityLevel.caution:
            return 'Caution';
          case EdibilityLevel.nonEdible:
            return 'Inedible';
          case EdibilityLevel.toxic:
            return 'Toxic';
          case EdibilityLevel.deadly:
            return 'Deadly';
        }
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
  String edibilityWarningFor(AppLanguage lang) => riskLevel.labelFor(lang);
}

class Mushroom {
  final String id;
  final String scientificName;
  final String spanishName;
  final String basqueName;
  final String englishName;
  final String family;
  final EdibilityLevel edibility;
  final String edibilityLabel;
  final String edibilityLabelEu;
  final String edibilityLabelEn;
  final String season;
  final String seasonEu;
  final String seasonEn;
  final String habitat;
  final String habitatEu;
  final String habitatEn;
  final String summary;
  final String summaryEu;
  final String summaryEn;
  final MushroomMorphology morphology;
  final MushroomMorphology morphologyEu;
  final MushroomMorphology morphologyEn;
  final List<MushroomConfusion> confusions;
  final List<String> images;

  const Mushroom({
    required this.id,
    required this.scientificName,
    required this.spanishName,
    required this.basqueName,
    this.englishName = '',
    required this.family,
    required this.edibility,
    required this.edibilityLabel,
    this.edibilityLabelEu = '',
    this.edibilityLabelEn = '',
    required this.season,
    this.seasonEu = '',
    this.seasonEn = '',
    required this.habitat,
    this.habitatEu = '',
    this.habitatEn = '',
    required this.summary,
    this.summaryEu = '',
    this.summaryEn = '',
    required this.morphology,
    MushroomMorphology? morphologyEu,
    MushroomMorphology? morphologyEn,
    required this.confusions,
    required this.images,
  })  : morphologyEu = morphologyEu ?? morphology,
        morphologyEn = morphologyEn ?? morphology;

  String get primaryImage =>
      images.isNotEmpty ? images.first : 'assets/images/logo_perretxikotan.png';

  String get primaryImageAsset => primaryImage;
  bool get isEdible =>
      edibility == EdibilityLevel.excellent ||
      edibility == EdibilityLevel.good ||
      edibility == EdibilityLevel.caution;
  bool get isToxic =>
      edibility == EdibilityLevel.toxic || edibility == EdibilityLevel.deadly;
  String get commonNameEs => spanishName;
  String get nameEu => basqueName;
  String get commonNameEn =>
      englishName.isNotEmpty ? englishName : scientificName;
  String get capDescription => morphology.cap;
  String get hymeniumDescription => morphology.hymenium;

  String displayNameFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return basqueName;
      case AppLanguage.es:
        return spanishName;
      case AppLanguage.en:
        return commonNameEn;
    }
  }

  String latinWithCommon(AppLanguage lang) {
    final common = displayNameFor(lang);
    return common.isNotEmpty ? '$scientificName ($common)' : scientificName;
  }

  String secondaryNamesFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return 'ES: $spanishName · EN: $commonNameEn';
      case AppLanguage.es:
        return 'EU: $basqueName · EN: $commonNameEn';
      case AppLanguage.en:
        return 'EU: $basqueName · ES: $spanishName';
    }
  }

  String edibilityLabelFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return edibilityLabelEu.isNotEmpty
            ? edibilityLabelEu
            : edibility.labelFor(lang);
      case AppLanguage.es:
        return edibilityLabel;
      case AppLanguage.en:
        return edibilityLabelEn.isNotEmpty
            ? edibilityLabelEn
            : edibility.labelFor(lang);
    }
  }

  String seasonFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return seasonEu.isNotEmpty ? seasonEu : season;
      case AppLanguage.es:
        return season;
      case AppLanguage.en:
        return seasonEn.isNotEmpty ? seasonEn : season;
    }
  }

  String habitatFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return habitatEu.isNotEmpty ? habitatEu : habitat;
      case AppLanguage.es:
        return habitat;
      case AppLanguage.en:
        return habitatEn.isNotEmpty ? habitatEn : habitat;
    }
  }

  String summaryFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return summaryEu.isNotEmpty ? summaryEu : summary;
      case AppLanguage.es:
        return summary;
      case AppLanguage.en:
        return summaryEn.isNotEmpty ? summaryEn : summary;
    }
  }

  MushroomMorphology morphologyFor(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.eu:
        return morphologyEu;
      case AppLanguage.es:
        return morphology;
      case AppLanguage.en:
        return morphologyEn;
    }
  }

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
    final baseMorph = MushroomMorphology.fromJson(morphMap);
    final morphEuMap = json['morphologyEu'] as Map<String, dynamic>?;
    final morphEnMap = json['morphologyEn'] as Map<String, dynamic>?;

    return Mushroom(
      id: json['id'] as String,
      scientificName: json['scientificName'] as String? ?? '',
      spanishName:
          json['spanishName'] as String? ?? json['commonNameEs'] as String? ?? '',
      basqueName:
          json['basqueName'] as String? ?? json['nameEu'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      family: json['family'] as String? ?? '',
      edibility: edibility,
      edibilityLabel: json['edibilityLabel'] as String? ??
          json['edibilityDetail'] as String? ??
          edibility.displayLabel,
      edibilityLabelEu: json['edibilityLabelEu'] as String? ??
          edibility.labelFor(AppLanguage.eu),
      edibilityLabelEn: json['edibilityLabelEn'] as String? ??
          edibility.labelFor(AppLanguage.en),
      season: json['season'] as String? ?? '',
      seasonEu: json['seasonEu'] as String? ?? '',
      seasonEn: json['seasonEn'] as String? ?? '',
      habitat: json['habitat'] as String? ?? '',
      habitatEu: json['habitatEu'] as String? ?? '',
      habitatEn: json['habitatEn'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      summaryEu: json['summaryEu'] as String? ?? '',
      summaryEn: json['summaryEn'] as String? ?? '',
      morphology: baseMorph,
      morphologyEu:
          morphEuMap != null ? MushroomMorphology.fromJson(morphEuMap) : baseMorph,
      morphologyEn:
          morphEnMap != null ? MushroomMorphology.fromJson(morphEnMap) : baseMorph,
      confusions: ((json['confusions'] as List<dynamic>?) ?? const [])
          .map((e) => MushroomConfusion.fromJson(e as Map<String, dynamic>))
          .toList(),
      images: ((json['images'] as List<dynamic>?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
