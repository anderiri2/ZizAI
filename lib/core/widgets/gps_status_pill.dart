import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../services/gps_accuracy_service.dart';
import '../theme/autumn_theme.dart';

/// Píldora flotante no intrusiva para retroalimentación visual al fijar coordenadas GPS en mapas y formularios.
class GpsStatusPill extends StatelessWidget {
  final double? accuracyMeters;
  final bool isLoading;
  final VoidCallback? onCancel;

  const GpsStatusPill({
    super.key,
    this.accuracyMeters,
    this.isLoading = true,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguage.fromLocale(Localizations.maybeLocaleOf(context));
    final s = AppStrings(lang);

    final quality = accuracyMeters != null
        ? GpsAccuracyService.classifyAccuracy(accuracyMeters!)
        : GpsSignalQuality.poor;

    final label = accuracyMeters != null
        ? quality == GpsSignalQuality.optimal
            ? s.tr(
                eu: 'GPS finkatua (±${accuracyMeters!.toStringAsFixed(0)}m)',
                es: 'GPS fijado (±${accuracyMeters!.toStringAsFixed(0)}m)',
                en: 'GPS locked (±${accuracyMeters!.toStringAsFixed(0)}m)',
              )
            : s.tr(
                eu: 'GPSa zehazten (±${accuracyMeters!.toStringAsFixed(0)}m)...',
                es: 'Afinando GPS (±${accuracyMeters!.toStringAsFixed(0)}m)...',
                en: 'Refining GPS (±${accuracyMeters!.toStringAsFixed(0)}m)...',
              )
        : s.tr(
            eu: 'Sateliteak bilatzen...',
            es: 'Buscando satélites...',
            en: 'Acquiring satellites...',
          );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AutumnColors.parchmentBg.withValues(alpha: 0.94),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: quality.color.withValues(alpha: 0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(quality.color),
                ),
              )
            else
              Icon(
                quality == GpsSignalQuality.optimal
                    ? Icons.gps_fixed_rounded
                    : Icons.satellite_alt_rounded,
                size: 16,
                color: quality.color,
              ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: quality.color,
              ),
            ),
            if (onCancel != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onCancel,
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: AutumnColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
