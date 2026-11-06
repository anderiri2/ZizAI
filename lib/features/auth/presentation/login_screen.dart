import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../backup/services/google_drive_backup_service.dart';

class LoginScreen extends ConsumerWidget {
  final VoidCallback onAuthenticated;

  const LoginScreen({
    super.key,
    required this.onAuthenticated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(googleDriveBackupProvider);
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);

    return Scaffold(
      backgroundColor: AutumnColors.barkDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/autumn_forest_bg.png',
            fit: BoxFit.cover,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AutumnColors.barkDark.withValues(alpha: 0.45),
                  AutumnColors.barkDark.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: LanguageSelectorPill(darkSurface: true),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Amanita caesarea illustrated app icon logo
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.48),
                                  blurRadius: 26,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                'assets/images/logo_zizai.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text.rich(
                            const TextSpan(
                              text: 'Ziz',
                              children: [
                                TextSpan(
                                  text: 'AI',
                                  style: TextStyle(color: AutumnColors.amberLeaf),
                                ),
                              ],
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AutumnColors.parchmentBg,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            s.loginTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AutumnColors.warmSand.withValues(alpha: 0.92),
                              fontSize: 14.5,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Translucent Google Drive & Offline Access Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: AutumnColors.parchmentBg
                                      .withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AutumnColors.amberLeaf
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: AutumnColors.mossGreen
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AutumnColors.mossGreen
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.verified_user_rounded,
                                              size: 14,
                                              color: AutumnColors.mossGreen,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              s.loginPrivacyBadge,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                fontWeight: FontWeight.w800,
                                                color: AutumnColors.mossGreen,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.shield_outlined,
                                          color: AutumnColors.boletusBrown,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            s.tr(
                                              eu: 'Zuk erabakitzen duzu non gorde',
                                              es: 'Elige dónde guardar tus datos',
                                              en: 'Choose where to store your data',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.w800,
                                              color: AutumnColors.boletusBrown,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      s.loginPrivacySubtitle,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        height: 1.44,
                                        color: AutumnColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    if (authState.errorMessage != null) ...[
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(bottom: 14),
                                        decoration: BoxDecoration(
                                          color: AutumnColors.edibilityToxic
                                              .withValues(alpha: 0.10),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          border: Border.all(
                                            color: AutumnColors.edibilityToxic
                                                .withValues(alpha: 0.35),
                                          ),
                                        ),
                                        child: Text(
                                          authState.errorMessage!,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AutumnColors.edibilityToxic,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],

                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AutumnColors.boletusBrown,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 15,
                                        ),
                                      ),
                                      onPressed: authState.isBusy
                                          ? null
                                          : () async {
                                              final ok = await ref
                                                  .read(
                                                    googleDriveBackupProvider
                                                        .notifier,
                                                  )
                                                  .signInWithGoogle();
                                              if (ok) {
                                                onAuthenticated();
                                              }
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
                                          : const Icon(
                                              Icons.account_circle_rounded,
                                            ),
                                      label: Text(
                                        s.signInWithGoogle,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            AutumnColors.boletusBrown,
                                        side: const BorderSide(
                                          color: AutumnColors.ochreGold,
                                          width: 1.4,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      onPressed: authState.isBusy
                                          ? null
                                          : () async {
                                              await ref
                                                  .read(
                                                    googleDriveBackupProvider
                                                        .notifier,
                                                  )
                                                  .continueInLocalMode();
                                              onAuthenticated();
                                            },
                                      icon: const Icon(
                                        Icons.forest_rounded,
                                        size: 19,
                                        color: AutumnColors.mossGreen,
                                      ),
                                      label: Text(
                                        s.continueOfflineMode,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 13,
                                          color: AutumnColors.textSecondary,
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            s.loginPrivacyBullet,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AutumnColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
