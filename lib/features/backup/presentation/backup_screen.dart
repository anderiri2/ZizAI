import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../map/data/spots_database.dart';
import '../services/google_drive_backup_service.dart';

class BackupScreen extends ConsumerWidget {
  final VoidCallback onSignOutToLogin;

  const BackupScreen({
    super.key,
    required this.onSignOutToLogin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleDriveBackupProvider);
    final spotsAsync = ref.watch(foragingSpotsProvider);
    final spots = spotsAsync.valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: AutumnColors.parchmentBg,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AutumnColors.ochreGold.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      color: AutumnColors.boletusBrown,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Copia de Seguridad',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AutumnColors.boletusBrown,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Text(
                          'Tus setales y notas en tu Google Drive personal',
                          style: TextStyle(
                            fontSize: 13,
                            color: AutumnColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Tarjeta de Estado de Cuenta de Google
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AutumnColors.warmSand),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: authState.isAuthenticatedWithGoogle
                              ? AutumnColors.mossGreen.withValues(alpha: 0.16)
                              : AutumnColors.creamCard,
                          child: Icon(
                            authState.isAuthenticatedWithGoogle
                                ? Icons.verified_user_rounded
                                : Icons.person_outline_rounded,
                            color: authState.isAuthenticatedWithGoogle
                                ? AutumnColors.mossGreen
                                : AutumnColors.boletusBrown,
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
                                    : 'Modo Local (Sin cuenta Google conectada)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AutumnColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authState.isAuthenticatedWithGoogle
                                    ? (authState.userEmail ?? '')
                                    : 'Conecta tu cuenta de Google para sincronizar con Drive',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AutumnColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (!authState.isAuthenticatedWithGoogle)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: authState.isBusy
                              ? null
                              : () {
                                  ref
                                      .read(googleDriveBackupProvider.notifier)
                                      .signInWithGoogle();
                                },
                          icon: const Icon(Icons.login_rounded, size: 19),
                          label: const Text('Conectar cuenta de Google'),
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AutumnColors.terracotta,
                          ),
                          onPressed: () async {
                            await ref
                                .read(googleDriveBackupProvider.notifier)
                                .signOut();
                            onSignOutToLogin();
                          },
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Cerrar sesión'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Mensajes de estado o error
              if (authState.statusMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AutumnColors.mossGreen.withValues(alpha: 0.12),
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
                            color: AutumnColors.mossGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (authState.errorMessage != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AutumnColors.edibilityToxic.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          AutumnColors.edibilityToxic.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: AutumnColors.edibilityToxic,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: const TextStyle(
                            color: AutumnColors.edibilityToxic,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Sección Google Drive Backup (Estilo WhatsApp appDataFolder)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AutumnColors.warmSand),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color:
                                AutumnColors.mossGreen.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.cloud_done_rounded,
                            color: AutumnColors.mossGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Backup en Google Drive (Estilo WhatsApp)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AutumnColors.boletusBrown,
                                ),
                              ),
                              Text(
                                'Carpeta privada oculta (appDataFolder)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AutumnColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _BackupStatRow(
                      label: 'Ubicaciones y notas registradas',
                      value: '${spots.length} setales',
                    ),
                    const SizedBox(height: 6),
                    _BackupStatRow(
                      label: 'Última copia en Google Drive',
                      value: authState.lastDriveBackupDate != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(authState.lastDriveBackupDate!)
                          : 'Ninguna copia realizada aún',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AutumnColors.mossGreen,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: authState.isBusy
                            ? null
                            : () async {
                                await ref
                                    .read(googleDriveBackupProvider.notifier)
                                    .backupToGoogleDrive(spots);
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
                        label: const Text('Guardar Copia en Google Drive'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AutumnColors.boletusBrown,
                          side: const BorderSide(color: AutumnColors.warmSand),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: authState.isBusy
                            ? null
                            : () async {
                                final restored = await ref
                                    .read(googleDriveBackupProvider.notifier)
                                    .restoreFromGoogleDrive();
                                if (restored != null) {
                                  await ref
                                      .read(foragingSpotsProvider.notifier)
                                      .restoreSpots(restored);
                                }
                              },
                        icon: const Icon(Icons.cloud_download_rounded),
                        label: const Text('Restaurar desde Google Drive'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Sección Copia de Seguridad Local (Offline Snapshot)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AutumnColors.warmSand),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color:
                                AutumnColors.ochreGold.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.folder_zip_rounded,
                            color: AutumnColors.ochreGold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instantánea Local sin Conexión (ZIP)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: AutumnColors.boletusBrown,
                                ),
                              ),
                              Text(
                                'Guarda un paquete comprimido en tu teléfono',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: AutumnColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _BackupStatRow(
                      label: 'Última instantánea local',
                      value: authState.lastLocalBackupDate != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(authState.lastLocalBackupDate!)
                          : 'Ninguna instantánea aún',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AutumnColors.creamCard,
                              foregroundColor: AutumnColors.boletusBrown,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: authState.isBusy
                                ? null
                                : () async {
                                    await ref
                                        .read(
                                            googleDriveBackupProvider.notifier)
                                        .saveLocalBackupSnapshot(spots);
                                  },
                            icon: const Icon(Icons.archive_rounded, size: 18),
                            label: const Text('Crear ZIP local'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AutumnColors.boletusBrown,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: authState.isBusy
                                ? null
                                : () async {
                                    final restored = await ref
                                        .read(
                                            googleDriveBackupProvider.notifier)
                                        .restoreFromLocalBackupSnapshot();
                                    if (restored != null) {
                                      await ref
                                          .read(foragingSpotsProvider.notifier)
                                          .restoreSpots(restored);
                                    }
                                  },
                            icon: const Icon(Icons.unarchive_rounded, size: 18),
                            label: const Text('Restaurar local'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Explicación de privacidad Standalone
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AutumnColors.creamCard,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: AutumnColors.boletusBrown,
                      size: 22,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Privacidad 100 % Standalone: Perretxikotan no tiene servidores propios. Tus coordenadas secretas de setales, notas descriptivas y fotos jamás salen de tu teléfono salvo hacia la carpeta privada de tu propia cuenta de Google Drive.',
                        style: TextStyle(
                          fontSize: 12.8,
                          height: 1.42,
                          color: AutumnColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackupStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _BackupStatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AutumnColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AutumnColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
