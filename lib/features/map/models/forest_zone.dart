import 'dart:convert';
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'tree_species.dart';

/// User-drawn forest or habitat polygon associated with a dominant [TreeSpecies].
class ForestZone {
  final String id;
  final String name;
  final String treeType;
  final List<LatLng> points;
  final String notes;
  final DateTime createdAt;

  const ForestZone({
    required this.id,
    required this.name,
    required this.treeType,
    required this.points,
    required this.notes,
    required this.createdAt,
  });

  TreeSpecies get species => TreeSpecies.fromId(treeType);

  /// Visual center used to place the polygon icon + name label.
  LatLng get centroid {
    if (points.isEmpty) return const LatLng(0, 0);
    double sumLat = 0;
    double sumLng = 0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  /// Approximate planar area in square meters computed with the Shoelace
  /// formula and mid-latitude cosine projection. Used to prioritize the smallest
  /// (most specific) polygon when nested or overlapping zones exist.
  double get approximateArea {
    if (points.length < 3) return 0;
    final centerLatRad = centroid.latitude * math.pi / 180.0;
    const metersPerDegLat = 111320.0;
    final metersPerDegLng = metersPerDegLat * math.cos(centerLatRad).abs();

    double area = 0;
    for (int i = 0, j = points.length - 1; i < points.length; j = i++) {
      final xi = points[i].longitude * metersPerDegLng;
      final yi = points[i].latitude * metersPerDegLat;
      final xj = points[j].longitude * metersPerDegLng;
      final yj = points[j].latitude * metersPerDegLat;
      area += (xj + xi) * (yj - yi);
    }
    return area.abs() * 0.5;
  }

  /// Ray-casting point-in-polygon check (inclusive of vertices/edges within a
  /// tiny floating-point tolerance).
  bool containsPoint(LatLng point) {
    if (points.length < 3) return false;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    const eps = 1e-9;
    if (point.latitude < minLat - eps ||
        point.latitude > maxLat + eps ||
        point.longitude < minLng - eps ||
        point.longitude > maxLng + eps) {
      return false;
    }

    for (int i = 0, j = points.length - 1; i < points.length; j = i++) {
      if (_isPointOnSegment(point, points[j], points[i])) {
        return true;
      }
    }

    bool inside = false;
    for (int i = 0, j = points.length - 1; i < points.length; j = i++) {
      final xi = points[i].longitude;
      final yi = points[i].latitude;
      final xj = points[j].longitude;
      final yj = points[j].latitude;

      final crossesLat = (yi > point.latitude) != (yj > point.latitude);
      if (crossesLat) {
        final intersectLng =
            (xj - xi) * (point.latitude - yi) / (yj - yi) + xi;
        if (point.longitude < intersectLng) {
          inside = !inside;
        }
      }
    }
    return inside;
  }

  static bool _isPointOnSegment(LatLng p, LatLng a, LatLng b) {
    const eps = 1e-8;
    final cross = (p.latitude - a.latitude) * (b.longitude - a.longitude) -
        (p.longitude - a.longitude) * (b.latitude - a.latitude);
    if (cross.abs() > eps) return false;

    final minLat = math.min(a.latitude, b.latitude) - eps;
    final maxLat = math.max(a.latitude, b.latitude) + eps;
    final minLng = math.min(a.longitude, b.longitude) - eps;
    final maxLng = math.max(a.longitude, b.longitude) + eps;
    return p.latitude >= minLat &&
        p.latitude <= maxLat &&
        p.longitude >= minLng &&
        p.longitude <= maxLng;
  }

  /// Orders arbitrary vertex coordinates into a clean, non-self-intersecting
  /// perimeter contour around the point cloud and removes near-duplicate taps.
  /// Keeps the first unique vertex anchored at index `0`.
  static List<LatLng> orderContourPoints(List<LatLng> rawPoints) {
    final deduped = <LatLng>[];
    for (final p in rawPoints) {
      final isDuplicate = deduped.any(
        (existing) =>
            (existing.latitude - p.latitude).abs() < 1e-6 &&
            (existing.longitude - p.longitude).abs() < 1e-6,
      );
      if (!isDuplicate) {
        deduped.add(p);
      }
    }
    if (deduped.length < 3) {
      return deduped;
    }

    double sumLat = 0;
    double sumLng = 0;
    for (final p in deduped) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    final cLat = sumLat / deduped.length;
    final cLng = sumLng / deduped.length;
    final cosLat = math.cos(cLat * math.pi / 180.0).abs().clamp(0.1, 1.0);

    (double, double) toLocal(LatLng p) => (
          (p.longitude - cLng) * cosLat,
          p.latitude - cLat,
        );

    final anchor = deduped.first;
    final ordered = List<LatLng>.from(deduped);
    ordered.sort((a, b) {
      final pa = toLocal(a);
      final pb = toLocal(b);
      final angleA = math.atan2(pa.$2, pa.$1);
      final angleB = math.atan2(pb.$2, pb.$1);
      final angleCmp = angleA.compareTo(angleB);
      if (angleCmp != 0) return angleCmp;
      final distA = pa.$1 * pa.$1 + pa.$2 * pa.$2;
      final distB = pb.$1 * pb.$1 + pb.$2 * pb.$2;
      return distA.compareTo(distB);
    });

    double dist((double, double) a, (double, double) b) {
      final dx = a.$1 - b.$1;
      final dy = a.$2 - b.$2;
      return math.sqrt(dx * dx + dy * dy);
    }

    double cross((double, double) o, (double, double) a, (double, double) b) =>
        (a.$1 - o.$1) * (b.$2 - o.$2) - (a.$2 - o.$2) * (b.$1 - o.$1);

    bool segmentsCross(LatLng a0, LatLng b0, LatLng c0, LatLng d0) {
      final a = toLocal(a0);
      final b = toLocal(b0);
      final c = toLocal(c0);
      final d = toLocal(d0);
      const eps = 1e-12;
      final d1 = cross(c, d, a);
      final d2 = cross(c, d, b);
      final d3 = cross(a, b, c);
      final d4 = cross(a, b, d);
      final properCross = ((d1 > eps && d2 < -eps) || (d1 < -eps && d2 > eps)) &&
          ((d3 > eps && d4 < -eps) || (d3 < -eps && d4 > eps));
      if (!properCross) return false;
      return (dist(a, c) + dist(b, d)) < (dist(a, b) + dist(c, d)) - 1e-12;
    }

    // 2-opt untangling pass to eliminate any remaining self-intersecting edges.
    final n = ordered.length;
    if (n >= 4) {
      bool changed = true;
      int guard = 0;
      final maxPasses = n * n;
      while (changed && guard < maxPasses) {
        changed = false;
        guard++;
        for (int i = 0; i < n - 1; i++) {
          final iNext = i + 1;
          for (int j = i + 2; j < n; j++) {
            if (i == 0 && j == n - 1) continue;
            final jNext = (j + 1) % n;
            if (segmentsCross(
              ordered[i],
              ordered[iNext],
              ordered[j],
              ordered[jNext],
            )) {
              int left = iNext;
              int right = j;
              while (left < right) {
                final tmp = ordered[left];
                ordered[left] = ordered[right];
                ordered[right] = tmp;
                left++;
                right--;
              }
              changed = true;
            }
          }
        }
      }
    }

    final anchorIdx = ordered.indexWhere(
      (p) =>
          (p.latitude - anchor.latitude).abs() < 1e-9 &&
          (p.longitude - anchor.longitude).abs() < 1e-9,
    );
    if (anchorIdx <= 0) {
      return List<LatLng>.unmodifiable(ordered);
    }
    return List<LatLng>.unmodifiable([
      ...ordered.sublist(anchorIdx),
      ...ordered.sublist(0, anchorIdx),
    ]);
  }

  /// Finds the containing forest zone for [point]. When overlapping zones exist,
  /// returns the smallest one by [approximateArea] (most specific habitat).
  static ForestZone? findContainingZone(
    LatLng point,
    List<ForestZone> zones,
  ) {
    ForestZone? best;
    double bestArea = double.infinity;
    for (final zone in zones) {
      if (!zone.containsPoint(point)) continue;
      final area = zone.approximateArea;
      if (best == null || area < bestArea) {
        best = zone;
        bestArea = area;
      }
    }
    return best;
  }

  ForestZone copyWith({
    String? id,
    String? name,
    String? treeType,
    List<LatLng>? points,
    String? notes,
    DateTime? createdAt,
  }) {
    return ForestZone(
      id: id ?? this.id,
      name: name ?? this.name,
      treeType: treeType ?? this.treeType,
      points: points ?? this.points,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'treeType': treeType,
      'points': points
          .map((p) => {'lat': p.latitude, 'lng': p.longitude})
          .toList(growable: false),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ForestZone.fromMap(Map<String, dynamic> map) {
    final rawPoints = map['points'] ?? map['pointsJson'];
    List<dynamic> decodedPoints = const [];
    if (rawPoints is String && rawPoints.trim().isNotEmpty) {
      decodedPoints = jsonDecode(rawPoints) as List<dynamic>;
    } else if (rawPoints is List) {
      decodedPoints = rawPoints;
    }

    final parsedPoints = decodedPoints
        .map((item) {
          final pointMap = Map<String, dynamic>.from(item as Map);
          final lat = (pointMap['lat'] as num).toDouble();
          final lng = (pointMap['lng'] as num).toDouble();
          return LatLng(lat, lng);
        })
        .toList(growable: false);

    final normalizedPoints = parsedPoints.length >= 3
        ? orderContourPoints(parsedPoints)
        : parsedPoints;

    return ForestZone(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? '',
      treeType: TreeSpecies.fromId(map['treeType'] as String?).id,
      points: normalizedPoints,
      notes: (map['notes'] as String?) ?? '',
      createdAt: DateTime.tryParse((map['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory ForestZone.fromJson(String source) =>
      ForestZone.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
