import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../localization/app_localizations.dart';
import '../services/gps_accuracy_service.dart';
import '../theme/autumn_theme.dart';

/// Modal interactivo de fijación previa de señal GPS.
/// Garantiza que el móvil localice satélites con precisión antes de iniciar una salida o registrar un setal.
class GpsAcquisitionSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? confirmButtonLabel;
  final double targetAccuracyMeters;
  final AppLanguage lang;

  const GpsAcquisitionSheet({
    super.key,
    required this.title,
    this.subtitle,
    this.confirmButtonLabel,
    this.targetAccuracyMeters = GpsAccuracyService.targetAccuracyMeters,
    required this.lang,
  });

  /// Alias de compatibilidad para salidas
  String get outingTitle => subtitle ?? title;

  static Future<LatLng?> show(
    BuildContext context, {
    String? title,
    String? outingTitle,
    String? subtitle,
    String? confirmButtonLabel,
    double targetAccuracyMeters = GpsAccuracyService.targetAccuracyMeters,
    required AppLanguage lang,
  }) {
    final effectiveTitle = title ?? outingTitle ?? 'ZizAI';
    final effectiveSubtitle = subtitle ?? (outingTitle != null && title != null ? outingTitle : null);
    return showModalBottomSheet<LatLng>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => GpsAcquisitionSheet(
        title: effectiveTitle,
        subtitle: effectiveSubtitle,
        confirmButtonLabel: confirmButtonLabel,
        targetAccuracyMeters: targetAccuracyMeters,
        lang: lang,
      ),
    );
  }

  @override
  State<GpsAcquisitionSheet> createState() => _GpsAcquisitionSheetState();
}

