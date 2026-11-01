import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/mushroom_detail_screen.dart';
import '../../outings/data/outings_database.dart';
import '../../outings/models/foraging_outing.dart';
import '../data/spots_database.dart';
import '../models/foraging_spot.dart';
import '../services/offline_map_service.dart';
import 'offline_maps_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Mushroom? initialMushroomToRegister;
  final String? initialImagePathToRegister;
  final String? initialSelectedOutingFilter;
  final VoidCallback? onInitialMushroomConsumed;
  final VoidCallback? onOpenOfflineMapsManager;
  final TileProvider? customTileProvider;

  const MapScreen({
    super.key,
    this.initialMushroomToRegister,
    this.initialImagePathToRegister,
    this.initialSelectedOutingFilter,
    this.onInitialMushroomConsumed,
    this.onOpenOfflineMapsManager,
    this.customTileProvider,
  });

  @override
  ConsumerState<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final OfflineCachingTileProvider _defaultOfflineTileProvider =
      OfflineCachingTileProvider();
  bool _useTopoLayer = true;
  bool _showAllRoutes = true;
  bool _isLocatingGps = false;
  ForagingSpot? _selectedSpot;
  LatLng? _currentUserLocation;

  /// Filtro: 'all' (Todos), 'standalone' (Puntos sueltos) o el ID de una Salida concreta.
  String _spotFilterMode = 'all';

  static const LatLng _defaultBasqueCenter = LatLng(43.0150, -2.5200);

  LatLngBounds get currentViewportBounds => _mapController.camera.visibleBounds;
  bool get isUsingTopoLayer => _useTopoLayer;

  void moveToRegion(LatLng center, double zoom) {
    _mapController.move(center, zoom);
  }

  void _openOfflineMapsModal() {
    if (widget.onOpenOfflineMapsManager != null) {
      widget.onOpenOfflineMapsManager!();
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OfflineMapsSheet(
        currentBounds: _mapController.camera.visibleBounds,
        isTopoLayer: _useTopoLayer,
        onSelectRegionOnMap: (center, zoom) {
          _mapController.move(center, zoom);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialSelectedOutingFilter != null) {
      _spotFilterMode = widget.initialSelectedOutingFilter!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingRegistration();
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialSelectedOutingFilter != null &&
        widget.initialSelectedOutingFilter !=
            oldWidget.initialSelectedOutingFilter) {
      setState(() {
        _spotFilterMode = widget.initialSelectedOutingFilter!;
      });
      _centerOnOutingFilter(widget.initialSelectedOutingFilter!);
    }
    if (widget.initialMushroomToRegister != null &&
        widget.initialMushroomToRegister !=
            oldWidget.initialMushroomToRegister) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPendingRegistration();
      });
    }
  }

  void _centerOnOutingFilter(String outingId) {
    final outings =
        ref.read(outingsProvider).valueOrNull ?? const <ForagingOuting>[];
    final target = outings.where((o) => o.id == outingId).firstOrNull;
    if (target != null && target.routePoints.isNotEmpty) {
      _mapController.move(target.routePoints.first, 13.8);
    }
  }

  void _checkPendingRegistration() {
    final pending = widget.initialMushroomToRegister;
    if (pending != null) {
      final initialPhoto = widget.initialImagePathToRegister;
      widget.onInitialMushroomConsumed?.call();
      final center = _currentUserLocation ?? _mapController.camera.center;
      _openAddOrEditSpotSheet(
        context,
        initialLatLng: center,
        preselectedMushroom: pending,
        preselectedPhotoPath: initialPhoto,
      );
    }
  }

  Future<void> _centerOnUserGps({bool openFormAfter = false}) async {
    setState(() => _isLocatingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El GPS está desactivado. Mantén pulsado cualquier punto del mapa para guardar un setal.',
              ),
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permiso de ubicación denegado. Mantén pulsado sobre el mapa para colocar un marcador manualmente.',
              ),
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      final target = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentUserLocation = target);
      _mapController.move(target, 15.0);

      if (openFormAfter && mounted) {
        await _openAddOrEditSpotSheet(context, initialLatLng: target);
      }
    } catch (_) {
      if (mounted) {
        final fallback = _mapController.camera.center;
        if (openFormAfter) {
          await _openAddOrEditSpotSheet(context, initialLatLng: fallback);
        }
      }
    } finally {
      if (mounted) setState(() => _isLocatingGps = false);
    }
  }

  Future<void> _openAddOrEditSpotSheet(
    BuildContext context, {
    required LatLng initialLatLng,
    ForagingSpot? existingSpot,
    Mushroom? preselectedMushroom,
    String? preselectedPhotoPath,
  }) async {
    final allMushrooms =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
    final activeOuting = ref.read(activeOutingRecorderProvider);

    final savedSpot = await showModalBottomSheet<ForagingSpot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpotFormBottomSheet(
        initialLatLng: initialLatLng,
        existingSpot: existingSpot,
        preselectedMushroom: preselectedMushroom,
        preselectedPhotoPath: preselectedPhotoPath,
        activeOutingId: activeOuting.isRecording
            ? activeOuting.activeOutingId
            : null,
        activeOutingTitle: activeOuting.isRecording
            ? activeOuting.title
            : null,
        catalogMushrooms: allMushrooms,
      ),
    );

    if (savedSpot != null) {
      await ref.read(foragingSpotsProvider.notifier).saveSpot(savedSpot);
      setState(() => _selectedSpot = savedSpot);
      _mapController.move(
        LatLng(savedSpot.latitude, savedSpot.longitude),
        _mapController.camera.zoom < 13 ? 13.5 : _mapController.camera.zoom,
      );
    }
  }

  void _openSavedSpotsListSheet(List<ForagingSpot> spots) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AutumnColors.parchmentBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
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
                      Icons.place_rounded,
                      color: AutumnColors.terracotta,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ubicaciones en Vista (${spots.length})',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AutumnColors.boletusBrown,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (spots.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'No hay puntos para el filtro seleccionado.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AutumnColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: spots.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final spot = spots[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: spot.isFromOuting
                                ? AutumnColors.mossGreen.withValues(alpha: 0.2)
                                : AutumnColors.ochreGold.withValues(alpha: 0.2),
                            child: Icon(
                              spot.isFromOuting
                                  ? Icons.hiking_rounded
                                  : Icons.location_on_rounded,
                              color: spot.isFromOuting
                                  ? AutumnColors.mossGreen
                                  : AutumnColors.boletusBrown,
                            ),
                          ),
                          title: Text(
                            '${spot.title} (${spot.quantityCount}x)',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AutumnColors.textPrimary,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (spot.mushroomName != null &&
                                  spot.mushroomName!.isNotEmpty)
                                Text(
                                  spot.mushroomName!,
                                  style: const TextStyle(
                                    color: AutumnColors.mossGreen,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              Text(
                                spot.isFromOuting
                                    ? 'Salida: ${spot.outingTitle ?? "Ruta GPS"}'
                                    : 'Punto suelto del Mapa Global',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AutumnColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            DateFormat('dd/MM/yy').format(spot.foundAt),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AutumnColors.textMuted,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            setState(() => _selectedSpot = spot);
                            _mapController.move(
                              LatLng(spot.latitude, spot.longitude),
                              14.0,
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final allSpots =
        ref.watch(foragingSpotsProvider).valueOrNull ?? const <ForagingSpot>[];
    final allOutings =
        ref.watch(outingsProvider).valueOrNull ?? const <ForagingOuting>[];
    final allMushrooms =
        ref.watch(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    // Filtrar los puntos según el selector del Mapa Global
    final visibleSpots = allSpots.where((s) {
      if (_spotFilterMode == 'all') return true;
      if (_spotFilterMode == 'standalone') return !s.isFromOuting;
      return s.outingId == _spotFilterMode;
    }).toList();

    // Filtrar las polilíneas de las rutas GPS a mostrar
    final visibleOutingRoutes = allOutings.where((o) {
      if (o.routePoints.length < 2) return false;
      if (_spotFilterMode == 'standalone') return false;
      if (_spotFilterMode == 'all') return _showAllRoutes;
      return o.id == _spotFilterMode;
    }).toList();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultBasqueCenter,
              initialZoom: 9.8,
              minZoom: 4.0,
              maxZoom: 17.5,
              onTap: (_, __) {
                if (_selectedSpot != null) {
                  setState(() => _selectedSpot = null);
                }
              },
              onLongPress: (_, latLng) {
                _openAddOrEditSpotSheet(context, initialLatLng: latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _useTopoLayer
                    ? 'https://tile.opentopomap.org/{z}/{x}/{y}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.perretxikotan.app',
                maxNativeZoom: _useTopoLayer ? 17 : 19,
                tileProvider:
                    widget.customTileProvider ?? _defaultOfflineTileProvider,
              ),
              // Capa de polilíneas de las rutas GPS de las Salidas
              if (visibleOutingRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: visibleOutingRoutes.map((outing) {
                    final isHighlighted = _spotFilterMode == outing.id;
                    return Polyline(
                      points: outing.routePoints,
                      color: isHighlighted
                          ? AutumnColors.terracotta
                          : AutumnColors.mossGreen.withValues(alpha: 0.82),
                      strokeWidth: isHighlighted ? 4.8 : 3.6,
                    );
                  }).toList(),
                ),
              if (_currentUserLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentUserLocation!,
                      width: 28,
                      height: 28,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
              // Marcadores diferenciados visualmente (Puntos de Salida vs Puntos sueltos)
              MarkerLayer(
                markers: visibleSpots.map((spot) {
                  final isSelected = _selectedSpot?.id == spot.id;
                  final isFromOuting = spot.isFromOuting;

                  return Marker(
                    point: LatLng(spot.latitude, spot.longitude),
                    width: isSelected ? 56 : 46,
                    height: isSelected ? 56 : 46,
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedSpot = spot);
                        _mapController.move(
                          LatLng(spot.latitude, spot.longitude),
                          _mapController.camera.zoom < 12.5
                              ? 13.0
                              : _mapController.camera.zoom,
                        );
                      },
                      child: AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AutumnColors.terracotta
                                : (isFromOuting
                                    ? AutumnColors.mossGreen
                                    : AutumnColors.boletusBrown),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isFromOuting
                                  ? Colors.white
                                  : AutumnColors.amberLeaf,
                              width: isSelected ? 3 : 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFromOuting
                                ? Icons.hiking_rounded
                                : Icons.park_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Cabecera translúcida con controles de Capa, Rutas, Mapas Offline y Filtro por Salida
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        decoration: BoxDecoration(
                          color: AutumnColors.barkDark.withValues(alpha: 0.82),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                AutumnColors.amberLeaf.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.explore_rounded,
                                  color: AutumnColors.amberLeaf,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    s.tr(
                                      eu: 'Perretxiko-lekuen Mapa',
                                      es: 'Mapa Global de Setales',
                                      en: 'Global Foraging Map',
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                _HeaderPillButton(
                                  icon: Icons.route_rounded,
                                  label: _showAllRoutes
                                      ? s.tr(eu: 'Ibilb. ON', es: 'Rutas ON', en: 'Routes ON')
                                      : s.tr(eu: 'Ibilb. OFF', es: 'Rutas OFF', en: 'Routes OFF'),
                                  active: _showAllRoutes,
                                  onTap: () {
                                    setState(
                                        () => _showAllRoutes = !_showAllRoutes);
                                  },
                                ),
                                const SizedBox(width: 6),
                                _HeaderPillButton(
                                  icon: _useTopoLayer
                                      ? Icons.terrain_rounded
                                      : Icons.map_outlined,
                                  label: _useTopoLayer
                                      ? 'Topo'
                                      : s.tr(eu: 'Kalea', es: 'Calle', en: 'Street'),
                                  active: _useTopoLayer,
                                  onTap: () {
                                    setState(
                                        () => _useTopoLayer = !_useTopoLayer);
                                  },
                                ),
                                const SizedBox(width: 6),
                                _HeaderPillButton(
                                  icon: Icons.download_for_offline_rounded,
                                  label: 'Offline',
                                  active: true,
                                  onTap: _openOfflineMapsModal,
                                ),
                                const SizedBox(width: 6),
                                _HeaderPillButton(
                                  icon: Icons.format_list_bulleted_rounded,
                                  label: '${visibleSpots.length}',
                                  active: false,
                                  onTap: () =>
                                      _openSavedSpotsListSheet(visibleSpots),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 30,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _FilterChipPill(
                                    label: s.tr(
                                      eu: 'Guztiak (${allSpots.length})',
                                      es: 'Todos (${allSpots.length})',
                                      en: 'All (${allSpots.length})',
                                    ),
                                    selected: _spotFilterMode == 'all',
                                    onTap: () =>
                                        setState(() => _spotFilterMode = 'all'),
                                  ),
                                  const SizedBox(width: 6),
                                  _FilterChipPill(
                                    label: s.tr(
                                      eu: 'Puntu solteak (${allSpots.where((sp) => !sp.isFromOuting).length})',
                                      es: 'Puntos sueltos (${allSpots.where((sp) => !sp.isFromOuting).length})',
                                      en: 'Standalone (${allSpots.where((sp) => !sp.isFromOuting).length})',
                                    ),
                                    selected: _spotFilterMode == 'standalone',
                                    onTap: () => setState(
                                        () => _spotFilterMode = 'standalone'),
                                  ),
                                  ...allOutings.map((outing) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: _FilterChipPill(
                                        label: s.tr(
                                          eu: 'Irteera: ${outing.title}',
                                          es: 'Salida: ${outing.title}',
                                          en: 'Outing: ${outing.title}',
                                        ),
                                        selected: _spotFilterMode == outing.id,
                                        onTap: () {
                                          setState(() =>
                                              _spotFilterMode = outing.id);
                                          _centerOnOutingFilter(outing.id);
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: _selectedSpot != null ? 275 : 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'btn_gps_center',
                  backgroundColor: AutumnColors.parchmentBg,
                  foregroundColor: AutumnColors.boletusBrown,
                  tooltip: s.tr(
                    eu: 'Zentratu nire GPS posizioan',
                    es: 'Centrar en mi posición GPS',
                    en: 'Center on my GPS location',
                  ),
                  onPressed: _isLocatingGps ? null : () => _centerOnUserGps(),
                  child: _isLocatingGps
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location_rounded),
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  heroTag: 'btn_add_spot',
                  backgroundColor: AutumnColors.boletusBrown,
                  foregroundColor: Colors.white,
                  onPressed: () {
                    final center = _mapController.camera.center;
                    _openAddOrEditSpotSheet(context, initialLatLng: center);
                  },
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: Text(
                    s.tr(
                      eu: 'Gorde Lekua',
                      es: 'Guardar Setal',
                      en: 'Save Spot',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          if (_selectedSpot != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 104,
              child: _SelectedSpotCard(
                spot: _selectedSpot!,
                linkedMushroom: allMushrooms
                    .where((m) => m.id == _selectedSpot!.mushroomId)
                    .firstOrNull,
                onClose: () => setState(() => _selectedSpot = null),
                onEdit: () {
                  final s = _selectedSpot!;
                  _openAddOrEditSpotSheet(
                    context,
                    initialLatLng: LatLng(s.latitude, s.longitude),
                    existingSpot: s,
                  );
                },
                onDelete: () async {
                  final s = _selectedSpot!;
                  await ref
                      .read(foragingSpotsProvider.notifier)
                      .removeSpot(s.id);
                  setState(() => _selectedSpot = null);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderPillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _HeaderPillButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? AutumnColors.ochreGold.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
          border: active
              ? Border.all(
                  color: AutumnColors.amberLeaf.withValues(alpha: 0.55))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? AutumnColors.amberLeaf : Colors.white,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AutumnColors.amberLeaf
              : Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AutumnColors.barkDark : Colors.white,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SelectedSpotCard extends StatelessWidget {
  final ForagingSpot spot;
  final Mushroom? linkedMushroom;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SelectedSpotCard({
    required this.spot,
    required this.linkedMushroom,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocalPhoto = !kIsWeb &&
        spot.photoPath != null &&
        spot.photoPath!.isNotEmpty &&
        File(spot.photoPath!).existsSync();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AutumnColors.parchmentBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AutumnColors.ochreGold, width: 1.4),
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
              if (hasLocalPhoto)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(spot.photoPath!),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else if (linkedMushroom != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    linkedMushroom!.primaryImage,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              if (hasLocalPhoto || linkedMushroom != null)
                const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: spot.isFromOuting
                                ? AutumnColors.mossGreen.withValues(alpha: 0.16)
                                : AutumnColors.ochreGold.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            spot.isFromOuting
                                ? 'SALIDA: ${spot.outingTitle ?? "RUTA"}'
                                : 'PUNTO SUELTO',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: spot.isFromOuting
                                  ? AutumnColors.mossGreen
                                  : AutumnColors.boletusBrown,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${spot.quantityCount} ej.${spot.weightGrams != null ? " (${spot.weightGrams}g)" : ""}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AutumnColors.terracotta,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spot.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                    if (spot.mushroomName != null &&
                        spot.mushroomName!.isNotEmpty)
                      GestureDetector(
                        onTap: linkedMushroom == null
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => MushroomDetailScreen(
                                      mushroom: linkedMushroom!,
                                    ),
                                  ),
                                );
                              },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            spot.mushroomName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AutumnColors.mossGreen,
                              decoration: linkedMushroom != null
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          ),
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
          if (spot.notes.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AutumnColors.creamCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                spot.notes,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.38,
                  color: AutumnColors.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AutumnColors.edibilityToxic,
                ),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Eliminar'),
              ),
              const SizedBox(width: 6),
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      AutumnColors.ochreGold.withValues(alpha: 0.2),
                  foregroundColor: AutumnColors.boletusBrown,
                ),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Editar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpotFormBottomSheet extends StatefulWidget {
  final LatLng initialLatLng;
  final ForagingSpot? existingSpot;
  final Mushroom? preselectedMushroom;
  final String? preselectedPhotoPath;
  final String? activeOutingId;
  final String? activeOutingTitle;
  final List<Mushroom> catalogMushrooms;

  const _SpotFormBottomSheet({
    required this.initialLatLng,
    this.existingSpot,
    this.preselectedMushroom,
    this.preselectedPhotoPath,
    this.activeOutingId,
    this.activeOutingTitle,
    required this.catalogMushrooms,
  });

  @override
  State<_SpotFormBottomSheet> createState() => _SpotFormBottomSheetState();
}

class _SpotFormBottomSheetState extends State<_SpotFormBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;
  late final TextEditingController _qtyController;
  late final TextEditingController _weightController;
  late DateTime _selectedDate;
  String? _selectedMushroomId;
  String? _selectedMushroomName;
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSpot;
    final pre = widget.preselectedMushroom;

    _titleController = TextEditingController(
      text: existing?.title ??
          (pre != null
              ? 'Setal de ${pre.basqueName.split('/').first.trim()}'
              : ''),
    );
    _notesController = TextEditingController(text: existing?.notes ?? '');
    _latController = TextEditingController(
      text: (existing?.latitude ?? widget.initialLatLng.latitude)
          .toStringAsFixed(5),
    );
    _lngController = TextEditingController(
      text: (existing?.longitude ?? widget.initialLatLng.longitude)
          .toStringAsFixed(5),
    );
    _qtyController = TextEditingController(
      text: '${existing?.quantityCount ?? 1}',
    );
    _weightController = TextEditingController(
      text: existing?.weightGrams != null ? '${existing!.weightGrams}' : '',
    );
    _selectedDate = existing?.foundAt ?? DateTime.now();
    _selectedMushroomId = existing?.mushroomId ?? pre?.id;
    _selectedMushroomName = existing?.mushroomName ??
        (pre != null ? '${pre.basqueName} / ${pre.spanishName}' : null);
    _photoPath = existing?.photoPath ?? widget.preselectedPhotoPath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _qtyController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1400,
        imageQuality: 82,
      );
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(appDir.path, 'spot_photos'));
      if (!photosDir.existsSync()) {
        await photosDir.create(recursive: true);
      }
      final fileName =
          'spot_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
      final savedFile =
          await File(picked.path).copy(p.join(photosDir.path, fileName));
      setState(() => _photoPath = savedFile.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo adjuntar la imagen: $e')),
        );
      }
    }
  }

  Future<void> _selectMushroomDialog() async {
    String filterQuery = '';
    final chosen = await showModalBottomSheet<Mushroom>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutumnColors.parchmentBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final q = filterQuery.trim().toLowerCase();
            final list = widget.catalogMushrooms.where((m) {
              if (q.isEmpty) return true;
              return m.spanishName.toLowerCase().contains(q) ||
                  m.basqueName.toLowerCase().contains(q) ||
                  m.scientificName.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Asociar Seta del Catálogo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AutumnColors.boletusBrown,
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        autofocus: true,
                        onChanged: (v) => setModalState(() => filterQuery = v),
                        decoration: const InputDecoration(
                          hintText:
                              'Buscar por nombre vasco, castellano o científico...',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (context, idx) {
                            final m = list[idx];
                            return ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  m.primaryImage,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Text(
                                m.spanishName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(
                                '${m.basqueName} · ${m.scientificName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => Navigator.of(ctx).pop(m),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (chosen != null) {
      setState(() {
        _selectedMushroomId = chosen.id;
        _selectedMushroomName =
            '${chosen.basqueName} / ${chosen.spanishName}';
        if (_titleController.text.trim().isEmpty) {
          _titleController.text =
              'Setal de ${chosen.basqueName.split('/').first.trim()}';
        }
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim().isEmpty
        ? 'Setal de otoño'
        : _titleController.text.trim();
    final lat = double.tryParse(_latController.text.replaceAll(',', '.')) ??
        widget.initialLatLng.latitude;
    final lng = double.tryParse(_lngController.text.replaceAll(',', '.')) ??
        widget.initialLatLng.longitude;
    final qty = int.tryParse(_qtyController.text.trim()) ?? 1;
    final grams = int.tryParse(_weightController.text.trim());

    final spot = ForagingSpot(
      id: widget.existingSpot?.id ??
          'spot_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      latitude: lat,
      longitude: lng,
      mushroomId: _selectedMushroomId,
      mushroomName: _selectedMushroomName,
      notes: _notesController.text.trim(),
      foundAt: _selectedDate,
      photoPath: _photoPath,
      outingId: widget.existingSpot?.outingId ?? widget.activeOutingId,
      outingTitle:
          widget.existingSpot?.outingTitle ?? widget.activeOutingTitle,
      quantityCount: qty < 1 ? 1 : qty,
      weightGrams: grams,
    );

    Navigator.of(context).pop(spot);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 22),
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
            Text(
              widget.existingSpot != null
                  ? 'Editar Setal y Nota'
                  : 'Guardar Nueva Ubicación de Setas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AutumnColors.boletusBrown,
                  ),
            ),
            if (widget.activeOutingTitle != null) ...[
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AutumnColors.mossGreen.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Se vinculará a tu salida activa: ${widget.activeOutingTitle}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AutumnColors.mossGreen,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nombre del lugar / setal',
                hintText: 'Ej. Hayedo norte junto a la regata - Gorbeia',
                prefixIcon: Icon(Icons.place_rounded),
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _selectMushroomDialog,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Especie encontrada (Catálogo)',
                  prefixIcon: Icon(Icons.eco_rounded),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedMushroomName ??
                            'Pulsa para elegir una seta del catálogo',
                        style: TextStyle(
                          color: _selectedMushroomName != null
                              ? AutumnColors.textPrimary
                              : AutumnColors.textMuted,
                          fontWeight: _selectedMushroomName != null
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: AutumnColors.boletusBrown,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nº ejemplares',
                      prefixIcon: Icon(Icons.tag_rounded),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso aprox. (g)',
                      hintText: 'Opcional',
                      prefixIcon: Icon(Icons.scale_rounded),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nota descriptiva del hallazgo',
                hintText:
                    'Detalla orientación de la ladera, árboles cercanos, humedad, cantidad o referencias...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 42),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _latController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Latitud',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lngController,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Longitud',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2015),
                        lastDate: DateTime(2035),
                      );
                      if (pickedDate != null) {
                        setState(() => _selectedDate = pickedDate);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 17),
                    label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _pickPhoto(ImageSource.gallery),
                    icon: const Icon(Icons.add_a_photo_rounded, size: 17),
                    label: Text(
                      _photoPath != null ? 'Cambiar foto' : 'Adjuntar foto',
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Guardar Ubicación y Nota'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
