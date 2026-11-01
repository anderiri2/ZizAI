import 'dart:convert';
import 'package:latlong2/latlong.dart';
import '../../map/models/foraging_spot.dart';

class OutingHarvestItem {
  final String? mushroomId;
  final String mushroomName;
  final int totalSpecimens;
  final int totalWeightGrams;
  final int spotsCount;

  const OutingHarvestItem({
    this.mushroomId,
    required this.mushroomName,
    required this.totalSpecimens,
    required this.totalWeightGrams,
    required this.spotsCount,
  });

  String get formattedSummary {
    final weightPart =
        totalWeightGrams > 0 ? ' (${totalWeightGrams}g)' : '';
    return '${totalSpecimens}x $mushroomName$weightPart';
  }
}

class ForagingOuting {
  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime endedAt;
  final int durationSeconds;
  final double distanceMeters;
  final List<LatLng> routePoints;
  final String notes;
  final bool isManual;

  const ForagingOuting({
    required this.id,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.durationSeconds,
    required this.distanceMeters,
    required this.routePoints,
    this.notes = '',
    this.isManual = false,
  });

  double get distanceKm => distanceMeters / 1000.0;

  String get formattedDistanceKm {
    if (isManual) {
      return 'Manual (Sin GPS)';
    }
    final km = distanceMeters / 1000.0;
    return '${km.toStringAsFixed(2)} km';
  }

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final mins = (durationSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${mins}m';
    }
    return '${mins}m';
  }

  /// Agrupa y calcula la cesta recolectada en esta salida a partir de los puntos del mapa.
  List<OutingHarvestItem> summarizeHarvest(List<ForagingSpot> allSpots) {
    final outingSpots = allSpots.where((s) => s.outingId == id).toList();
    final Map<String, OutingHarvestItem> grouped = {};

    for (final s in outingSpots) {
      final key = s.mushroomId ?? s.mushroomName ?? 'Seta silvestre';
      final displayName = (s.mushroomName != null && s.mushroomName!.isNotEmpty)
          ? s.mushroomName!.split('/').first.trim()
          : 'Seta silvestre';

      final prev = grouped[key];
      if (prev == null) {
        grouped[key] = OutingHarvestItem(
          mushroomId: s.mushroomId,
          mushroomName: displayName,
          totalSpecimens: s.quantityCount,
          totalWeightGrams: s.weightGrams ?? 0,
          spotsCount: 1,
        );
      } else {
        grouped[key] = OutingHarvestItem(
          mushroomId: s.mushroomId,
          mushroomName: prev.mushroomName,
          totalSpecimens: prev.totalSpecimens + s.quantityCount,
          totalWeightGrams: prev.totalWeightGrams + (s.weightGrams ?? 0),
          spotsCount: prev.spotsCount + 1,
        );
      }
    }

    return grouped.values.toList()
      ..sort((a, b) => b.totalSpecimens.compareTo(a.totalSpecimens));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'durationSeconds': durationSeconds,
      'distanceMeters': distanceMeters,
      'routePointsJson': json.encode(
        routePoints
            .map((pt) => {'lat': pt.latitude, 'lng': pt.longitude})
            .toList(),
      ),
      'notes': notes,
      'isManual': isManual ? 1 : 0,
    };
  }

  factory ForagingOuting.fromMap(Map<String, dynamic> map) {
    List<LatLng> parsedPoints = [];
    final rawRoute = map['routePointsJson'];
    if (rawRoute is String && rawRoute.isNotEmpty) {
      final decoded = json.decode(rawRoute) as List<dynamic>;
      parsedPoints = decoded.map((e) {
        final m = e as Map<String, dynamic>;
        return LatLng(
          (m['lat'] as num).toDouble(),
          (m['lng'] as num).toDouble(),
        );
      }).toList();
    } else if (map['routePoints'] is List) {
      parsedPoints = (map['routePoints'] as List<dynamic>).map((e) {
        final m = e as Map<String, dynamic>;
        return LatLng(
          (m['lat'] as num).toDouble(),
          (m['lng'] as num).toDouble(),
        );
      }).toList();
    }

    return ForagingOuting(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Salida al monte',
      startedAt: DateTime.tryParse(map['startedAt'] as String? ?? '') ??
          DateTime.now(),
      endedAt: DateTime.tryParse(map['endedAt'] as String? ?? '') ??
          DateTime.now(),
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 0,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      routePoints: parsedPoints,
      notes: map['notes'] as String? ?? '',
      isManual: (map['isManual'] == 1 || map['isManual'] == true),
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory ForagingOuting.fromJson(Map<String, dynamic> json) =>
      ForagingOuting.fromMap(json);
}
