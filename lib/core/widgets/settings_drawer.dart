import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';
import '../theme/autumn_theme.dart';
import '../widgets/safety_disclaimer_banner.dart';
import '../../features/backup/services/google_drive_backup_service.dart';

class SettingsDrawer extends ConsumerWidget {
  final VoidCallback? onNavigateToBackupTab;

  const SettingsDrawer({
    super.key,
    this.onNavigateToBackupTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final s = AppStrings(currentLang);
    final authState = ref.watch(googleDriveBackupProvider);

    return Drawer(
      backgroundColor: AutumnColors.parchmentBg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header del Drawer con logotipo de Amanita caesarea
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AutumnColors.barkDark,
                    AutumnColors.boletusBrown,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AutumnColors.barkDark.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AutumnColors.amberLeaf.withValues(alpha: 0.7),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/logo_perretxikotan.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Perretxikotan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AutumnColors.amberLeaf.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'v1.5.1',
                                style: TextStyle(
                                  color: AutumnColors.amberLeaf,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.tr(
                      eu: 'Ezarpenak eta Hizkuntza',
                      es: 'Ajustes y Configuración',
                      en: 'Settings & Language',
                    ),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Contenido scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                children: [
                  // SECCIÓN: HIZKUNTZA / IDIOMA
                  _SectionHeader(
                    icon: Icons.language_rounded,
                    title: s.tr(
                      eu: 'Hizkuntza',
                      es: 'Idioma de la Aplicación',
                      en: 'App Language',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tarjetas táctiles de selección de idioma
                  _LanguageCardTile(
                    language: AppLanguage.eu,
                    title: 'Euskara',
                    subtitle: 'Hizkuntza lehenetsia',
                    isSelected: currentLang == AppLanguage.eu,
                    badgeText: 'EU',
                    onTap: () {
                      ref
                          .read(appLanguageProvider.notifier)
                          .setLanguage(AppLanguage.eu);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LanguageCardTile(
                    language: AppLanguage.es,
                    title: 'Castellano',
                    subtitle: 'Guía micológica en español',
                    isSelected: currentLang == AppLanguage.es,
                    badgeText: 'ES',
                    onTap: () {
                      ref
                          .read(appLanguageProvider.notifier)
                          .setLanguage(AppLanguage.es);
                    },
                  ),
                  const SizedBox(height: 8),
                  _LanguageCardTile(
                    language: AppLanguage.en,
                    title: 'English',
                    subtitle: 'Mycological field guide',
                    isSelected: currentLang == AppLanguage.en,
                    badgeText: 'EN',
                    onTap: () {
                      ref
                          .read(appLanguageProvider.notifier)
                          .setLanguage(AppLanguage.en);
                    },
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // SECCIÓN: KONTUA ETA GOOGLE DRIVE
                  _SectionHeader(
                    icon: Icons.cloud_sync_rounded,
                    title: s.tr(
                      eu: 'Google Kontua eta Sinkronizazioa',
                      es: 'Cuenta de Google y Nube',
                      en: 'Google Account & Cloud',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AutumnColors.warmSand),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: authState.isAuthenticatedWithGoogle
                                  ? AutumnColors.mossGreen.withValues(alpha: 0.15)
                                  : AutumnColors.barkDark.withValues(alpha: 0.1),
                              child: Icon(
                                authState.isAuthenticatedWithGoogle
                                    ? Icons.verified_user_rounded
                                    : Icons.person_outline_rounded,
                                color: authState.isAuthenticatedWithGoogle
                                    ? AutumnColors.mossGreen
                                    : AutumnColors.boletusBrown,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authState.isAuthenticatedWithGoogle
                                        ? (authState.userDisplayName ??
                                            authState.userEmail ??
                                            'Google Conectado')
                                        : s.tr(
                                            eu: 'Tokiko modua (Konexiorik gabe)',
                                            es: 'Modo Local (Sin cuenta vinculada)',
                                            en: 'Local Mode (No account linked)',
                                          ),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: AutumnColors.boletusBrown,
                                    ),
                                  ),
                                  Text(
                                    authState.isAuthenticatedWithGoogle
                                        ? 'Google Drive appDataFolder aktibo'
                                        : s.tr(
                                            eu: 'Datuak zure telefonoan bakarrik daude',
                                            es: 'Datos almacenados en este teléfono',
                                            en: 'Data stored locally on device',
                                          ),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: AutumnColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (authState.isAuthenticatedWithGoogle)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AutumnColors.dangerRed,
                              side: BorderSide(
                                color: AutumnColors.dangerRed.withValues(alpha: 0.4),
                              ),
                              minimumSize: const Size.fromHeight(38),
                            ),
                            onPressed: () => ref
                                .read(googleDriveBackupProvider.notifier)
                                .signOut(),
                            icon: const Icon(Icons.logout_rounded, size: 16),
                            label: Text(
                              s.tr(
                                eu: 'Itxi Google saioa',
                                es: 'Desconectar cuenta Google',
                                en: 'Disconnect Google account',
                              ),
                              style: const TextStyle(fontSize: 12.5),
                            ),
                          )
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AutumnColors.boletusBrown,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(38),
                            ),
                            onPressed: () async {
                              await ref
                                  .read(googleDriveBackupProvider.notifier)
                                  .signInWithGoogle();
                            },
                            icon: const Icon(Icons.login_rounded, size: 16),
                            label: Text(
                              s.tr(
                                eu: 'Konektatu Google Kontuarekin',
                                es: 'Conectar con Google',
                                en: 'Connect with Google',
                              ),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // SECCIÓN: SEGURTASUN-KOPIAK ETA FITXATEGIAK
                  _SectionHeader(
                    icon: Icons.archive_rounded,
                    title: s.tr(
                      eu: 'Tokiko Segurtasun Kopiak',
                      es: 'Copias de Seguridad Locales',
                      en: 'Local Backups',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AutumnColors.warmSand),
                    ),
                    tileColor: Colors.white,
                    leading: const Icon(
                      Icons.folder_zip_rounded,
                      color: AutumnColors.boletusBrown,
                    ),
                    title: Text(
                      s.tr(
                        eu: 'Kudeatu ZIP Instantaneak',
                        es: 'Administrar Instantáneas ZIP',
                        en: 'Manage ZIP Snapshots',
                      ),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                    subtitle: Text(
                      s.tr(
                        eu: 'Zure jarduera osoa esportatu edo leheneratu',
                        es: 'Exporta o restaura toda tu actividad localmente',
                        en: 'Export or import your full activity archive',
                      ),
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).pop();
                      onNavigateToBackupTab?.call();
                    },
                  ),

                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  // SECCIÓN: INFORMAZIOA ETA SEGURTASUNA
                  _SectionHeader(
                    icon: Icons.health_and_safety_rounded,
                    title: s.tr(
                      eu: 'Segurtasuna eta Informazioa',
                      es: 'Seguridad e Información',
                      en: 'Safety & About',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AutumnColors.warmSand),
                    ),
                    tileColor: Colors.white,
                    leading: const Icon(
                      Icons.warning_amber_rounded,
                      color: AutumnColors.cautionOrange,
                    ),
                    title: Text(
                      s.tr(
                        eu: 'Mikologia eta Segurtasun Dekalogoa',
                        es: 'Decálogo de Seguridad Micológica',
                        en: 'Safety & Mycology Decalogue',
                      ),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                    subtitle: Text(
                      s.tr(
                        eu: 'Irakurri aholkuak perretxikoak bildu aurretik',
                        es: 'Recomendaciones vitales antes de recolectar',
                        en: 'Vital foraging precautions & tips',
                      ),
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.of(context).pop();
                      SafetyDisclaimerBanner.showSafetyDialog(context);
                    },
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AutumnColors.boletusBrown),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AutumnColors.boletusBrown,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageCardTile extends StatelessWidget {
  final AppLanguage language;
  final String title;
  final String subtitle;
  final String badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageCardTile({
    required this.language,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AutumnColors.amberLeaf.withValues(alpha: 0.14)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AutumnColors.amberLeaf : AutumnColors.warmSand,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AutumnColors.amberLeaf.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isSelected
                    ? AutumnColors.amberLeaf
                    : AutumnColors.barkDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AutumnColors.boletusBrown,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: isSelected
                          ? AutumnColors.boletusBrown
                          : AutumnColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AutumnColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AutumnColors.amberLeaf,
                size: 22,
              )
            else
              Icon(
                Icons.radio_button_unchecked_rounded,
                color: AutumnColors.textSecondary.withValues(alpha: 0.4),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
