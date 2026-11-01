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
  bool _useTopoLayer = true;
  LatLng? _pickedPoint;

  static const LatLng _defaultBasqueCenter = LatLng(43.0340, -2.7270);

  Future<void> _handleMapTap(LatLng point) async {
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
    final center = widget.initialCenter ?? _defaultBasqueCenter;
    final allSpots =
        ref.watch(foragingSpotsProvider).valueOrNull ?? const <ForagingSpot>[];
    final existingOutingSpots =
        allSpots.where((s) => s.outingId == widget.outingId).toList();

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
                urlTemplate: _useTopoLayer
                    ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.perretxikotan.perretxikotan',
                tileProvider: _offlineTileProvider,
              ),
              MarkerLayer(
                markers: [
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
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AutumnColors.amberLeaf.withValues(alpha: 0.25),
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
                                s.tr(
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
                                '${widget.outingTitle} • ${existingOutingSpots.length} setales',
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
