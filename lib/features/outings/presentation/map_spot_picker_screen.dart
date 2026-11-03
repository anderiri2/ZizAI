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
import '../../map/services/offline_map_service.dart';
import '../data/outings_database.dart';
import '../models/foraging_outing.dart';
import 'outings_screen.dart';

class MapSpotPickerScreen extends ConsumerStatefulWidget {
  final String outingId;
  final String outingTitle;
  final LatLng? initialCenter;

  const MapSpotPickerScreen({
    super.key,
    required this.outingId,
    required this.outingTitle,
    this.initialCenter,
  });

  @override
  ConsumerState<MapSpotPickerScreen> createState() =>
      _MapSpotPickerScreenState();
}

class _MapSpotPickerScreenState extends ConsumerState<MapSpotPickerScreen> {
  final MapController _mapController = MapController();
  final OfflineCachingTileProvider _offlineTileProvider =
      OfflineCachingTileProvider();
  static const Distance _distanceCalc = Distance();
  bool _useTopoLayer = true;
  bool _isDrawingRoute = false;
  LatLng? _pickedPoint;

  static const LatLng _defaultForestCenter = LatLng(43.0340, -2.7270);

  double _calculateRouteDistanceMeters(List<LatLng> pts) {
    if (pts.length < 2) return 0.0;
    double total = 0.0;
    for (int i = 1; i < pts.length; i++) {
      total += _distanceCalc.as(LengthUnit.Meter, pts[i - 1], pts[i]);
    }
    return total;
  }

  Future<void> _updateOutingRoutePoints(
    ForagingOuting? savedOuting,
    ActiveOutingState activeOuting,
    List<LatLng> updatedPoints,
  ) async {
    if (activeOuting.isRecording &&
        activeOuting.activeOutingId == widget.outingId) {
      if (updatedPoints.isNotEmpty) {
        ref
            .read(activeOutingRecorderProvider.notifier)
            .addRoutePoint(updatedPoints.last);
      }
      return;
    }

    if (savedOuting != null) {
      final updatedOuting = ForagingOuting(
        id: savedOuting.id,
        title: savedOuting.title,
        startedAt: savedOuting.startedAt,
        endedAt: savedOuting.endedAt,
        durationSeconds: savedOuting.durationSeconds,
        distanceMeters: _calculateRouteDistanceMeters(updatedPoints),
        routePoints: updatedPoints,
        notes: savedOuting.notes,
        isManual: savedOuting.isManual,
      );
      await ref.read(outingsProvider.notifier).saveOuting(updatedOuting);
    }
  }

  Future<void> _handleMapTap(
    LatLng point,
    ForagingOuting? savedOuting,
    ActiveOutingState activeOuting,
    List<LatLng> currentRoutePoints,
  ) async {
    if (_isDrawingRoute) {
      final nextPoints = [...currentRoutePoints, point];
      await _updateOutingRoutePoints(savedOuting, activeOuting, nextPoints);
      return;
    }

    setState(() {
      _pickedPoint = point;
    });

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
    final allSpots =
        ref.watch(foragingSpotsProvider).valueOrNull ?? const <ForagingSpot>[];
    final existingOutingSpots =
        allSpots.where((sp) => sp.outingId == widget.outingId).toList();
    final allOutings =
        ref.watch(outingsProvider).valueOrNull ?? const <ForagingOuting>[];
    final savedOuting =
        allOutings.where((o) => o.id == widget.outingId).firstOrNull;
    final activeOuting = ref.watch(activeOutingRecorderProvider);

    final routePoints = (activeOuting.isRecording &&
            activeOuting.activeOutingId == widget.outingId)
        ? activeOuting.routePoints
        : (savedOuting?.routePoints ?? const <LatLng>[]);

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
              onTap: (_, latLng) => _handleMapTap(
                latLng,
                savedOuting,
                activeOuting,
                routePoints,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _useTopoLayer
                    ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.perretxikotan.perretxikotan',
                tileProvider: _offlineTileProvider,
              ),
              if (routePoints.length >= 2)
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
                markers: [
                  ...routePoints.map(
                    (pt) => Marker(
                      point: pt,
                      width: 14,
                      height: 14,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AutumnColors.terracotta,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ),
                  // Marcadores de setas ya registradas en esta salida
                  ...existingOutingSpots.map(
                    (spot) => Marker(
                      point: LatLng(spot.latitude, spot.longitude),
                      width: 36,
                      height: 36,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AutumnColors.mossGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  // Marcador provisional del punto seleccionado
                  if (_pickedPoint != null)
                    Marker(
                      point: _pickedPoint!,
                      width: 44,
                      height: 44,
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AutumnColors.amberLeaf
                                    .withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isDrawingRoute
                                    ? Icons.route_rounded
                                    : Icons.touch_app_rounded,
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
                                    _isDrawingRoute
                                        ? s.tr(
                                            eu: 'Ukitu mapan ibilbidea eskuz marrazteko',
                                            es: 'Toca el mapa para trazar la ruta a mano',
                                            en: 'Tap on the map to trace route by hand',
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
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isDrawingRoute = false),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: !_isDrawingRoute
                                        ? AutumnColors.mossGreen
                                        : Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.add_location_alt_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        s.tr(
                                          eu: 'Seta kokatu',
                                          es: 'Ubicar seta',
                                          en: 'Place spot',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _isDrawingRoute = true),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _isDrawingRoute
                                        ? AutumnColors.terracotta
                                        : Colors.white10,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.route_rounded,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        s.tr(
                                          eu: 'Ibilbidea marraztu',
                                          es: 'Trazar ruta',
                                          en: 'Trace route',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_isDrawingRoute &&
                                savedOuting != null &&
                                routePoints.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white12,
                                  foregroundColor: Colors.white,
                                ),
                                tooltip: s.tr(
                                  eu: 'Desegin azken puntua',
                                  es: 'Deshacer último punto',
                                  en: 'Undo last point',
                                ),
                                icon: const Icon(Icons.undo_rounded, size: 18),
                                onPressed: () {
                                  final next = routePoints.sublist(
                                    0,
                                    routePoints.length - 1,
                                  );
                                  _updateOutingRoutePoints(
                                    savedOuting,
                                    activeOuting,
                                    next,
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
                setState(() => _useTopoLayer = !_useTopoLayer);
              },
              child: Icon(
                _useTopoLayer ? Icons.terrain_rounded : Icons.map_rounded,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
