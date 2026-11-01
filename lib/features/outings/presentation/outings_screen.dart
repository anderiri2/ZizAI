import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../core/theme/autumn_theme.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/mushroom_detail_screen.dart';
import '../../map/data/spots_database.dart';
import '../../map/models/foraging_spot.dart';
import '../data/outings_database.dart';
import '../models/foraging_outing.dart';

class OutingsScreen extends ConsumerStatefulWidget {
  final void Function(String outingId)? onViewOutingOnGlobalMap;
  final void Function(String outingId)? onViewOutingInGlobalMap;
  final VoidCallback? onAddSpotInMapDuringOuting;

  const OutingsScreen({
    super.key,
    this.onViewOutingOnGlobalMap,
    this.onViewOutingInGlobalMap,
    this.onAddSpotInMapDuringOuting,
  });

  @override
  ConsumerState<OutingsScreen> createState() => _OutingsScreenState();
}

class _OutingsScreenState extends ConsumerState<OutingsScreen> {
  final MapController _liveMapController = MapController();

  Future<void> _promptStartNewOuting() async {
    final titleCtrl = TextEditingController(
      text: 'Salida de otoño (${DateFormat('dd/MM').format(DateTime.now())})',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AutumnColors.parchmentBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Iniciar Nueva Salida al Monte',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AutumnColors.boletusBrown,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se grabará tu recorrido GPS y podrás ir anotando todas las setas que encuentres en la vuelta.',
              style: TextStyle(
                fontSize: 13.5,
                color: AutumnColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nombre de la salida / zona',
                hintText: 'Ej. Vuelta por el Hayedo de Altube',
                prefixIcon: Icon(Icons.hiking_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Empezar Ruta GPS'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(activeOutingRecorderProvider.notifier).startOuting(
            titleCtrl.text,
            initialPoint: const LatLng(43.0340, -2.7270),
          );
    }
  }

  Future<void> _openRegisterFindInActiveOuting(
    ActiveOutingState activeState,
  ) async {
    final catalog =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
    final currentPos = activeState.routePoints.isNotEmpty
        ? activeState.routePoints.last
        : const LatLng(43.0350, -2.7280);

    final newSpot = await showModalBottomSheet<ForagingSpot>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OutingFindFormSheet(
        position: currentPos,
        outingId: activeState.activeOutingId!,
        outingTitle: activeState.title,
        catalogMushrooms: catalog,
      ),
    );

    if (newSpot != null) {
      await ref.read(foragingSpotsProvider.notifier).saveSpot(newSpot);
      // También añadimos la coordenada del hallazgo al trazado de la ruta
      ref
          .read(activeOutingRecorderProvider.notifier)
          .addRoutePoint(LatLng(newSpot.latitude, newSpot.longitude));
    }
  }

