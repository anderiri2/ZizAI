import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/gps_accuracy_service.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../../core/widgets/gps_acquisition_sheet.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../map/data/spots_database.dart';
import '../../map/models/foraging_spot.dart';
import '../../map/presentation/widgets/foraging_spot_marker.dart';
import '../../map/presentation/widgets/map_crosshair_target.dart';
import '../../map/services/offline_map_service.dart';
import '../data/outings_database.dart';
import 'outings_screen.dart';

/// Pantalla inmersiva a pantalla completa para el seguimiento de la salida activa (GPS o Manual)
/// con controles flotantes superpuestos para pausar, registrar setas y terminar.
class LiveOutingMapScreen extends ConsumerStatefulWidget {
  const LiveOutingMapScreen({super.key});

  @override
  ConsumerState<LiveOutingMapScreen> createState() =>
      _LiveOutingMapScreenState();
}

class _LiveOutingMapScreenState extends ConsumerState<LiveOutingMapScreen> {
  final MapController _mapController = MapController();
  final OfflineCachingTileProvider _offlineTileProvider =
      OfflineCachingTileProvider();
  bool _isPickingSpotOnMap = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _centerOnUserOrRoute(ActiveOutingState activeState) {
    if (activeState.routePoints.isNotEmpty) {
      _mapController.move(activeState.routePoints.last, 16.0);
    }
  }

