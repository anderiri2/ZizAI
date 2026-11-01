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
import '../../../core/theme/autumn_theme.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/mushroom_detail_screen.dart';
import '../data/spots_database.dart';
import '../models/foraging_spot.dart';

class MapScreen extends ConsumerStatefulWidget {
  final Mushroom? initialMushroomToRegister;
  final VoidCallback? onInitialMushroomConsumed;

  const MapScreen({
    super.key,
    this.initialMushroomToRegister,
    this.onInitialMushroomConsumed,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  bool _useTopoLayer = true;
  bool _isLocatingGps = false;
  ForagingSpot? _selectedSpot;
  LatLng? _currentUserLocation;

  // Centro inicial en el corazón de Euskadi / Montes Vascos (Gorbeia / Urkiola / Aralar)
  static const LatLng _defaultBasqueCenter = LatLng(43.0150, -2.5200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingMushroomRegistration();
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMushroomToRegister != null &&
        widget.initialMushroomToRegister !=
            oldWidget.initialMushroomToRegister) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkPendingMushroomRegistration();
      });
    }
  }

  void _checkPendingMushroomRegistration() {
    final pending = widget.initialMushroomToRegister;
    if (pending != null) {
      widget.onInitialMushroomConsumed?.call();
      final center = _currentUserLocation ?? _mapController.camera.center;
      _openAddOrEditSpotSheet(
        context,
        initialLatLng: center,
        preselectedMushroom: pending,
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
                'El GPS está desactivado. Puedes mantener pulsado cualquier punto del mapa para guardar un setal.',
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
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo obtener señal GPS en este momento. Puedes pulsar largo en el mapa para marcar el punto.',
              ),
            ),
          );
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
  }) async {
    final allMushrooms =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    final savedSpot = await showModalBottomSheet<ForagingSpot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SpotFormBottomSheet(
        initialLatLng: initialLatLng,
        existingSpot: existingSpot,
        preselectedMushroom: preselectedMushroom,
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
                      'Mis Setales Guardados (${spots.length})',
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
                        'Aún no has guardado ninguna ubicación.\nMantén pulsado un punto del mapa o usa el botón Guardar Setal.',
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
                            backgroundColor:
                                AutumnColors.ochreGold.withValues(alpha: 0.2),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                          title: Text(
                            spot.title,
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
                              if (spot.notes.isNotEmpty)
                                Text(
                                  spot.notes,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12),
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
    final spotsAsync = ref.watch(foragingSpotsProvider);
    final spots = spotsAsync.valueOrNull ?? const <ForagingSpot>[];
    final allMushrooms =
        ref.watch(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    return Scaffold(
      body: Stack(
        children: [
          // Mapa interactivo OpenTopoMap / OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultBasqueCenter,
              initialZoom: 9.6,
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withValues(alpha: 0.45),
                              blurRadius: 10,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: spots.map((spot) {
                  final isSelected = _selectedSpot?.id == spot.id;
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
                                : AutumnColors.boletusBrown,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AutumnColors.amberLeaf,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.park_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Barra superior translúcida con controles de capa y listado de setales
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AutumnColors.barkDark.withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                AutumnColors.amberLeaf.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.explore_rounded,
                              color: AutumnColors.amberLeaf,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Mapa de Setales',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  Text(
                                    'Mantén pulsado el mapa para guardar un sitio',
                                    style: TextStyle(
                                      color: AutumnColors.warmSand
                                          .withValues(alpha: 0.85),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Conmutador Topográfico / Estándar
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() => _useTopoLayer = !_useTopoLayer);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AutumnColors.ochreGold
                                      .withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AutumnColors.amberLeaf
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _useTopoLayer
                                          ? Icons.terrain_rounded
                                          : Icons.map_outlined,
                                      color: AutumnColors.amberLeaf,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _useTopoLayer ? 'Topo' : 'Calle',
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
                            const SizedBox(width: 8),
                            // Ver lista de setales
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => _openSavedSpotsListSheet(spots),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.format_list_bulleted_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${spots.length}',
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botones laterales de control de mapa (GPS + Añadir ubicación)
          Positioned(
            right: 16,
            bottom: _selectedSpot != null ? 265 : 112,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton.small(
                  heroTag: 'btn_gps_center',
                  backgroundColor: AutumnColors.parchmentBg,
                  foregroundColor: AutumnColors.boletusBrown,
                  tooltip: 'Centrar en mi posición GPS',
                  onPressed:
                      _isLocatingGps ? null : () => _centerOnUserGps(),
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
                  label: const Text(
                    'Guardar Setal',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Tarjeta inferior emergente al seleccionar un marcador del mapa
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
                    Text(
                      spot.title,
                      style: const TextStyle(
                        fontSize: 16.5,
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
                          padding: const EdgeInsets.only(top: 3),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.eco_rounded,
                                size: 14,
                                color: AutumnColors.mossGreen,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
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
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      '${DateFormat('dd/MM/yyyy').format(spot.foundAt)} · ${spot.latitude.toStringAsFixed(4)}, ${spot.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AutumnColors.textMuted,
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
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AutumnColors.creamCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                spot.notes,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.2,
                  height: 1.38,
                  color: AutumnColors.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
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
                  backgroundColor: AutumnColors.ochreGold.withValues(alpha: 0.2),
                  foregroundColor: AutumnColors.boletusBrown,
                ),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: const Text('Editar nota'),
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
  final List<Mushroom> catalogMushrooms;

  const _SpotFormBottomSheet({
    required this.initialLatLng,
    this.existingSpot,
    this.preselectedMushroom,
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
          (pre != null ? 'Setal de ${pre.basqueName.split('/').first.trim()}' : ''),
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
    _selectedDate = existing?.foundAt ?? DateTime.now();
    _selectedMushroomId = existing?.mushroomId ?? pre?.id;
    _selectedMushroomName = existing?.mushroomName ??
        (pre != null ? '${pre.basqueName} / ${pre.spanishName}' : null);
    _photoPath = existing?.photoPath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _latController.dispose();
    _lngController.dispose();
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
            const SizedBox(height: 14),

            // Nombre del sitio
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Nombre del lugar / setal',
                hintText: 'Ej. Hayedo norte junto a la regata - Gorbeia',
                prefixIcon: Icon(Icons.place_rounded),
              ),
            ),
            const SizedBox(height: 12),

            // Selector de especie del catálogo
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
                            'Pulsa para elegir una seta del catálogo (opcional)',
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

            // Nota descriptiva detallada
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nota descriptiva del hallazgo',
                hintText:
                    'Detalla orientación de la ladera, árboles cercanos, humedad, cantidad o referencias para volver...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 42),
                  child: Icon(Icons.notes_rounded),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Coordenadas y Fecha
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

            // Fecha y Fotografía opcional
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

            if (_photoPath != null &&
                !kIsWeb &&
                File(_photoPath!).existsSync()) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(_photoPath!),
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                      ),
                      onPressed: () => setState(() => _photoPath = null),
                      icon: const Icon(Icons.close_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ],

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