  Future<void> _confirmDeleteOuting(
    ForagingOuting outing,
    int associatedSpotsCount,
  ) async {
    if (associatedSpotsCount == 0) {
      await ref.read(outingsProvider.notifier).removeOuting(outing.id);
      return;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AutumnColors.parchmentBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Eliminar Salida del Historial',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AutumnColors.boletusBrown,
          ),
        ),
        content: Text(
          'Esta salida ("${outing.title}") tiene $associatedSpotsCount ubicaciones de setas registradas.\n\n'
          '¿Qué deseas hacer con las ubicaciones de setas encontradas en esta vuelta?',
          style: const TextStyle(
            fontSize: 14,
            height: 1.42,
            color: AutumnColors.textSecondary,
          ),
        ),
        actionsAlignment: MainAxisAlignment.end,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop('cancel'),
            child: const Text('Cancelar'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AutumnColors.mossGreen,
              side: const BorderSide(color: AutumnColors.mossGreen),
            ),
            onPressed: () => Navigator.of(ctx).pop('keep_spots'),
            icon: const Icon(Icons.place_rounded, size: 18),
            label: const Text('Conservar setas en Mapa Global'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AutumnColors.edibilityToxic,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop('delete_all'),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: const Text('Borrar salida y sus puntos'),
          ),
        ],
      ),
    );

    if (choice == 'keep_spots') {
      await ref
          .read(foragingSpotsProvider.notifier)
          .detachOutingSpots(outing.id);
      await ref.read(outingsProvider.notifier).removeOuting(outing.id);
    } else if (choice == 'delete_all') {
      await ref
          .read(foragingSpotsProvider.notifier)
          .deleteOutingSpots(outing.id);
      await ref.read(outingsProvider.notifier).removeOuting(outing.id);
    }
  }

  String _formatElapsed(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final outingsAsync = ref.watch(outingsProvider);
    final allSpots =
        ref.watch(foragingSpotsProvider).valueOrNull ?? const <ForagingSpot>[];
    final allMushrooms =
        ref.watch(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
    final activeOuting = ref.watch(activeOutingRecorderProvider);

    return Scaffold(
      backgroundColor: AutumnColors.parchmentBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AutumnColors.mossGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.route_rounded,
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
                          'Salidas al Monte',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AutumnColors.boletusBrown,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Text(
                          'Rutas GPS grabadas y resumen de setas recogidas',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AutumnColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!activeOuting.isRecording)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AutumnColors.mossGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _promptStartNewOuting,
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 19),
                      label: const Text('Nueva Salida'),
                    ),
                ],
              ),
            ),

            // Grabador de Salida en Vivo (si hay una ruta en curso)
            if (activeOuting.isRecording)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: _ActiveOutingRecorderCard(
                  activeState: activeOuting,
                  mapController: _liveMapController,
                  elapsedFormatted: _formatElapsed(activeOuting.elapsedSeconds),
                  outingSpots: allSpots
                      .where((s) => s.outingId == activeOuting.activeOutingId)
                      .toList(),
                  onAddPointTap: (latLng) {
                    ref
                        .read(activeOutingRecorderProvider.notifier)
                        .addRoutePoint(latLng);
                  },
                  onRegisterFind: () =>
                      _openRegisterFindInActiveOuting(activeOuting),
                  onTogglePause: () {
                    ref
                        .read(activeOutingRecorderProvider.notifier)
                        .togglePause();
                  },
                  onFinish: () async {
                    final completed = ref
                        .read(activeOutingRecorderProvider.notifier)
                        .finishOuting();
                    if (completed != null) {
                      await ref
                          .read(outingsProvider.notifier)
                          .saveOuting(completed);
                    }
                  },
                ),
              ),

            // Listado de Tarjetas Resumen de Salidas
            Expanded(
              child: outingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AutumnColors.ochreGold,
                  ),
                ),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (outings) {
                  if (outings.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.hiking_rounded,
                              size: 56,
                              color:
                                  AutumnColors.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Aún no has documentado ninguna salida al monte.\nPulsa "Nueva Salida" para grabar tu recorrido GPS y las setas que recojas.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AutumnColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 115),
                    itemCount: outings.length,
                    itemBuilder: (context, idx) {
                      final outing = outings[idx];
                      final outingSpots = allSpots
                          .where((s) => s.outingId == outing.id)
                          .toList();
                      final harvest = outing.summarizeHarvest(allSpots);

                      return _OutingSummaryCard(
                        outing: outing,
                        outingSpots: outingSpots,
                        harvestItems: harvest,
                        catalogMushrooms: allMushrooms,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OutingDetailScreen(
                                outing: outing,
                                outingSpots: outingSpots,
                                harvestItems: harvest,
                                catalogMushrooms: allMushrooms,
                              ),
                            ),
                          );
                        },
                        onViewOnGlobalMap: (widget.onViewOutingOnGlobalMap ??
                                    widget.onViewOutingInGlobalMap) ==
                                null
                            ? null
                            : () => (widget.onViewOutingOnGlobalMap ??
                                widget.onViewOutingInGlobalMap)!(outing.id),
                        onDelete: () => _confirmDeleteOuting(
                          outing,
                          outingSpots.length,
                        ),
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
  }
}

class _ActiveOutingRecorderCard extends StatelessWidget {
  final ActiveOutingState activeState;
  final MapController mapController;
  final String elapsedFormatted;
  final List<ForagingSpot> outingSpots;
  final ValueChanged<LatLng> onAddPointTap;
  final VoidCallback onRegisterFind;
  final VoidCallback onTogglePause;
  final VoidCallback onFinish;

