import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../ai_identifier/services/gemini_mushroom_service.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../map/data/spots_database.dart';
import '../../map/models/foraging_spot.dart';
import '../../map/services/offline_map_service.dart';
import '../../outings/data/outings_database.dart';
import '../../outings/models/foraging_outing.dart';
import '../services/google_drive_backup_service.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _smartMergeOnRestore = true;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final authState = ref.watch(googleDriveBackupProvider);
    final spots =
        ref.watch(foragingSpotsProvider).valueOrNull ?? const <ForagingSpot>[];
    final outings =
        ref.watch(outingsProvider).valueOrNull ?? const <ForagingOuting>[];
    final favorites = ref.watch(favoriteMushroomsProvider).toList();
    final aiMessages = ref.watch(geminiMushroomProvider).messages;
    final offlineRegions = ref.watch(offlineMapServiceProvider).regions;

    final photosCount = spots
            .where((sp) => sp.photoPath != null && sp.photoPath!.isNotEmpty)
            .length +
        aiMessages
            .where((m) => m.imagePath != null && m.imagePath!.isNotEmpty)
            .length;

    final totalKm = outings.fold<double>(0.0, (acc, o) => acc + o.distanceKm);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E6D3),
              AutumnColors.parchmentBg,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 130),
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AutumnColors.boletusBrown,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      color: AutumnColors.amberLeaf,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tr(
                            eu: 'Segurtasun-kopia Osoa',
                            es: 'Copia de Seguridad Integral',
                            en: 'Full Activity Cloud Backup',
                          ),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: AutumnColors.boletusBrown,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        Text(
                          s.tr(
                            eu: 'Google Drive pertsonala (WhatsApp erara) • %100 pribatua',
                            es: 'Google Drive personal (estilo WhatsApp) • 100% sin servidor propio',
                            en: 'Personal Google Drive (WhatsApp style) • 100% private',
                          ),
                          style: const TextStyle(
                            color: AutumnColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tarjeta de Cuenta de Google
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AutumnColors.barkDark,
                      AutumnColors.boletusBrown,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AutumnColors.barkDark.withValues(alpha: 0.2),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AutumnColors.amberLeaf.withValues(alpha: 0.25),
                          child: Icon(
                            authState.isAuthenticatedWithGoogle
                                ? Icons.verified_user_rounded
                                : Icons.person_outline_rounded,
                            color: AutumnColors.amberLeaf,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.isAuthenticatedWithGoogle
                                    ? (authState.userDisplayName ??
                                        'Cuenta de Google conectada')
                                    : 'Modo Local (Sin vincular a Google)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authState.isAuthenticatedWithGoogle
                                    ? (authState.userEmail ?? '')
                                    : 'Inicia sesión para activar Backup en Google Drive e IA Gemini',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!authState.isAuthenticatedWithGoogle)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: authState.isBusy
                              ? null
                              : () => ref
                                  .read(googleDriveBackupProvider.notifier)
                                  .signInWithGoogle(),
                          style: FilledButton.styleFrom(
                            backgroundColor: AutumnColors.ochreGold,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.login_rounded, size: 18),
                          label: const Text('Vincular Cuenta de Google'),
                        ),
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: authState.isBusy
                                  ? null
                                  : () => ref
                                      .read(googleDriveBackupProvider.notifier)
                                      .signOut(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.35),
                                ),
                              ),
                              icon: const Icon(Icons.logout_rounded, size: 17),
                              label: const Text('Cerrar sesión de Google'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Resumen de Toda la Actividad Registrada a Incluir en el Backup
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
                    const Text(
                      'Actividad Incluida en el Paquete perretxikotan_backup.zip',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AutumnColors.boletusBrown,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.place_rounded,
                            value: '${spots.length}',
                            label: 'Setales en Mapa',
                            color: AutumnColors.terracotta,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.hiking_rounded,
                            value:
                                '${outings.length} (${totalKm.toStringAsFixed(1)} km)',
                            label: 'Salidas GPS',
                            color: AutumnColors.mossGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.photo_camera_rounded,
                            value: '$photosCount',
                            label: 'Fotografías',
                            color: AutumnColors.ochreGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.favorite_rounded,
                            value: '${favorites.length}',
                            label: 'Setas Favoritas',
                            color: AutumnColors.dangerRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.auto_awesome_rounded,
                            value: '${aiMessages.length}',
                            label: 'Mensajes IA',
                            color: AutumnColors.boletusBrown,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.download_for_offline_rounded,
                            value: '${offlineRegions.length}',
                            label: 'Zonas Offline',
                            color: AutumnColors.mossGreen,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22),
                    _BackupTimestampRow(
                      icon: Icons.cloud_done_rounded,
                      label: 'Último backup en Google Drive:',
                      date: authState.lastDriveBackupDate,
                    ),
                    const SizedBox(height: 6),
                    _BackupTimestampRow(
                      icon: Icons.folder_zip_rounded,
                      label: 'Último snapshot ZIP en el dispositivo:',
                      date: authState.lastLocalBackupDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Configuración de Fusión Inteligente y Auto-Backup
              Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AutumnColors.warmSand),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AutumnColors.mossGreen,
                          title: const Text(
                            'Fusión Inteligente al Restaurar (Recomendado)',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                          subtitle: Text(
                            _smartMergeOnRestore
                                ? 'Combina los datos de Google Drive con los datos locales sin perder ninguna salida ni ubicación.'
                                : 'Modo Reemplazo: sustituye los datos actuales del teléfono por el contenido exacto del backup.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AutumnColors.textSecondary,
                            ),
                          ),
                          value: _smartMergeOnRestore,
                          onChanged: (v) =>
                              setState(() => _smartMergeOnRestore = v),
                        ),
                      ),
                      const Divider(height: 12),
                      Material(
                        color: Colors.transparent,
                        child: SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AutumnColors.ochreGold,
                          title: const Text(
                            'Copia automática tras registrar salidas',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                          subtitle: const Text(
                            'Sincroniza automáticamente tu actividad cuando tengas conexión.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AutumnColors.textSecondary,
                            ),
                          ),
                          value: authState.autoBackupEnabled,
                          onChanged: (v) => ref
                              .read(googleDriveBackupProvider.notifier)
                              .setAutoBackupEnabled(v),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Mensajes de estado o error
              if (authState.statusMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AutumnColors.mossGreen.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AutumnColors.mossGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AutumnColors.mossGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.statusMessage!,
                          style: const TextStyle(
                            color: AutumnColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (authState.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AutumnColors.cautionOrange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AutumnColors.cautionOrange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AutumnColors.cautionOrange,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: AutumnColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Acciones en la Nube (Google Drive appDataFolder)
              Text(
                'Nube Personal (Google Drive appDataFolder)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AutumnColors.boletusBrown,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: authState.isBusy
                    ? null
                    : () async {
                        await ref
                            .read(googleDriveBackupProvider.notifier)
                            .backupAllActivityToGoogleDrive(
                              spots: spots,
                              outings: outings,
                              favoriteIds: favorites,
                              aiMessages: aiMessages,
                              offlineRegions: offlineRegions,
                            );
                      },
                icon: authState.isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.cloud_upload_rounded),
                label: const Text(
                  'Respaldar Toda mi Actividad en Google Drive',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: authState.isBusy
                    ? null
                    : () async {
                        final payload = await ref
                            .read(googleDriveBackupProvider.notifier)
                            .restoreFullActivityFromGoogleDrive();
                        if (payload != null) {
                          await ref
                              .read(googleDriveBackupProvider.notifier)
                              .applyRestoredPayloadToApp(
                                ref,
                                payload,
                                smartMerge: _smartMergeOnRestore,
                              );
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AutumnColors.boletusBrown,
                  side: const BorderSide(
                    color: AutumnColors.boletusBrown,
                    width: 1.4,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.cloud_download_rounded),
                label: Text(
                  _smartMergeOnRestore
                      ? 'Restaurar desde Google Drive (Fusión Inteligente)'
                      : 'Restaurar desde Google Drive (Reemplazar Todo)',
                ),
              ),

              const SizedBox(height: 22),

              // Acciones de Copia Local Instantánea (Funciona 100% Offline)
              Text(
                'Copia de Respaldo Local (ZIP en el Teléfono)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AutumnColors.boletusBrown,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: authState.isBusy
                          ? null
                          : () => ref
                              .read(googleDriveBackupProvider.notifier)
                              .saveLocalSnapshotAllActivity(
                                spots: spots,
                                outings: outings,
                                favoriteIds: favorites,
                                aiMessages: aiMessages,
                                offlineRegions: offlineRegions,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AutumnColors.warmSand,
                        foregroundColor: AutumnColors.boletusBrown,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.save_alt_rounded, size: 18),
                      label: const Text('Guardar ZIP Local'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: authState.isBusy
                          ? null
                          : () async {
                              final payload = await ref
                                  .read(googleDriveBackupProvider.notifier)
                                  .restoreFromLocalSnapshotFullActivity();
                              if (payload != null) {
                                await ref
                                    .read(googleDriveBackupProvider.notifier)
                                    .applyRestoredPayloadToApp(
                                      ref,
                                      payload,
                                      smartMerge: _smartMergeOnRestore,
                                    );
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AutumnColors.warmSand,
                        foregroundColor: AutumnColors.boletusBrown,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.restore_page_rounded, size: 18),
                      label: const Text('Restaurar Local'),
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

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AutumnColors.parchmentBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: AutumnColors.boletusBrown,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              color: AutumnColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackupTimestampRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final DateTime? date;

  const _BackupTimestampRow({
    required this.icon,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = date != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(date!)
        : 'Sin realizar aún';
    return Row(
      children: [
        Icon(icon, size: 17, color: AutumnColors.mossGreen),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AutumnColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          formatted,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AutumnColors.boletusBrown,
          ),
        ),
      ],
    );
  }
}
