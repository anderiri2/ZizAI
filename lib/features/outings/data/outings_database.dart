import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/foraging_outing.dart';

class OutingsDatabase {
  static const String _tableName = 'foraging_outings';
  static const String _prefsFallbackKey = 'zizai_outings_json_v1';
  static const String _seededKey = 'zizai_outings_seeded_v1';

  Database? _db;

  Future<Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null) return _db;
    try {
      final dbDir = await getDatabasesPath();
      final fullPath = p.join(dbDir, 'zizai_outings_v1.db');
      _db = await openDatabase(
        fullPath,
        version: 2,
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
              notes TEXT NOT NULL,
              isManual INTEGER DEFAULT 0
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            try {
              await db.execute(
                'ALTER TABLE $_tableName ADD COLUMN isManual INTEGER DEFAULT 0',
              );
            } catch (_) {}
          }
        },
      );
      return _db;
    } catch (_) {
      return null;
    }
  }

  static const Set<String> _legacySampleIds = {
    'outing_gorbeia_otzarreta',
    'outing_urbasa_hayedo',
  };

  Future<List<ForagingOuting>> getAllOutings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);

    final db = await _getDatabase();
    if (db != null) {
      // Purgar salidas de ejemplo residuales si existieran
      for (final sampleId in _legacySampleIds) {
        await db.delete(_tableName, where: 'id = ?', whereArgs: [sampleId]);
      }
      final rows = await db.query(_tableName, orderBy: 'startedAt DESC');
      return rows.map((r) => ForagingOuting.fromMap(r)).toList();
    }

    final raw = prefs.getString(_prefsFallbackKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    final list = decoded
        .map((e) => ForagingOuting.fromMap(e as Map<String, dynamic>))
        .where((o) => !_legacySampleIds.contains(o.id))
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
  final bool isManual;

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
    this.isManual = false,
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
    bool? isManual,
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
      isManual: isManual ?? this.isManual,
    );
  }
}

