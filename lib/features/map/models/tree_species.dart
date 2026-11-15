import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

/// Dominant tree species or woodland habitat associated with mushroom spots and
/// user-defined forest zones.
enum TreeSpecies {
  beech(
    id: 'beech',
    scientificName: 'Fagus sylvatica',
    color: Color(0xFFD97706),
    icon: Icons.park_rounded,
  ),
  oak(
    id: 'oak',
    scientificName: 'Quercus robur / petraea',
    color: Color(0xFF8B5E3C),
    icon: Icons.nature_rounded,
  ),
  pine(
    id: 'pine',
    scientificName: 'Pinus sylvestris / radiata',
    color: Color(0xFF15803D),
    icon: Icons.forest_rounded,
  ),
  holmOak(
    id: 'holm_oak',
    scientificName: 'Quercus ilex',
    color: Color(0xFF4D7C0F),
    icon: Icons.eco_rounded,
  ),
  chestnut(
    id: 'chestnut',
    scientificName: 'Castanea sativa',
    color: Color(0xFFB45309),
    icon: Icons.yard_rounded,
  ),
  pyreneanOak(
    id: 'pyrenean_oak',
    scientificName: 'Quercus pyrenaica',
    color: Color(0xFFC2410C),
    icon: Icons.energy_savings_leaf_rounded,
  ),
  fir(
    id: 'fir',
    scientificName: 'Abies alba / Larix',
    color: Color(0xFF0F766E),
    icon: Icons.terrain_rounded,
  ),
  birch(
    id: 'birch',
    scientificName: 'Betula pendula',
    color: Color(0xFFCA8A04),
    icon: Icons.spa_rounded,
  ),
  riverside(
    id: 'riverside',
    scientificName: 'Alnus / Populus / Salix',
    color: Color(0xFF0284C7),
    icon: Icons.water_rounded,
  ),
  eucalyptus(
    id: 'eucalyptus',
    scientificName: 'Eucalyptus globulus',
    color: Color(0xFF0D9488),
    icon: Icons.air_rounded,
  ),
  meadow(
    id: 'meadow',
    scientificName: 'Pradera / Pastizal',
    color: Color(0xFF65A30D),
    icon: Icons.grass_rounded,
  ),
  mixed(
    id: 'mixed',
    scientificName: 'Bosque mixto',
    color: Color(0xFF6D28D9),
    icon: Icons.grain_rounded,
  );

  const TreeSpecies({
    required this.id,
    required this.scientificName,
    required this.color,
    required this.icon,
  });

  final String id;
  final String scientificName;
  final Color color;
  final IconData icon;

  /// Filter sentinel used when filtering spots without an assigned tree.
  static const String unassignedFilterId = 'unassigned';

  /// Short localized tree / habitat name (e.g., "Haya", "Pagoa", "Beech").
  String label(AppLanguage lang) {
    return switch (this) {
      TreeSpecies.beech => switch (lang) {
          AppLanguage.eu => 'Pagoa',
          AppLanguage.es => 'Haya',
          AppLanguage.en => 'Beech',
        },
      TreeSpecies.oak => switch (lang) {
          AppLanguage.eu => 'Haritza',
          AppLanguage.es => 'Roble',
          AppLanguage.en => 'Oak',
        },
      TreeSpecies.pine => switch (lang) {
          AppLanguage.eu => 'Pinua',
          AppLanguage.es => 'Pino',
          AppLanguage.en => 'Pine',
        },
      TreeSpecies.holmOak => switch (lang) {
          AppLanguage.eu => 'Artea',
          AppLanguage.es => 'Encina',
          AppLanguage.en => 'Holm oak',
        },
      TreeSpecies.chestnut => switch (lang) {
          AppLanguage.eu => 'Gaztainondoa',
          AppLanguage.es => 'Castaño',
          AppLanguage.en => 'Chestnut',
        },
      TreeSpecies.pyreneanOak => switch (lang) {
          AppLanguage.eu => 'Ametza',
          AppLanguage.es => 'Marojo / Rebollo',
          AppLanguage.en => 'Pyrenean oak',
        },
      TreeSpecies.fir => switch (lang) {
          AppLanguage.eu => 'Izeia / Laritza',
          AppLanguage.es => 'Abeto / Alerce',
          AppLanguage.en => 'Fir / Larch',
        },
      TreeSpecies.birch => switch (lang) {
          AppLanguage.eu => 'Urkia',
          AppLanguage.es => 'Abedul',
          AppLanguage.en => 'Birch',
        },
      TreeSpecies.riverside => switch (lang) {
          AppLanguage.eu => 'Erribera / Haltza',
          AppLanguage.es => 'Ribera / Chopo / Aliso',
          AppLanguage.en => 'Riverside / Alder / Poplar',
        },
      TreeSpecies.eucalyptus => switch (lang) {
          AppLanguage.eu => 'Eukaliptoa',
          AppLanguage.es => 'Eucalipto',
          AppLanguage.en => 'Eucalyptus',
        },
      TreeSpecies.meadow => switch (lang) {
          AppLanguage.eu => 'Belazea / Larrea',
          AppLanguage.es => 'Pradera / Pastizal',
          AppLanguage.en => 'Meadow / Pasture',
        },
      TreeSpecies.mixed => switch (lang) {
          AppLanguage.eu => 'Baso mistoa / Bestea',
          AppLanguage.es => 'Bosque mixto / Otro',
          AppLanguage.en => 'Mixed forest / Other',
        },
    };
  }

