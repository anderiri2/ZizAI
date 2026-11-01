import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo emblema
                    Container(
                      width: 126,
                      height: 126,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AutumnColors.parchmentBg,
                        border: Border.all(
                          color: AutumnColors.amberLeaf,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo_perretxikotan.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Perretxikotan',
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
                      'Tu cuaderno micológico de campo y mapa privado de setales',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AutumnColors.warmSand.withValues(alpha: 0.92),
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Tarjeta translúcida de acceso con Google
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
                              color:
                                  AutumnColors.amberLeaf.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.cloud_done_rounded,
                                    color: AutumnColors.mossGreen,
                                    size: 24,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Copia de Seguridad en tu Google Drive',
                                      style: TextStyle(
                                        fontSize: 16.5,
                                        fontWeight: FontWeight.w800,
                                        color: AutumnColors.boletusBrown,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Inicia sesión con tu cuenta personal de Google para respaldar automáticamente tus ubicaciones de setas y notas descriptivas en tu propio Google Drive (al estilo WhatsApp), sin servidores externos.',
                                style: TextStyle(
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
                                    borderRadius: BorderRadius.circular(14),
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

                              // Botón principal: Iniciar sesión con Google
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AutumnColors.boletusBrown,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: authState.isBusy
                                    ? null
                                    : () async {
                                        final ok = await ref
                                            .read(googleDriveBackupProvider
                                                .notifier)
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
                                    : const Icon(Icons.account_circle_rounded),
                                label: const Text(
                                  'Iniciar sesión con Google',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Botón secundario: Modo local / Sin cobertura en el monte
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AutumnColors.boletusBrown,
                                  side: const BorderSide(
                                    color: AutumnColors.ochreGold,
                                    width: 1.4,
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: authState.isBusy
                                    ? null
                                    : () async {
                                        await ref
                                            .read(googleDriveBackupProvider
                                                .notifier)
                                            .continueInLocalMode();
                                        onAuthenticated();
                                      },
                                icon: const Icon(
                                  Icons.forest_rounded,
                                  size: 19,
                                  color: AutumnColors.mossGreen,
                                ),
                                label: const Text(
                                  'Continuar en modo local (Offline)',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
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
            ),
          ),
        ],
      ),
    );
  }
}
