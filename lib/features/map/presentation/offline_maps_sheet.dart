import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/autumn_theme.dart';
import '../services/offline_map_service.dart';

class OfflineMapsSheet extends ConsumerStatefulWidget {
  final LatLngBounds currentBounds;
  final bool isTopoLayer;
  final void Function(LatLng center, double zoom) onSelectRegionOnMap;

  const OfflineMapsSheet({
    super.key,
    required this.currentBounds,
    required this.isTopoLayer,
    required this.onSelectRegionOnMap,
  });

  @override
  ConsumerState<OfflineMapsSheet> createState() => _OfflineMapsSheetState();
}

class _OfflineMapsSheetState extends ConsumerState<OfflineMapsSheet> {
  Future<void> _promptDownloadCurrentView() async {
    final nameCtrl = TextEditingController(
      text: 'Mi zona (${DateFormat('dd/MM').format(DateTime.now())})',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AutumnColors.parchmentBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Descargar Vista Actual Offline',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AutumnColors.boletusBrown,
          ),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Nombre para identificar esta zona',
            hintText: 'Ej. Hayedo de Ultzama',
            prefixIcon: Icon(Icons.download_for_offline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.download_rounded),
            label: const Text('Descargar Ahora'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final b = widget.currentBounds;
      await ref.read(offlineMapServiceProvider.notifier).downloadRegion(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: nameCtrl.text.trim().isEmpty
                ? 'Zona personalizada'
                : nameCtrl.text.trim(),
            description:
                'Encuadre descargado (${widget.isTopoLayer ? "Mapa Topográfico" : "Mapa Estándar"})',
            north: b.north,
            south: b.south,
            east: b.east,
            west: b.west,
            isTopoLayer: widget.isTopoLayer,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final offlineState = ref.watch(offlineMapServiceProvider);
    final downloadedIds =
        offlineState.downloadedRegions.map((r) => r.id).toSet();

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
                          'Mapas sin Conexión (Offline)',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AutumnColors.boletusBrown,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Text(
                          'Espacio ocupado: ${offlineState.formattedTotalMb} (${offlineState.downloadedRegions.length} zonas)',
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
                            'Descargando teselas topográficas...',
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
                  label: const Text(
                    'Descargar Vista Actual en Pantalla',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Zonas ya descargadas en el dispositivo
              if (offlineState.downloadedRegions.isNotEmpty) ...[
                const Text(
                  'Zonas Descargadas en tu Teléfono',
                  style: TextStyle(
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
                        '${region.tilesCount} teselas · ${region.formattedSizeMb} · ${DateFormat('dd/MM/yy').format(region.downloadedAt)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Centrar mapa en esta zona',
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
                            tooltip: 'Eliminar zona offline',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AutumnColors.edibilityToxic,
                            ),
                            onPressed: () {
                              ref
                                  .read(offlineMapServiceProvider.notifier)
                                  .deleteRegion(region.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 10),
              ],

              // Zonas micológicas recomendadas (Euskadi / Navarra)
              const Text(
                'Zonas Micológicas Recomendadas (1 Toque)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AutumnColors.boletusBrown,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Descarga curvas de nivel y caminos forestales (zooms 11-14) para usar en el monte con el GPS en modo avión.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: AutumnColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              ...kPredefinedMycologicalZones.map((zone) {
                final id = zone['id'] as String;
                final isAlreadyDownloaded = downloadedIds.contains(id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AutumnColors.ochreGold.withValues(alpha: 0.18),
                      child: const Icon(
                        Icons.terrain_rounded,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                    title: Text(
                      zone['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      zone['description'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: isAlreadyDownloaded
                        ? const Chip(
                            label: Text(
                              'Descargado',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AutumnColors.mossGreen,
                              ),
                            ),
                          )
                        : FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AutumnColors.creamCard,
                              foregroundColor: AutumnColors.boletusBrown,
                            ),
                            onPressed: offlineState.isDownloading
                                ? null
                                : () {
                                    ref
                                        .read(
                                            offlineMapServiceProvider.notifier)
                                        .downloadRegion(
                                          id: id,
                                          name: zone['name'] as String,
                                          description:
                                              zone['description'] as String,
                                          north:
                                              (zone['north'] as num).toDouble(),
                                          south:
                                              (zone['south'] as num).toDouble(),
                                          east:
                                              (zone['east'] as num).toDouble(),
                                          west:
                                              (zone['west'] as num).toDouble(),
                                          isTopoLayer: true,
                                        );
                                  },
                            icon: const Icon(Icons.download_rounded, size: 17),
                            label: const Text('Bajar'),
                          ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
