import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../services/offline_map_service.dart';

class OfflineMapsSheet extends ConsumerStatefulWidget {
  final LatLngBounds currentBounds;
  final bool isTopoLayer;
  final MapLayerType? activeLayer;
  final void Function(LatLng center, double zoom) onSelectRegionOnMap;

  const OfflineMapsSheet({
    super.key,
    required this.currentBounds,
    required this.isTopoLayer,
    this.activeLayer,
    required this.onSelectRegionOnMap,
  });

  @override
  ConsumerState<OfflineMapsSheet> createState() => _OfflineMapsSheetState();
}

class _OfflineMapsSheetState extends ConsumerState<OfflineMapsSheet> {
  late MapLayerType _selectedDownloadLayer;

  @override
  void initState() {
    super.initState();
    _selectedDownloadLayer = widget.activeLayer ??
        (widget.isTopoLayer ? MapLayerType.topo : MapLayerType.streets);
  }

  Future<void> _promptDownloadCurrentView() async {
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);

    final defaultName =
        '${s.tr(eu: "Nire eremua", es: "Mi zona", en: "My area")} (${DateFormat('dd/MM').format(DateTime.now())})';
    final nameCtrl = TextEditingController(text: defaultName);
    var chosenLayer = _selectedDownloadLayer;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AutumnColors.parchmentBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            s.tr(
              eu: 'Deskargatu Uneko Ikuspegia Offline',
              es: 'Descargar Vista Actual Offline',
              en: 'Download Current View Offline',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AutumnColors.boletusBrown,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: s.tr(
                    eu: 'Eremu hau identifikatzeko izena',
                    es: 'Nombre para identificar esta zona',
                    en: 'Region name to identify',
                  ),
                  hintText: s.tr(
                    eu: 'Adib. Ultzamako pagadia',
                    es: 'Ej. Hayedo de Ultzama',
                    en: 'E.g. Ultzama beech forest',
                  ),
                  prefixIcon: const Icon(Icons.download_for_offline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                s.tr(
                  eu: 'Deskargatu beharreko mapa mota:',
                  es: 'Capa cartográfica a descargar:',
                  en: 'Map layer to download:',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: AutumnColors.boletusBrown,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: MapLayerType.values.map((layer) {
                  final isSelected = chosenLayer == layer;
                  final icon = switch (layer) {
                    MapLayerType.topo => Icons.terrain_rounded,
                    MapLayerType.satellite => Icons.satellite_alt_rounded,
                    MapLayerType.streets => Icons.map_rounded,
                  };
                  return ChoiceChip(
                    selected: isSelected,
                    avatar: Icon(icon, size: 16),
                    label: Text(layer.localized(lang)),
                    selectedColor: AutumnColors.ochreGold.withValues(alpha: 0.28),
                    onSelected: (val) {
                      if (val) {
                        setDialogState(() => chosenLayer = layer);
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel')),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.download_rounded),
              label: Text(
                s.tr(
                  eu: 'Deskargatu Orain',
                  es: 'Descargar Ahora',
                  en: 'Download Now',
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final b = widget.currentBounds;
      setState(() => _selectedDownloadLayer = chosenLayer);
      await ref.read(offlineMapServiceProvider.notifier).downloadRegion(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: nameCtrl.text.trim().isEmpty
                ? s.tr(
                    eu: 'Nire eremua',
                    es: 'Zona personalizada',
                    en: 'Custom area',
                  )
                : nameCtrl.text.trim(),
            description: s.tr(
              eu: 'Deskargatutako ikuspegia (${chosenLayer.localized(lang)})',
              es: 'Encuadre descargado (${chosenLayer.localized(lang)})',
              en: 'Downloaded view (${chosenLayer.localized(lang)})',
            ),
            north: b.north,
            south: b.south,
            east: b.east,
            west: b.west,
            layerType: chosenLayer,
            isTopoLayer: chosenLayer == MapLayerType.topo,
            lang: lang,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final offlineState = ref.watch(offlineMapServiceProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.80,
      maxChildSize: 0.94,
      minChildSize: 0.55,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: const BoxDecoration(
            color: AutumnColors.parchmentBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
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
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AutumnColors.mossGreen.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.offline_pin_rounded,
                      color: AutumnColors.mossGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tr(
                            eu: 'Konexiorik Gabeko Mapak (Offline)',
                            es: 'Mapas sin Conexión (Offline)',
                            en: 'Offline Forest Maps',
                          ),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AutumnColors.boletusBrown,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Text(
                          s.tr(
                            eu: 'Erabilitako lekua: ${offlineState.formattedTotalMb} (${offlineState.downloadedRegions.length} eremu)',
                            es: 'Espacio ocupado: ${offlineState.formattedTotalMb} (${offlineState.downloadedRegions.length} zonas)',
                            en: 'Storage used: ${offlineState.formattedTotalMb} (${offlineState.downloadedRegions.length} regions)',
                          ),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AutumnColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Progreso de descarga activa
              if (offlineState.isDownloading) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AutumnColors.creamCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AutumnColors.ochreGold),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offlineState.statusMessage ??
                            s.tr(
                              eu: 'Lauza topografikoak deskargatzen...',
                              es: 'Descargando teselas topográficas...',
                              en: 'Downloading topographic tiles...',
                            ),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AutumnColors.boletusBrown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: offlineState.progress,
                        backgroundColor: AutumnColors.warmSand,
                        color: AutumnColors.mossGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                ),
              ],

              // Botón principal: Descargar vista actual del mapa
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AutumnColors.boletusBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: offlineState.isDownloading
                      ? null
                      : _promptDownloadCurrentView,
                  icon: const Icon(Icons.crop_free_rounded),
                  label: Text(
                    s.tr(
                      eu: 'Deskargatu Pantailako Uneko Ikuspegia',
                      es: 'Descargar Vista Actual en Pantalla',
                      en: 'Download Current View on Screen',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Zonas ya descargadas en el dispositivo
              if (offlineState.downloadedRegions.isNotEmpty) ...[
                Text(
                  s.tr(
                    eu: 'Telefonoan deskargatutako eremuak',
                    es: 'Zonas Descargadas en tu Teléfono',
                    en: 'Downloaded Regions on Device',
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AutumnColors.boletusBrown,
                  ),
                ),
                const SizedBox(height: 8),
                ...offlineState.downloadedRegions.map((region) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            AutumnColors.mossGreen.withValues(alpha: 0.16),
                        child: const Icon(
                          Icons.check_circle_rounded,
                          color: AutumnColors.mossGreen,
                        ),
                      ),
                      title: Text(
                        region.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                        ),
                      ),
                      subtitle: Text(
                        '${region.layerType.localized(lang)} · ${region.tilesCount} teselas · ${region.formattedSizeMb} · ${DateFormat('dd/MM/yy').format(region.downloadedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: s.tr(
                              eu: 'Kokatu mapa eremu honetan',
                              es: 'Centrar mapa en esta zona',
                              en: 'Center map on this region',
                            ),
                            icon: const Icon(
                              Icons.my_location_rounded,
                              color: AutumnColors.boletusBrown,
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              widget.onSelectRegionOnMap(region.center, 12.8);
                            },
                          ),
                          IconButton(
                            tooltip: s.tr(
                              eu: 'Ezabatu offline eremua',
                              es: 'Eliminar zona offline',
                              en: 'Delete offline region',
                            ),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AutumnColors.edibilityToxic,
                            ),
                            onPressed: () {
                              ref
                                  .read(offlineMapServiceProvider.notifier)
                                  .deleteRegion(region.id, lang: lang);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                  child: Center(
                    child: Text(
                      s.tr(
                        eu: 'Ez dago oraindik eremurik deskargatuta telefonoan.\nErabili goiko botoia pantailako eremua deskargatzeko.',
                        es: 'No hay zonas descargadas en el teléfono todavía.\nUsa el botón superior para descargar la vista actual.',
                        en: 'No offline areas saved yet.\nUse the button above to download the current view.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AutumnColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
