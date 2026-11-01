import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/foraging_outing.dart';

class OutingsDatabase {
  static const String _tableName = 'foraging_outings';
  static const String _prefsFallbackKey = 'perretxikotan_outings_json_v1';
  static const String _seededKey = 'perretxikotan_outings_seeded_v1';

  Database? _db;

  Future<Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null) return _db;
    try {
      final dbDir = await getDatabasesPath();
      final fullPath = p.join(dbDir, 'perretxikotan_outings_v1.db');
      _db = await openDatabase(
        fullPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              startedAt TEXT NOT NULL,
              endedAt TEXT NOT NULL,
              durationSeconds INTEGER NOT NULL,
              distanceMeters REAL NOT NULL,
              routePointsJson TEXT NOT NULL,
              notes TEXT NOT NULL
            )
          ''');
        },
      );
      return _db;
    } catch (_) {
      return null;
    }
  }

  List<ForagingOuting> _initialSampleOutings() {
    return [
      ForagingOuting(
        id: 'outing_gorbeia_otzarreta',
        title: 'Vuelta circular por Otzarreta (Gorbeia)',
        startedAt: DateTime(2026, 10, 18, 9, 0),
        endedAt: DateTime(2026, 10, 18, 11, 35),
        durationSeconds: 9300,
        distanceMeters: 4820,
        routePoints: const [
          LatLng(43.0332, -2.7254),
          LatLng(43.0345, -2.7271),
          LatLng(43.0358, -2.7289),
          LatLng(43.0374, -2.7312),
          LatLng(43.0392, -2.7341),
          LatLng(43.0405, -2.7320),
          LatLng(43.0388, -2.7285),
          LatLng(43.0361, -2.7262),
          LatLng(43.0332, -2.7254),
        ],
        notes:
            'Mañana templada con niebla baja entre las hayas trasmochas. Terreno muy húmedo tras las lluvias de la semana.',
      ),
      ForagingOuting(
        id: 'outing_urbasa_hayedo',
        title: 'Ruta micológica por Urbasa',
        startedAt: DateTime(2026, 10, 24, 9, 30),
        endedAt: DateTime(2026, 10, 24, 12, 40),
        durationSeconds: 11400,
        distanceMeters: 6150,
        routePoints: const [
          LatLng(42.8305, -2.1120),
          LatLng(42.8318, -2.1142),
          LatLng(42.8331, -2.1164),
          LatLng(42.8350, -2.1190),
          LatLng(42.8364, -2.1215),
          LatLng(42.8378, -2.1185),
          LatLng(42.8348, -2.1148),
          LatLng(42.8305, -2.1120),
        ],
        notes:
            'Recorrido por las vaguadas kársticas del raso de Urbasa. Mucho musgo y abundancia de Ziza horia y Tripaki argia.',
      ),
    ];
  }

  Future<List<ForagingOuting>> getAllOutings() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seededKey) ?? false;

    final db = await _getDatabase();
    if (db != null) {
      final rows = await db.query(_tableName, orderBy: 'startedAt DESC');
      if (rows.isEmpty && !alreadySeeded) {
        final samples = _initialSampleOutings();
        for (final o in samples) {
          await db.insert(
            _tableName,
            o.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await prefs.setBool(_seededKey, true);
        return samples;
      }
      return rows.map((r) => ForagingOuting.fromMap(r)).toList();
    }

    final raw = prefs.getString(_prefsFallbackKey);
    if (raw == null && !alreadySeeded) {
      final samples = _initialSampleOutings();
      await _saveFallbackList(prefs, samples);
      await prefs.setBool(_seededKey, true);
      return samples;
    }
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    final list = decoded
        .map((e) => ForagingOuting.fromMap(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return list;
  }

  Future<void> upsertOuting(ForagingOuting outing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);

    final db = await _getDatabase();
    if (db != null) {
      await db.insert(
        _tableName,
        outing.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }

    final current = await getAllOutings();
    final idx = current.indexWhere((o) => o.id == outing.id);
    if (idx >= 0) {
      current[idx] = outing;
    } else {
      current.insert(0, outing);
    }
    await _saveFallbackList(prefs, current);
  }

  Future<void> deleteOuting(String id) async {
    final db = await _getDatabase();
    if (db != null) {
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final current = await getAllOutings();
    current.removeWhere((o) => o.id == id);
    await _saveFallbackList(prefs, current);
  }

  Future<void> replaceAllOutings(List<ForagingOuting> outings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);

    final db = await _getDatabase();
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete(_tableName);
        for (final o in outings) {
          await txn.insert(
            _tableName,
            o.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return;
    }

    await _saveFallbackList(prefs, outings);
  }

  Future<void> mergeOutings(List<ForagingOuting> incoming) async {
    final existing = await getAllOutings();
    final byId = <String, ForagingOuting>{
      for (final o in existing) o.id: o,
    };
    for (final inc in incoming) {
      byId[inc.id] = inc;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    await replaceAllOutings(merged);
  }

  Future<void> _saveFallbackList(
    SharedPreferences prefs,
    List<ForagingOuting> outings,
  ) async {
    final encoded = json.encode(outings.map((o) => o.toMap()).toList());
    await prefs.setString(_prefsFallbackKey, encoded);
  }
}

final outingsDatabaseProvider = Provider<OutingsDatabase>((ref) {
  return OutingsDatabase();
});

class OutingsNotifier extends StateNotifier<AsyncValue<List<ForagingOuting>>> {
  final OutingsDatabase _db;

  OutingsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadOutings();
  }

  Future<void> loadOutings() async {
    try {
      final list = await _db.getAllOutings();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveOuting(ForagingOuting outing) async {
    await _db.upsertOuting(outing);
    await loadOutings();
  }

  Future<void> removeOuting(String id) async {
    await _db.deleteOuting(id);
    await loadOutings();
  }

  Future<void> restoreOutings(
    List<ForagingOuting> outings, {
    bool merge = true,
  }) async {
    if (merge) {
      await _db.mergeOutings(outings);
    } else {
      await _db.replaceAllOutings(outings);
    }
    await loadOutings();
  }

  Future<void> mergeOutings(List<ForagingOuting> outings) =>
      restoreOutings(outings, merge: true);

  Future<void> replaceAllOutings(List<ForagingOuting> outings) =>
      restoreOutings(outings, merge: false);
}

final outingsProvider =
    StateNotifierProvider<OutingsNotifier, AsyncValue<List<ForagingOuting>>>(
        (ref) {
  final db = ref.watch(outingsDatabaseProvider);
  return OutingsNotifier(db);
});

/// Estado del grabador de ruta GPS de una salida activa en tiempo real.
class ActiveOutingState {
  final bool isRecording;
  final bool isPaused;
  final String? activeOutingId;
  final String title;
  final DateTime? startedAt;
  final int elapsedSeconds;
  final double distanceMeters;
  final List<LatLng> routePoints;
  final String notes;

  const ActiveOutingState({
    this.isRecording = false,
    this.isPaused = false,
    this.activeOutingId,
    this.title = '',
    this.startedAt,
    this.elapsedSeconds = 0,
    this.distanceMeters = 0.0,
    this.routePoints = const [],
    this.notes = '',
  });

  ActiveOutingState copyWith({
    bool? isRecording,
    bool? isPaused,
    String? activeOutingId,
    String? title,
    DateTime? startedAt,
    int? elapsedSeconds,
    double? distanceMeters,
    List<LatLng>? routePoints,
    String? notes,
  }) {
    return ActiveOutingState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      activeOutingId: activeOutingId ?? this.activeOutingId,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      routePoints: routePoints ?? this.routePoints,
      notes: notes ?? this.notes,
    );
  }
}

class ActiveOutingRecorder extends StateNotifier<ActiveOutingState> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSub;
  static const Distance _distanceCalc = Distance();

  ActiveOutingRecorder() : super(const ActiveOutingState());

  Future<void> startOuting(String title, {LatLng? initialPoint}) async {
    final now = DateTime.now();
    final id = 'outing_${now.millisecondsSinceEpoch}';
    final startPts = initialPoint != null ? <LatLng>[initialPoint] : <LatLng>[];

    state = ActiveOutingState(
      isRecording: true,
      isPaused: false,
      activeOutingId: id,
      title: title.trim().isEmpty ? 'Salida al monte' : title.trim(),
      startedAt: now,
      elapsedSeconds: 0,
      distanceMeters: 0.0,
      routePoints: startPts,
    );

    _startTimer();
    await _startGpsStream();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRecording && !state.isPaused) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });
  }

  Future<void> _startGpsStream() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      _positionSub?.cancel();
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 8,
        ),
      ).listen((pos) {
        if (state.isRecording && !state.isPaused) {
          addRoutePoint(LatLng(pos.latitude, pos.longitude));
        }
      });
    } catch (_) {}
  }

  void addRoutePoint(LatLng newPoint) {
    if (!state.isRecording) return;
    final pts = List<LatLng>.from(state.routePoints);
    double addedMeters = 0.0;
    if (pts.isNotEmpty) {
      addedMeters = _distanceCalc.as(LengthUnit.Meter, pts.last, newPoint);
    }
    pts.add(newPoint);
    state = state.copyWith(
      routePoints: pts,
      distanceMeters: state.distanceMeters + addedMeters,
    );
  }

  void togglePause() {
    if (!state.isRecording) return;
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  ForagingOuting? finishOuting() {
    if (!state.isRecording || state.activeOutingId == null) return null;
    _timer?.cancel();
    _positionSub?.cancel();

    final completed = ForagingOuting(
      id: state.activeOutingId!,
      title: state.title,
      startedAt: state.startedAt ?? DateTime.now(),
      endedAt: DateTime.now(),
      durationSeconds: state.elapsedSeconds,
      distanceMeters: state.distanceMeters,
      routePoints: state.routePoints,
      notes: state.notes,
    );

    state = const ActiveOutingState();
    return completed;
  }

  void cancelOuting() {
    _timer?.cancel();
    _positionSub?.cancel();
    state = const ActiveOutingState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }
}

final activeOutingRecorderProvider =
    StateNotifierProvider<ActiveOutingRecorder, ActiveOutingState>((ref) {
  return ActiveOutingRecorder();
});