  const _ActiveOutingRecorderCard({
    required this.activeState,
    required this.mapController,
    required this.elapsedFormatted,
    required this.outingSpots,
    required this.onAddPointTap,
    required this.onRegisterFind,
    required this.onTogglePause,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final center = activeState.routePoints.isNotEmpty
        ? activeState.routePoints.last
        : const LatLng(43.0340, -2.7270);
    final km = (activeState.distanceMeters / 1000.0).toStringAsFixed(2);
    final totalSpecimens =
        outingSpots.fold<int>(0, (sum, s) => sum + s.quantityCount);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AutumnColors.barkDark,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AutumnColors.amberLeaf, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: activeState.isPaused
                      ? AutumnColors.amberLeaf
                      : Colors.greenAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Grabando: ${activeState.title}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                elapsedFormatted,
                style: const TextStyle(
                  color: AutumnColors.amberLeaf,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mapa en vivo de la ruta (puedes tocar sobre él para simular pasos GPS)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 135,
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 14.2,
                  onTap: (_, latLng) => onAddPointTap(latLng),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.perretxikotan.app',
                  ),
                  if (activeState.routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: activeState.routePoints,
                          color: AutumnColors.terracotta,
                          strokeWidth: 4.5,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      ...outingSpots.map(
                        (s) => Marker(
                          point: LatLng(s.latitude, s.longitude),
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AutumnColors.mossGreen,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            child: const Icon(
                              Icons.eco_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      if (activeState.routePoints.isNotEmpty)
                        Marker(
                          point: activeState.routePoints.last,
                          width: 22,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Distancia: $km km · Cesta: $totalSpecimens ejemplares (${outingSpots.length} puntos)',
                style: TextStyle(
                  color: AutumnColors.warmSand.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Toca el mapa para trazar paso',
                style: TextStyle(
                  color: AutumnColors.amberLeaf.withValues(alpha: 0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AutumnColors.ochreGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: onRegisterFind,
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: const Text(
                    'Anotar Seta Aquí',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                ),
                onPressed: onTogglePause,
                icon: Icon(
                  activeState.isPaused
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
              ),
              const SizedBox(width: 6),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AutumnColors.mossGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: onFinish,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text('Terminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OutingSummaryCard extends StatelessWidget {
  final ForagingOuting outing;
  final List<ForagingSpot> outingSpots;
  final List<OutingHarvestItem> harvestItems;
  final List<Mushroom> catalogMushrooms;
  final VoidCallback onTap;
  final VoidCallback? onViewOnGlobalMap;
  final VoidCallback onDelete;

  const _OutingSummaryCard({
    required this.outing,
    required this.outingSpots,
    required this.harvestItems,
    required this.catalogMushrooms,
    required this.onTap,
    this.onViewOnGlobalMap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpecimens =
        harvestItems.fold<int>(0, (sum, item) => sum + item.totalSpecimens);
    final totalGrams =
        harvestItems.fold<int>(0, (sum, item) => sum + item.totalWeightGrams);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera de la salida + Miniatura gráfica de la vuelta dada
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mini-mapa vectorial de la polilínea de la ruta GPS y sus hallazgos
                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      color: AutumnColors.creamCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AutumnColors.warmSand),
                    ),
                    child: CustomPaint(
                      painter: _RoutePreviewPainter(
                        routePoints: outing.routePoints,
                        spotPoints: outingSpots
                            .map((s) => LatLng(s.latitude, s.longitude))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('dd/MM/yyyy · HH:mm')
                                    .format(outing.startedAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AutumnColors.textMuted,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: onDelete,
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 20,
                                color: AutumnColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          outing.title,
                          style: const TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AutumnColors.boletusBrown,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Métricas de la vuelta dada
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _MetricBadge(
                              icon: Icons.straighten_rounded,
                              label: outing.formattedDistanceKm,
                            ),
                            _MetricBadge(
                              icon: Icons.schedule_rounded,
                              label: outing.formattedDuration,
                            ),
                            _MetricBadge(
                              icon: Icons.shopping_basket_rounded,
                              label: totalGrams > 0
                                  ? '$totalSpecimens ej. (${totalGrams}g)'
                                  : '$totalSpecimens ej.',
                              highlight: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (outing.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  outing.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AutumnColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Desglose de Setas Recogidas en la vuelta
              Row(
                children: [
                  const Icon(
                    Icons.eco_rounded,
                    size: 16,
                    color: AutumnColors.mossGreen,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Setas recogidas (${outingSpots.length} ubicaciones):',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AutumnColors.boletusBrown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (harvestItems.isEmpty)
                const Text(
                  'Ruta sin hallazgos registrados.',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AutumnColors.textMuted,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: harvestItems.map((item) {
                    final matchedMushroom = catalogMushrooms
                        .where((m) => m.id == item.mushroomId)
                        .firstOrNull;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AutumnColors.creamCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AutumnColors.warmSand),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (matchedMushroom != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                matchedMushroom.primaryImage,
                                width: 22,
                                height: 22,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            item.formattedSummary,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AutumnColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              if (onViewOnGlobalMap != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AutumnColors.mossGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onViewOnGlobalMap,
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: const Text(
                      'Ver ruta y puntos en Mapa Global',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _MetricBadge({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? AutumnColors.mossGreen.withValues(alpha: 0.14)
            : AutumnColors.creamCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color:
                highlight ? AutumnColors.mossGreen : AutumnColors.boletusBrown,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: highlight
                  ? AutumnColors.mossGreen
                  : AutumnColors.boletusBrown,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dibuja en miniatura el trazado GPS de la vuelta dada y los puntos de setas encontradas.
class _RoutePreviewPainter extends CustomPainter {
  final List<LatLng> routePoints;
  final List<LatLng> spotPoints;

  _RoutePreviewPainter({
    required this.routePoints,
    required this.spotPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final all = [...routePoints, ...spotPoints];
    if (all.isEmpty) return;

    double minLat = all.first.latitude;
    double maxLat = all.first.latitude;
    double minLng = all.first.longitude;
    double maxLng = all.first.longitude;

    for (final pt in all) {
      minLat = math.min(minLat, pt.latitude);
      maxLat = math.max(maxLat, pt.latitude);
      minLng = math.min(minLng, pt.longitude);
      maxLng = math.max(maxLng, pt.longitude);
    }

    final latSpan = math.max(maxLat - minLat, 0.002);
    final lngSpan = math.max(maxLng - minLng, 0.002);
    const pad = 12.0;
    final drawW = size.width - pad * 2;
    final drawH = size.height - pad * 2;

    Offset project(LatLng pt) {
      final x = pad + ((pt.longitude - minLng) / lngSpan) * drawW;
      final y = size.height - pad - ((pt.latitude - minLat) / latSpan) * drawH;
      return Offset(x, y);
    }

    if (routePoints.length >= 2) {
      final path = Path();
      final first = project(routePoints.first);
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < routePoints.length; i++) {
        final p = project(routePoints[i]);
        path.lineTo(p.dx, p.dy);
      }

      final linePaint = Paint()
        ..color = AutumnColors.terracotta
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(path, linePaint);
    }

    final dotPaint = Paint()
      ..color = AutumnColors.mossGreen
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final s in spotPoints) {
      final center = project(s);
      canvas.drawCircle(center, 4.2, dotPaint);
      canvas.drawCircle(center, 4.2, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePreviewPainter oldDelegate) {
    return oldDelegate.routePoints != routePoints ||
        oldDelegate.spotPoints != spotPoints;
  }
}

/// Pantalla de detalle completo de una Salida al Monte.
class OutingDetailScreen extends StatelessWidget {
  final ForagingOuting outing;
  final List<ForagingSpot> outingSpots;
  final List<OutingHarvestItem> harvestItems;
  final List<Mushroom> catalogMushrooms;

  const OutingDetailScreen({
    super.key,
    required this.outing,
    required this.outingSpots,
    required this.harvestItems,
    required this.catalogMushrooms,
  });

  @override
  Widget build(BuildContext context) {
    final center = outing.routePoints.isNotEmpty
        ? outing.routePoints.first
        : (outingSpots.isNotEmpty
            ? LatLng(outingSpots.first.latitude, outingSpots.first.longitude)
            : const LatLng(43.0358, -2.7289));

    return Scaffold(
      backgroundColor: AutumnColors.parchmentBg,
      appBar: AppBar(
        title: Text(outing.title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 36),
        children: [
          // Mapa de la vuelta dada y los puntos registrados
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: SizedBox(
              height: 270,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: 13.8,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.perretxikotan.app',
                  ),
                  if (outing.routePoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: outing.routePoints,
                          color: AutumnColors.terracotta,
                          strokeWidth: 4.5,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: outingSpots.map((spot) {
                      return Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: 42,
                        height: 42,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AutumnColors.mossGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AutumnColors.amberLeaf,
                              width: 2.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${spot.quantityCount}x',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tarjeta de resumen de métricas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AutumnColors.warmSand),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, dd/MM/yyyy · HH:mm').format(outing.startedAt),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AutumnColors.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _DetailStatColumn(
                      label: 'Distancia',
                      value: outing.formattedDistanceKm,
                      icon: Icons.straighten_rounded,
                    ),
                    _DetailStatColumn(
                      label: 'Duración',
                      value: outing.formattedDuration,
                      icon: Icons.timer_rounded,
                    ),
                    _DetailStatColumn(
                      label: 'Hallazgos',
                      value: '${outingSpots.length} puntos',
                      icon: Icons.place_rounded,
                    ),
                  ],
                ),
                if (outing.notes.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    outing.notes,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: AutumnColors.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Cesta de la Salida por Especie',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AutumnColors.boletusBrown,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          ...harvestItems.map((item) {
            final mushroom = catalogMushrooms
                .where((m) => m.id == item.mushroomId)
                .firstOrNull;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: mushroom != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          mushroom.primaryImage,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const CircleAvatar(child: Icon(Icons.eco_rounded)),
                title: Text(
                  item.mushroomName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${item.totalSpecimens} ejemplares en ${item.spotsCount} punto(s)${item.totalWeightGrams > 0 ? ' · ${item.totalWeightGrams} g' : ''}',
                ),
                trailing: mushroom != null
                    ? const Icon(Icons.chevron_right_rounded)
                    : null,
                onTap: mushroom == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) =>
                                MushroomDetailScreen(mushroom: mushroom),
                          ),
                        );
                      },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DetailStatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailStatColumn({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AutumnColors.ochreGold, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AutumnColors.boletusBrown,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AutumnColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _OutingFindFormSheet extends StatefulWidget {
  final LatLng position;
  final String outingId;
  final String outingTitle;
  final List<Mushroom> catalogMushrooms;

  const _OutingFindFormSheet({
    required this.position,
    required this.outingId,
    required this.outingTitle,
    required this.catalogMushrooms,
  });

  @override
  State<_OutingFindFormSheet> createState() => _OutingFindFormSheetState();
}

class _OutingFindFormSheetState extends State<_OutingFindFormSheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '3');
  final _weightCtrl = TextEditingController();
  Mushroom? _selectedMushroom;

  @override
  void initState() {
    super.initState();
    if (widget.catalogMushrooms.isNotEmpty) {
      _selectedMushroom = widget.catalogMushrooms
          .where((m) => m.id == 'boletus_edulis')
          .firstOrNull ??
          widget.catalogMushrooms.first;
      _titleCtrl.text =
          'Hallazgo de ${_selectedMushroom!.basqueName.split('/').first.trim()}';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _qtyCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
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
            Text(
              'Anotar Seta en "${widget.outingTitle}"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AutumnColors.boletusBrown,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Mushroom>(
              initialValue: _selectedMushroom,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Especie del catálogo',
                prefixIcon: Icon(Icons.eco_rounded),
              ),
              items: widget.catalogMushrooms.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(
                    '${m.basqueName.split('/').first.trim()} · ${m.spanishName}',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (m) {
                setState(() {
                  _selectedMushroom = m;
                  if (m != null) {
                    _titleCtrl.text =
                        'Hallazgo de ${m.basqueName.split('/').first.trim()}';
                  }
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nº ejemplares',
                      prefixIcon: Icon(Icons.tag_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso aprox. (g)',
                      hintText: 'Opcional',
                      prefixIcon: Icon(Icons.scale_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Nota descriptiva',
                hintText: 'Ej. Junto al arroyo bajo dos hayas...',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final qty = int.tryParse(_qtyCtrl.text.trim()) ?? 1;
                  final grams = int.tryParse(_weightCtrl.text.trim());
                  final m = _selectedMushroom;

                  final spot = ForagingSpot(
                    id: 'spot_${DateTime.now().millisecondsSinceEpoch}',
                    title: _titleCtrl.text.trim().isEmpty
                        ? 'Hallazgo en salida'
                        : _titleCtrl.text.trim(),
                    latitude: widget.position.latitude,
                    longitude: widget.position.longitude,
                    mushroomId: m?.id,
                    mushroomName: m != null
                        ? '${m.basqueName} / ${m.spanishName}'
                        : 'Seta silvestre',
                    notes: _notesCtrl.text.trim(),
                    foundAt: DateTime.now(),
                    outingId: widget.outingId,
                    outingTitle: widget.outingTitle,
                    quantityCount: qty < 1 ? 1 : qty,
                    weightGrams: grams,
                  );
                  Navigator.of(context).pop(spot);
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Guardar en la Salida y Mapa Global'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