class _GpsAcquisitionSheetState extends State<GpsAcquisitionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  StreamSubscription<Position>? _positionSub;

  Position? _latestPosition;
  double? _bestAccuracy;
  bool _isAutoStarting = false;
  int _countdownSeconds = 2;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _startListeningGps();
  }

  void _onPositionUpdate(Position pos) {
    if (!mounted) return;
    setState(() {
      _latestPosition = pos;
      if (_bestAccuracy == null || pos.accuracy < _bestAccuracy!) {
        _bestAccuracy = pos.accuracy;
      }
    });

    // Si la precisión alcanza el umbral objetivo, iniciar cuenta de confirmación
    if (pos.accuracy <= widget.targetAccuracyMeters && !_isAutoStarting) {
      _triggerAutoStart(pos);
    }
  }

  void _startListeningGps() {
    _positionSub = GpsAccuracyService.getPositionStream(distanceFilter: 0).listen(
      _onPositionUpdate,
      onError: (_) {},
    );

    unawaited(() async {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted && _latestPosition == null) {
          _onPositionUpdate(last);
        }
      } catch (_) {}
      try {
        final current = await Geolocator.getCurrentPosition();
        if (mounted && _latestPosition == null) {
          _onPositionUpdate(current);
        }
      } catch (_) {}
    }());
  }

  void _triggerAutoStart(Position finalPos) {
    setState(() {
      _isAutoStarting = true;
      _countdownSeconds = 2;
    });

    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    // Cancelar la suscripción de fijación GPS para liberar el canal nativo antes de iniciar la salida
    _positionSub?.cancel();
    _positionSub = null;

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdownSeconds--);
      if (_countdownSeconds <= 0) {
        timer.cancel();
        _confirmStart(finalPos);
      }
    });
  }

  void _confirmStart([Position? pos]) {
    final p = pos ?? _latestPosition;
    _positionSub?.cancel();
    _positionSub = null;
    if (p != null) {
      Navigator.of(context).pop(LatLng(p.latitude, p.longitude));
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _positionSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final accuracy = _latestPosition?.accuracy;
    final quality = accuracy != null
        ? GpsAccuracyService.classifyAccuracy(accuracy)
        : GpsSignalQuality.poor;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
      decoration: const BoxDecoration(
        color: AutumnColors.parchmentBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de arrastre
          Container(
            width: 44,
            height: 4.5,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AutumnColors.warmSand,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Título o subtítulo superior
          if (widget.subtitle != null || widget.title.isNotEmpty)
            Text(
              widget.subtitle ?? widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AutumnColors.textSecondary,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            widget.subtitle != null
                ? widget.title
                : s.tr(
                    eu: 'GPS Seinalea Zehazten...',
                    es: 'Fijando Señal GPS...',
                    en: 'Acquiring GPS Fix...',
                  ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AutumnColors.boletusBrown,
            ),
          ),
          const SizedBox(height: 18),

          // Radar pulsante con satélite
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.45);
                  final opacity = (1.0 - _pulseController.value).clamp(0.0, 1.0);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: quality.color.withValues(alpha: opacity * 0.28),
                      ),
                    ),
                  );
                },
              ),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: quality.color.withValues(alpha: 0.15),
                  border: Border.all(color: quality.color, width: 2.5),
                ),
                child: Icon(
                  quality == GpsSignalQuality.optimal
                      ? Icons.gps_fixed_rounded
                      : Icons.satellite_alt_rounded,
                  size: 34,
                  color: quality.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Texto de estado y medidor
          Text(
            quality.localizedStatus(widget.lang, accuracy),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: quality.color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            accuracy != null
                ? s.tr(
                    eu: 'Helburua: < ${GpsAccuracyService.targetAccuracyMeters.toInt()}m errore-marjina garbia lortzeko.',
                    es: 'Objetivo: < ${GpsAccuracyService.targetAccuracyMeters.toInt()}m de margen para evitar desvíos en el bosque.',
                    en: 'Goal: < ${GpsAccuracyService.targetAccuracyMeters.toInt()}m margin to prevent erratic route jumps.',
                  )
                : s.tr(
                    eu: 'Zeru irekira begira jarri gailua sateliteak azkarrago hartzeko...',
                    es: 'Apunta el móvil al cielo despejado para sincronizar satélites...',
                    en: 'Point phone towards open sky to sync satellites faster...',
                  ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AutumnColors.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),

          // Barra de precisión
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: accuracy != null
                  ? (1.0 - (accuracy / 60.0)).clamp(0.12, 1.0)
                  : null,
              backgroundColor: AutumnColors.warmSand,
              valueColor: AlwaysStoppedAnimation<Color>(quality.color),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _positionSub?.cancel();
                    _positionSub = null;
                    Navigator.of(context).pop(null);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: AutumnColors.warmSand),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel'),
                    style: const TextStyle(
                      color: AutumnColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _latestPosition != null
                      ? () => _confirmStart(_latestPosition)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: quality.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    _isAutoStarting
                        ? Icons.timer_outlined
                        : (widget.confirmButtonLabel != null
                            ? Icons.check_circle_outline_rounded
                            : Icons.play_arrow_rounded),
                  ),
                  label: Text(
                    _isAutoStarting
                        ? (widget.confirmButtonLabel != null
                            ? '${widget.confirmButtonLabel} ($_countdownSeconds s)...'
                            : s.tr(
                                eu: 'Hasten ($_countdownSeconds s)...',
                                es: 'Empezando en $_countdownSeconds s...',
                                en: 'Starting in ${_countdownSeconds}s...',
                              ))
                        : accuracy != null
                            ? (widget.confirmButtonLabel != null
                                ? '${widget.confirmButtonLabel} (±${accuracy.toInt()}m)'
                                : s.tr(
                                    eu: 'Hasi Orain (±${accuracy.toInt()}m)',
                                    es: 'Empezar ya (±${accuracy.toInt()}m)',
                                    en: 'Start now (±${accuracy.toInt()}m)',
                                  ))
                            : s.tr(
                                eu: 'Sateliteak itxaroten...',
                                es: 'Esperando GPS...',
                                en: 'Waiting GPS...',
                              ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                    ),
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
