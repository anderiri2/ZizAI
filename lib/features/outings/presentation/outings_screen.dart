import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/mushroom_detail_screen.dart';
import '../../map/data/spots_database.dart';
import '../../map/models/foraging_spot.dart';
import '../data/outings_database.dart';
import '../models/foraging_outing.dart';
import 'live_outing_map_screen.dart';
import 'map_spot_picker_screen.dart';

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
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);
    final titleCtrl = TextEditingController(
      text:
          '${s.tr(eu: "Udazkeneko irteera", es: "Salida de otoño", en: "Autumn outing")} (${DateFormat('dd/MM').format(DateTime.now())})',
    );
    int selectedMode = 0; // 0 = GPS en Vivo, 1 = Manual en Directo, 2 = Retrospectiva
    DateTime selectedDate = DateTime.now();
    int durationMinutes = 120;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFFFAF4EA),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            s.tr(
              eu: 'Irteera Berria Antolatu',
              es: 'Nueva Salida al Monte',
              en: 'New Foraging Outing',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AutumnColors.boletusBrown,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.tr(
                    eu: 'Aukeratu irteera mota:',
                    es: 'Elige la modalidad de salida:',
                    en: 'Choose outing mode:',
                  ),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AutumnColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),

                // Modo 0: GPS en Vivo
                InkWell(
                  onTap: () => setDialogState(() => selectedMode = 0),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMode == 0
                          ? AutumnColors.amberLeaf.withValues(alpha: 0.14)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedMode == 0
                            ? AutumnColors.amberLeaf
                            : AutumnColors.warmSand,
                        width: selectedMode == 0 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.gps_fixed_rounded,
                          color: AutumnColors.mossGreen,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.tr(
                                  eu: 'GPS Ibilbidea Zuzenean',
                                  es: 'Ruta GPS en Vivo',
                                  en: 'Live GPS Track',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AutumnColors.boletusBrown,
                                ),
                              ),
                              Text(
                                s.tr(
                                  eu: 'Ibilbidea satelite bidez grabatzen du',
                                  es: 'Graba el recorrido y distancia continuamente',
                                  en: 'Records live GPS trail and distance',
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AutumnColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selectedMode == 0
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selectedMode == 0
                              ? AutumnColors.amberLeaf
                              : AutumnColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Modo 1: Salida Manual (Sin GPS)
                InkWell(
                  onTap: () => setDialogState(() => selectedMode = 1),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMode == 1
                          ? AutumnColors.amberLeaf.withValues(alpha: 0.14)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedMode == 1
                            ? AutumnColors.amberLeaf
                            : AutumnColors.warmSand,
                        width: selectedMode == 1 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.battery_charging_full_rounded,
                          color: AutumnColors.amberLeaf,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.tr(
                                  eu: 'Eskuzko Irteera (GPS gabe)',
                                  es: 'Salida Manual (Sin GPS)',
                                  en: 'Manual Outing (No GPS)',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AutumnColors.boletusBrown,
                                ),
                              ),
                              Text(
                                s.tr(
                                  eu: '%0 bateria-gastua • Mapan setalak markatu',
                                  es: '0% batería GPS • Ubica setas en el mapa',
                                  en: 'Zero battery drain • Place spots on map',
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AutumnColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selectedMode == 1
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selectedMode == 1
                              ? AutumnColors.amberLeaf
                              : AutumnColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Modo 2: Salida Retrospectiva (Pasada)
                InkWell(
                  onTap: () => setDialogState(() => selectedMode = 2),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selectedMode == 2
                          ? AutumnColors.amberLeaf.withValues(alpha: 0.14)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedMode == 2
                            ? AutumnColors.amberLeaf
                            : AutumnColors.warmSand,
                        width: selectedMode == 2 ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history_rounded,
                          color: AutumnColors.boletusBrown,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.tr(
                                  eu: 'Iraganeko Irteera Erregistratu',
                                  es: 'Registrar Salida Pasada',
                                  en: 'Log Past Outing',
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AutumnColors.boletusBrown,
                                ),
                              ),
                              Text(
                                s.tr(
                                  eu: 'Etxera itzultzean datak eta setak sartu',
                                  es: 'Guarda salidas anteriores con fecha y notas',
                                  en: 'Record previous trips with date and finds',
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AutumnColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          selectedMode == 2
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: selectedMode == 2
                              ? AutumnColors.amberLeaf
                              : AutumnColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: s.tr(
                      eu: 'Irteeraren izena',
                      es: 'Nombre de la salida',
                      en: 'Outing name',
                    ),
                    hintText: s.tr(
                      eu: 'Adib. Altubeko pagadia',
                      es: 'Ej. Hayedo de Altube',
                      en: 'E.g. Altube beech forest',
                    ),
                    prefixIcon: const Icon(Icons.hiking_rounded),
                  ),
                ),

                if (selectedMode == 2) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          icon: const Icon(Icons.calendar_month_rounded, size: 16),
                          label: Text(
                            DateFormat('dd/MM/yyyy').format(selectedDate),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: durationMinutes,
                          decoration: InputDecoration(
                            labelText: s.tr(
                              eu: 'Iraupen gutxi gorabeherakoa',
                              es: 'Duración aprox.',
                              en: 'Approx. duration',
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          items: const [
                            DropdownMenuItem(value: 60, child: Text('1h 00m')),
                            DropdownMenuItem(value: 90, child: Text('1h 30m')),
                            DropdownMenuItem(value: 120, child: Text('2h 00m')),
                            DropdownMenuItem(value: 180, child: Text('3h 00m')),
                            DropdownMenuItem(value: 240, child: Text('4h 00m')),
                          ],
                          onChanged: (v) {
                            if (v != null) {
                              setDialogState(() => durationMinutes = v);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AutumnColors.boletusBrown,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: Icon(
                selectedMode == 2
                    ? Icons.save_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                selectedMode == 2
                    ? s.tr(eu: 'Gorde Irteera', es: 'Guardar Salida', en: 'Save Outing')
                    : selectedMode == 1
                        ? s.tr(eu: 'Hasi Eskuz (GPS gabe)', es: 'Iniciar Sin GPS', en: 'Start Manual')
                        : s.tr(eu: 'Hasi GPS Ibilbidea', es: 'Empezar Ruta GPS', en: 'Start GPS Route'),
              ),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      if (selectedMode == 2) {
        // Salida Retrospectiva
        final outing = ref
            .read(activeOutingRecorderProvider.notifier)
            .createRetrospectiveOuting(
              title: titleCtrl.text,
              startedAt: selectedDate,
              durationSeconds: durationMinutes * 60,
              notes: s.tr(
                eu: 'Eskuz erregistratutako irteera.',
                es: 'Salida manual registrada retrospectivamente.',
                en: 'Manually logged outing.',
              ),
            );
        await ref.read(outingsProvider.notifier).saveOuting(outing);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AutumnColors.mossGreen,
              content: Text(
                s.tr(
                  eu: '"${outing.title}" irteera gorde da. Orain perretxikoak gehitu ditzakezu mapan.',
                  es: 'Salida "${outing.title}" guardada. Ya puedes añadir setas tocando en el mapa.',
                  en: 'Outing "${outing.title}" saved. You can now add mushrooms by tapping the map.',
                ),
              ),
              action: SnackBarAction(
                label: s.tr(
                  eu: 'Seta gehitu',
                  es: 'Añadir seta',
                  en: 'Add mushroom',
                ),
                textColor: Colors.white,
                onPressed: () =>
                    _openMapSpotPickerForOuting(outing.id, outing.title),
              ),
            ),
          );
        }
      } else {
        // Salida en Vivo (GPS o Manual)
        final isManual = selectedMode == 1;
        LatLng? initialPoint;
        if (!isManual) {
          try {
            final pos = await Geolocator.getLastKnownPosition() ??
                await Geolocator.getCurrentPosition().timeout(
                  const Duration(seconds: 2),
                );
            initialPoint = LatLng(pos.latitude, pos.longitude);
          } catch (_) {}
        }
        await ref.read(activeOutingRecorderProvider.notifier).startOuting(
              titleCtrl.text,
              initialPoint: initialPoint,
              isManual: isManual,
            );
      }
    }
  }

  Future<void> _openMapSpotPickerForOuting(
    String outingId,
    String outingTitle,
  ) async {
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);
    final newSpot = await Navigator.of(context).push<ForagingSpot>(
      MaterialPageRoute(
        builder: (_) => MapSpotPickerScreen(
          outingId: outingId,
          outingTitle: outingTitle,
        ),
      ),
    );

    if (newSpot != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AutumnColors.mossGreen,
          content: Text(
            s.tr(
              eu: '"${newSpot.mushroomName ?? 'aurkikuntza'}" perretxikoa gehitu da "$outingTitle" irteerara',
              es: 'Seta "${newSpot.mushroomName ?? 'hallazgo'}" añadida a la salida "$outingTitle"',
              en: 'Mushroom "${newSpot.mushroomName ?? 'find'}" added to outing "$outingTitle"',
            ),
          ),
        ),
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
      builder: (ctx) => OutingFindFormSheet(
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

    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);

    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AutumnColors.parchmentBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          s.tr(
            eu: 'Ezabatu Irteera Historialetik',
            es: 'Eliminar Salida del Historial',
            en: 'Delete Outing from History',
          ),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AutumnColors.boletusBrown,
          ),
        ),
        content: Text(
          s.tr(
            eu: '"${outing.title}" irteera honek $associatedSpotsCount perretxiko-leku ditu erregistratuta.\n\nZer egin nahi duzu aurkitutako perretxikoekin?',
            es: 'Esta salida ("${outing.title}") tiene $associatedSpotsCount ubicaciones de setas registradas.\n\n¿Qué deseas hacer con las ubicaciones de setas encontradas en esta vuelta?',
            en: 'This outing ("${outing.title}") has $associatedSpotsCount mushroom spots recorded.\n\nWhat would you like to do with them?',
          ),
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
            child: Text(s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel')),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AutumnColors.mossGreen,
              side: const BorderSide(color: AutumnColors.mossGreen),
            ),
            onPressed: () => Navigator.of(ctx).pop('keep_spots'),
            icon: const Icon(Icons.place_rounded, size: 18),
            label: Text(
              s.tr(
                eu: 'Mantendu setak Mapa Orokorrean',
                es: 'Conservar setas en Mapa Global',
                en: 'Keep spots on Global Map',
              ),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AutumnColors.edibilityToxic,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop('delete_all'),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text(
              s.tr(
                eu: 'Ezabatu irteera eta bere puntuak',
                es: 'Borrar salida y sus puntos',
                en: 'Delete outing and spots',
              ),
            ),
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

  void _openFullscreenLiveOutingMap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const LiveOutingMapScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
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
            // Header
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
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tr(
                            eu: 'Mendiko Irteerak',
                            es: 'Salidas al Monte',
                            en: 'Foraging Outings',
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AutumnColors.boletusBrown,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          s.tr(
                            eu: 'GPS ibilbideak eta bildutako perretxikoen laburpena',
                            es: 'Rutas GPS grabadas y resumen de setas recogidas',
                            en: 'Recorded GPS routes & harvested mushroom summary',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AutumnColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!activeOuting.isRecording)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AutumnColors.mossGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onPressed: _promptStartNewOuting,
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 18),
                      label: Text(
                        s.tr(
                          eu: 'Irteera Berria',
                          es: 'Nueva Salida',
                          en: 'New Outing',
                        ),
                      ),
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
                  lang: lang,
                  mapController: _liveMapController,
                  elapsedFormatted: _formatElapsed(activeOuting.elapsedSeconds),
                  outingSpots: allSpots
                      .where((s) => s.outingId == activeOuting.activeOutingId)
                      .toList(),
                  onOpenFullscreenLiveMap: _openFullscreenLiveOutingMap,
                  onAddPointTap: (latLng) {
                    ref
                        .read(activeOutingRecorderProvider.notifier)
                        .addRoutePoint(latLng);
                  },
                  onRegisterFind: () =>
                      _openRegisterFindInActiveOuting(activeOuting),
                  onPickSpotOnMap: () => _openMapSpotPickerForOuting(
                    activeOuting.activeOutingId!,
                    activeOuting.title,
                  ),
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
                            Text(
                              s.tr(
                                eu: 'Oraindik ez duzu mendiko irteerarik dokumentatu.\nSakatu "Irteera Berria" zure GPS ibilbidea eta jasotako perretxikoak grabatzeko.',
                                es: 'Aún no has documentado ninguna salida al monte.\nPulsa "Nueva Salida" para grabar tu recorrido GPS y las setas que recojas.',
                                en: 'You have not documented any foraging outing yet.\nTap "New Outing" to record your GPS track and found mushrooms.',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                        lang: lang,
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
                        onAddSpotOnMap: () =>
                            _openMapSpotPickerForOuting(outing.id, outing.title),
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
  final AppLanguage lang;
  final MapController mapController;
  final String elapsedFormatted;
  final List<ForagingSpot> outingSpots;
  final ValueChanged<LatLng> onAddPointTap;
  final VoidCallback onRegisterFind;
  final VoidCallback onTogglePause;
  final VoidCallback onFinish;
  final VoidCallback? onPickSpotOnMap;
  final VoidCallback? onOpenFullscreenLiveMap;

  const _ActiveOutingRecorderCard({
    required this.activeState,
    required this.lang,
    required this.mapController,
    required this.elapsedFormatted,
    required this.outingSpots,
    required this.onAddPointTap,
    required this.onRegisterFind,
    required this.onTogglePause,
    required this.onFinish,
    this.onPickSpotOnMap,
    this.onOpenFullscreenLiveMap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    final center = activeState.routePoints.isNotEmpty
        ? activeState.routePoints.last
        : (outingSpots.isNotEmpty
            ? LatLng(outingSpots.last.latitude, outingSpots.last.longitude)
            : const LatLng(43.0340, -2.7270));
    final km = (activeState.distanceMeters / 1000.0).toStringAsFixed(2);
    final totalSpecimens =
        outingSpots.fold<int>(0, (sum, sp) => sum + sp.quantityCount);

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.tr(eu: "Grabatzen", es: "Grabando", en: "Recording")}: ${activeState.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (activeState.isManual)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          s.tr(
                            eu: 'Eskuzko irteera (GPS aktiborik gabe)',
                            es: 'Salida Manual (Sin GPS activo)',
                            en: 'Manual Outing (No active GPS)',
                          ),
                          style: TextStyle(
                            color: AutumnColors.amberLeaf.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
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
          // Mapa en vivo de la ruta (pulsar para ampliar a pantalla completa)
          GestureDetector(
            onTap: onOpenFullscreenLiveMap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                height: 145,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: center,
                        initialZoom: 14.2,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                        onTap: (_, __) => onOpenFullscreenLiveMap?.call(),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.perretxikotan.perretxikotan',
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
                              (sp) => Marker(
                                point: LatLng(sp.latitude, sp.longitude),
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
                    // Botón flotante para ampliar a pantalla completa
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              s.tr(eu: 'Handitu', es: 'Ampliar', en: 'Expand'),
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
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.tr(
                            eu: 'Sakatu mapa ikuspegi murgilgarrirako',
                            es: 'Toca el mapa para abrir vista inmersiva',
                            en: 'Tap map to open immersive view',
                          ),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  activeState.isManual
                      ? s.tr(
                          eu: 'Eskuzko modua (GPS gabe) · Saskia: $totalSpecimens ale (${outingSpots.length} leku)',
                          es: 'Modo Manual (Sin GPS) · Cesta: $totalSpecimens ej. (${outingSpots.length} puntos)',
                          en: 'Manual Mode (No GPS) · Basket: $totalSpecimens spec. (${outingSpots.length} spots)',
                        )
                      : s.tr(
                          eu: 'Distantzia: $km km · Saskia: $totalSpecimens ale (${outingSpots.length} leku)',
                          es: 'Distancia: $km km · Cesta: $totalSpecimens ej. (${outingSpots.length} puntos)',
                          en: 'Distance: $km km · Basket: $totalSpecimens spec. (${outingSpots.length} spots)',
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AutumnColors.warmSand.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activeState.isManual
                    ? s.tr(
                        eu: 'Sakatu mapa kokatzeko',
                        es: 'Toca mapa para ubicar',
                        en: 'Tap map to place spot',
                      )
                    : s.tr(
                        eu: 'Sakatu mapa urratsa marrazteko',
                        es: 'Toca el mapa para trazar paso',
                        en: 'Tap map to trace step',
                      ),
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
                  label: Text(
                    s.tr(
                      eu: 'Seta Hemen Anotatu',
                      es: 'Anotar Seta Aquí',
                      en: 'Spot Mushroom Here',
                    ),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
              if (onPickSpotOnMap != null) ...[
                const SizedBox(width: 6),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AutumnColors.amberLeaf,
                    foregroundColor: Colors.white,
                  ),
                  tooltip: s.tr(
                    eu: 'Kokatu seta mapan pantaila osoan',
                    es: 'Ubicar seta en el mapa a pantalla completa',
                    en: 'Locate mushroom on fullscreen map',
                  ),
                  onPressed: onPickSpotOnMap,
                  icon: const Icon(Icons.touch_app_rounded, size: 20),
                ),
              ],
              if (onOpenFullscreenLiveMap != null) ...[
                const SizedBox(width: 6),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                  ),
                  tooltip: s.tr(
                    eu: 'Handitu mapa pantaila osora',
                    es: 'Ampliar mapa a pantalla completa',
                    en: 'Expand map to fullscreen',
                  ),
                  onPressed: onOpenFullscreenLiveMap,
                  icon: const Icon(Icons.fullscreen_rounded, size: 20),
                ),
              ],
              const SizedBox(width: 6),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AutumnColors.mossGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: onFinish,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  s.tr(
                    eu: 'Amaitu',
                    es: 'Terminar',
                    en: 'Finish',
                  ),
                ),
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
  final AppLanguage lang;
  final List<ForagingSpot> outingSpots;
  final List<OutingHarvestItem> harvestItems;
  final List<Mushroom> catalogMushrooms;
  final VoidCallback onTap;
  final VoidCallback? onViewOnGlobalMap;
  final VoidCallback? onAddSpotOnMap;
  final VoidCallback onDelete;

  const _OutingSummaryCard({
    required this.outing,
    required this.lang,
    required this.outingSpots,
    required this.harvestItems,
    required this.catalogMushrooms,
    required this.onTap,
    this.onViewOnGlobalMap,
    this.onAddSpotOnMap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
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
                  // Mini-mapa con fondo cartográfico real de la ruta GPS y sus hallazgos
                  _OutingRouteMiniMap(
                    routePoints: outing.routePoints,
                    spotPoints: outingSpots
                        .map((sp) => LatLng(sp.latitude, sp.longitude))
                        .toList(),
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
                        if (outing.isManual)
                          Container(
                            margin: const EdgeInsets.only(top: 4, bottom: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AutumnColors.amberLeaf.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AutumnColors.amberLeaf
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.touch_app_rounded,
                                  size: 13,
                                  color: AutumnColors.boletusBrown,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  s.tr(
                                    eu: 'Eskuzko Irteera (GPS gabe)',
                                    es: 'Salida Manual (Sin GPS)',
                                    en: 'Manual Outing (No GPS)',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AutumnColors.boletusBrown,
                                  ),
                                ),
                              ],
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
                              label: outing.isManual
                                  ? s.tr(
                                      eu: 'Eskuzkoa (GPS gabe)',
                                      es: 'Manual (Sin GPS)',
                                      en: 'Manual (No GPS)',
                                    )
                                  : outing.formattedDistanceKm,
                            ),
                            _MetricBadge(
                              icon: Icons.schedule_rounded,
                              label: outing.formattedDuration,
                            ),
                            _MetricBadge(
                              icon: Icons.shopping_basket_rounded,
                              label: totalGrams > 0
                                  ? '$totalSpecimens ${s.tr(eu: "ale", es: "ej.", en: "spec.")} (${totalGrams}g)'
                                  : '$totalSpecimens ${s.tr(eu: "ale", es: "ej.", en: "spec.")}',
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
                    '${s.tr(eu: "Bildutako perretxikoak", es: "Setas recogidas", en: "Mushroom harvest")} (${outingSpots.length} ${s.tr(eu: "leku", es: "ubicaciones", en: "spots")}):',
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
                Text(
                  s.tr(
                    eu: 'Ibilbidean ez da aurkikuntzarik erregistratu.',
                    es: 'Ruta sin hallazgos registrados.',
                    en: 'Route with no recorded finds.',
                  ),
                  style: const TextStyle(
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
                    final itemMushroomName = matchedMushroom != null
                        ? (lang == AppLanguage.eu
                            ? matchedMushroom.basqueName
                            : (lang == AppLanguage.en
                                ? matchedMushroom.englishName
                                : matchedMushroom.spanishName))
                        : item.mushroomName;
                    final weightPart = item.totalWeightGrams > 0
                        ? ' (${item.totalWeightGrams}g)'
                        : '';

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
                            '${item.totalSpecimens}x $itemMushroomName$weightPart',
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

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onAddSpotOnMap != null)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AutumnColors.boletusBrown,
                        side: const BorderSide(color: AutumnColors.amberLeaf),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                      ),
                      onPressed: onAddSpotOnMap,
                      icon: const Icon(
                        Icons.add_location_alt_rounded,
                        size: 15,
                      ),
                      label: Text(
                        s.tr(
                          eu: 'Mapan gehitu',
                          es: 'Añadir en mapa',
                          en: 'Add on map',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  if (onViewOnGlobalMap != null) ...[
                    const SizedBox(width: 8),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AutumnColors.mossGreen,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onViewOnGlobalMap,
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: Text(
                        s.tr(
                          eu: 'Mapan Ikusi',
                          es: 'Ver en Mapa',
                          en: 'View on Map',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
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

/// Miniatura de mapa real con fondo topográfico, trazado GPS y puntos de setas.
class _OutingRouteMiniMap extends StatelessWidget {
  final List<LatLng> routePoints;
  final List<LatLng> spotPoints;

  const _OutingRouteMiniMap({
    required this.routePoints,
    required this.spotPoints,
  });

  ({LatLng center, double zoom}) _computeCamera() {
    final all = [...routePoints, ...spotPoints];
    if (all.isEmpty) {
      return (center: const LatLng(43.0340, -2.7270), zoom: 12.5);
    }

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

    final center = LatLng((minLat + maxLat) / 2.0, (minLng + maxLng) / 2.0);
    final maxSpan = math.max(maxLat - minLat, maxLng - minLng);

    double zoom;
    if (maxSpan < 0.002) {
      zoom = 15.0;
    } else if (maxSpan < 0.006) {
      zoom = 14.0;
    } else if (maxSpan < 0.015) {
      zoom = 13.0;
    } else if (maxSpan < 0.035) {
      zoom = 12.0;
    } else if (maxSpan < 0.08) {
      zoom = 11.0;
    } else {
      zoom = 10.0;
    }

    return (center: center, zoom: zoom);
  }

  @override
  Widget build(BuildContext context) {
    final cam = _computeCamera();

    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: AutumnColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AutumnColors.warmSand, width: 1.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: IgnorePointer(
          child: FlutterMap(
            options: MapOptions(
              initialCenter: cam.center,
              initialZoom: cam.zoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.perretxikotan.perretxikotan',
              ),
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.white.withValues(alpha: 0.85),
                      strokeWidth: 5.0,
                    ),
                    Polyline(
                      points: routePoints,
                      color: AutumnColors.terracotta,
                      strokeWidth: 3.2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  ...spotPoints.map(
                    (pt) => Marker(
                      point: pt,
                      width: 12,
                      height: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AutumnColors.mossGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pantalla de detalle completo de una Salida al Monte.
class OutingDetailScreen extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final center = outing.routePoints.isNotEmpty
        ? outing.routePoints.first
        : (outingSpots.isNotEmpty
            ? LatLng(outingSpots.first.latitude, outingSpots.first.longitude)
            : const LatLng(43.0358, -2.7289));

    return Scaffold(
      backgroundColor: AutumnColors.parchmentBg,
      appBar: AppBar(
        title: Text(outing.title),
        actions: [
          IconButton(
            tooltip: s.tr(
              eu: 'Gehitu perretxikoa mapan hautatuz',
              es: 'Añadir seta seleccionando en el mapa',
              en: 'Add mushroom selecting on map',
            ),
            icon: const Icon(Icons.add_location_alt_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MapSpotPickerScreen(
                    outingId: outing.id,
                    outingTitle: outing.title,
                    initialCenter: center,
                  ),
                ),
              );
            },
          ),
        ],
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
                    userAgentPackageName: 'com.perretxikotan.perretxikotan',
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
                      label: s.tr(eu: 'Distantzia', es: 'Distancia', en: 'Distance'),
                      value: outing.isManual
                          ? s.tr(eu: 'Eskuzkoa (GPS gabe)', es: 'Manual (Sin GPS)', en: 'Manual (No GPS)')
                          : outing.formattedDistanceKm,
                      icon: Icons.straighten_rounded,
                    ),
                    _DetailStatColumn(
                      label: s.tr(eu: 'Iraupena', es: 'Duración', en: 'Duration'),
                      value: outing.formattedDuration,
                      icon: Icons.timer_rounded,
                    ),
                    _DetailStatColumn(
                      label: s.tr(eu: 'Aurkikuntzak', es: 'Hallazgos', en: 'Finds'),
                      value: '${outingSpots.length} ${s.tr(eu: "leku", es: "puntos", en: "spots")}',
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
            s.tr(
              eu: 'Irteerako Saskia Espezieka',
              es: 'Cesta de la Salida por Especie',
              en: 'Harvest Basket by Species',
            ),
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
            final mName = mushroom != null
                ? (lang == AppLanguage.eu
                    ? mushroom.basqueName
                    : (lang == AppLanguage.en
                        ? mushroom.englishName
                        : mushroom.spanishName))
                : item.mushroomName;

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
                  mName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${item.totalSpecimens} ${s.tr(eu: "ale", es: "ejemplares", en: "specimens")} (${item.spotsCount} ${s.tr(eu: "leku", es: "punto(s)", en: "spot(s)")})${item.totalWeightGrams > 0 ? ' · ${item.totalWeightGrams} g' : ''}',
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

class OutingFindFormSheet extends ConsumerStatefulWidget {
  final LatLng position;
  final String outingId;
  final String outingTitle;
  final List<Mushroom> catalogMushrooms;

  const OutingFindFormSheet({
    super.key,
    required this.position,
    required this.outingId,
    required this.outingTitle,
    required this.catalogMushrooms,
  });

  @override
  ConsumerState<OutingFindFormSheet> createState() => _OutingFindFormSheetState();
}

class _OutingFindFormSheetState extends ConsumerState<OutingFindFormSheet> {
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '3');
  final _weightCtrl = TextEditingController();
  Mushroom? _selectedMushroom;

  @override
  void initState() {
    super.initState();
    final lang = ref.read(appLanguageProvider);
    final s = AppStrings(lang);
    if (widget.catalogMushrooms.isNotEmpty) {
      _selectedMushroom = widget.catalogMushrooms
          .where((m) => m.id == 'boletus_edulis')
          .firstOrNull ??
          widget.catalogMushrooms.first;
      final mName = lang == AppLanguage.eu
          ? _selectedMushroom!.basqueName.split('/').first.trim()
          : (lang == AppLanguage.en
              ? _selectedMushroom!.englishName
              : _selectedMushroom!.spanishName);
      _titleCtrl.text =
          '${s.tr(eu: "Aurkikuntza", es: "Hallazgo de", en: "Find of")}: $mName';
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
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
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
              '${s.tr(eu: "Seta gorde hemen", es: "Anotar Seta en", en: "Log Mushroom in")}: "${widget.outingTitle}"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AutumnColors.boletusBrown,
                  ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Mushroom>(
              initialValue: _selectedMushroom,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: s.tr(
                  eu: 'Katalogoko espeziea',
                  es: 'Especie del catálogo',
                  en: 'Catalog species',
                ),
                prefixIcon: const Icon(Icons.eco_rounded),
              ),
              items: widget.catalogMushrooms.map((m) {
                final mTitle = lang == AppLanguage.eu
                    ? m.basqueName
                    : (lang == AppLanguage.en ? m.englishName : m.spanishName);
                final mSubtitle = lang == AppLanguage.eu
                    ? m.spanishName
                    : m.scientificName;
                return DropdownMenuItem(
                  value: m,
                  child: Text(
                    '$mTitle · $mSubtitle',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (m) {
                setState(() {
                  _selectedMushroom = m;
                  if (m != null) {
                    final mName = lang == AppLanguage.eu
                        ? m.basqueName.split('/').first.trim()
                        : (lang == AppLanguage.en ? m.englishName : m.spanishName);
                    _titleCtrl.text =
                        '${s.tr(eu: "Aurkikuntza", es: "Hallazgo de", en: "Find of")}: $mName';
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
                    decoration: InputDecoration(
                      labelText: s.tr(
                        eu: 'Ale kopurua',
                        es: 'Nº ejemplares',
                        en: 'Quantity',
                      ),
                      prefixIcon: const Icon(Icons.tag_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: s.tr(
                        eu: 'Gutxi gorabeherako pisua (g)',
                        es: 'Peso aprox. (g)',
                        en: 'Approx. weight (g)',
                      ),
                      hintText: s.tr(eu: 'Aukerakoa', es: 'Opcional', en: 'Optional'),
                      prefixIcon: const Icon(Icons.scale_rounded),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: s.tr(
                  eu: 'Ohar deskribatzailea',
                  es: 'Nota descriptiva',
                  en: 'Descriptive note',
                ),
                hintText: s.tr(
                  eu: 'Adib. Bi pinu azpian erreka ondoan...',
                  es: 'Ej. Junto al arroyo bajo dos hayas...',
                  en: 'E.g. Next to stream under two beeches...',
                ),
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
                        ? s.tr(
                            eu: 'Irteerako aurkikuntza',
                            es: 'Hallazgo en salida',
                            en: 'Find in outing',
                          )
                        : _titleCtrl.text.trim(),
                    latitude: widget.position.latitude,
                    longitude: widget.position.longitude,
                    mushroomId: m?.id,
                    mushroomName: m != null
                        ? (lang == AppLanguage.eu
                            ? m.basqueName
                            : (lang == AppLanguage.en
                                ? m.englishName
                                : m.spanishName))
                        : s.tr(
                            eu: 'Basoko perretxikoa',
                            es: 'Seta silvestre',
                            en: 'Wild mushroom',
                          ),
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
                label: Text(
                  s.tr(
                    eu: 'Irteeran eta Mapa Orokorrean Gorde',
                    es: 'Guardar en la Salida y Mapa Global',
                    en: 'Save to Outing and Global Map',
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