  Future<void> _centerDianaOnGps(ActiveOutingState activeState) async {
    if (!activeState.isManual && activeState.routePoints.isNotEmpty) {
      _mapController.move(
        activeState.routePoints.last,
        _mapController.camera.zoom < 15.0 ? 15.5 : _mapController.camera.zoom,
      );
      HapticFeedback.selectionClick();
      return;
    }

    final lang = ref.read(appLanguageProvider);
    final hasPerm = await GpsAccuracyService.ensureLocationPermission(
      context,
      lang: lang,
    );
    if (!hasPerm || !mounted) return;

    final s = AppStrings(lang);
    final locked = await GpsAcquisitionSheet.show(
      context,
      title: s.tr(
        eu: 'Setalaren koordenatuak zehaztu',
        es: 'Fijar coordenadas del setal',
        en: 'Lock mushroom spot coordinates',
      ),
      subtitle: s.tr(
        eu: '${activeState.title} • GPS Seinalea',
        es: '${activeState.title} • Señal GPS',
        en: '${activeState.title} • GPS Fix',
      ),
      confirmButtonLabel: s.tr(
        eu: 'Zentratu diana hemen',
        es: 'Centrar diana aquí',
        en: 'Center crosshair here',
      ),
      lang: lang,
    );
    if (locked != null && mounted) {
      _mapController.move(
        locked,
        _mapController.camera.zoom < 15.0 ? 15.5 : _mapController.camera.zoom,
      );
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _handleRegisterFindAtCurrentPosition(
    ActiveOutingState activeState,
  ) async {
    final activeId = activeState.activeOutingId;
    if (activeId == null) return;

    LatLng targetLocation;
    if (!activeState.isManual && activeState.routePoints.isNotEmpty) {
      targetLocation = activeState.routePoints.last;
    } else {
      final lang = ref.read(appLanguageProvider);
      final hasPerm = await GpsAccuracyService.ensureLocationPermission(
        context,
        lang: lang,
      );
      if (!hasPerm) return;

      if (!mounted) return;
      final s = AppStrings(lang);
      final locked = await GpsAcquisitionSheet.show(
        context,
        title: s.tr(
          eu: 'Setalaren koordenatuak zehaztu',
          es: 'Fijar coordenadas del setal',
          en: 'Lock mushroom spot coordinates',
        ),
        subtitle: s.tr(
          eu: '${activeState.title} • GPS Seinalea',
          es: '${activeState.title} • Señal GPS',
          en: '${activeState.title} • GPS Fix',
        ),
        confirmButtonLabel: s.tr(
          eu: 'Finkatu koordenatuak',
          es: 'Fijar coordenadas',
          en: 'Lock coordinates',
        ),
        lang: lang,
      );
      if (locked == null) return;
      targetLocation = locked;
      _mapController.move(targetLocation, 16.0);
    }

    await _openFindFormAtLocation(targetLocation, activeState);
  }

  Future<void> _openFindFormAtLocation(
    LatLng targetLocation,
    ActiveOutingState activeState,
  ) async {
    final activeId = activeState.activeOutingId;
    if (activeId == null) return;

    final catalog =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    if (!mounted) return;
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

  void _handleMapTap(LatLng latLng) {
    if (_isPickingSpotOnMap) {
      _mapController.move(
        latLng,
        _mapController.camera.zoom < 14.5 ? 15.0 : _mapController.camera.zoom,
      );
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _confirmDianaSpotOnLiveMap(
    ActiveOutingState activeState,
  ) async {
    final targetLocation = _mapController.camera.center;
    setState(() => _isPickingSpotOnMap = false);
    await _openFindFormAtLocation(targetLocation, activeState);
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
            eu: 'Ibilbidea eta bildutako ${outingSpots.length} perretxiko-leku gorde egingo dira zure historian.',
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
              s.tr(
                  eu: 'Amaitu eta Gorde',
                  es: 'Terminar y Guardar',
                  en: 'Finish & Save'),
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
    final allMushrooms =
        ref.watch(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
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

    final activeLayer = ref.watch(activeMapLayerProvider);

    final center = activeState.routePoints.isNotEmpty
        ? activeState.routePoints.last
        : (outingSpots.isNotEmpty
            ? LatLng(outingSpots.last.latitude, outingSpots.last.longitude)
            : const LatLng(43.0340, -2.7270));

    return Scaffold(
      body: PopScope(
        canPop: !_isPickingSpotOnMap,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_isPickingSpotOnMap) {
            setState(() => _isPickingSpotOnMap = false);
          }
        },
        child: Stack(
          children: [
            // Mapa a pantalla completa
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 15.5,
                minZoom: 4.0,
                maxZoom: 18.0,
                onTap: (_, latLng) => _handleMapTap(latLng),
              ),
              children: [
                TileLayer(
                  urlTemplate: activeLayer.urlTemplate,
                  userAgentPackageName: 'com.zizai.zizai',
                  maxNativeZoom: activeLayer.maxZoom,
                  tileProvider: _offlineTileProvider,
                ),
                if (!activeState.isManual &&
                    activeState.routePoints.length >= 2)
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
                  rotate: true,
                  markers: [
                    ...outingSpots.map(
                      (spot) => Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: 40,
                        height: 40,
                        rotate: true,
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
                          child: ForagingSpotMarkerWidget(
                            spot: spot,
                            allMushrooms: allMushrooms,
                            size: 38,
                          ),
                        ),
                      ),
                    ),
                    if (!activeState.isManual &&
                        activeState.routePoints.isNotEmpty)
                      Marker(
                        point: activeState.routePoints.last,
                        width: 26,
                        height: 26,
                        rotate: true,
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

            // Diana de alta precisión si está en modo ubicar seta en el mapa
            if (_isPickingSpotOnMap) const MapCrosshairTarget(),

            // Banner interactivo si está en modo Diana
            if (_isPickingSpotOnMap)
              Positioned(
                top: MediaQuery.of(context).padding.top + 76,
                left: 14,
                right: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  AutumnColors.amberLeaf.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.touch_app_rounded,
                              color: AutumnColors.amberLeaf,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s.tr(
                                    eu: 'Ukitu hatzarekin edo mugitu diana',
                                    es: 'Toca con el dedo o mueve la diana',
                                    en: 'Tap with finger or move crosshair',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  s.tr(
                                    eu: 'Kokatu diana setala dagoen leku zehatzean',
                                    es: 'Apunta la diana al lugar exacto del setal',
                                    en: 'Aim crosshair at the exact mushroom spot',
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.16),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () =>
                                setState(() => _isPickingSpotOnMap = false),
                            child: Text(
                              s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
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
                                        eu: 'Eskuzko modua (GPS gabe) · $totalSpecimens ale (${outingSpots.length} perretxiko-leku)',
                                        es: 'Modo manual (sin GPS) · $totalSpecimens ej. (${outingSpots.length} setales)',
                                        en: 'Manual mode (no GPS) · $totalSpecimens spec. (${outingSpots.length} spots)',
                                      )
                                    : s.tr(
                                        eu: '$km km ibilbidea · $totalSpecimens ale (${outingSpots.length} perretxiko-leku)',
                                        es: '$km km de ruta · $totalSpecimens ej. (${outingSpots.length} setales)',
                                        en: '$km km route · $totalSpecimens spec. (${outingSpots.length} spots)',
                                      ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AutumnColors.warmSand
                                      .withValues(alpha: 0.9),
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
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            ref.read(activeMapLayerProvider.notifier).state =
                                activeLayer.next;
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AutumnColors.amberLeaf
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  activeLayer.icon,
                                  size: 14,
                                  color: AutumnColors.amberLeaf,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  activeLayer.shortLabel(lang),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
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
                    onPressed: () {
                      ref.read(activeMapLayerProvider.notifier).state =
                          activeLayer.next;
                    },
                    tooltip: activeLayer.localized(lang),
                    child: Icon(
                      activeLayer.icon,
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

            // Barra Inferior: modo confirmación de Diana o barra normal de acciones
            if (_isPickingSpotOnMap)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 14,
                left: 14,
                right: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AutumnColors.parchmentBg.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AutumnColors.warmSand),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AutumnColors.mossGreen.withValues(alpha: 0.15),
                          foregroundColor: AutumnColors.mossGreen,
                          padding: const EdgeInsets.all(12),
                        ),
                        tooltip: s.tr(
                          eu: 'Zentratu diana nire GPS posizioan',
                          es: 'Centrar diana en mi ubicación GPS',
                          en: 'Center crosshair on my GPS location',
                        ),
                        onPressed: () => _centerDianaOnGps(activeState),
                        icon: const Icon(Icons.my_location_rounded, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          key: const ValueKey('btn_confirm_live_diana_spot'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AutumnColors.boletusBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 3,
                          ),
                          onPressed: () =>
                              _confirmDianaSpotOnLiveMap(activeState),
                          icon:
                              const Icon(Icons.check_circle_rounded, size: 22),
                          label: Text(
                            s.tr(
                              eu: 'Finkatu setala hemen',
                              es: 'Fijar setal aquí',
                              en: 'Set spot here',
                            ),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 14,
                left: 14,
                right: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
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
                                ? s.tr(
                                    eu: 'Berrabiarazi',
                                    es: 'Reanudar',
                                    en: 'Resume')
                                : s.tr(
                                    eu: 'Gelditu',
                                    es: 'Pausar',
                                    en: 'Pause'),
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

                          // Botón Primario: en Salida Manual activa la Diana; en Ruta GPS anota en el GPS actual
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AutumnColors.ochreGold,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                if (activeState.isManual) {
                                  setState(() => _isPickingSpotOnMap = true);
                                } else {
                                  _handleRegisterFindAtCurrentPosition(
                                    activeState,
                                  );
                                }
                              },
                              icon: Icon(
                                activeState.isManual
                                    ? Icons.touch_app_rounded
                                    : Icons.add_location_alt_rounded,
                                size: 19,
                              ),
                              label: Text(
                                activeState.isManual
                                    ? s.tr(
                                        eu: 'Kokatu Mapan',
                                        es: 'Ubicar en Mapa',
                                        en: 'Place on Map',
                                      )
                                    : s.tr(
                                        eu: 'Perretxikoa hemen',
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

                          // Botón Secundario: solo en Ruta GPS (en Salida Manual el botón principal ya activa la Diana)
                          if (!activeState.isManual) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: AutumnColors.amberLeaf,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(10),
                              ),
                              tooltip: s.tr(
                                eu: 'Kokatu mapan dianarekin',
                                es: 'Ubicar seta con diana en el mapa',
                                en: 'Pick spot on map with crosshair',
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPickingSpotOnMap = true;
                                });
                              },
                              icon: const Icon(Icons.touch_app_rounded,
                                  size: 22),
                            ),
                          ],
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
      ),
    );
  }
}
