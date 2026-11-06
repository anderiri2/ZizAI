import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/autumn_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/backup/services/google_drive_backup_service.dart';
import 'features/home/presentation/home_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: ZizAiApp(),
    ),
  );
}

enum _AppStage {
  splash,
  login,
  home,
}

class ZizAiApp extends ConsumerStatefulWidget {
  const ZizAiApp({super.key});

  @override
  ConsumerState<ZizAiApp> createState() => _ZizAiAppState();
}

class _ZizAiAppState extends ConsumerState<ZizAiApp> {
  _AppStage _stage = _AppStage.splash;

  @override
  void initState() {
    super.initState();
    ref.read(googleDriveBackupProvider.notifier).initializeAuthSession();
  }

  void _handleSplashFinished() {
    final authState = ref.read(googleDriveBackupProvider);
    setState(() {
      _stage = authState.hasEnteredApp ? _AppStage.home : _AppStage.login;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZizAI',
      debugShowCheckedModeBanner: false,
      theme: AutumnTheme.lightTheme,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: switch (_stage) {
          _AppStage.splash => SplashScreen(
              key: const ValueKey('splash'),
              onFinished: _handleSplashFinished,
            ),
          _AppStage.login => LoginScreen(
              key: const ValueKey('login'),
              onAuthenticated: () {
                setState(() => _stage = _AppStage.home);
              },
            ),
          _AppStage.home => HomeShellScreen(
              key: const ValueKey('home'),
              onSignOutToLogin: () {
                setState(() => _stage = _AppStage.login);
              },
            ),
        },
      ),
    );
  }
}
