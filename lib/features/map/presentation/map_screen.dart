import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/gps_accuracy_service.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../../core/widgets/gps_acquisition_sheet.dart';
import '../../../core/widgets/gps_status_pill.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/mushroom_detail_screen.dart';
import '../../outings/data/outings_database.dart';
import '../../outings/models/foraging_outing.dart';
import '../../outings/presentation/map_spot_picker_screen.dart';
import '../data/spots_database.dart';
import '../models/foraging_spot.dart';
import '../services/offline_map_service.dart';
import 'offline_maps_sheet.dart';
import 'widgets/foraging_spot_marker.dart';
import 'widgets/map_crosshair_target.dart';

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
  MapLayerType _activeLayer = MapLayerType.topo;
  bool _showAllOutings = true;
  bool _showStandaloneSpots = true;
  final Set<String> _selectedOutingIds = <String>{};
  String? _selectedMushroomSpeciesFilter;
  String _edibilityFilter = 'all'; // 'all', 'edible', 'toxic'
  bool _isLocatingGps = false;
  double? _lastGpsAccuracy;
  ForagingSpot? _selectedSpot;
  LatLng? _currentUserLocation;

  bool _isPickingLocationForMushroom = false;
  Mushroom? _pendingMushroomToPlace;
  String? _pendingPhotoToPlace;
  bool _isPlacingSpotWithDiana = false;

  static const List<Color> _routePalette = [
    AutumnColors.terracotta,
    AutumnColors.mossGreen,
    AutumnColors.amberLeaf,
    AutumnColors.ochreGold,
    Color(0xFF8D5B4C), // Castaño
    Color(0xFFB85D19), // Caldera
    Color(0xFF2E6B55), // Pino
    Color(0xFF6B4226), // Roble
  ];

  Color _getRouteColor(int index) {
    return _routePalette[index % _routePalette.length];
  }

  static const LatLng _defaultBasqueCenter = LatLng(43.0150, -2.5200);

  LatLngBounds get currentViewportBounds => _mapController.camera.visibleBounds;
  bool get isUsingTopoLayer => _activeLayer == MapLayerType.topo;
  MapLayerType get activeLayer => _activeLayer;

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
        isTopoLayer: isUsingTopoLayer,
        activeLayer: _activeLayer,
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
      _showAllOutings = false;
      _showStandaloneSpots = false;
      _selectedOutingIds.add(widget.initialSelectedOutingFilter!);
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
        _showAllOutings = false;
        _showStandaloneSpots = false;
        _selectedOutingIds.clear();
        _selectedOutingIds.add(widget.initialSelectedOutingFilter!);
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
      setState(() {
        _isPickingLocationForMushroom = true;
        _pendingMushroomToPlace = pending;
        _pendingPhotoToPlace = initialPhoto;
      });
      if (_currentUserLocation != null) {
        _mapController.move(_currentUserLocation!, 13.5);
      }
    }
  }

  Future<void> _centerOnUserGps({bool openFormAfter = false}) async {
    final lang = ref.read(appLanguageProvider);
    final hasPerm = await GpsAccuracyService.ensureLocationPermission(context, lang: lang);
    if (!hasPerm) return;

    setState(() {
      _isLocatingGps = true;
      _lastGpsAccuracy = null;
    });

    try {
      final pos = await GpsAccuracyService.acquireAccurateFix(
        maxAcceptableMeters: 25.0,
        timeout: const Duration(seconds: 10),
      );

      if (pos != null) {
        final target = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentUserLocation = target;
          _lastGpsAccuracy = pos.accuracy;
        });
        _mapController.move(target, 15.5);

        if (openFormAfter && mounted) {
          await _openAddOrEditSpotSheet(context, initialLatLng: target);
        }
      } else {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          final target = LatLng(lastKnown.latitude, lastKnown.longitude);
          setState(() {
            _currentUserLocation = target;
            _lastGpsAccuracy = lastKnown.accuracy;
          });
          _mapController.move(target, 15.0);
          if (openFormAfter && mounted) {
            await _openAddOrEditSpotSheet(context, initialLatLng: target);
          }
        }
      }
    } catch (_) {
      if (mounted) {
        final fallback = _mapController.camera.center;
        if (openFormAfter) {
          await _openAddOrEditSpotSheet(context, initialLatLng: fallback);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLocatingGps = false);
      }
    }
  }

  Future<void> _showSaveSpotLocationChoiceSheet(BuildContext context) async {
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);

    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: AutumnColors.parchmentBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AutumnColors.warmSand,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              s.tr(
                eu: 'Nola kokatu nahi duzu setala?',
                es: '¿Cómo deseas ubicar el setal?',
                en: 'How do you want to place the spot?',
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AutumnColors.boletusBrown,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AutumnColors.warmSand),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AutumnColors.mossGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.my_location_rounded,
                    color: AutumnColors.mossGreen,
                    size: 24,
                  ),
                ),
                title: Text(
                  s.tr(
                    eu: 'Nire uneko GPS kokapenean',
                    es: 'En mi ubicación GPS actual',
                    en: 'At my current GPS location',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AutumnColors.boletusBrown,
                  ),
                ),
                subtitle: Text(
                  s.tr(
                    eu: 'Satelite bidezko doitasun zehatza egiaztatzen du',
                    es: 'Garantiza precisión satelital antes de guardar',
                    en: 'Locks precise satellite accuracy before saving',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AutumnColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AutumnColors.textSecondary),
                onTap: () => Navigator.of(ctx).pop('gps'),
              ),
            ),
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AutumnColors.warmSand),
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AutumnColors.terracotta.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: AutumnColors.terracotta,
                    size: 24,
                  ),
                ),
                title: Text(
                  s.tr(
                    eu: 'Mapan hatzarekin seinalatu (diana)',
                    es: 'Marcar con el dedo en el mapa (con diana)',
                    en: 'Mark on map with finger (crosshair)',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AutumnColors.boletusBrown,
                  ),
                ),
                subtitle: Text(
                  s.tr(
                    eu: 'Ukitu pantailan hatzarekin edo doitu diana interaktiboarekin',
                    es: 'Toca con el dedo en el mapa o ajusta la posición con la diana',
                    en: 'Tap on the map with finger or adjust with crosshair',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AutumnColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AutumnColors.textSecondary),
                onTap: () => Navigator.of(ctx).pop('finger_diana'),
              ),
            ),
          ],
        ),
      ),
    );

    if (choice == 'gps') {
      if (!context.mounted) return;
      final hasPerm = await GpsAccuracyService.ensureLocationPermission(
        context,
        lang: lang,
      );
      if (!hasPerm) return;

      if (!context.mounted) return;
      final accuratePoint = await GpsAcquisitionSheet.show(
        context,
        title: s.tr(
          eu: 'Setal Berria Gorde',
          es: 'Guardar Nuevo Setal',
          en: 'Save New Mushroom Spot',
        ),
        subtitle: s.tr(
          eu: 'Doitasun handiko GPS seinalea bilatzen',
          es: 'Buscando señal GPS de alta precisión',
          en: 'Locking high-accuracy GPS fix',
        ),
        confirmButtonLabel: s.tr(
          eu: 'Finkatu koordenatuak',
          es: 'Fijar coordenadas',
          en: 'Lock coordinates',
        ),
        lang: lang,
      );

      if (accuratePoint != null && context.mounted) {
        _mapController.move(
          accuratePoint,
          _mapController.camera.zoom < 14 ? 14.5 : _mapController.camera.zoom,
        );
        _openAddOrEditSpotSheet(context, initialLatLng: accuratePoint);
      }
    } else if (choice == 'map' || choice == 'finger_diana') {
      setState(() {
        _isPlacingSpotWithDiana = true;
        _selectedSpot = null;
      });
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
        lang: ref.read(appLanguageProvider),
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

  void _openMapFilterSheet(
    List<ForagingSpot> allSpots,
    List<ForagingOuting> allOutings,
    List<Mushroom> allMushrooms,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MapFilterAndRoutesSheet(
        allSpots: allSpots,
        allOutings: allOutings,
        allMushrooms: allMushrooms,
        initialSpeciesFilter: _selectedMushroomSpeciesFilter,
        initialEdibilityFilter: _edibilityFilter,
        initialShowAllOutings: _showAllOutings,
        initialShowStandaloneSpots: _showStandaloneSpots,
        initialSelectedOutingIds: _selectedOutingIds,
        routePalette: _routePalette,
        lang: ref.read(appLanguageProvider),
        onApply: ({
          String? speciesFilter,
          required String edibilityFilter,
          required bool showAllOutings,
          required bool showStandaloneSpots,
          required Set<String> selectedOutingIds,
        }) {
          setState(() {
            _selectedMushroomSpeciesFilter = speciesFilter;
            _edibilityFilter = edibilityFilter;
            _showAllOutings = showAllOutings;
            _showStandaloneSpots = showStandaloneSpots;
            _selectedOutingIds.clear();
            _selectedOutingIds.addAll(selectedOutingIds);
          });
          if (!showAllOutings && selectedOutingIds.length == 1) {
            _centerOnOutingFilter(selectedOutingIds.first);
          }
        },
      ),
    );
  }

  void _openSavedSpotsListSheet(List<ForagingSpot> spots) {
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);
    final allMushrooms =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
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
                      s.tr(
                        eu: 'Gordetako Lekuak (${spots.length})',
                        es: 'Ubicaciones Guardadas (${spots.length})',
                        en: 'Saved Locations (${spots.length})',
                      ),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AutumnColors.boletusBrown,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (spots.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        s.tr(
                          eu: 'Ez dago punturik hautatutako iragazkiarekin.',
                          es: 'No hay puntos para el filtro seleccionado.',
                          en: 'No spots match the selected filter.',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AutumnColors.textSecondary),
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
                          leading: ForagingSpotMarkerWidget(
                            spot: spot,
                            allMushrooms: allMushrooms,
                            size: 36,
                          ),
                          title: Text(
                            '${spot.title} (${spot.quantityCount})',
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
                                    ? s.tr(
                                        eu: 'Irteera: ${spot.outingTitle ?? "GPS ibilbidea"}',
                                        es: 'Salida: ${spot.outingTitle ?? "Ruta GPS"}',
                                        en: 'Outing: ${spot.outingTitle ?? "GPS route"}',
                                      )
                                    : s.tr(
                                        eu: 'Mapa Globaleko leku bakartua',
                                        es: 'Punto suelto del Mapa Global',
                                        en: 'Standalone Global Map spot',
                                      ),
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
      if (!s.isFromOuting) {
        if (!_showStandaloneSpots) return false;
      } else {
        if (!_showAllOutings && !_selectedOutingIds.contains(s.outingId)) {
          return false;
        }
      }
      if (_selectedMushroomSpeciesFilter != null &&
          s.mushroomId != _selectedMushroomSpeciesFilter) {
        return false;
      }
      if (_edibilityFilter != 'all' && s.mushroomId != null) {
        final m = allMushrooms.where((sp) => sp.id == s.mushroomId).firstOrNull;
        if (m != null) {
          if (_edibilityFilter == 'edible' && !m.isEdible) return false;
          if (_edibilityFilter == 'toxic' && !m.isToxic) return false;
        }
      }
      return true;
    }).toList();

    // Filtrar las polilíneas de las rutas GPS a mostrar
    final visibleOutingRoutes = allOutings.where((o) {
      if (o.routePoints.length < 2) return false;
      if (_showAllOutings) return true;
      return _selectedOutingIds.contains(o.id);
    }).toList();

    int activeFilterCount = 0;
    if (!_showAllOutings || !_showStandaloneSpots || _selectedOutingIds.isNotEmpty) {
      activeFilterCount++;
    }
    if (_selectedMushroomSpeciesFilter != null) activeFilterCount++;
    if (_edibilityFilter != 'all') activeFilterCount++;

    return Scaffold(
      body: PopScope(
        canPop: !_isPlacingSpotWithDiana && !_isPickingLocationForMushroom,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (_isPlacingSpotWithDiana) {
            setState(() => _isPlacingSpotWithDiana = false);
          } else if (_isPickingLocationForMushroom) {
            setState(() {
              _isPickingLocationForMushroom = false;
              _pendingMushroomToPlace = null;
              _pendingPhotoToPlace = null;
            });
          }
        },
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultBasqueCenter,
                initialZoom: 9.8,
                minZoom: 4.0,
                maxZoom: 17.5,
                onTap: (_, latLng) {
                  if (_isPlacingSpotWithDiana) {
                    _mapController.move(
                      latLng,
                      _mapController.camera.zoom < 14.5
                          ? 15.0
                          : _mapController.camera.zoom,
                    );
                    HapticFeedback.selectionClick();
                    return;
                  }
                  if (_isPickingLocationForMushroom &&
                      _pendingMushroomToPlace != null) {
                    final mushroom = _pendingMushroomToPlace!;
                    final photo = _pendingPhotoToPlace;
                    setState(() {
                      _isPickingLocationForMushroom = false;
                      _pendingMushroomToPlace = null;
                      _pendingPhotoToPlace = null;
                    });
                    _openAddOrEditSpotSheet(
                      context,
                      initialLatLng: latLng,
                      preselectedMushroom: mushroom,
                      preselectedPhotoPath: photo,
                    );
                    return;
                  }
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
                urlTemplate: _activeLayer.urlTemplate,
                userAgentPackageName: 'com.zizai.zizai',
                maxNativeZoom: _activeLayer.maxZoom,
                tileProvider:
                    widget.customTileProvider ?? _defaultOfflineTileProvider,
              ),
              // Capa de polilíneas de las rutas GPS de las Salidas con paleta cromática otoñal
              if (visibleOutingRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: visibleOutingRoutes.map((outing) {
                    final idx = allOutings.indexOf(outing);
                    final routeColor = _getRouteColor(idx >= 0 ? idx : 0);
                    final isHighlighted = !_showAllOutings &&
                        _selectedOutingIds.length == 1 &&
                        _selectedOutingIds.first == outing.id;
                    return Polyline(
                      points: outing.routePoints,
                      color: isHighlighted
                          ? AutumnColors.terracotta
                          : routeColor.withValues(alpha: 0.88),
                      strokeWidth: isHighlighted ? 5.2 : 3.8,
                    );
                  }).toList(),
                ),
              if (_currentUserLocation != null)
                MarkerLayer(
                  rotate: true,
                  markers: [
                    Marker(
                      point: _currentUserLocation!,
                      width: 28,
                      height: 28,
                      rotate: true,
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
              // Marcadores con color según calidad/comestibilidad y cantidad recolectada
              MarkerLayer(
                rotate: true,
                markers: visibleSpots.map((spot) {
                  final isSelected = _selectedSpot?.id == spot.id;

                  return Marker(
                    point: LatLng(spot.latitude, spot.longitude),
                    width: isSelected ? 50 : 40,
                    height: isSelected ? 50 : 40,
                    rotate: true,
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
                        child: ForagingSpotMarkerWidget(
                          spot: spot,
                          allMushrooms: allMushrooms,
                          isSelected: isSelected,
                          size: isSelected ? 48 : 38,
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
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        decoration: BoxDecoration(
                          color: AutumnColors.barkDark.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                AutumnColors.amberLeaf.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                      es: 'Mapa de Setales',
                                      en: 'Foraging Map',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _HeaderPillButton(
                                  icon: Icons.eco_rounded,
                                  label: '${visibleSpots.length}',
                                  active: false,
                                  onTap: () =>
                                      _openSavedSpotsListSheet(visibleSpots),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 32,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  _HeaderFilterButton(
                                    activeCount: activeFilterCount,
                                    label: activeFilterCount > 0
                                        ? s.tr(
                                            eu: 'Filtroak eta Ibilbideak ($activeFilterCount)',
                                            es: 'Filtros y Rutas ($activeFilterCount)',
                                            en: 'Filters & Routes ($activeFilterCount)',
                                          )
                                        : s.tr(
                                            eu: 'Filtroak eta Ibilbideak',
                                            es: 'Filtros y Rutas',
                                            en: 'Filters & Routes',
                                          ),
                                    onTap: () => _openMapFilterSheet(
                                      allSpots,
                                      allOutings,
                                      allMushrooms,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _HeaderPillButton(
                                    icon: switch (_activeLayer) {
                                      MapLayerType.topo =>
                                        Icons.terrain_rounded,
                                      MapLayerType.satellite =>
                                        Icons.satellite_alt_rounded,
                                      MapLayerType.streets =>
                                        Icons.map_outlined,
                                    },
                                    label: switch (_activeLayer) {
                                      MapLayerType.topo => 'Topo',
                                      MapLayerType.satellite => s.tr(
                                          eu: 'Satelitea',
                                          es: 'Satélite',
                                          en: 'Satellite'),
                                      MapLayerType.streets => s.tr(
                                          eu: 'Kalea',
                                          es: 'Calle',
                                          en: 'Street'),
                                    },
                                    active: _activeLayer != MapLayerType.streets,
                                    onTap: () {
                                      setState(() {
                                        _activeLayer = switch (_activeLayer) {
                                          MapLayerType.topo =>
                                            MapLayerType.satellite,
                                          MapLayerType.satellite =>
                                            MapLayerType.streets,
                                          MapLayerType.streets =>
                                            MapLayerType.topo,
                                        };
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _HeaderPillButton(
                                    icon: Icons.download_for_offline_rounded,
                                    label: 'Offline',
                                    active: false,
                                    onTap: _openOfflineMapsModal,
                                  ),
                                  if (activeFilterCount > 0) ...[
                                    const SizedBox(width: 8),
                                    if (_selectedMushroomSpeciesFilter != null) ...[
                                      () {
                                        final m = allMushrooms
                                            .where((sp) =>
                                                sp.id ==
                                                _selectedMushroomSpeciesFilter)
                                            .firstOrNull;
                                        final label = m != null
                                            ? m.scientificName
                                            : s.tr(eu: 'Perretxikoa', es: 'Seta', en: 'Mushroom');
                                        return _ActiveFilterTag(
                                          icon: Icons.eco_rounded,
                                          label: label,
                                          onRemove: () => setState(() =>
                                              _selectedMushroomSpeciesFilter =
                                                  null),
                                        );
                                      }(),
                                    ],
                                    if (_edibilityFilter == 'edible')
                                      _ActiveFilterTag(
                                        icon: Icons.restaurant_rounded,
                                        label: s.tr(
                                            eu: 'Jangarriak',
                                            es: 'Comestibles',
                                            en: 'Edible'),
                                        onRemove: () => setState(
                                            () => _edibilityFilter = 'all'),
                                      ),
                                    if (_edibilityFilter == 'toxic')
                                      _ActiveFilterTag(
                                        icon: Icons.warning_rounded,
                                        label: s.tr(
                                            eu: 'Toxikoak',
                                            es: 'Tóxicas',
                                            en: 'Toxic'),
                                        onRemove: () => setState(
                                            () => _edibilityFilter = 'all'),
                                      ),
                                    if (!_showStandaloneSpots)
                                      _ActiveFilterTag(
                                        icon: Icons.place_rounded,
                                        label: s.tr(
                                            eu: 'Puntu solteak OFF',
                                            es: 'Puntos libres OFF',
                                            en: 'Standalone OFF'),
                                        onRemove: () => setState(
                                            () => _showStandaloneSpots = true),
                                      ),
                                    if (!_showAllOutings) ...[
                                      () {
                                        if (_selectedOutingIds.isEmpty) {
                                          return _ActiveFilterTag(
                                            icon: Icons.hiking_rounded,
                                            label: s.tr(
                                                eu: 'Irteerak OFF',
                                                es: 'Salidas OFF',
                                                en: 'Outings OFF'),
                                            onRemove: () => setState(
                                                () => _showAllOutings = true),
                                          );
                                        }
                                        if (_selectedOutingIds.length == 1) {
                                          final out = allOutings
                                              .where((o) =>
                                                  o.id ==
                                                  _selectedOutingIds.first)
                                              .firstOrNull;
                                          return _ActiveFilterTag(
                                            icon: Icons.hiking_rounded,
                                            label: out != null
                                                ? out.title
                                                : s.tr(
                                                    eu: 'Irteera',
                                                    es: 'Salida',
                                                    en: 'Outing'),
                                            onRemove: () => setState(
                                                () => _showAllOutings = true),
                                          );
                                        }
                                        return _ActiveFilterTag(
                                          icon: Icons.hiking_rounded,
                                          label: s.tr(
                                            eu: '${_selectedOutingIds.length} irteera',
                                            es: '${_selectedOutingIds.length} salidas',
                                            en: '${_selectedOutingIds.length} outings',
                                          ),
                                          onRemove: () => setState(
                                              () => _showAllOutings = true),
                                        );
                                      }(),
                                    ],
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: InkWell(
                                        onTap: () => setState(() {
                                          _showAllOutings = true;
                                          _showStandaloneSpots = true;
                                          _selectedOutingIds.clear();
                                          _selectedMushroomSpeciesFilter = null;
                                          _edibilityFilter = 'all';
                                        }),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent
                                                .withValues(alpha: 0.22),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                  Icons.clear_all_rounded,
                                                  size: 14,
                                                  color: Colors.white),
                                              const SizedBox(width: 4),
                                              Text(
                                                s.tr(
                                                    eu: 'Garbitu',
                                                    es: 'Limpiar',
                                                    en: 'Clear'),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

          // Píldora no invasiva de precisión GPS al centrar o fijar ubicación
          if (_isLocatingGps)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              child: Center(
                child: GpsStatusPill(
                  accuracyMeters: _lastGpsAccuracy,
                  isLoading: true,
                  onCancel: () => setState(() => _isLocatingGps = false),
                ),
              ),
            ),

          // Banner interactivo si se viene del catálogo a ubicar una seta
          if (_isPickingLocationForMushroom && _pendingMushroomToPlace != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 76,
              left: 14,
              right: 14,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AutumnColors.ochreGold.withValues(alpha: 0.95),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                s.tr(
                                  eu: 'Ukitu mapan perretxikoa kokatzeko',
                                  es: 'Toca en el mapa para ubicar la seta',
                                  en: 'Tap on the map to place the mushroom',
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${_pendingMushroomToPlace!.scientificName} (${_pendingMushroomToPlace!.displayNameFor(s.lang)})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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
                          onPressed: () {
                            setState(() {
                              _isPickingLocationForMushroom = false;
                              _pendingMushroomToPlace = null;
                              _pendingPhotoToPlace = null;
                            });
                          },
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

          // Diana de alta precisión en el centro del mapa
          if (_isPlacingSpotWithDiana || _isPickingLocationForMushroom)
            const MapCrosshairTarget(),

          // Banner interactivo si se ubica con diana / tocar con el dedo
          if (_isPlacingSpotWithDiana)
            Positioned(
              top: MediaQuery.of(context).padding.top + 104,
              left: 14,
              right: 14,
              child: _DianaPlacementBanner(
                lang: lang,
                onCancel: () => setState(() => _isPlacingSpotWithDiana = false),
              ),
            ),

          // Barra flotante inferior de confirmación de diana
          if (_isPlacingSpotWithDiana)
            Positioned(
              left: 16,
              right: 16,
              bottom: 104,
              child: _DianaPlacementBottomBar(
                lang: lang,
                isLocatingGps: _isLocatingGps,
                onCenterGps: () => _centerOnUserGps(openFormAfter: false),
                onConfirm: () {
                  final center = _mapController.camera.center;
                  setState(() => _isPlacingSpotWithDiana = false);
                  _openAddOrEditSpotSheet(context, initialLatLng: center);
                },
              ),
            ),

          if (!_isPlacingSpotWithDiana && !_isPickingLocationForMushroom)
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
                    key: const ValueKey('btn_add_spot'),
                    heroTag: 'btn_add_spot',
                    backgroundColor: AutumnColors.boletusBrown,
                    foregroundColor: Colors.white,
                    onPressed: () => _showSaveSpotLocationChoiceSheet(context),
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

          if (_selectedSpot != null &&
              !_isPlacingSpotWithDiana &&
              !_isPickingLocationForMushroom)
            Positioned(
              left: 16,
              right: 16,
              bottom: 104,
              child: _SelectedSpotCard(
                spot: _selectedSpot!,
                lang: lang,
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

class _HeaderFilterButton extends StatelessWidget {
  final int activeCount;
  final String label;
  final VoidCallback onTap;

  const _HeaderFilterButton({
    required this.activeCount,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = activeCount > 0;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? AutumnColors.amberLeaf.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AutumnColors.amberLeaf
                : Colors.white24,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              color: active ? AutumnColors.amberLeaf : Colors.white,
              size: 15,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? AutumnColors.amberLeaf : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedSpotCard extends StatelessWidget {
  final ForagingSpot spot;
  final Mushroom? linkedMushroom;
  final AppLanguage lang;
  final VoidCallback onClose;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SelectedSpotCard({
    required this.spot,
    required this.linkedMushroom,
    required this.lang,
    required this.onClose,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
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
                                ? '${s.tr(eu: 'IRTEERA', es: 'SALIDA', en: 'OUTING')}: ${spot.outingTitle ?? ''}'
                                : s.tr(eu: 'PUNTU SOLTEA', es: 'PUNTO LIBRE', en: 'STANDALONE'),
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
                          '${spot.quantityCount} ${s.tr(eu: "ale", es: "ej.", en: "spec.")}${spot.weightGrams != null ? " (${spot.weightGrams}g)" : ""}',
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
                label: Text(s.tr(eu: 'Ezabatu', es: 'Eliminar', en: 'Delete')),
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
                label: Text(s.tr(eu: 'Editatu', es: 'Editar', en: 'Edit')),
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
  final AppLanguage lang;

  const _SpotFormBottomSheet({
    required this.initialLatLng,
    this.existingSpot,
    this.preselectedMushroom,
    this.preselectedPhotoPath,
    this.activeOutingId,
    this.activeOutingTitle,
    required this.catalogMushrooms,
    required this.lang,
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
  bool _isLoadingGps = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingSpot;
    final pre = widget.preselectedMushroom;
    final defaultTitle = pre != null
        ? (widget.lang == AppLanguage.eu
            ? '${pre.scientificName} lekua'
            : (widget.lang == AppLanguage.es
                ? 'Setal de ${pre.scientificName}'
                : 'Spot of ${pre.scientificName}'))
        : '';

    _titleController = TextEditingController(
      text: existing?.title ?? defaultTitle,
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
        pre?.latinWithCommon(widget.lang);
    _photoPath = existing?.photoPath ?? widget.preselectedPhotoPath;
  }

  void _onCoordinateChanged(String val, bool isLatitude) {
    final trimmed = val.trim();
    if (trimmed.contains(',') ||
        trimmed.contains(';') ||
        (trimmed.contains(' ') &&
            trimmed.split(RegExp(r'\s+')).length >= 2)) {
      final parts = trimmed.split(RegExp(r'[,;\s]+'));
      if (parts.length >= 2) {
        final parsedLat = double.tryParse(parts[0].replaceAll(',', '.'));
        final parsedLng = double.tryParse(parts[1].replaceAll(',', '.'));
        if (parsedLat != null && parsedLng != null) {
          setState(() {
            _latController.text = parsedLat.toStringAsFixed(5);
            _lngController.text = parsedLng.toStringAsFixed(5);
          });
        }
      }
    }
  }

  Future<void> _fillCurrentGpsLocation() async {
    final lang = widget.lang;
    final hasPerm = await GpsAccuracyService.ensureLocationPermission(
      context,
      lang: lang,
    );
    if (!hasPerm) return;

    if (!mounted) return;
    final s = AppStrings(lang);
    final pos = await GpsAcquisitionSheet.show(
      context,
      title: s.tr(
        eu: 'Setalaren koordenatuak zehaztu',
        es: 'Fijar coordenadas del setal',
        en: 'Lock mushroom spot coordinates',
      ),
      subtitle: s.tr(
        eu: 'Doitasun handiko GPS seinalea bilatzen',
        es: 'Buscando señal GPS de alta precisión',
        en: 'Locking high-accuracy GPS fix',
      ),
      confirmButtonLabel: s.tr(
        eu: 'Finkatu koordenatuak',
        es: 'Fijar coordenadas',
        en: 'Lock coordinates',
      ),
      lang: lang,
    );

    if (pos != null && mounted) {
      setState(() {
        _latController.text = pos.latitude.toStringAsFixed(5);
        _lngController.text = pos.longitude.toStringAsFixed(5);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AutumnColors.mossGreen,
          duration: const Duration(seconds: 2),
          content: Text(
            s.tr(
              eu: 'GPS koordenatuak zehaztasunez hartuta',
              es: 'Coordenadas GPS fijadas con precisión',
              en: 'GPS coordinates locked with accuracy',
            ),
          ),
        ),
      );
    }
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
    final s = AppStrings(widget.lang);
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
          SnackBar(
            content: Text(
              s.tr(
                eu: 'Ezin izan da irudia erantsi: $e',
                es: 'No se pudo adjuntar la imagen: $e',
                en: 'Could not attach image: $e',
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _selectMushroomDialog() async {
    final s = AppStrings(widget.lang);
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
              return m.scientificName.toLowerCase().contains(q) ||
                  m.spanishName.toLowerCase().contains(q) ||
                  m.basqueName.toLowerCase().contains(q) ||
                  m.commonNameEn.toLowerCase().contains(q);
            }).toList()
              ..sort((a, b) => a.scientificName
                  .toLowerCase()
                  .compareTo(b.scientificName.toLowerCase()));

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
                        s.tr(
                          eu: 'Lotu Katalogoko Perretxikoa',
                          es: 'Asociar Seta del Catálogo',
                          en: 'Link Catalog Mushroom',
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AutumnColors.boletusBrown,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        autofocus: true,
                        onChanged: (v) => setModalState(() => filterQuery = v),
                        decoration: InputDecoration(
                          hintText: s.tr(
                            eu: 'Bilatu izen zientifikoz, euskaraz edo gaztelaniaz...',
                            es: 'Buscar por nombre científico, euskera o castellano...',
                            en: 'Search by scientific, Basque or Spanish name...',
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (context, idx) {
                            final m = list[idx];
                            final primaryTitle = m.scientificName;
                            final commonName = m.displayNameFor(widget.lang);
                            final otherName = widget.lang == AppLanguage.eu
                                ? m.spanishName
                                : m.basqueName;
                            final secondaryTitle = '$commonName ($otherName)';
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
                                primaryTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              subtitle: Text(
                                secondaryTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AutumnColors.mossGreen,
                                ),
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
        _selectedMushroomName = chosen.latinWithCommon(widget.lang);
        if (_titleController.text.trim().isEmpty) {
          _titleController.text = widget.lang == AppLanguage.eu
              ? '${chosen.scientificName} lekua'
              : (widget.lang == AppLanguage.es
                  ? 'Setal de ${chosen.scientificName}'
                  : 'Spot of ${chosen.scientificName}');
        }
      });
    }
  }

  void _submit() {
    final s = AppStrings(widget.lang);
    final fallbackTitle = s.tr(
      eu: 'Udazkeneko perretxiko-lekua',
      es: 'Setal de otoño',
      en: 'Autumn foraging spot',
    );
    final title = _titleController.text.trim().isEmpty
        ? fallbackTitle
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
    final s = AppStrings(widget.lang);
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
                  ? s.tr(
                      eu: 'Editatu Lekua eta Oharra',
                      es: 'Editar Setal y Nota',
                      en: 'Edit Spot & Notes',
                    )
                  : s.tr(
                      eu: 'Gorde Perretxiko Leku Berria',
                      es: 'Guardar Nueva Ubicación de Setas',
                      en: 'Save New Mushroom Spot',
                    ),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AutumnColors.boletusBrown,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 13,
                  color: AutumnColors.mossGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  s.spotFormPrivacyNotice,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AutumnColors.mossGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
                  s.tr(
                    eu: 'Zure irteera aktiboari lotuko zaio: ${widget.activeOutingTitle}',
                    es: 'Se vinculará a tu salida activa: ${widget.activeOutingTitle}',
                    en: 'Will be linked to your active outing: ${widget.activeOutingTitle}',
                  ),
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
              decoration: InputDecoration(
                labelText: s.tr(
                  eu: 'Perretxiko-lekuaren izena',
                  es: 'Nombre del setal',
                  en: 'Spot name',
                ),
                hintText: s.tr(
                  eu: 'Adib. Iparraldeko pagadia errekaren ondoan',
                  es: 'Ej. Hayedo norte junto a la regata',
                  en: 'E.g. Northern beechwood near stream',
                ),
                prefixIcon: const Icon(Icons.place_rounded),
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _selectMushroomDialog,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: s.tr(
                    eu: 'Aurkitutako espeziea (Katalogoa)',
                    es: 'Especie encontrada (Catálogo)',
                    en: 'Found species (Catalog)',
                  ),
                  prefixIcon: const Icon(Icons.eco_rounded),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedMushroomName ??
                            s.tr(
                              eu: 'Ukitu katalogoko perretxiko bat hautatzeko',
                              es: 'Pulsa para elegir una seta del catálogo',
                              en: 'Tap to choose a mushroom from catalog',
                            ),
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
                    decoration: InputDecoration(
                      labelText: s.tr(
                        eu: 'Ale kopurua',
                        es: 'Nº ejemplares',
                        en: 'Specimen count',
                      ),
                      prefixIcon: const Icon(Icons.tag_rounded),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: s.tr(
                        eu: 'Gutxi gorabeherako pisua (g)',
                        es: 'Peso aprox. (g)',
                        en: 'Approx. weight (g)',
                      ),
                      hintText: s.tr(
                        eu: 'Aukerakoa',
                        es: 'Opcional',
                        en: 'Optional',
                      ),
                      prefixIcon: const Icon(Icons.scale_rounded),
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
              decoration: InputDecoration(
                labelText: s.tr(
                  eu: 'Aurkikuntzaren ohar deskribatzailea',
                  es: 'Nota descriptiva del hallazgo',
                  en: 'Descriptive note of the find',
                ),
                hintText: s.tr(
                  eu: 'Zehaztu magalaren orientazioa, inguruko zuhaitzak, hezetasuna edo erreferentziak...',
                  es: 'Detalla orientación de la ladera, árboles cercanos, humedad, cantidad o referencias...',
                  en: 'Detail slope orientation, nearby trees, moisture, quantity or landmarks...',
                ),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 42),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // SECCIÓN: COORDENADAS GEOESPACIALES (MANUAL / GPS / MAPA)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AutumnColors.warmSand,
                  width: 1.2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.pin_drop_rounded,
                        color: AutumnColors.terracotta,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.tr(
                            eu: 'Koordenatu Geoespazialak (GPS / Eskuz)',
                            es: 'Coordenadas Geoespaciales (GPS / Manual)',
                            en: 'Geospatial Coordinates (GPS / Manual)',
                          ),
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AutumnColors.boletusBrown,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          onChanged: (v) => _onCoordinateChanged(v, true),
                          decoration: InputDecoration(
                            labelText: s.tr(
                              eu: 'Latitudea',
                              es: 'Latitud',
                              en: 'Latitude',
                            ),
                            prefixIcon: const Icon(Icons.north_rounded, size: 16),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _lngController,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                            decimal: true,
                          ),
                          onChanged: (v) => _onCoordinateChanged(v, false),
                          decoration: InputDecoration(
                            labelText: s.tr(
                              eu: 'Longitudea',
                              es: 'Longitud',
                              en: 'Longitude',
                            ),
                            prefixIcon: const Icon(Icons.east_rounded, size: 16),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AutumnColors.terracotta,
                            side: const BorderSide(
                              color: AutumnColors.terracotta,
                              width: 1.1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            final currentLat = double.tryParse(
                                    _latController.text.replaceAll(',', '.')) ??
                                widget.initialLatLng.latitude;
                            final currentLng = double.tryParse(
                                    _lngController.text.replaceAll(',', '.')) ??
                                widget.initialLatLng.longitude;
                            final picked =
                                await Navigator.of(context).push<LatLng>(
                              MaterialPageRoute(
                                builder: (_) => MapSpotPickerScreen(
                                  outingId: widget.activeOutingId ?? '',
                                  outingTitle: widget.activeOutingTitle ??
                                      s.tr(
                                        eu: 'Perretxiko-lekua',
                                        es: 'Setal',
                                        en: 'Spot',
                                      ),
                                  initialCenter: LatLng(currentLat, currentLng),
                                  pickCoordinatesOnly: true,
                                ),
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _latController.text =
                                    picked.latitude.toStringAsFixed(5);
                                _lngController.text =
                                    picked.longitude.toStringAsFixed(5);
                              });
                            }
                          },
                          icon: const Icon(Icons.edit_location_alt_rounded,
                              size: 15),
                          label: Text(
                            s.tr(
                              eu: 'Mapan Kokatu',
                              es: 'Ajustar en Mapa',
                              en: 'Adjust on Map',
                            ),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AutumnColors.mossGreen,
                            side: const BorderSide(
                              color: AutumnColors.mossGreen,
                              width: 1.1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 7,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed:
                              _isLoadingGps ? null : _fillCurrentGpsLocation,
                          icon: _isLoadingGps
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location_rounded, size: 15),
                          label: Text(
                            s.tr(
                              eu: 'Uneko GPSa',
                              es: 'GPS Actual',
                              en: 'Current GPS',
                            ),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
                      _photoPath != null
                          ? s.tr(eu: 'Argazkia aldatu', es: 'Cambiar foto', en: 'Change photo')
                          : s.tr(eu: 'Argazkia erantsi', es: 'Adjuntar foto', en: 'Attach photo'),
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
                label: Text(
                  s.tr(
                    eu: 'Gorde Lekua eta Oharra',
                    es: 'Guardar Ubicación y Nota',
                    en: 'Save Spot and Note',
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

class _ActiveFilterTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterTag({
    required this.icon,
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: BoxDecoration(
        color: AutumnColors.amberLeaf.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AutumnColors.barkDark),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AutumnColors.barkDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.close_rounded,
                  size: 14, color: AutumnColors.barkDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFilterAndRoutesSheet extends StatefulWidget {
  final List<ForagingSpot> allSpots;
  final List<ForagingOuting> allOutings;
  final List<Mushroom> allMushrooms;
  final String? initialSpeciesFilter;
  final String initialEdibilityFilter;
  final bool initialShowAllOutings;
  final bool initialShowStandaloneSpots;
  final Set<String> initialSelectedOutingIds;
  final List<Color> routePalette;
  final AppLanguage lang;
  final void Function({
    String? speciesFilter,
    required String edibilityFilter,
    required bool showAllOutings,
    required bool showStandaloneSpots,
    required Set<String> selectedOutingIds,
  }) onApply;

  const _MapFilterAndRoutesSheet({
    required this.allSpots,
    required this.allOutings,
    required this.allMushrooms,
    required this.initialSpeciesFilter,
    required this.initialEdibilityFilter,
    required this.initialShowAllOutings,
    required this.initialShowStandaloneSpots,
    required this.initialSelectedOutingIds,
    required this.routePalette,
    required this.lang,
    required this.onApply,
  });

  @override
  State<_MapFilterAndRoutesSheet> createState() =>
      _MapFilterAndRoutesSheetState();
}

class _MapFilterAndRoutesSheetState extends State<_MapFilterAndRoutesSheet> {
  late String? _speciesFilter;
  late String _edibilityFilter;
  late bool _showAllOutings;
  late bool _showStandaloneSpots;
  late Set<String> _selectedOutingIds;

  @override
  void initState() {
    super.initState();
    _speciesFilter = widget.initialSpeciesFilter;
    _edibilityFilter = widget.initialEdibilityFilter;
    _showAllOutings = widget.initialShowAllOutings;
    _showStandaloneSpots = widget.initialShowStandaloneSpots;
    _selectedOutingIds =
        Set<String>.from(widget.initialSelectedOutingIds);
  }

  void _pickSpeciesDialog() async {
    final s = AppStrings(widget.lang);
    String searchQuery = '';
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
            final q = searchQuery.trim().toLowerCase();
            final list = widget.allMushrooms.where((m) {
              if (q.isEmpty) return true;
              return m.scientificName.toLowerCase().contains(q) ||
                  m.spanishName.toLowerCase().contains(q) ||
                  m.basqueName.toLowerCase().contains(q) ||
                  m.commonNameEn.toLowerCase().contains(q);
            }).toList()
              ..sort((a, b) => a.scientificName
                  .toLowerCase()
                  .compareTo(b.scientificName.toLowerCase()));

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
                      Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AutumnColors.boletusBrown),
                          const SizedBox(width: 8),
                          Text(
                            s.tr(
                              eu: 'Espeziaren arabera iragazi',
                              es: 'Filtrar por Especie',
                              en: 'Filter by Species',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AutumnColors.boletusBrown,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: s.tr(
                            eu: 'Bilatu izen zientifikoz, euskaraz edo gaztelaniaz...',
                            es: 'Buscar por nombre científico, euskera o castellano...',
                            en: 'Search by scientific, Basque or Spanish name...',
                          ),
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (v) => setModalState(() => searchQuery = v),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (ctx, i) {
                            final m = list[i];
                            final primaryTitle = m.scientificName;
                            final commonName = m.displayNameFor(widget.lang);
                            final otherName = widget.lang == AppLanguage.eu
                                ? m.spanishName
                                : m.basqueName;
                            final secondaryTitle = '$commonName ($otherName)';
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
                                primaryTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              subtitle: Text(
                                secondaryTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AutumnColors.mossGreen,
                                ),
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
        _speciesFilter = chosen.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;
    final sheetHeight = screenHeight * 0.52;
    final chosenMushroom = widget.allMushrooms
        .where((m) => m.id == _speciesFilter)
        .firstOrNull;

    return SizedBox(
      height: sheetHeight,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 14),
        decoration: const BoxDecoration(
          color: AutumnColors.parchmentBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
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
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: AutumnColors.boletusBrown),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.tr(
                      eu: 'Mapako Filtroak eta GPS Ibilbideak',
                      es: 'Filtros y Rutas GPS del Mapa',
                      en: 'Map Filters & GPS Routes',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AutumnColors.boletusBrown,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _speciesFilter = null;
                      _edibilityFilter = 'all';
                      _showAllOutings = true;
                      _showStandaloneSpots = true;
                      _selectedOutingIds.clear();
                    });
                  },
                  child: Text(
                    s.tr(eu: 'Berrezarri', es: 'Restablecer', en: 'Reset'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECCIÓN 1: SETAS Y ESPECIES
            _sectionTitle(
              Icons.eco_rounded,
              s.tr(
                eu: '1. Perretxikoak motaren eta espeziearen arabera',
                es: '1. Setas por Tipo y Especie',
                en: '1. Mushrooms by Type & Species',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _choiceChip(
                  label: s.tr(eu: 'Guztiak', es: 'Todas', en: 'All'),
                  selected: _edibilityFilter == 'all',
                  onSelected: () => setState(() => _edibilityFilter = 'all'),
                ),
                const SizedBox(width: 8),
                _choiceChip(
                  label: s.tr(eu: 'Jangarriak', es: 'Comestibles', en: 'Edible'),
                  selected: _edibilityFilter == 'edible',
                  onSelected: () => setState(() => _edibilityFilter = 'edible'),
                ),
                const SizedBox(width: 8),
                _choiceChip(
                  label: s.tr(eu: 'Toxikoak', es: 'Tóxicas', en: 'Toxic'),
                  selected: _edibilityFilter == 'toxic',
                  onSelected: () => setState(() => _edibilityFilter = 'toxic'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (chosenMushroom != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AutumnColors.mossGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AutumnColors.mossGreen.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        chosenMushroom.primaryImage,
                        width: 38,
                        height: 38,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chosenMushroom.scientificName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 13),
                          ),
                          Text(
                            '${chosenMushroom.displayNameFor(widget.lang)} (${widget.lang == AppLanguage.eu ? chosenMushroom.spanishName : chosenMushroom.basqueName})',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AutumnColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () => setState(() => _speciesFilter = null),
                    ),
                  ],
                ),
              ),
            ] else ...[
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AutumnColors.boletusBrown,
                  side: const BorderSide(color: AutumnColors.ochreGold),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 11),
                ),
                onPressed: _pickSpeciesDialog,
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(
                  s.tr(
                    eu: 'Katalogoko espezie zehatzaren arabera iragazi (${widget.allMushrooms.length} espezie)',
                    es: 'Filtrar por especie concreta del catálogo (${widget.allMushrooms.length} especies)',
                    en: 'Filter by specific catalog species (${widget.allMushrooms.length} species)',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            // SECCIÓN 2: IRTEERAK ETA IBILBIDEAK
            _sectionTitle(
              Icons.hiking_rounded,
              s.tr(
                eu: '2. Irteerak eta Ibilbideak',
                es: '2. Salidas y Rutas',
                en: '2. Outings & Routes',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _choiceChip(
                  label: s.tr(
                    eu: 'Denak ikusi (${widget.allOutings.length + 1})',
                    es: 'Ver todas (${widget.allOutings.length + 1})',
                    en: 'Show all (${widget.allOutings.length + 1})',
                  ),
                  selected: _showAllOutings && _showStandaloneSpots,
                  onSelected: () {
                    setState(() {
                      _showAllOutings = true;
                      _showStandaloneSpots = true;
                      _selectedOutingIds.clear();
                    });
                  },
                ),
                const SizedBox(width: 8),
                _choiceChip(
                  label: s.tr(
                    eu: 'Denak ezkutatu',
                    es: 'Ocultar todas',
                    en: 'Hide all',
                  ),
                  selected: !_showAllOutings &&
                      !_showStandaloneSpots &&
                      _selectedOutingIds.isEmpty,
                  onSelected: () {
                    setState(() {
                      _showAllOutings = false;
                      _showStandaloneSpots = false;
                      _selectedOutingIds.clear();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AutumnColors.warmSand.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    activeColor: AutumnColors.mossGreen,
                    value: _showStandaloneSpots,
                    secondary: const Icon(
                      Icons.place_rounded,
                      color: AutumnColors.boletusBrown,
                    ),
                    title: Text(
                      s.tr(
                        eu: 'Puntu solteak (irteerarik gabe)',
                        es: 'Puntos sueltos (sin salida)',
                        en: 'Standalone spots (no outing)',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.allSpots.where((s) => !s.isFromOuting).length} ${s.tr(eu: "perretxiko-leku", es: "setales", en: "spots")}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onChanged: (val) {
                      setState(() {
                        _showStandaloneSpots = val ?? false;
                      });
                    },
                  ),
                  if (widget.allOutings.isNotEmpty) const Divider(height: 1),
                  ...widget.allOutings.map((out) {
                    final idx = widget.allOutings.indexOf(out);
                    final color = widget
                        .routePalette[idx % widget.routePalette.length];
                    final isChecked = _showAllOutings ||
                        _selectedOutingIds.contains(out.id);
                    final outSpotsCount = widget.allSpots
                        .where((s) => s.outingId == out.id)
                        .length;
                    final hasRoute = out.routePoints.length >= 2;

                    return CheckboxListTile(
                      activeColor: AutumnColors.mossGreen,
                      value: isChecked,
                      secondary: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 2)
                          ],
                        ),
                      ),
                      title: Text(
                        out.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${hasRoute ? "${(out.distanceMeters / 1000.0).toStringAsFixed(2)} km" : s.tr(eu: "Eskuzkoa", es: "Manual", en: "Manual")} · ${DateFormat('dd/MM/yyyy').format(out.startedAt)} · $outSpotsCount ${s.tr(eu: "perretxiko-leku", es: "setales", en: "spots")}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (_showAllOutings) {
                            _showAllOutings = false;
                            _selectedOutingIds.clear();
                            _selectedOutingIds
                                .addAll(widget.allOutings.map((o) => o.id));
                          }
                          if (val == true) {
                            _selectedOutingIds.add(out.id);
                          } else {
                            _selectedOutingIds.remove(out.id);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    const SizedBox(height: 10),
    SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AutumnColors.ochreGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          widget.onApply(
            speciesFilter: _speciesFilter,
            edibilityFilter: _edibilityFilter,
            showAllOutings: _showAllOutings,
            showStandaloneSpots: _showStandaloneSpots,
            selectedOutingIds: _selectedOutingIds,
          );
        },
        icon: const Icon(Icons.check_rounded),
        label: Text(
          s.tr(
            eu: 'Filtroak Aplikatu',
            es: 'Aplicar Filtros',
            en: 'Apply Filters',
          ),
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    ),
  ],
),
),
);
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AutumnColors.terracotta),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AutumnColors.boletusBrown,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AutumnColors.amberLeaf,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? AutumnColors.barkDark : AutumnColors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}

class _DianaPlacementBanner extends StatelessWidget {
  final AppLanguage lang;
  final VoidCallback onCancel;

  const _DianaPlacementBanner({
    required this.lang,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
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
                  color: AutumnColors.amberLeaf.withValues(alpha: 0.22),
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
                  backgroundColor: Colors.white.withValues(alpha: 0.16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: Size.zero,
                ),
                onPressed: onCancel,
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
    );
  }
}

class _DianaPlacementBottomBar extends StatelessWidget {
  final AppLanguage lang;
  final bool isLocatingGps;
  final VoidCallback onCenterGps;
  final VoidCallback onConfirm;

  const _DianaPlacementBottomBar({
    required this.lang,
    required this.isLocatingGps,
    required this.onCenterGps,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    return Container(
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
            style: IconButton.styleFrom(
              backgroundColor: AutumnColors.mossGreen.withValues(alpha: 0.15),
              foregroundColor: AutumnColors.mossGreen,
              padding: const EdgeInsets.all(12),
            ),
            tooltip: s.tr(
              eu: 'Zentratu diana nire GPS posizioan',
              es: 'Centrar diana en mi ubicación GPS',
              en: 'Center crosshair on my GPS location',
            ),
            onPressed: isLocatingGps ? null : onCenterGps,
            icon: isLocatingGps
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Icon(Icons.my_location_rounded, size: 22),
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
              onPressed: onConfirm,
              icon: const Icon(Icons.check_circle_rounded, size: 22),
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
    );
  }
}
