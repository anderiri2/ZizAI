import 'package:flutter/material.dart';
import '../../../../core/theme/autumn_theme.dart';

/// Diana / Retícula de alta precisión para ubicar setales en el mapa.
/// Diseñada con halos de contraste blancos para ser visible sobre cualquier
/// tipo de mapa (ortofotos/satélite oscuro, capas topográficas o callejeros claros).
class MapCrosshairTarget extends StatelessWidget {
  final String? label;
  final Color primaryColor;
  final Color accentColor;

  const MapCrosshairTarget({
    super.key,
    this.label,
    this.primaryColor = AutumnColors.boletusBrown,
    this.accentColor = AutumnColors.terracotta,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: Center(
        child: SizedBox(
          width: 90,
          height: 110,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Pin / Marcador que sobrevuela la diana y apunta al centro exacto
              Positioned(
                top: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(8, 10),
                      painter: _PinTipPainter(color: accentColor),
                    ),
                  ],
                ),
              ),

              // Diana con cruz de mira y anillos concéntricos
              Positioned(
                bottom: 8,
                child: CustomPaint(
                  size: const Size(64, 64),
                  painter: _CrosshairPainter(
                    primaryColor: primaryColor,
                    accentColor: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinTipPainter extends CustomPainter {
  final Color color;
  _PinTipPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTipPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CrosshairPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _CrosshairPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Sombra sutil de la diana en el suelo
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.8;
    canvas.drawCircle(center + const Offset(0, 2), radius - 3, shadowPaint);

    // Círculo exterior blanco para contraste en fondos oscuros y claros
    final outerBgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2;
    canvas.drawCircle(center, radius - 3, outerBgPaint);

    // Círculo exterior coloreado
    final outerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawCircle(center, radius - 3, outerPaint);

    // Círculo interior
    final innerPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(center, radius * 0.44, innerPaint);

    // Cruz / Ticks (N, S, E, O) con reborde blanco de seguridad
    final crossBgPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.8
      ..strokeCap = StrokeCap.round;

    final crossPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    void drawTick(Offset start, Offset end) {
      canvas.drawLine(start, end, crossBgPaint);
      canvas.drawLine(start, end, crossPaint);
    }

    // Top tick
    drawTick(
      Offset(center.dx, center.dy - radius - 2),
      Offset(center.dx, center.dy - radius * 0.52),
    );
    // Bottom tick
    drawTick(
      Offset(center.dx, center.dy + radius * 0.52),
      Offset(center.dx, center.dy + radius + 2),
    );
    // Left tick
    drawTick(
      Offset(center.dx - radius - 2, center.dy),
      Offset(center.dx - radius * 0.52, center.dy),
    );
    // Right tick
    drawTick(
      Offset(center.dx + radius * 0.52, center.dy),
      Offset(center.dx + radius + 2, center.dy),
    );

    // Punto central exacto
    final centerDotBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4.8, centerDotBg);

    final centerDotPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.2, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.accentColor != accentColor;
}
