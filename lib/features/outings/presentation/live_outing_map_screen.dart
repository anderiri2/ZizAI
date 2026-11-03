import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../map/data/spots_database.dart';
import '../../map/models/foraging_spot.dart';
import '../data/outings_database.dart';
import 'outings_screen.dart';

/// Pantalla inmersiva a pantalla completa para el seguimiento de la salida activa (GPS o Manual)
/// con controles flotantes superpuestos para pausar, registrar setas y terminar.
class LiveOutingMapScreen extends ConsumerStatefulWidget {
  final MapController? externalMapController;

  const LiveOutingMapScreen({
    super.key,
    this.externalMapController,
  });

  @override
  ConsumerState<LiveOutingMapScreen> createState() =>
      _LiveOutingMapScreenState();
}

class _LiveOutingMapScreenState extends ConsumerState<LiveOutingMapScreen> {
  late final MapController _mapController;
  bool _useTopoLayer = true;
  bool _isPickingSpotOnMap = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.externalMapController ?? MapController();
  }

  void _centerOnUserOrRoute(ActiveOutingState activeState) {
    if (activeState.routePoints.isNotEmpty) {
      _mapController.move(activeState.routePoints.last, 16.0);
    }
  }

  Future<void> _handleRegisterFindAtCurrentPosition(
    ActiveOutingState activeState,
  ) async {
    final activeId = activeState.activeOutingId;
    if (activeId == null) return;

    LatLng targetLocation;
    if (activeState.routePoints.isNotEmpty) {
      targetLocation = activeState.routePoints.last;
    } else {
      targetLocation = _mapController.camera.center;
    }

    final catalog =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    final newSpot = await showModalBottomSheet<ForagingSpot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OutingFindFormSheet(
        position: targetLocation,
        outingId: activeId,
        outingTitle: activeState.title,
        catalogMushrooms: catalog,
      ),
    );

    if (newSpot != null) {
      await ref.read(foragingSpotsProvider.notifier).saveSpot(newSpot);
      ref
          .read(activeOutingRecorderProvider.notifier)
          .addRoutePoint(LatLng(newSpot.latitude, newSpot.longitude));

      if (mounted) {
        final lang = ref.read(appLanguageProvider);
        final s = AppStrings(lang);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AutumnColors.mossGreen,
            content: Text(
              '${s.tr(eu: "Perretxikoa gordea", es: "Seta guardada", en: "Mushroom saved")}: ${newSpot.mushroomName ?? newSpot.title}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleMapTap(
    LatLng latLng,
    ActiveOutingState activeState,
  ) async {
    if (_isPickingSpotOnMap) {
      setState(() => _isPickingSpotOnMap = false);
      final activeId = activeState.activeOutingId;
      if (activeId == null) return;

      final catalog =
          ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

      final newSpot = await showModalBottomSheet<ForagingSpot>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => OutingFindFormSheet(
          position: latLng,
          outingId: activeId,
          outingTitle: activeState.title,
          catalogMushrooms: catalog,
        ),
      );

      if (newSpot != null) {
        await ref.read(foragingSpotsProvider.notifier).saveSpot(newSpot);
        ref
            .read(activeOutingRecorderProvider.notifier)
            .addRoutePoint(LatLng(newSpot.latitude, newSpot.longitude));

        if (mounted) {
          final lang = ref.read(appLanguageProvider);
          final s = AppStrings(lang);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AutumnColors.mossGreen,
              content: Text(
                '${s.tr(eu: "Perretxikoa gordea", es: "Seta guardada", en: "Mushroom saved")}: ${newSpot.mushroomName ?? newSpot.title}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
      }
    } else {
      // Simular un paso o punto de avance en el mapa
      ref.read(activeOutingRecorderProvider.notifier).addRoutePoint(latLng);
    }
  }

  Future<void> _confirmFinishOuting(
    ActiveOutingState activeState,
    List<ForagingSpot> outingSpots,
  ) async {
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AutumnColors.parchmentBg,
        title: Text(
          s.tr(
            eu: 'Irteera amaitu?',
            es: '¿Terminar la salida al monte?',
            en: 'Finish foraging outing?',
          ),
          style: const TextStyle(
            color: AutumnColors.boletusBrown,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          s.tr(
            eu: 'Ibilbidea eta bildutako ${outingSpots.length} setal gorde egingo dira zure historian.',
            es: 'El recorrido y los ${outingSpots.length} setales anotados se guardarán permanentemente en tu historial.',
            en: 'The route and ${outingSpots.length} recorded spots will be saved to your history.',
          ),
          style: const TextStyle(color: AutumnColors.barkDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AutumnColors.mossGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              s.tr(eu: 'Amaitu eta Gorde', es: 'Terminar y Guardar', en: 'Finish & Save'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final savedOuting =
          ref.read(activeOutingRecorderProvider.notifier).finishOuting();
      if (savedOuting != null) {
        await ref.read(outingsProvider.notifier).saveOuting(savedOuting);
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeState = ref.watch(activeOutingRecorderProvider);
    final allSpots = ref.watch(foragingSpotsProvider).valueOrNull ?? const [];
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);

    final outingSpots = allSpots
        .where((sp) => sp.outingId == activeState.activeOutingId)
        .toList();

    final km = (activeState.distanceMeters / 1000.0).toStringAsFixed(2);
    final totalSpecimens =
        outingSpots.fold<int>(0, (sum, sp) => sum + sp.quantityCount);

    final secs = activeState.elapsedSeconds;
    final hours = (secs ~/ 3600).toString().padLeft(2, '0');
    final mins = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (secs % 60).toString().padLeft(2, '0');
    final elapsedFormatted = '$hours:$mins:$seconds';

    final center = activeState.routePoints.isNotEmpty
        ? activeState.routePoints.last
        : (outingSpots.isNotEmpty
            ? LatLng(outingSpots.last.latitude, outingSpots.last.longitude)
            : const LatLng(43.0340, -2.7270));

    return Scaffold(
      body: Stack(
        children: [
          // Mapa a pantalla completa
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.5,
              minZoom: 4.0,
              maxZoom: 18.0,
              onTap: (_, latLng) => _handleMapTap(latLng, activeState),
            ),
            children: [
              TileLayer(
                urlTemplate: _useTopoLayer
                    ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.perretxikotan.perretxikotan',
                maxNativeZoom: _useTopoLayer ? 17 : 19,
              ),
              if (activeState.routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: activeState.routePoints,
                      color: AutumnColors.terracotta,
                      strokeWidth: 5.0,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...outingSpots.map(
                    (spot) => Marker(
                      point: LatLng(spot.latitude, spot.longitude),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AutumnColors.barkDark,
                              duration: const Duration(seconds: 2),
                              content: Text(
                                '${spot.mushroomName ?? spot.title} · ${spot.quantityCount} ${s.tr(eu: "ale", es: "ej.", en: "spec.")}',
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AutumnColors.mossGreen,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black38,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.eco_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (activeState.routePoints.isNotEmpty)
                    Marker(
                      point: activeState.routePoints.last,
                      width: 26,
                      height: 26,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.blueAccent,
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Banner interactivo si está en modo "Ubicar seta en el mapa"
          if (_isPickingSpotOnMap)
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              left: 16,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AutumnColors.terracotta.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.touch_app_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.tr(
                              eu: 'Ukitu mapan perretxikoa kokatzeko',
                              es: 'Toca en el mapa para ubicar la seta',
                              en: 'Tap on the map to place the mushroom',
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.black26,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            minimumSize: Size.zero,
                          ),
                          onPressed: () =>
                              setState(() => _isPickingSpotOnMap = false),
                          child: Text(
                            s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel'),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Barra Superior Flotante
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            right: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AutumnColors.barkDark.withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AutumnColors.amberLeaf.withValues(alpha: 0.7),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Botón minimizar / volver
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.fullscreen_exit_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: activeState.isPaused
                                        ? AutumnColors.amberLeaf
                                        : Colors.greenAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    activeState.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              activeState.isManual
                                  ? s.tr(
                                      eu: 'Eskuzko modua (GPS gabe) · $totalSpecimens ale (${outingSpots.length} setal)',
                                      es: 'Modo manual (sin GPS) · $totalSpecimens ej. (${outingSpots.length} setales)',
                                      en: 'Manual mode (no GPS) · $totalSpecimens spec. (${outingSpots.length} spots)',
                                    )
                                  : s.tr(
                                      eu: '$km km ibilbidea · $totalSpecimens ale (${outingSpots.length} setal)',
                                      es: '$km km de ruta · $totalSpecimens ej. (${outingSpots.length} setales)',
                                      en: '$km km route · $totalSpecimens spec. (${outingSpots.length} spots)',
                                    ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color:
                                    AutumnColors.warmSand.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        elapsedFormatted,
                        style: const TextStyle(
                          color: AutumnColors.amberLeaf,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Botones laterales rápidos de capa y recentrado
          Positioned(
            right: 14,
            bottom: 120,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'live_outing_topo_switch',
                  backgroundColor: AutumnColors.parchmentBg,
                  foregroundColor: AutumnColors.boletusBrown,
                  onPressed: () =>
                      setState(() => _useTopoLayer = !_useTopoLayer),
                  tooltip: _useTopoLayer
                      ? s.tr(eu: 'Kalea', es: 'Calle', en: 'Street')
                      : 'Topo',
                  child: Icon(
                    _useTopoLayer ? Icons.terrain_rounded : Icons.map_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'live_outing_center_btn',
                  backgroundColor: AutumnColors.parchmentBg,
                  foregroundColor: AutumnColors.boletusBrown,
                  onPressed: () => _centerOnUserOrRoute(activeState),
                  tooltip: s.tr(eu: 'Zentratu', es: 'Centrar', en: 'Center'),
                  child: const Icon(Icons.my_location_rounded, size: 20),
                ),
              ],
            ),
          ),

          // Barra Inferior Flotante de Acciones
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 14,
            left: 14,
            right: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AutumnColors.barkDark.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: AutumnColors.amberLeaf.withValues(alpha: 0.6),
                      width: 1.2,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Pausar / Reanudar
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white12,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(10),
                        ),
                        tooltip: activeState.isPaused
                            ? s.tr(eu: 'Berrabiarazi', es: 'Reanudar', en: 'Resume')
                            : s.tr(eu: 'Gelditu', es: 'Pausar', en: 'Pause'),
                        onPressed: () => ref
                            .read(activeOutingRecorderProvider.notifier)
                            .togglePause(),
                        icon: Icon(
                          activeState.isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Botón Primario: Anotar en GPS actual
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AutumnColors.ochreGold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () =>
                              _handleRegisterFindAtCurrentPosition(
                            activeState,
                          ),
                          icon: const Icon(Icons.add_location_alt_rounded,
                              size: 19),
                          label: Text(
                            s.tr(
                              eu: 'Seta hemen',
                              es: 'Anotar aquí',
                              en: 'Spot here',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Botón Secundario: Ubicar tocando en mapa
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: _isPickingSpotOnMap
                              ? AutumnColors.terracotta
                              : AutumnColors.amberLeaf,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.all(10),
                        ),
                        tooltip: s.tr(
                          eu: 'Kokatu mapan ukituz',
                          es: 'Ubicar seta tocando el mapa',
                          en: 'Pick spot on map',
                        ),
                        onPressed: () {
                          setState(() {
                            _isPickingSpotOnMap = !_isPickingSpotOnMap;
                          });
                        },
                        icon: const Icon(Icons.touch_app_rounded, size: 22),
                      ),
                      const SizedBox(width: 8),

                      // Terminar y Guardar
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AutumnColors.mossGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => _confirmFinishOuting(
                          activeState,
                          outingSpots,
                        ),
                        child: Text(
                          s.tr(eu: 'Amaitu', es: 'Terminar', en: 'Finish'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