class ActiveOutingRecorder extends StateNotifier<ActiveOutingState> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSub;
  static const Distance _distanceCalc = Distance();
  DateTime? _lastPauseTime;
  int _accumulatedPausedSeconds = 0;

  ActiveOutingRecorder() : super(const ActiveOutingState());

  Future<void> startOuting(
    String title, {
    LatLng? initialPoint,
    bool isManual = false,
  }) async {
    final now = DateTime.now();
    final id = 'outing_${now.millisecondsSinceEpoch}';
    final startPts = initialPoint != null ? <LatLng>[initialPoint] : <LatLng>[];
    _lastPauseTime = null;
    _accumulatedPausedSeconds = 0;

    state = ActiveOutingState(
      isRecording: true,
      isPaused: false,
      activeOutingId: id,
      title: title.trim().isEmpty ? 'Salida al monte' : title.trim(),
      startedAt: now,
      elapsedSeconds: 0,
      distanceMeters: 0.0,
      routePoints: startPts,
      isManual: isManual,
    );

    _startTimer();
    if (!isManual) {
      await _startGpsStream();
    }
  }

  ForagingOuting createRetrospectiveOuting({
    required String title,
    required DateTime startedAt,
    required int durationSeconds,
    required String notes,
  }) {
    final id = 'outing_${DateTime.now().millisecondsSinceEpoch}';
    return ForagingOuting(
      id: id,
      title: title.trim().isEmpty ? 'Salida al monte' : title.trim(),
      startedAt: startedAt,
      endedAt: startedAt.add(Duration(seconds: durationSeconds)),
      durationSeconds: durationSeconds,
      distanceMeters: 0.0,
      routePoints: const [],
      notes: notes,
      isManual: true,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.isRecording && !state.isPaused && state.startedAt != null) {
        final totalSecs =
            DateTime.now().difference(state.startedAt!).inSeconds -
                _accumulatedPausedSeconds;
        state = state.copyWith(
          elapsedSeconds: totalSecs > 0 ? totalSecs : 0,
        );
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

      // En Android 13+ (API 33+), el servicio en primer plano requiere permiso explícito de notificaciones
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final notifStatus = await Permission.notification.status;
          if (!notifStatus.isGranted) {
            await Permission.notification.request();
          }
        } catch (_) {}
      }

      late final LocationSettings locationSettings;
      if (defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 6,
          intervalDuration: const Duration(seconds: 4),
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: 'ZizAI • ${state.title}',
            notificationText: 'Grabando ruta GPS activa en el monte...',
            notificationChannelName: 'ZizAI Salida GPS',
            notificationIcon:
                const AndroidResource(name: 'ic_notification', defType: 'drawable'),
            enableWakeLock: true,
            setOngoing: true,
          ),
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 6,
          activityType: ActivityType.fitness,
          pauseLocationUpdatesAutomatically: false,
          showBackgroundLocationIndicator: true,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 6,
        );
      }

      // Asegurar que cualquier stream GPS previo esté completamente cerrado
      await _positionSub?.cancel();
      _positionSub = null;
      // Breve margen para que el singleton de GeolocatorAndroid en Dart libere el canal nativo
      await Future.delayed(const Duration(milliseconds: 300));

      _positionSub = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (pos) {
          if (state.isRecording && !state.isPaused) {
            // Descartar lecturas ruidosas con margen de error excesivo (> 35 m en monte)
            if (pos.accuracy > 35.0) return;
            addRoutePoint(LatLng(pos.latitude, pos.longitude));
          }
        },
        onError: (err) {
          debugPrint('ZizAI GPS Stream Error: $err');
        },
      );
    } catch (e) {
      debugPrint('ZizAI _startGpsStream Exception: $e');
    }
  }

  /// Reanuda el stream GPS de la salida activa si otro modal puntual de fijación GPS liberó el canal nativo.
  Future<void> ensureGpsStreamActive() async {
    if (state.isRecording && !state.isManual) {
      await _startGpsStream();
    }
  }

  void addRoutePoint(LatLng newPoint) {
    if (!state.isRecording) return;
    final pts = List<LatLng>.from(state.routePoints);
    double addedMeters = 0.0;
    if (pts.isNotEmpty) {
      addedMeters = _distanceCalc.as(LengthUnit.Meter, pts.last, newPoint);
      // Evitar registrar teletransportes o saltos GPS anómalos (> 400 m de golpe en senderismo)
      if (addedMeters > 400.0) return;
    }
    pts.add(newPoint);
    state = state.copyWith(
      routePoints: pts,
      distanceMeters: state.distanceMeters + addedMeters,
    );
  }

  void togglePause() {
    if (!state.isRecording) return;
    final willPause = !state.isPaused;
    if (willPause) {
      _lastPauseTime = DateTime.now();
    } else {
      if (_lastPauseTime != null) {
        _accumulatedPausedSeconds +=
            DateTime.now().difference(_lastPauseTime!).inSeconds;
        _lastPauseTime = null;
      }
    }
    state = state.copyWith(isPaused: willPause);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  ForagingOuting? finishOuting() {
    if (!state.isRecording || state.activeOutingId == null) return null;
    _timer?.cancel();
    _positionSub?.cancel();

    final totalSecs = state.startedAt != null
        ? (DateTime.now().difference(state.startedAt!).inSeconds -
            _accumulatedPausedSeconds)
        : state.elapsedSeconds;
    final finalDuration = totalSecs > 0 ? totalSecs : state.elapsedSeconds;

    final completed = ForagingOuting(
      id: state.activeOutingId!,
      title: state.title,
      startedAt: state.startedAt ?? DateTime.now(),
      endedAt: DateTime.now(),
      durationSeconds: finalDuration,
      distanceMeters: state.distanceMeters,
      routePoints: state.routePoints,
      notes: state.notes,
      isManual: state.isManual,
    );

    _lastPauseTime = null;
    _accumulatedPausedSeconds = 0;
    state = const ActiveOutingState();
    return completed;
  }

  void cancelOuting() {
    _timer?.cancel();
    _positionSub?.cancel();
    _lastPauseTime = null;
    _accumulatedPausedSeconds = 0;
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
