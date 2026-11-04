import 'package:flutter/material.dart';
import '../../../../core/theme/autumn_theme.dart';
import '../../../catalog/models/mushroom.dart';
import '../../models/foraging_spot.dart';

class ForagingSpotMarkerWidget extends StatelessWidget {
  final ForagingSpot spot;
  final List<Mushroom> allMushrooms;
  final bool isSelected;
  final double size;

  const ForagingSpotMarkerWidget({
    super.key,
    required this.spot,
    required this.allMushrooms,
    this.isSelected = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    final mushroom = spot.mushroomId == null
        ? null
        : allMushrooms.where((m) => m.id == spot.mushroomId).firstOrNull;
    final color = mushroom?.edibility.badgeColor ?? AutumnColors.boletusBrown;
    final count = spot.quantityCount > 0 ? spot.quantityCount : 1;
    final text = '$count';

    final fontSize = count > 99
        ? (size * 0.28).clamp(9.0, 11.0)
        : (count > 9
            ? (size * 0.34).clamp(10.0, 13.0)
            : (size * 0.38).clamp(11.0, 15.0));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AutumnColors.terracotta : Colors.white,
          width: isSelected ? 3.0 : 2.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
