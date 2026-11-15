import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/autumn_theme.dart';
import '../../models/forest_zone.dart';
import '../../models/tree_species.dart';

/// Compact tinted badge showing the associated [TreeSpecies].
class TreeSpeciesBadge extends StatelessWidget {
  final TreeSpecies species;
  final AppLanguage lang;
  final bool compact;
  final bool useForestLabel;

  const TreeSpeciesBadge({
    super.key,
    required this.species,
    required this.lang,
    this.compact = false,
    this.useForestLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final label =
        useForestLabel ? species.forestLabel(lang) : species.label(lang);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: species.color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: species.color.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            species.icon,
            size: compact ? 13 : 15,
            color: species.color,
          ),
          SizedBox(width: compact ? 4 : 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 11.5 : 12.5,
                fontWeight: FontWeight.w700,
                color: species.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive tree species / habitat selector with quick scrollable pills and
/// an expanded 12-species visual picker modal.
class TreeSpeciesPickerField extends StatelessWidget {
  final String? selectedTreeType;
  final AppLanguage lang;
  final ValueChanged<String?> onChanged;
  final String? autoDetectedForestName;
  final bool allowUnassigned;
  final bool useForestLabels;

  const TreeSpeciesPickerField({
    super.key,
    required this.selectedTreeType,
    required this.lang,
    required this.onChanged,
    this.autoDetectedForestName,
    this.allowUnassigned = true,
    this.useForestLabels = false,
  });

  String _tr({
    required String eu,
    required String es,
    required String en,
  }) {
    return switch (lang) {
      AppLanguage.eu => eu,
      AppLanguage.es => es,
      AppLanguage.en => en,
    };
  }

  Future<void> _openFullSelector(BuildContext context) async {
    final chosen = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: AutumnColors.creamCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AutumnColors.warmSand,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.forest_rounded,
                    color: AutumnColors.mossGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      useForestLabels
                          ? _tr(
                              eu: 'Aukeratu baso mota',
                              es: 'Elige el tipo de bosque',
                              en: 'Choose forest type',
                            )
                          : _tr(
                              eu: 'Zein zuhaitzen azpian?',
                              es: '¿Bajo qué árbol se encontró?',
                              en: 'Found under which tree?',
                            ),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AutumnColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (allowUnassigned) ...[
                InkWell(
                  onTap: () => Navigator.of(ctx).pop(''),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selectedTreeType == null
                          ? AutumnColors.mossGreen.withValues(alpha: 0.14)
                          : AutumnColors.parchmentBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedTreeType == null
                            ? AutumnColors.mossGreen
                            : AutumnColors.warmSand,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: AutumnColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _tr(
                            eu: 'Zehaztu gabe',
                            es: 'Sin especificar',
                            en: 'Unspecified',
                          ),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AutumnColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: TreeSpecies.values.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.35,
                  ),
                  itemBuilder: (_, index) {
                    final species = TreeSpecies.values[index];
                    final isSelected = selectedTreeType == species.id;
                    final title = useForestLabels
                        ? species.forestLabel(lang)
                        : species.label(lang);
                    return InkWell(
                      onTap: () => Navigator.of(ctx).pop(species.id),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? species.color.withValues(alpha: 0.18)
                              : AutumnColors.parchmentBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? species.color
                                : AutumnColors.warmSand,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: species.color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                species.icon,
                                color: species.color,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected
                                          ? species.color
                                          : AutumnColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    species.scientificName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontStyle: FontStyle.italic,
                                      color: AutumnColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (chosen == null) return;
    if (chosen.isEmpty) {
      onChanged(null);
    } else {
      onChanged(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSpecies = TreeSpecies.tryFromId(selectedTreeType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.park_rounded,
              size: 16,
              color: AutumnColors.mossGreen,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                useForestLabels
                    ? _tr(
                        eu: 'Baso mota nagusia',
                        es: 'Tipo de bosque / árbol dominante',
                        en: 'Dominant forest / tree species',
                      )
                    : _tr(
                        eu: 'Zuhaitz mota / habitata',
                        es: 'Árbol / hábitat asociado',
                        en: 'Associated tree / habitat',
                      ),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AutumnColors.textSecondary,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => _openFullSelector(context),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              ),
              icon: const Icon(Icons.grid_view_rounded, size: 15),
              label: Text(
                _tr(eu: 'Denak', es: 'Ver todos', en: 'All'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (autoDetectedForestName != null &&
            autoDetectedForestName!.trim().isNotEmpty &&
            selectedSpecies != null) ...[
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AutumnColors.mossGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AutumnColors.mossGreen.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: AutumnColors.mossGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tr(
                      eu: 'Basoagatik automatikoki hautatua: $autoDetectedForestName',
                      es: 'Detectado automáticamente por bosque: $autoDetectedForestName',
                      en: 'Auto-selected from forest zone: $autoDetectedForestName',
                    ),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AutumnColors.mossGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (allowUnassigned) ...[
                _TreeChip(
                  label: _tr(
                    eu: 'Zehaztu gabe',
                    es: 'Sin especificar',
                    en: 'Unspecified',
                  ),
                  icon: Icons.help_outline_rounded,
                  color: AutumnColors.textSecondary,
                  isSelected: selectedSpecies == null,
                  onTap: () => onChanged(null),
                ),
                const SizedBox(width: 8),
              ],
              ...TreeSpecies.values.map((species) {
                final isSelected = selectedSpecies == species;
                final label = useForestLabels
                    ? species.forestLabel(lang)
                    : species.label(lang);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _TreeChip(
                    label: label,
                    icon: species.icon,
                    color: species.color,
                    isSelected: isSelected,
                    onTap: () => onChanged(species.id),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _TreeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TreeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : AutumnColors.parchmentBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AutumnColors.warmSand,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? color : AutumnColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? color : AutumnColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared flutter_map layers for rendering [ForestZone] polygons and centroid
/// labels consistently across the Global Map and Foraging Outings.
class ForestZonesMapLayers {
  const ForestZonesMapLayers._();

  static Widget buildPolygonLayer({
    required List<ForestZone> zones,
    String? selectedZoneId,
  }) {
    final polygons = zones
        .where((z) => z.points.length >= 3)
        .map((zone) {
          final isSelected = zone.id == selectedZoneId;
          final species = zone.species;
          return Polygon<String>(
            points: zone.points,
            color: species.color.withValues(alpha: isSelected ? 0.36 : 0.22),
            borderColor: isSelected ? Colors.white : species.color,
            borderStrokeWidth: isSelected ? 3.2 : 2.1,
            hitValue: zone.id,
          );
        })
        .toList(growable: false);

    return PolygonLayer<String>(
      polygonLabels: false,
      polygons: polygons,
    );
  }

  static Widget buildLabelMarkerLayer({
    required List<ForestZone> zones,
    required AppLanguage lang,
    String? selectedZoneId,
    void Function(ForestZone zone)? onZoneTap,
  }) {
    final markers = zones
        .where((z) => z.points.length >= 3)
        .map((zone) {
          final isSelected = zone.id == selectedZoneId;
          final species = zone.species;
          final displayName = zone.name.trim().isEmpty
              ? species.forestLabel(lang)
              : zone.name.trim();

          return Marker(
            point: zone.centroid,
            width: 144,
            height: 30,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: onZoneTap == null ? null : () => onZoneTap(zone),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? species.color
                      : Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? Colors.white : species.color,
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      species.icon,
                      size: 13,
                      color: isSelected ? Colors.white : species.color,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : AutumnColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .toList(growable: false);

    return MarkerLayer(markers: markers);
  }
}
