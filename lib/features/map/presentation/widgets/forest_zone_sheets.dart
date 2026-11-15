import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/autumn_theme.dart';
import '../../models/foraging_spot.dart';
import '../../models/forest_zone.dart';
import '../../models/tree_species.dart';
import 'tree_species_picker.dart';

/// Top floating instruction & tree-species bar while drawing or editing a
/// [ForestZone] polygon on the map.
class ForestDrawingBanner extends StatelessWidget {
  final AppLanguage lang;
  final int pointsCount;
  final TreeSpecies selectedSpecies;
  final int? movingVertexIndex;
  final bool isEditingExisting;
  final ValueChanged<TreeSpecies> onSpeciesChanged;
  final VoidCallback onCancel;

  const ForestDrawingBanner({
    super.key,
    required this.lang,
    required this.pointsCount,
    required this.selectedSpecies,
    required this.movingVertexIndex,
    required this.isEditingExisting,
    required this.onSpeciesChanged,
    required this.onCancel,
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

  @override
  Widget build(BuildContext context) {
    final bool readyToSave = pointsCount >= 3;
    final String instruction;
    if (movingVertexIndex != null) {
      final numLabel = movingVertexIndex! + 1;
      instruction = _tr(
        eu: '#$numLabel puntua hautatuta: ukitu mapa edo sakatu Mugitu hona',
        es: 'Vértice #$numLabel seleccionado: toca el mapa o pulsa Mover aquí',
        en: 'Vertex #$numLabel selected: tap map or press Move here',
      );
    } else if (!readyToSave) {
      instruction = _tr(
        eu: 'Ukitu mapa edo erabili erdigunea (+ Puntua). Gutxienez 3 puntu.',
        es: 'Toca el mapa o usa la diana (+ Punto). Marca al menos 3 puntos.',
        en: 'Tap map or use crosshair (+ Point). Mark at least 3 points.',
      );
    } else {
      instruction = _tr(
        eu: 'Poligonoa prest ($pointsCount puntu). Ukitu puntu bat mugitzeko edo gorde.',
        es: 'Polígono listo ($pointsCount pts). Toca un vértice para moverlo o guarda.',
        en: 'Polygon ready ($pointsCount pts). Tap a vertex to move it or save.',
      );
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          color: AutumnColors.barkDark.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selectedSpecies.color.withValues(alpha: 0.75),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  selectedSpecies.icon,
                  color: selectedSpecies.color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEditingExisting
                        ? _tr(
                            eu: 'Basoaren poligonoa editatzen',
                            es: 'Editando polígono del bosque',
                            en: 'Editing forest polygon',
                          )
                        : _tr(
                            eu: 'Baso mapa marrazten',
                            es: 'Dibujando mapa de bosque',
                            en: 'Drawing forest map',
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: readyToSave
                        ? AutumnColors.mossGreen
                        : AutumnColors.amberLeaf,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pointsCount pts',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: readyToSave ? Colors.white : AutumnColors.barkDark,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  key: const ValueKey('btn_cancel_forest_drawing'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              instruction,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 30,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: TreeSpecies.values.map((species) {
                  final isSelected = species == selectedSpecies;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => onSpeciesChanged(species),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? species.color
                              : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : species.color.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              species.icon,
                              size: 13,
                              color: isSelected ? Colors.white : species.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              species.forestLabel(lang),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom floating action bar while drawing or editing a [ForestZone] polygon.
class ForestDrawingBottomBar extends StatelessWidget {
  final AppLanguage lang;
  final int pointsCount;
  final int? movingVertexIndex;
  final TreeSpecies species;
  final VoidCallback onUndoOrDeleteVertex;
  final VoidCallback onAddOrMoveVertexAtCenter;
  final VoidCallback onSave;

  const ForestDrawingBottomBar({
    super.key,
    required this.lang,
    required this.pointsCount,
    required this.movingVertexIndex,
    required this.species,
    required this.onUndoOrDeleteVertex,
    required this.onAddOrMoveVertexAtCenter,
    required this.onSave,
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

  @override
  Widget build(BuildContext context) {
    final bool canSave = pointsCount >= 3;
    final bool isMovingVertex = movingVertexIndex != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AutumnColors.barkDark.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: species.color.withValues(alpha: 0.7),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton.filledTonal(
            key: const ValueKey('btn_undo_polygon_vertex'),
            onPressed: pointsCount == 0 ? null : onUndoOrDeleteVertex,
            style: IconButton.styleFrom(
              backgroundColor: isMovingVertex
                  ? AutumnColors.edibilityToxic.withValues(alpha: 0.22)
                  : Colors.white.withValues(alpha: 0.14),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white30,
            ),
            tooltip: isMovingVertex
                ? _tr(
                    eu: 'Ezabatu puntua',
                    es: 'Eliminar vértice',
                    en: 'Delete vertex',
                  )
                : _tr(
                    eu: 'Desegin azken puntua',
                    es: 'Deshacer último punto',
                    en: 'Undo last point',
                  ),
            icon: Icon(
              isMovingVertex ? Icons.delete_outline_rounded : Icons.undo_rounded,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              key: const ValueKey('btn_add_polygon_vertex'),
              onPressed: onAddOrMoveVertexAtCenter,
              style: ElevatedButton.styleFrom(
                backgroundColor: AutumnColors.amberLeaf,
                foregroundColor: AutumnColors.barkDark,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                isMovingVertex
                    ? Icons.open_with_rounded
                    : Icons.add_location_alt_rounded,
                size: 18,
              ),
              label: Text(
                isMovingVertex
                    ? _tr(eu: 'Mugitu hona', es: 'Mover aquí', en: 'Move here')
                    : _tr(eu: '+ Puntua', es: '+ Punto', en: '+ Point'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              key: const ValueKey('btn_save_forest_polygon'),
              onPressed: canSave ? onSave : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: species.color,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.14),
                disabledForegroundColor: Colors.white38,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                _tr(eu: 'Gorde Basoa', es: 'Guardar', en: 'Save'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom card shown when the user taps a saved [ForestZone] polygon or label.
class SelectedForestZoneCard extends StatelessWidget {
  final ForestZone zone;
  final int spotsInsideCount;
  final AppLanguage lang;
  final VoidCallback onClose;
  final VoidCallback onEditData;
  final VoidCallback onEditPolygon;
  final VoidCallback onDelete;

  const SelectedForestZoneCard({
    super.key,
    required this.zone,
    required this.spotsInsideCount,
    required this.lang,
    required this.onClose,
    required this.onEditData,
    required this.onEditPolygon,
    required this.onDelete,
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

  @override
  Widget build(BuildContext context) {
    final species = zone.species;
    final title = zone.name.trim().isEmpty
        ? species.forestLabel(lang)
        : zone.name.trim();

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AutumnColors.parchmentBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: species.color, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: species.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: species.color.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(species.icon, color: species.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        TreeSpeciesBadge(
                          species: species,
                          lang: lang,
                          compact: true,
                          useForestLabel: true,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AutumnColors.warmSand.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                size: 12,
                                color: AutumnColors.boletusBrown,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _tr(
                                  eu: '$spotsInsideCount leku barruan',
                                  es: '$spotsInsideCount setales dentro',
                                  en: '$spotsInsideCount spots inside',
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AutumnColors.boletusBrown,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onClose,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
          if (zone.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AutumnColors.creamCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                zone.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AutumnColors.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AutumnColors.edibilityToxic,
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: Text(_tr(eu: 'Ezabatu', es: 'Eliminar', en: 'Delete')),
              ),
              const SizedBox(width: 4),
              OutlinedButton.icon(
                onPressed: onEditPolygon,
                style: OutlinedButton.styleFrom(
                  foregroundColor: species.color,
                  side: BorderSide(color: species.color),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                icon: const Icon(Icons.polyline_rounded, size: 16),
                label: Text(
                  _tr(eu: 'Poligonoa', es: 'Polígono', en: 'Polygon'),
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: species.color.withValues(alpha: 0.18),
                  foregroundColor: species.color,
                ),
                onPressed: onEditData,
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: Text(_tr(eu: 'Datuak', es: 'Datos', en: 'Edit')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet form for naming and categorizing a [ForestZone].
class ForestZoneFormBottomSheet extends StatefulWidget {
  final List<LatLng> points;
  final TreeSpecies initialSpecies;
  final ForestZone? existingZone;
  final List<ForagingSpot> allSpots;
  final AppLanguage lang;

  const ForestZoneFormBottomSheet({
    super.key,
    required this.points,
    required this.initialSpecies,
    this.existingZone,
    required this.allSpots,
    required this.lang,
  });

  @override
  State<ForestZoneFormBottomSheet> createState() =>
      _ForestZoneFormBottomSheetState();
}

class _ForestZoneFormBottomSheetState extends State<ForestZoneFormBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late String _selectedTreeType;
  late bool _hasCustomName;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingZone;
    _selectedTreeType = existing?.treeType ?? widget.initialSpecies.id;
    final defaultName =
        TreeSpecies.fromId(_selectedTreeType).defaultZoneName(widget.lang);
    _nameController = TextEditingController(
      text: existing != null && existing.name.trim().isNotEmpty
          ? existing.name
          : defaultName,
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _hasCustomName = existing != null && existing.name.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _tr({
    required String eu,
    required String es,
    required String en,
  }) {
    return switch (widget.lang) {
      AppLanguage.eu => eu,
      AppLanguage.es => es,
      AppLanguage.en => en,
    };
  }

  int _countUnassignedSpotsInside() {
    final probeZone = ForestZone(
      id: 'probe',
      name: '',
      treeType: _selectedTreeType,
      points: widget.points,
      notes: '',
      createdAt: DateTime.now(),
    );
    int count = 0;
    for (final spot in widget.allSpots) {
      if (spot.treeType != null && spot.treeType!.trim().isNotEmpty) {
        continue;
      }
      if (probeZone.containsPoint(LatLng(spot.latitude, spot.longitude))) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final selectedSpecies = TreeSpecies.fromId(_selectedTreeType);
    final unassignedInside = _countUnassignedSpotsInside();

    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 22),
      decoration: const BoxDecoration(
        color: AutumnColors.parchmentBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
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
                Icon(
                  selectedSpecies.icon,
                  color: selectedSpecies.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.existingZone == null
                        ? _tr(
                            eu: 'Gorde Baso Eremua',
                            es: 'Guardar Zona de Bosque',
                            en: 'Save Forest Zone',
                          )
                        : _tr(
                            eu: 'Editatu Baso Eremua',
                            es: 'Editar Zona de Bosque',
                            en: 'Edit Forest Zone',
                          ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AutumnColors.boletusBrown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TreeSpeciesPickerField(
              selectedTreeType: _selectedTreeType,
              lang: widget.lang,
              allowUnassigned: false,
              useForestLabels: true,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedTreeType = value;
                  if (!_hasCustomName) {
                    _nameController.text =
                        TreeSpecies.fromId(value).defaultZoneName(widget.lang);
                  }
                });
              },
            ),
            const SizedBox(height: 14),
            TextField(
              key: const ValueKey('field_forest_zone_name'),
              controller: _nameController,
              onChanged: (_) => _hasCustomName = true,
              decoration: InputDecoration(
                labelText: _tr(
                  eu: 'Basoaren izena (adib. Goiko Pagadia)',
                  es: 'Nombre del bosque (ej. Hayedo Norte)',
                  en: 'Forest name (e.g. North Beechwood)',
                ),
                prefixIcon: const Icon(Icons.label_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: _tr(
                  eu: 'Oharrak (lurzoru mota, orientazioa...)',
                  es: 'Notas (tipo de suelo, orientación, accesos...)',
                  en: 'Notes (soil, aspect, access...)',
                ),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
            if (unassignedInside > 0) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AutumnColors.mossGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AutumnColors.mossGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: AutumnColors.mossGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _tr(
                          eu: 'Barruan zuhaitzik gabeko $unassignedInside leku daude; automatikoki esleituko zaie.',
                          es: '$unassignedInside setales dentro sin árbol asignado recibirán este árbol automáticamente.',
                          en: '$unassignedInside unassigned spots inside will automatically inherit this tree.',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AutumnColors.mossGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const ValueKey('btn_confirm_save_forest_zone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedSpecies.color,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final cleanName = _nameController.text.trim().isEmpty
                      ? selectedSpecies.defaultZoneName(widget.lang)
                      : _nameController.text.trim();
                  final result = ForestZone(
                    id: widget.existingZone?.id ??
                        'forest_${DateTime.now().millisecondsSinceEpoch}',
                    name: cleanName,
                    treeType: selectedSpecies.id,
                    points: List<LatLng>.from(widget.points),
                    notes: _notesController.text.trim(),
                    createdAt:
                        widget.existingZone?.createdAt ?? DateTime.now(),
                  );
                  Navigator.of(context).pop(result);
                },
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  _tr(
                    eu: 'Gorde Basoa',
                    es: 'Guardar Bosque',
                    en: 'Save Forest Zone',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modal list sheet displaying all saved [ForestZone] polygons with spot counts,
/// quick zoom-to-zone, edit-polygon, delete, and "+ Draw Forest" action.
class SavedForestZonesSheet extends StatelessWidget {
  final List<ForestZone> zones;
  final List<ForagingSpot> allSpots;
  final AppLanguage lang;
  final VoidCallback onStartDrawingNew;
  final ValueChanged<ForestZone> onSelectZone;
  final ValueChanged<ForestZone> onEditZonePolygon;
  final ValueChanged<ForestZone> onDeleteZone;

  const SavedForestZonesSheet({
    super.key,
    required this.zones,
    required this.allSpots,
    required this.lang,
    required this.onStartDrawingNew,
    required this.onSelectZone,
    required this.onEditZonePolygon,
    required this.onDeleteZone,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
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
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _tr(
                      eu: 'Baso Mapak (${zones.length})',
                      es: 'Mapas de Bosques (${zones.length})',
                      en: 'Forest Maps (${zones.length})',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AutumnColors.boletusBrown,
                        ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onStartDrawingNew();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AutumnColors.mossGreen,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: Text(
                    _tr(
                      eu: 'Marraztu',
                      es: 'Dibujar',
                      en: 'Draw',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (zones.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 26),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.polyline_rounded,
                        size: 36,
                        color: AutumnColors.textMuted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _tr(
                          eu: 'Oraindik ez duzu baso-eremurik marraztu. Marraztu pagadiak, hariztiak edo pinudiak mapan.',
                          es: 'Todavía no has dibujado zonas de bosque. Dibuja hayedos, robledales o pinares en el mapa.',
                          en: 'No forest zones drawn yet. Draw beechwoods, oakwoods or pine forests on the map.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AutumnColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: zones.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final zone = zones[index];
                    final species = zone.species;
                    final spotsCount = allSpots
                        .where(
                          (sp) => zone.containsPoint(
                            LatLng(sp.latitude, sp.longitude),
                          ),
                        )
                        .length;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        backgroundColor:
                            species.color.withValues(alpha: 0.16),
                        child: Icon(species.icon, color: species.color),
                      ),
                      title: Text(
                        zone.name.trim().isEmpty
                            ? species.forestLabel(lang)
                            : zone.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AutumnColors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        '${species.forestLabel(lang)} • '
                        '${_tr(eu: "$spotsCount leku", es: "$spotsCount setales", en: "$spotsCount spots")} • '
                        '${zone.points.length} pts',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AutumnColors.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: _tr(
                              eu: 'Editatu poligonoa',
                              es: 'Editar polígono',
                              en: 'Edit polygon',
                            ),
                            icon: const Icon(
                              Icons.polyline_rounded,
                              size: 19,
                              color: AutumnColors.boletusBrown,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onEditZonePolygon(zone);
                            },
                          ),
                          IconButton(
                            tooltip: _tr(
                              eu: 'Ezabatu',
                              es: 'Eliminar',
                              en: 'Delete',
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 19,
                              color: AutumnColors.edibilityToxic,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              onDeleteZone(zone);
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        onSelectZone(zone);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
