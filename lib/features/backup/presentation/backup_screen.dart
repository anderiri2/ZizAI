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
                            eu: 'Google Drive pertsonala • %100 pribatua eta segurua',
                            es: 'Google Drive personal • 100% privado y seguro',
                            en: 'Personal Google Drive • 100% private and secure',
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
              const SizedBox(height: 14),

              // Banner de Garantía de Privacidad
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  color: AutumnColors.mossGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AutumnColors.mossGreen.withValues(alpha: 0.28),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AutumnColors.mossGreen.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AutumnColors.mossGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.tr(
                              eu: 'Datuen pribatutasuna bermatua',
                              es: 'Privacidad 100% garantizada',
                              en: '100% Privacy guaranteed',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.tr(
                              eu: 'Zure perretxiko-lekuak eta ibilbideak ez dira inorekin partekatzen. Zure gailuan edo zure Google Driven bakarrik gordetzen dira.',
                              es: 'Tus setales y rutas no se comparten con nadie. Se guardan solo en tu móvil o en tu propio Google Drive.',
                              en: 'Your spots and routes are never shared with anyone. Stored solely on your device or personal Google Drive.',
                            ),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AutumnColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

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
                                        s.tr(
                                          eu: 'Google Drive konektatuta',
                                          es: 'Google Drive conectado',
                                          en: 'Google Drive connected',
                                        ))
                                    : s.tr(
                                        eu: 'Tokiko Modua (Gailuan bakarrik)',
                                        es: 'Modo Local (Solo en dispositivo)',
                                        en: 'Local Mode (Device only)',
                                      ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                authState.isAuthenticatedWithGoogle
                                    ? (authState.userEmail ??
                                        s.tr(
                                          eu: 'Google Drive pribatua (appDataFolder)',
                                          es: 'Google Drive privado (appDataFolder)',
                                          en: 'Private Google Drive (appDataFolder)',
                                        ))
                                    : s.tr(
                                        eu: 'Datuak telefono honetan bakarrik daude. Konektatu Google Drive hodeian babesteko.',
                                        es: 'Tus datos se guardan solo en este móvil. Vincula Drive para respaldo en la nube.',
                                        en: 'Data is stored on this phone only. Link Drive for cloud backup.',
                                      ),
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
                          label: Text(
                            s.tr(
                              eu: 'Konektatu nire Google Drive pertsonala',
                              es: 'Vincular mi Google Drive personal',
                              en: 'Connect personal Google Drive',
                            ),
                          ),
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
                              label: Text(
                                s.tr(
                                  eu: 'Itxi Google saioa (Gorde lokalean)',
                                  es: 'Cerrar sesión de Google (Guardar en local)',
                                  en: 'Disconnect Google (Store locally)',
                                ),
                              ),
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
                    Text(
                      s.tr(
                        eu: 'zizai_backup.zip paketean sartutako jarduera',
                        es: 'Actividad Incluida en el Paquete zizai_backup.zip',
                        en: 'Activity Included in zizai_backup.zip',
                      ),
                      style: const TextStyle(
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
                            label: s.tr(
                              eu: 'Perretxiko-lekuak',
                              es: 'Setales en Mapa',
                              en: 'Map Spots',
                            ),
                            color: AutumnColors.terracotta,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.hiking_rounded,
                            value:
                                '${outings.length} (${totalKm.toStringAsFixed(1)} km)',
                            label: s.tr(
                              eu: 'GPS Ibilbideak',
                              es: 'Salidas GPS',
                              en: 'GPS Outings',
                            ),
                            color: AutumnColors.mossGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.photo_camera_rounded,
                            value: '$photosCount',
                            label: s.tr(
                              eu: 'Argazkiak',
                              es: 'Fotografías',
                              en: 'Photos',
                            ),
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
                            label: s.tr(
                              eu: 'Gogoko perretxikoak',
                              es: 'Setas Favoritas',
                              en: 'Favorites',
                            ),
                            color: AutumnColors.dangerRed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MetricTile(
                            icon: Icons.download_for_offline_rounded,
                            value: '${offlineRegions.length}',
                            label: s.tr(
                              eu: 'Offline Eremuak',
                              es: 'Zonas Offline',
                              en: 'Offline Areas',
                            ),
                            color: AutumnColors.mossGreen,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 22),
                    _BackupTimestampRow(
                      icon: Icons.cloud_done_rounded,
                      label: s.tr(
                        eu: 'Azken backup-a Google Drive-n:',
                        es: 'Último backup en Google Drive:',
                        en: 'Last Google Drive backup:',
                      ),
                      date: authState.lastDriveBackupDate,
                      lang: lang,
                    ),
                    const SizedBox(height: 6),
                    _BackupTimestampRow(
                      icon: Icons.folder_zip_rounded,
                      label: s.tr(
                        eu: 'Azken ZIP snapshot-a gailuan:',
                        es: 'Último snapshot ZIP en el dispositivo:',
                        en: 'Last ZIP snapshot on device:',
                      ),
                      date: authState.lastLocalBackupDate,
                      lang: lang,
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
                          title: Text(
                            s.tr(
                              eu: 'Fusio adimentsua leheneratzean (Gomendatua)',
                              es: 'Fusión Inteligente al Restaurar (Recomendado)',
                              en: 'Smart Merge on Restore (Recommended)',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                          subtitle: Text(
                            _smartMergeOnRestore
                                ? s.tr(
                                    eu: 'Google Drive-ko eta tokiko datuak bateratzen ditu irteera edo kokapenik galdu gabe.',
                                    es: 'Combina los datos de Google Drive con los datos locales sin perder ninguna salida ni ubicación.',
                                    en: 'Combines Google Drive and local data without losing any outings or spots.',
                                  )
                                : s.tr(
                                    eu: 'Ordezkatze modua: telefonoko uneko datuak kopiako edukiarekin ordezkatzen ditu.',
                                    es: 'Modo Reemplazo: sustituye los datos actuales del teléfono por el contenido exacto del backup.',
                                    en: 'Replace mode: overwrites current data with the exact backup content.',
                                  ),
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
                          title: Text(
                            s.tr(
                              eu: 'Kopia automatikoa irteerak erregistratu ondoren',
                              es: 'Copia automática tras registrar salidas',
                              en: 'Automatic backup after saving outings',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                          subtitle: Text(
                            s.tr(
                              eu: 'Konexioa duzunean zure jarduera automatikoki sinkronizatzen du.',
                              es: 'Sincroniza automáticamente tu actividad cuando tengas conexión.',
                              en: 'Automatically syncs your activity when internet is available.',
                            ),
                            style: const TextStyle(
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
                s.tr(
                  eu: 'Hodei Pertsonala (Google Drive appDataFolder)',
                  es: 'Nube Personal (Google Drive appDataFolder)',
                  en: 'Personal Cloud (Google Drive appDataFolder)',
                ),
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
                              lang: lang,
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
                label: Text(
                  s.tr(
                    eu: 'Gorde nire jarduera guztia Google Drive-n',
                    es: 'Respaldar Toda mi Actividad en Google Drive',
                    en: 'Backup All My Activity to Google Drive',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: authState.isBusy
                    ? null
                    : () async {
                        final payload = await ref
                            .read(googleDriveBackupProvider.notifier)
                            .restoreFullActivityFromGoogleDrive(lang: lang);
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
                      ? s.tr(
                          eu: 'Leheneratu Google Drive-tik (Fusio adimentsua)',
                          es: 'Restaurar desde Google Drive (Fusión Inteligente)',
                          en: 'Restore from Google Drive (Smart Merge)',
                        )
                      : s.tr(
                          eu: 'Leheneratu Google Drive-tik (Dena ordezkatu)',
                          es: 'Restaurar desde Google Drive (Reemplazar Todo)',
                          en: 'Restore from Google Drive (Replace All)',
                        ),
                ),
              ),

              const SizedBox(height: 22),

              // Acciones de Copia Local Instantánea (Funciona 100% Offline)
              Text(
                s.tr(
                  eu: 'Tokiko Segurtasun Kopia (ZIP telefonoan)',
                  es: 'Copia de Respaldo Local (ZIP en el Teléfono)',
                  en: 'Local Backup (ZIP on Phone)',
                ),
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
                                lang: lang,
                              ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AutumnColors.warmSand,
                        foregroundColor: AutumnColors.boletusBrown,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(Icons.save_alt_rounded, size: 18),
                      label: Text(
                        s.tr(
                          eu: 'Gorde Tokiko ZIP-a',
                          es: 'Guardar ZIP Local',
                          en: 'Save Local ZIP',
                        ),
                      ),
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
                                  .restoreFromLocalSnapshotFullActivity(lang: lang);
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
                      label: Text(
                        s.tr(
                          eu: 'Leheneratu Tokikotik',
                          es: 'Restaurar Local',
                          en: 'Restore Local',
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
  final AppLanguage lang;

  const _BackupTimestampRow({
    required this.icon,
    required this.label,
    required this.date,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    final formatted = date != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(date!)
        : s.tr(
            eu: 'Oraindik egin gabe',
            es: 'Sin realizar aún',
            en: 'Not performed yet',
          );
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
