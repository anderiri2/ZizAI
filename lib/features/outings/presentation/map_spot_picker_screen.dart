import 'dart:ui';
import 'package:flutter/material.dart';
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
import '../../map/services/offline_map_service.dart';
import '../data/outings_database.dart';
import '../models/foraging_outing.dart';
import 'outings_screen.dart';
import '../../map/presentation/widgets/foraging_spot_marker.dart';

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
  LatLng? _pickedPoint;

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
        eu: 'Finkatu koordenatuak',
        es: 'Fijar coordenadas',
        en: 'Lock coordinates',
      ),
      lang: lang,
    );

    if (pos != null && mounted) {
      _mapController.move(
        pos,
        _mapController.camera.zoom < 14 ? 14.5 : _mapController.camera.zoom,
      );
      _handleMapTap(pos);
    }
  }

  Future<void> _handleMapTap(LatLng point) async {
    setState(() {
      _pickedPoint = point;
    });

    if (widget.pickCoordinatesOnly) {
      Navigator.of(context).pop(point);
      return;
    }

    final allMushrooms =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    // Abrir formulario para registrar la seta en esta posición seleccionada
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
        : (!isManualOuting ? (savedOuting?.routePoints ?? const <LatLng>[]) : const <LatLng>[]);

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
              initialZoom: 13.5,
              minZoom: 5.0,
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
                  // Marcador provisional del punto seleccionado
                  if (_pickedPoint != null)
                    Marker(
                      point: _pickedPoint!,
                      width: 44,
                      height: 44,
                      rotate: true,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AutumnColors.terracotta,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: AutumnColors.terracotta
                                  .withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

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
                      color: AutumnColors.barkDark.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AutumnColors.amberLeaf.withValues(alpha: 0.6),
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.pickCoordinatesOnly
                                    ? s.tr(
                                        eu: 'Ukitu mapan posizio zehatza hautatzeko',
                                        es: 'Toca el mapa para seleccionar la posición exacta',
                                        en: 'Tap map to select exact location',
                                      )
                                    : s.tr(
                                        eu: 'Ukitu mapan perretxikoa kokatzeko',
                                        es: 'Toca en el mapa para ubicar la seta',
                                        en: 'Tap on the map to place mushroom',
                                      ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.outingTitle} • ${existingOutingSpots.length} ${s.tr(eu: "perretxiko-leku", es: "setales", en: "spots")}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
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

          // Botón GPS para ubicar seta en posición actual precisa
          Positioned(
            bottom: 84,
            right: 18,
            child: FloatingActionButton.small(
              key: const ValueKey('btn_gps_picker_spot'),
              heroTag: 'btn_gps_picker_spot',
              backgroundColor: AutumnColors.boletusBrown,
              foregroundColor: Colors.white,
              onPressed: _handleGpsSpotPick,
              tooltip: s.tr(
                eu: 'Nire uneko GPS kokapenean kokatu',
                es: 'Ubicar en mi posición GPS actual',
                en: 'Place at current GPS location',
              ),
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // Botón flotante para alternar capa Topográfica / OSM
          Positioned(
            bottom: 30,
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
        ],
      ),
    );
  }
}
