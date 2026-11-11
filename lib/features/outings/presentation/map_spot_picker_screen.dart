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
import '../models/foraging_outing.dart';
import 'outings_screen.dart';

class MapSpotPickerScreen extends ConsumerStatefulWidget {
  final String outingId;
  final String outingTitle;
  final LatLng? initialCenter;
  final bool pickCoordinatesOnly;

  const MapSpotPickerScreen({
    super.key,
    required this.outingId,
    required this.outingTitle,
    this.initialCenter,
    this.pickCoordinatesOnly = false,
  });

  @override
  ConsumerState<MapSpotPickerScreen> createState() =>
      _MapSpotPickerScreenState();
}

class _MapSpotPickerScreenState extends ConsumerState<MapSpotPickerScreen> {
  final MapController _mapController = MapController();
  final OfflineCachingTileProvider _offlineTileProvider =
      OfflineCachingTileProvider();

  static const LatLng _defaultForestCenter = LatLng(43.0340, -2.7270);

  Future<void> _handleGpsSpotPick() async {
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);

    final hasPerm = await GpsAccuracyService.ensureLocationPermission(
      context,
      lang: lang,
    );
    if (!hasPerm) return;

    if (!mounted) return;
    final pos = await GpsAcquisitionSheet.show(
      context,
      title: s.tr(
        eu: 'Setalaren koordenatuak zehaztu',
        es: 'Fijar coordenadas del setal',
        en: 'Lock mushroom spot coordinates',
      ),
      subtitle: s.tr(
        eu: '${widget.outingTitle} • GPS Seinalea',
        es: '${widget.outingTitle} • Señal GPS',
        en: '${widget.outingTitle} • GPS Fix',
      ),
      confirmButtonLabel: s.tr(
        eu: 'Zentratu diana hemen',
        es: 'Centrar diana aquí',
        en: 'Center crosshair here',
      ),
      lang: lang,
    );
    await ref
        .read(activeOutingRecorderProvider.notifier)
        .ensureGpsStreamActive();

