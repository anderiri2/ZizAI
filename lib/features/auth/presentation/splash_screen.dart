import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback onFinished;
  final String? subtitleOverride;
  final List<String>? stageLabelsOverride;

  const SplashScreen({
    super.key,
    required this.onFinished,
    this.subtitleOverride,
    this.stageLabelsOverride,
  });

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const int _totalFrames = 24;
  static const Color _forestDarkBg = Color(0xFF192718);
  static const Color _frameBrownBorder = Color(0xFF3A3224);

  late final AnimationController _controller;
  bool _precached = false;
  bool _completed = false;

  static String _frameAssetPath(int index1Based) {
    final numStr = index1Based.clamp(1, _totalFrames).toString().padLeft(2, '0');
    return 'assets/images/splash_frames/frame_$numStr.png';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_completed) {
        _completed = true;
        widget.onFinished();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precached = true;
      for (var i = 1; i <= _totalFrames; i++) {
        precacheImage(AssetImage(_frameAssetPath(i)), context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final strings = AppStrings(lang);

    return Scaffold(
      backgroundColor: _forestDarkBg,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value.clamp(0.0, 1.0);
              final frameIndex =
                  (1 + (t * (_totalFrames - 1)).round()).clamp(1, _totalFrames);

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 2.0s animated Amanita caesarea hatching & opening from the user's video
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 320,
                          maxHeight: 480,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _forestDarkBg,
                            borderRadius: BorderRadius.circular(36),
                            border: Border.all(
                              color: _frameBrownBorder,
                              width: 6,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.55),
                                blurRadius: 32,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              _frameAssetPath(frameIndex),
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AutumnColors.parchmentBg,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.subtitleOverride ?? strings.appSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AutumnColors.amberLeaf.withValues(alpha: 0.96),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: t,
                          minHeight: 5,
                          backgroundColor: Colors.white.withValues(alpha: 0.14),
                          color: const Color(0xFFEC651A),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
