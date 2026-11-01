import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/autumn_theme.dart';

class SplashScreen extends StatefulWidget {
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
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..forward();

    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _stageText(double t) {
    final labels = widget.stageLabelsOverride ??
        const [
          'Bolba zuritik jaiotzen · Naciendo de la volva...',
          'Belardian hazten · Emergiendo en el campo...',
          'Amanita caesarea (Gorringo) irekitzen · Abriendo sombrero...',
        ];
    if (t < 0.36) return labels[0];
    if (t < 0.72) return labels[1];
    return labels[2];
  }

  @override
  Widget build(BuildContext context) {
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
                  AutumnColors.barkDark.withValues(alpha: 0.62),
                  AutumnColors.barkDark.withValues(alpha: 0.90),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = _controller.value;

                  // Stage weights for smooth crossfade of the 3 Amanita caesarea photos
                  final stage1Opacity = (1.0 - ((t - 0.25) / 0.22)).clamp(0.0, 1.0);
                  final stage2In = ((t - 0.20) / 0.22).clamp(0.0, 1.0);
                  final stage2Out = (1.0 - ((t - 0.62) / 0.22)).clamp(0.0, 1.0);
                  final stage2Opacity = math.min(stage2In, stage2Out);
                  final stage3Opacity = ((t - 0.56) / 0.26).clamp(0.0, 1.0);

                  // Vertical birth growth from ground (Alignment.bottomCenter)
                  final growthCurve = Curves.easeOutBack.transform(t.clamp(0.0, 1.0));
                  final scaleY = 0.64 + 0.36 * growthCurve;
                  final scaleX = 0.76 + 0.24 * Curves.easeOutCubic.transform(t);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Warm golden sun halo behind the Amanita caesarea
                            Container(
                              width: 195 + (20 * t),
                              height: 195 + (20 * t),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFF8F00)
                                        .withValues(alpha: 0.36 * t),
                                    AutumnColors.amberLeaf
                                        .withValues(alpha: 0.14 * t),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Circular meadow frame with rising & opening Amanita caesarea
                            Container(
                              width: 192,
                              height: 192,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AutumnColors.parchmentBg,
                                border: Border.all(
                                  color: Color.lerp(
                                    AutumnColors.mossGreen,
                                    const Color(0xFFFF6F00),
                                    t,
                                  )!,
                                  width: 3.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.50),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Transform(
                                      alignment: Alignment.bottomCenter,
                                      transform: Matrix4.diagonal3Values(
                                        scaleX,
                                        scaleY,
                                        1.0,
                                      ),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          if (stage1Opacity > 0)
                                            Opacity(
                                              opacity: stage1Opacity,
                                              child: Image.asset(
                                                'assets/images/splash_caesarea_stage1_egg.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          if (stage2Opacity > 0)
                                            Opacity(
                                              opacity: stage2Opacity,
                                              child: Image.asset(
                                                'assets/images/splash_caesarea_stage2_emerging.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          if (stage3Opacity > 0)
                                            Opacity(
                                              opacity: stage3Opacity,
                                              child: Image.asset(
                                                'assets/images/splash_caesarea_stage3_open.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    // Vector botanical overlay animating the volva birth, cap opening & spores
                                    CustomPaint(
                                      painter: _AmanitaCaesareaGrowthPainter(
                                        progress: t,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Perretxikotan',
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(
                              color: AutumnColors.parchmentBg,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitleOverride ??
                            'Mikologia · Perretxiko-lekuak · Euskal Herria',
                        style: TextStyle(
                          color: AutumnColors.amberLeaf.withValues(alpha: 0.96),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AutumnColors.amberLeaf.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          _stageText(t),
                          style: const TextStyle(
                            color: AutumnColors.parchmentBg,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: t,
                            minHeight: 5,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.16),
                            color: const Color(0xFFFF7043),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmanitaCaesareaGrowthPainter extends CustomPainter {
  final double progress;

  const _AmanitaCaesareaGrowthPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final groundY = h * 0.90;

    // Subtle animated silhouette fade-out as the real macro photo reaches full bloom
    final vectorAlpha = (1.0 - ((progress - 0.68) / 0.32)).clamp(0.18, 0.72);

    // 1. Meadow grass blades swaying at the bottom
    final grassPaint = Paint()
      ..color = const Color(0xFF33691E).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (var i = -4; i <= 4; i++) {
      final bx = cx + i * (w * 0.085);
      final sway = math.sin(progress * math.pi * 2 + i) * 4.0;
      final bladePath = Path()
        ..moveTo(bx, h)
        ..quadraticBezierTo(
          bx + sway,
          groundY - 12,
          bx + sway * 1.4,
          groundY - 22 - (i.abs() % 3) * 5,
        );
      canvas.drawPath(bladePath, grassPaint);
    }

    // 2. Golden stem (pie amarillo oro) rising from the white volva
    final stemGrowth = ((progress - 0.18) / 0.65).clamp(0.0, 1.0);
    final stemHeight = h * 0.34 * Curves.easeOutCubic.transform(stemGrowth);
    final stemTopY = groundY - 18 - stemHeight;

    if (stemGrowth > 0.02) {
      final stemPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: vectorAlpha * 0.65)
        ..style = PaintingStyle.fill;
      final stemRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, groundY - 14 - stemHeight * 0.5),
          width: w * 0.16,
          height: stemHeight,
        ),
        const Radius.circular(10),
      );
      canvas.drawRRect(stemRect, stemPaint);
    }

    // 3. Amanita caesarea orange cap opening from dome to wide umbrella
    final capOpen = ((progress - 0.28) / 0.72).clamp(0.0, 1.0);
    final capWidth = w * (0.26 + 0.38 * Curves.easeOutBack.transform(capOpen));
    final capHeight = h * (0.22 - 0.05 * capOpen);

    if (progress > 0.10) {
      // Golden gills underneath as cap opens
      if (capOpen > 0.25) {
        final gillPaint = Paint()
          ..color = const Color(0xFFFFCA28).withValues(alpha: vectorAlpha * 0.75)
          ..style = PaintingStyle.fill;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, stemTopY + capHeight * 0.32),
            width: capWidth * 0.92,
            height: capHeight * 0.42,
          ),
          gillPaint,
        );
      }

      // Vibrant orange-red cap dome
      final capPaint = Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.4),
          radius: 0.9,
          colors: [
            const Color(0xFFFF8F00).withValues(alpha: vectorAlpha * 0.72),
            const Color(0xFFD84315).withValues(alpha: vectorAlpha * 0.72),
          ],
        ).createShader(
          Rect.fromCenter(
            center: Offset(cx, stemTopY),
            width: capWidth,
            height: capHeight,
          ),
        );

      final capPath = Path()
        ..moveTo(cx - capWidth * 0.5, stemTopY + capHeight * 0.3)
        ..cubicTo(
          cx - capWidth * 0.48,
          stemTopY - capHeight * 0.7,
          cx + capWidth * 0.48,
          stemTopY - capHeight * 0.7,
          cx + capWidth * 0.5,
          stemTopY + capHeight * 0.3,
        )
        ..quadraticBezierTo(
          cx,
          stemTopY + capHeight * (0.42 - 0.18 * capOpen),
          cx - capWidth * 0.5,
          stemTopY + capHeight * 0.3,
        )
        ..close();
      canvas.drawPath(capPath, capPaint);
    }

    // 4. White egg volva splitting open at the base
    final splitSpread = (progress * 1.3).clamp(0.0, 1.0);
    final volvaPaint = Paint()
      ..color = const Color(0xFFFDFBF7).withValues(alpha: vectorAlpha * 0.82)
      ..style = PaintingStyle.fill;

    final leftVolva = Path()
      ..moveTo(cx, groundY + 4)
      ..quadraticBezierTo(
        cx - w * (0.18 + 0.06 * splitSpread),
        groundY - 4,
        cx - w * (0.14 + 0.09 * splitSpread),
        groundY - h * 0.22,
      )
      ..quadraticBezierTo(
        cx - w * 0.04 * splitSpread,
        groundY - h * 0.14,
        cx,
        groundY + 4,
      )
      ..close();

    final rightVolva = Path()
      ..moveTo(cx, groundY + 4)
      ..quadraticBezierTo(
        cx + w * (0.18 + 0.06 * splitSpread),
        groundY - 4,
        cx + w * (0.14 + 0.09 * splitSpread),
        groundY - h * 0.22,
      )
      ..quadraticBezierTo(
        cx + w * 0.04 * splitSpread,
        groundY - h * 0.14,
        cx,
        groundY + 4,
      )
      ..close();

    canvas.drawPath(leftVolva, volvaPaint);
    canvas.drawPath(rightVolva, volvaPaint);

    // 5. Golden spores floating up in the meadow sunlight
    if (progress > 0.35) {
      final sporeProgress = ((progress - 0.35) / 0.65).clamp(0.0, 1.0);
      final sporePaint = Paint()
        ..color = const Color(0xFFFFD54F)
            .withValues(alpha: (1.0 - sporeProgress * 0.5) * 0.75)
        ..style = PaintingStyle.fill;

      for (var i = 0; i < 8; i++) {
        final angle = (i / 8.0) * math.pi + 0.2;
        final radius = w * (0.18 + 0.26 * sporeProgress);
        final sx = cx + math.cos(angle) * radius;
        final sy =
            (h * 0.58) - math.sin(angle) * radius - (sporeProgress * 22.0);
        canvas.drawCircle(Offset(sx, sy), 2.4, sporePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AmanitaCaesareaGrowthPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
