import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../localization/app_localizations.dart';

/// Niveles de calidad de la fijación de señal GPS en el monte.
enum GpsSignalQuality {
  /// Buscando satélites o precisión insuficiente (> 35 m).
  poor,

  /// Precisión intermedia (15 m - 35 m).
  acceptable,

  /// Señal óptima para tracking de precisión (< 15 m).
  optimal;

  Color get color {
    switch (this) {
      case GpsSignalQuality.optimal:
        return const Color(0xFF2E7D32); // Verde bosque
      case GpsSignalQuality.acceptable:
        return const Color(0xFFE65100); // Ámbar cálido
      case GpsSignalQuality.poor:
        return const Color(0xFFC62828); // Rojo alerta
    }
  }

  String localizedStatus(AppLanguage lang, double? accuracyMeters) {
    final s = AppStrings(lang);
    final accStr = accuracyMeters != null ? ' (±${accuracyMeters.toStringAsFixed(0)}m)' : '';
    switch (this) {
      case GpsSignalQuality.optimal:
        return s.tr(
          eu: 'GPS seinale ezin hobea$accStr',
          es: 'Señal GPS óptima$accStr',
          en: 'Optimal GPS fix$accStr',
        );
      case GpsSignalQuality.acceptable:
        return s.tr(
          eu: 'GPS seinalea hobetzen$accStr...',
          es: 'Afinando precisión GPS$accStr...',
          en: 'Refining GPS accuracy$accStr...',
        );
      case GpsSignalQuality.poor:
        return s.tr(
          eu: 'Sateliteak bilatzen$accStr...',
          es: 'Buscando satélites$accStr...',
          en: 'Acquiring satellites$accStr...',
        );
    }
  }
}

class GpsAccuracyService {
  GpsAccuracyService._();

  /// Umbral objetivo de precisión óptima en metros para auto-iniciar grabación.
  static const double targetAccuracyMeters = 15.0;

  /// Margen máximo aceptable en metros para registrar puntos en ruta sin ruido.
  static const double maxAcceptableAccuracyMeters = 35.0;

  /// Clasifica la precisión según los estándares de geolocalización en senderismo.
  static GpsSignalQuality classifyAccuracy(double accuracyMeters) {
    if (accuracyMeters <= targetAccuracyMeters) {
      return GpsSignalQuality.optimal;
    }
    if (accuracyMeters <= maxAcceptableAccuracyMeters) {
      return GpsSignalQuality.acceptable;
    }
    return GpsSignalQuality.poor;
  }

  /// Verifica si el hardware de GPS está habilitado y solicita permisos si faltan.
  static Future<bool> ensureLocationPermission(
    BuildContext context, {
    AppLanguage lang = AppLanguage.es,
  }) async {
    final s = AppStrings(lang);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        final openSettings = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(
              s.tr(
                eu: 'GPSa desgaituta dago',
                es: 'GPS desactivado',
                en: 'GPS is disabled',
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              s.tr(
                eu: 'Gaitu gailuaren kokapen-zerbitzua mendiko ibilbidea zehaztasunez grabatzeko.',
                es: 'Activa la ubicación del dispositivo para registrar con precisión tu ruta micológica.',
                en: 'Please enable location services to accurately record your foraging track.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(s.tr(eu: 'Utzi', es: 'Cancelar', en: 'Cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(
                  s.tr(
                    eu: 'Ireki Ezarpenak',
                    es: 'Abrir Ajustes',
                    en: 'Open Settings',
                  ),
                ),
              ),
            ],
          ),
        );
        if (openSettings == true) {
          await Geolocator.openLocationSettings();
        }
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.tr(
                eu: 'Kokapen baimena beharrezkoa da GPS bidez grabatzeko.',
                es: 'Se requiere permiso de ubicación para registrar con GPS.',
                en: 'Location permission required for GPS recording.',
              ),
            ),
            action: permission == LocationPermission.deniedForever
                ? SnackBarAction(
                    label: s.tr(eu: 'Ajusteak', es: 'Ajustes', en: 'Settings'),
                    onPressed: () => Geolocator.openAppSettings(),
                  )
                : null,
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Escucha en directo la señal GPS con alta precisión.
  static Stream<Position> getPositionStream({
    int distanceFilter = 5,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Espera activamente a que el GPS obtenga una posición con precisión adecuada.
  static Future<Position?> acquireAccurateFix({
    double maxAcceptableMeters = 30.0,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final completer = Completer<Position?>();
    StreamSubscription<Position>? sub;
    Position? bestSeen;

    void onCandidatePosition(Position pos) {
      if (bestSeen == null || pos.accuracy < bestSeen!.accuracy) {
        bestSeen = pos;
      }
      if (pos.accuracy <= maxAcceptableMeters && !completer.isCompleted) {
        sub?.cancel();
        completer.complete(pos);
      }
    }

    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        sub?.cancel();
        completer.complete(bestSeen);
      }
    });

    try {
      sub = getPositionStream(distanceFilter: 0).listen(
        (pos) {
          onCandidatePosition(pos);
          if (completer.isCompleted) {
            timer.cancel();
          }
        },
        onError: (_) {
          if (!completer.isCompleted && bestSeen != null) {
            timer.cancel();
            sub?.cancel();
            completer.complete(bestSeen);
          }
        },
      );

      // Consultar también posición puntual por si el stream no emite cambios en reposo/emulador
      unawaited(() async {
        try {
          final current = await Geolocator.getCurrentPosition();
          onCandidatePosition(current);
          if (completer.isCompleted) {
            timer.cancel();
          }
        } catch (_) {
          try {
            final last = await Geolocator.getLastKnownPosition();
            if (last != null) {
              onCandidatePosition(last);
              if (completer.isCompleted) {
                timer.cancel();
              }
            }
          } catch (_) {}
        }
      }());
    } catch (_) {
      timer.cancel();
      sub?.cancel();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }

    return completer.future;
  }
}
