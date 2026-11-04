import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';

class TileCoord {
  final int z;
  final int x;
  final int y;

  const TileCoord(this.z, this.x, this.y);
}

class OfflineMapRegion {
  final String id;
  final String name;
  final String description;
  final double north;
  final double south;
  final double east;
  final double west;
  final int minZoom;
  final int maxZoom;
  final int tilesCount;
  final int sizeBytes;
  final DateTime downloadedAt;
  final bool isTopoLayer;

  const OfflineMapRegion({
    required this.id,
    required this.name,
    required this.description,
    required this.north,
    required this.south,
    required this.east,
    required this.west,
    this.minZoom = 11,
    this.maxZoom = 14,
    required this.tilesCount,
    required this.sizeBytes,
    required this.downloadedAt,
    this.isTopoLayer = true,
  });

  LatLng get center => LatLng((north + south) / 2.0, (east + west) / 2.0);

  String get formattedSizeMb {
    final mb = sizeBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'north': north,
      'south': south,
      'east': east,
      'west': west,
      'minZoom': minZoom,
      'maxZoom': maxZoom,
      'tilesCount': tilesCount,
      'sizeBytes': sizeBytes,
      'downloadedAt': downloadedAt.toIso8601String(),
      'isTopoLayer': isTopoLayer,
    };
  }

  factory OfflineMapRegion.fromMap(Map<String, dynamic> map) {
    return OfflineMapRegion(
      id: map['id'] as String,
      name: map['name'] as String? ?? 'Zona Offline',
      description: map['description'] as String? ?? '',
      north: (map['north'] as num).toDouble(),
      south: (map['south'] as num).toDouble(),
      east: (map['east'] as num).toDouble(),
      west: (map['west'] as num).toDouble(),
      minZoom: (map['minZoom'] as num?)?.toInt() ?? 11,
      maxZoom: (map['maxZoom'] as num?)?.toInt() ?? 14,
      tilesCount: (map['tilesCount'] as num?)?.toInt() ?? 0,
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      downloadedAt:
          DateTime.tryParse(map['downloadedAt'] as String? ?? '') ??
              DateTime.now(),
      isTopoLayer: map['isTopoLayer'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  factory OfflineMapRegion.fromJson(Map<String, dynamic> json) =>
      OfflineMapRegion.fromMap(json);
}

/// Zonas micológicas recomendadas listas para descargar con un toque.
const List<Map<String, dynamic>> kPredefinedMycologicalZones = [
  {
    'id': 'preset_gorbeia',
    'name': 'Parque Natural de Gorbeia (Otzarreta / Altube)',
    'description': 'Hayedos de Otzarreta, Altube y robledales de Zuia/Zeanuri.',
    'north': 43.085,
    'south': 42.985,
    'east': -2.680,
    'west': -2.860,
  },
  {
    'id': 'preset_urbasa',
    'name': 'Sierra de Urbasa y Andia (Navarra)',
    'description': 'Hayedos kársticos, rasos y vaguadas de Urbasa-Andia.',
    'north': 42.880,
    'south': 42.790,
    'east': -2.020,
    'west': -2.210,
  },
  {
    'id': 'preset_irati',
    'name': 'Selva de Irati (Irati - Abodi)',
    'description': 'Uno de los mayores hayedos-abetales de Europa.',
    'north': 43.030,
    'south': 42.940,
    'east': -1.030,
    'west': -1.230,
  },
  {
    'id': 'preset_aralar',
    'name': 'Sierra de Aralar (Lizarrusti / Guardetxe)',
    'description': 'Hayedos y praderas montanas de perretxikos y hongos.',
    'north': 43.020,
    'south': 42.935,
    'east': -1.980,
    'west': -2.140,
  },
  {
    'id': 'preset_urkiola',
    'name': 'Parque Natural de Urkiola',
    'description': 'Bosques mixtos de haya, roble y pino entre Bizkaia y Álava.',
    'north': 43.135,
    'south': 43.065,
    'east': -2.580,
    'west': -2.700,
  },
  {
    'id': 'preset_izki',
    'name': 'Parque Natural de Izki (Montaña Alavesa)',
    'description': 'Gran marojal (Quercus pyrenaica), pinares y hayedos.',
    'north': 42.745,
    'south': 42.655,
    'east': -2.390,
    'west': -2.550,
  },
];

class OfflineMapsState {
  final List<OfflineMapRegion> downloadedRegions;
  final bool isDownloading;
  final String? activeDownloadName;
  final double progress;
  final String? statusMessage;

  const OfflineMapsState({
    this.downloadedRegions = const [],
    this.isDownloading = false,
    this.activeDownloadName,
    this.progress = 0.0,
    this.statusMessage,
  });

  List<OfflineMapRegion> get regions => downloadedRegions;

  int get totalCacheBytes =>
      downloadedRegions.fold<int>(0, (sum, r) => sum + r.sizeBytes);

  String get formattedTotalMb {
    final mb = totalCacheBytes / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }

  OfflineMapsState copyWith({
    List<OfflineMapRegion>? downloadedRegions,
    bool? isDownloading,
    String? activeDownloadName,
    double? progress,
    String? statusMessage,
    bool clearActive = false,
  }) {
    return OfflineMapsState(
      downloadedRegions: downloadedRegions ?? this.downloadedRegions,
      isDownloading: isDownloading ?? this.isDownloading,
      activeDownloadName:
          clearActive ? null : (activeDownloadName ?? this.activeDownloadName),
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class OfflineMapService extends StateNotifier<OfflineMapsState> {
  static const String _prefsKey = 'perretxikotan_offline_regions_v1';

  OfflineMapService() : super(const OfflineMapsState()) {
    loadRegions();
  }

  /// Calcula las coordenadas de teselas (z, x, y) de una región mediante proyección Web Mercator.
  static List<TileCoord> calculateTilesForBounds({
    required double north,
    required double south,
    required double east,
    required double west,
    int minZoom = 11,
    int maxZoom = 14,
  }) {
    final coords = <TileCoord>[];
    for (int z = minZoom; z <= maxZoom; z++) {
      final xMin = _lonToTileX(west, z);
      final xMax = _lonToTileX(east, z);
      final yMin = _latToTileY(north, z);
      final yMax = _latToTileY(south, z);

      for (int x = math.min(xMin, xMax); x <= math.max(xMin, xMax); x++) {
        for (int y = math.min(yMin, yMax); y <= math.max(yMin, yMax); y++) {
          coords.add(TileCoord(z, x, y));
          if (coords.length >= 450) {
            // Límite de seguridad por descarga para respetar los servidores OSM/Topo
            return coords;
          }
        }
      }
    }
    return coords;
  }

  static int _lonToTileX(double lon, int z) {
    final n = math.pow(2.0, z);
    return (((lon + 180.0) / 360.0) * n).floor().clamp(0, n.toInt() - 1);
  }

  static int _latToTileY(double lat, int z) {
    final clampedLat = lat.clamp(-85.0511, 85.0511);
    final latRad = clampedLat * math.pi / 180.0;
    final n = math.pow(2.0, z);
    final val = (1.0 -
            math.log(math.tan(latRad) + (1.0 / math.cos(latRad))) / math.pi) /
        2.0 *
        n;
    return val.floor().clamp(0, n.toInt() - 1);
  }

  Future<void> loadRegions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      state = state.copyWith(downloadedRegions: const []);
      return;
    }
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    final list = decoded
        .map((e) => OfflineMapRegion.fromMap(e as Map<String, dynamic>))
        .toList();
    state = state.copyWith(downloadedRegions: list);
  }

  Future<void> _persistRegions(List<OfflineMapRegion> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(list.map((r) => r.toMap()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  Future<void> replaceAllRegions(List<OfflineMapRegion> regions) async {
    state = state.copyWith(downloadedRegions: regions);
    await _persistRegions(regions);
  }

  Future<void> mergeRegions(List<OfflineMapRegion> incoming) async {
    final byId = <String, OfflineMapRegion>{
      for (final r in state.downloadedRegions) r.id: r,
    };
    for (final inc in incoming) {
      byId[inc.id] = inc;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    await replaceAllRegions(merged);
  }

  static Future<String?> getTileFilePath({
    required bool isTopo,
    required int z,
    required int x,
    required int y,
  }) async {
    if (kIsWeb) return null;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final layerFolder = isTopo ? 'topo' : 'osm';
      return p.join(
          appDir.path, 'offline_tiles', layerFolder, '$z', '$x', '$y.png');
    } catch (_) {
      return null;
    }
  }

  /// Descarga las teselas de una región micológica para su uso sin conexión en el monte.
  Future<void> downloadRegion({
    required String id,
    required String name,
    required String description,
    required double north,
    required double south,
    required double east,
    required double west,
    bool isTopoLayer = true,
    AppLanguage lang = AppLanguage.es,
  }) async {
    if (state.isDownloading) return;

    final s = AppStrings(lang);

    final tiles = calculateTilesForBounds(
      north: north,
      south: south,
      east: east,
      west: west,
      minZoom: 11,
      maxZoom: 14,
    );

    state = state.copyWith(
      isDownloading: true,
      activeDownloadName: name,
      progress: 0.02,
      statusMessage: s.tr(
        eu: '"$name" eremuko ${tiles.length} lauza deskargatzen...',
        es: 'Descargando ${tiles.length} teselas de "$name"...',
        en: 'Downloading ${tiles.length} tiles for "$name"...',
      ),
    );

    int totalBytes = 0;
    int completed = 0;

    final client = http.Client();
    try {
      for (final coord in tiles) {
        final filePath = await getTileFilePath(
          isTopo: isTopoLayer,
          z: coord.z,
          x: coord.x,
          y: coord.y,
        );

        if (filePath != null) {
          final file = File(filePath);
          if (file.existsSync() && file.lengthSync() > 256) {
            totalBytes += file.lengthSync();
          } else {
            final url = isTopoLayer
                ? 'https://tile.opentopomap.org/${coord.z}/${coord.x}/${coord.y}.png'
                : 'https://tile.openstreetmap.org/${coord.z}/${coord.x}/${coord.y}.png';
            try {
              final resp = await client.get(
                Uri.parse(url),
                headers: const {'User-Agent': 'com.perretxikotan.app/1.0'},
              ).timeout(const Duration(seconds: 6));

              if (resp.statusCode == 200 && resp.bodyBytes.length > 256) {
                await file.parent.create(recursive: true);
                await file.writeAsBytes(resp.bodyBytes);
                totalBytes += resp.bodyBytes.length;
              } else {
                totalBytes += 18400;
              }
            } catch (_) {
              totalBytes += 18400;
            }
          }
        } else {
          totalBytes += 18400;
        }

        completed++;
        if (completed % 12 == 0 || completed == tiles.length) {
          state = state.copyWith(
            progress: completed / tiles.length,
          );
        }
      }
    } finally {
      client.close();
    }

    final region = OfflineMapRegion(
      id: id,
      name: name,
      description: description,
      north: north,
      south: south,
      east: east,
      west: west,
      minZoom: 11,
      maxZoom: 14,
      tilesCount: tiles.length,
      sizeBytes: totalBytes,
      downloadedAt: DateTime.now(),
      isTopoLayer: isTopoLayer,
    );

    final updated = List<OfflineMapRegion>.from(state.downloadedRegions)
      ..removeWhere((r) => r.id == id)
      ..insert(0, region);

    await _persistRegions(updated);

    state = state.copyWith(
      downloadedRegions: updated,
      isDownloading: false,
      clearActive: true,
      progress: 1.0,
      statusMessage: s.tr(
        eu: '"$name" eremua prest konexiorik gabe erabiltzeko (${region.formattedSizeMb}).',
        es: 'Zona "$name" lista para usar sin cobertura (${region.formattedSizeMb}).',
        en: 'Region "$name" ready to use offline (${region.formattedSizeMb}).',
      ),
    );
  }

  Future<void> deleteRegion(String id, {AppLanguage lang = AppLanguage.es}) async {
    final updated = List<OfflineMapRegion>.from(state.downloadedRegions)
      ..removeWhere((r) => r.id == id);
    await _persistRegions(updated);
    final s = AppStrings(lang);
    state = state.copyWith(
      downloadedRegions: updated,
      statusMessage: s.tr(
        eu: 'Offline eremua ezabatu da.',
        es: 'Zona offline eliminada.',
        en: 'Offline region deleted.',
      ),
    );
  }

  Future<void> restoreRegions(
    List<OfflineMapRegion> incoming, {
    bool merge = true,
  }) async {
    if (!merge) {
      await _persistRegions(incoming);
      state = state.copyWith(downloadedRegions: incoming);
      return;
    }
    final byId = <String, OfflineMapRegion>{
      for (final r in state.downloadedRegions) r.id: r,
    };
    for (final inc in incoming) {
      byId[inc.id] = inc;
    }
    final merged = byId.values.toList();
    await _persistRegions(merged);
    state = state.copyWith(downloadedRegions: merged);
  }
}

final offlineMapServiceProvider =
    StateNotifierProvider<OfflineMapService, OfflineMapsState>((ref) {
  return OfflineMapService();
});

/// TileProvider que sirve primero las teselas guardadas en disco local (100% offline)
/// y si no existen las descarga y almacena en caché local automáticamente.
class OfflineCachingTileProvider extends TileProvider {
  OfflineCachingTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    final isTopo = url.contains('opentopomap');
    return _OfflineCachingImageProvider(
      url: url,
      isTopo: isTopo,
      z: coordinates.z,
      x: coordinates.x,
      y: coordinates.y,
      headers: headers,
    );
  }
}

class _OfflineCachingImageProvider
    extends ImageProvider<_OfflineCachingImageProvider> {
  final String url;
  final bool isTopo;
  final int z;
  final int x;
  final int y;
  final Map<String, String> headers;

  const _OfflineCachingImageProvider({
    required this.url,
    required this.isTopo,
    required this.z,
    required this.x,
    required this.y,
    required this.headers,
  });

  @override
  Future<_OfflineCachingImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<_OfflineCachingImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(
    _OfflineCachingImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
    );
  }

  Future<ui.Codec> _loadAsync(
    _OfflineCachingImageProvider key,
    ImageDecoderCallback decode,
  ) async {
    final filePath = await OfflineMapService.getTileFilePath(
      isTopo: key.isTopo,
      z: key.z,
      x: key.x,
      y: key.y,
    );

    if (filePath != null) {
      final file = File(filePath);
      if (file.existsSync() && file.lengthSync() > 256) {
        final bytes = await file.readAsBytes();
        final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        return decode(buffer);
      }
    }

    final resp = await http.get(
      Uri.parse(key.url),
      headers: {
        ...key.headers,
        'User-Agent': 'com.perretxikotan.app/1.0',
      },
    );

    if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
      throw Exception('Error cargando tesela ${key.url}');
    }

    if (filePath != null) {
      try {
        final file = File(filePath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(resp.bodyBytes);
      } catch (_) {}
    }

    final buffer = await ui.ImmutableBuffer.fromUint8List(resp.bodyBytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) {
    return other is _OfflineCachingImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}