  /// Localized forest formation name (e.g., "Hayedo", "Pagadia", "Beechwood").
  String forestLabel(AppLanguage lang) {
    return switch (this) {
      TreeSpecies.beech => switch (lang) {
          AppLanguage.eu => 'Pagadia',
          AppLanguage.es => 'Hayedo',
          AppLanguage.en => 'Beechwood',
        },
      TreeSpecies.oak => switch (lang) {
          AppLanguage.eu => 'Hariztia',
          AppLanguage.es => 'Robledal',
          AppLanguage.en => 'Oakwood',
        },
      TreeSpecies.pine => switch (lang) {
          AppLanguage.eu => 'Pinudia',
          AppLanguage.es => 'Pinar',
          AppLanguage.en => 'Pine forest',
        },
      TreeSpecies.holmOak => switch (lang) {
          AppLanguage.eu => 'Artadia',
          AppLanguage.es => 'Encinar',
          AppLanguage.en => 'Holm oak grove',
        },
      TreeSpecies.chestnut => switch (lang) {
          AppLanguage.eu => 'Gaztainadia',
          AppLanguage.es => 'Castañar',
          AppLanguage.en => 'Chestnut grove',
        },
      TreeSpecies.pyreneanOak => switch (lang) {
          AppLanguage.eu => 'Ameztia',
          AppLanguage.es => 'Rebollar / Marojal',
          AppLanguage.en => 'Pyrenean oakwood',
        },
      TreeSpecies.fir => switch (lang) {
          AppLanguage.eu => 'Izeidia / Lariztia',
          AppLanguage.es => 'Abetal / Alerzal',
          AppLanguage.en => 'Fir / Larch forest',
        },
      TreeSpecies.birch => switch (lang) {
          AppLanguage.eu => 'Urkidia',
          AppLanguage.es => 'Abedular',
          AppLanguage.en => 'Birch grove',
        },
      TreeSpecies.riverside => switch (lang) {
          AppLanguage.eu => 'Erriberako basoa',
          AppLanguage.es => 'Bosque de ribera',
          AppLanguage.en => 'Riparian woodland',
        },
      TreeSpecies.eucalyptus => switch (lang) {
          AppLanguage.eu => 'Eukaliptudia',
          AppLanguage.es => 'Eucaliptal',
          AppLanguage.en => 'Eucalyptus grove',
        },
      TreeSpecies.meadow => switch (lang) {
          AppLanguage.eu => 'Larrea / Belazea',
          AppLanguage.es => 'Pradera / Pastizal',
          AppLanguage.en => 'Meadow / Pasture',
        },
      TreeSpecies.mixed => switch (lang) {
          AppLanguage.eu => 'Baso mistoa',
          AppLanguage.es => 'Bosque mixto',
          AppLanguage.en => 'Mixed forest',
        },
    };
  }

  /// Suggested default zone name when saving a new polygon on the map.
  String defaultZoneName(AppLanguage lang) => forestLabel(lang);

  /// Resolves a stored [id] into a [TreeSpecies], or null if unset/unknown.
  static TreeSpecies? tryFromId(String? id) {
    if (id == null) return null;
    final normalized = id.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final value in TreeSpecies.values) {
      if (value.id == normalized) {
        return value;
      }
    }
    return null;
  }

  /// Resolves a stored [id] into a [TreeSpecies], falling back to [mixed].
  static TreeSpecies fromId(String? id) {
    return tryFromId(id) ?? TreeSpecies.mixed;
  }
}