    if (pos != null && mounted) {
      _mapController.move(
        pos,
        _mapController.camera.zoom < 15.0 ? 15.5 : _mapController.camera.zoom,
      );
      HapticFeedback.selectionClick();
    }
  }

  void _handleMapTapToAimDiana(LatLng point) {
    _mapController.move(
      point,
      _mapController.camera.zoom < 14.5 ? 15.0 : _mapController.camera.zoom,
    );
    HapticFeedback.selectionClick();
  }

  Future<void> _confirmDianaCenterSpot() async {
    final point = _mapController.camera.center;

    if (widget.pickCoordinatesOnly) {
      Navigator.of(context).pop(point);
      return;
    }

    final allMushrooms =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    // Abrir formulario para registrar la seta en la posición central exacta de la diana
    final newSpot = await showModalBottomSheet<ForagingSpot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OutingFindFormSheet(
        position: point,
        outingId: widget.outingId,
        outingTitle: widget.outingTitle,
        catalogMushrooms: allMushrooms,
      ),
    );

    if (newSpot != null && mounted) {
      await ref.read(foragingSpotsProvider.notifier).saveSpot(newSpot);
      if (mounted) {
        Navigator.of(context).pop(newSpot);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final activeLayer = ref.watch(activeMapLayerProvider);
    final allMushrooms =
        ref.watch(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
    final allSpots =
        ref.watch(foragingSpotsProvider).valueOrNull ?? const <ForagingSpot>[];
    final existingOutingSpots =
        allSpots.where((sp) => sp.outingId == widget.outingId).toList();
    final allOutings =
        ref.watch(outingsProvider).valueOrNull ?? const <ForagingOuting>[];
    final savedOuting =
        allOutings.where((o) => o.id == widget.outingId).firstOrNull;
    final activeOuting = ref.watch(activeOutingRecorderProvider);

    final isManualOuting = (activeOuting.isRecording &&
            activeOuting.activeOutingId == widget.outingId)
        ? activeOuting.isManual
        : (savedOuting?.isManual ?? false);

    final routePoints = (!isManualOuting &&
            activeOuting.isRecording &&
            activeOuting.activeOutingId == widget.outingId)
        ? activeOuting.routePoints
        : (!isManualOuting
            ? (savedOuting?.routePoints ?? const <LatLng>[])
            : const <LatLng>[]);

    ForagingSpot? largestSpot;
    for (final sp in existingOutingSpots) {
      if (largestSpot == null ||
          sp.quantityCount > largestSpot.quantityCount ||
          (sp.quantityCount == largestSpot.quantityCount &&
              (sp.weightGrams ?? 0) > (largestSpot.weightGrams ?? 0))) {
        largestSpot = sp;
      }
    }

    final center = widget.initialCenter ??
        (routePoints.isNotEmpty
            ? routePoints.last
            : (largestSpot != null
                ? LatLng(largestSpot.latitude, largestSpot.longitude)
                : _defaultForestCenter));

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 14.5,
              minZoom: 5.0,
              maxZoom: 18.0,
              onTap: (_, latLng) => _handleMapTapToAimDiana(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: activeLayer.urlTemplate,
                userAgentPackageName: 'com.zizai.zizai',
                maxNativeZoom: activeLayer.maxZoom,
                tileProvider: _offlineTileProvider,
              ),
              if (!isManualOuting && routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.white.withValues(alpha: 0.9),
                      strokeWidth: 7.0,
                    ),
                    Polyline(
                      points: routePoints,
                      color: AutumnColors.terracotta,
                      strokeWidth: 4.5,
                    ),
                  ],
                ),
              MarkerLayer(
                rotate: true,
                markers: [
                  if (!isManualOuting)
                    ...routePoints.map(
                      (pt) => Marker(
                        point: pt,
                        width: 14,
                        height: 14,
                        rotate: true,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AutumnColors.terracotta,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  // Marcadores de perretxikos ya registrados en esta salida
                  ...existingOutingSpots.map(
                    (spot) => Marker(
                      point: LatLng(spot.latitude, spot.longitude),
                      width: 36,
                      height: 36,
                      rotate: true,
                      child: ForagingSpotMarkerWidget(
                        spot: spot,
                        allMushrooms: allMushrooms,
                        size: 34,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Diana interactiva de alta precisión en el centro del mapa
          const MapCrosshairTarget(),

          // Banner interactivo flotante en la parte superior
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AutumnColors.barkDark.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AutumnColors.amberLeaf.withValues(alpha: 0.65),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AutumnColors.amberLeaf
                                .withValues(alpha: 0.25),
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
                                widget.pickCoordinatesOnly
                                    ? s.tr(
                                        eu: 'Kokatu diana posizio zehatzean',
                                        es: 'Apunta la diana a la posición exacta',
                                        en: 'Aim crosshair at exact location',
                                      )
                                    : '${widget.outingTitle} • ${existingOutingSpots.length} ${s.tr(eu: "perretxiko-leku", es: "setales", en: "spots")}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Botón flotante para alternar capa Topográfica / Satélite / Callejero
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 94,
            right: 18,
            child: FloatingActionButton.small(
              heroTag: 'toggle_topo_layer_picker',
              backgroundColor: AutumnColors.parchmentBg,
              foregroundColor: AutumnColors.boletusBrown,
              onPressed: () {
                ref.read(activeMapLayerProvider.notifier).state =
                    activeLayer.next;
              },
              tooltip: activeLayer.localized(lang),
              child: Icon(activeLayer.icon),
            ),
          ),

          // Barra inferior de confirmación de Diana (idéntica a la del Mapa Global)
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    key: const ValueKey('btn_gps_picker_spot'),
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
                    onPressed: _handleGpsSpotPick,
                    icon: const Icon(Icons.my_location_rounded, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const ValueKey('btn_confirm_diana_spot'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AutumnColors.boletusBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                      ),
                      onPressed: _confirmDianaCenterSpot,
                      icon: const Icon(Icons.check_circle_rounded, size: 22),
                      label: Text(
                        widget.pickCoordinatesOnly
                            ? s.tr(
                                eu: 'Finkatu koordenatuak hemen',
                                es: 'Fijar coordenadas aquí',
                                en: 'Set coordinates here',
                              )
                            : s.tr(
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
          ),
        ],
      ),
    );
  }
}
