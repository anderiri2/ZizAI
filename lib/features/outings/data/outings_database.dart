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
import '../../map/models/foraging_spot.dart';
import '../models/foraging_outing.dart';

class OutingsDatabase {
  static const String _tableName = 'foraging_outings';
  static const String _prefsFallbackKey = 'zizai_outings_json_v1';
  static const String _seededKey = 'zizai_outings_seeded_v1';

  Database? _db;
  Future<void> _pendingOp = Future<void>.value();

  Future<T> _synchronized<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _pendingOp = _pendingOp.then((_) async {
      try {
        completer.complete(await action());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

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

  Future<List<ForagingOuting>> _getAllOutingsInternal() async {
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

  Future<void> _upsertOutingInternal(ForagingOuting outing) async {
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

    final current = await _getAllOutingsInternal();
    final idx = current.indexWhere((o) => o.id == outing.id);
    if (idx >= 0) {
      current[idx] = outing;
    } else {
      current.insert(0, outing);
    }
    await _saveFallbackList(prefs, current);
  }

  Future<void> _replaceAllOutingsInternal(List<ForagingOuting> outings) async {
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

  Future<List<ForagingOuting>> getAllOutings() =>
      _synchronized(_getAllOutingsInternal);

  Future<void> upsertOuting(ForagingOuting outing) =>
      _synchronized(() => _upsertOutingInternal(outing));

  Future<void> deleteOuting(String id) => _synchronized(() async {
        final db = await _getDatabase();
        if (db != null) {
          await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final current = await _getAllOutingsInternal();
        current.removeWhere((o) => o.id == id);
        await _saveFallbackList(prefs, current);
      });

  Future<void> replaceAllOutings(List<ForagingOuting> outings) =>
      _synchronized(() => _replaceAllOutingsInternal(outings));

  Future<void> mergeOutings(List<ForagingOuting> incoming) =>
      _synchronized(() async {
        final existing = await _getAllOutingsInternal();
        final byId = <String, ForagingOuting>{
          for (final o in existing) o.id: o,
        };
        for (final inc in incoming) {
          byId[inc.id] = inc;
        }
        final merged = byId.values.toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        await _replaceAllOutingsInternal(merged);
      });

  /// Reconstruye salidas huérfanas a partir de setas ya guardadas cuyo outingId no figure en la BD.
  Future<int> recoverOrphanedOutingsFromSpots(List<ForagingSpot> spots) async {
    if (spots.isEmpty) return 0;
    return _synchronized(() async {
      final grouped = <String, List<ForagingSpot>>{};
      for (final spot in spots) {
        final oid = spot.outingId;
        if (oid == null ||
            oid.isEmpty ||
            oid == 'temp' ||
            _legacySampleIds.contains(oid)) {
          continue;
        }
        grouped.putIfAbsent(oid, () => <ForagingSpot>[]).add(spot);
      }
      if (grouped.isEmpty) return 0;

      final existing = await _getAllOutingsInternal();
      final existingIds = existing.map((o) => o.id).toSet();

      var recoveredCount = 0;
      for (final entry in grouped.entries) {
        if (existingIds.contains(entry.key)) continue;
        final outingSpots = entry.value;

        var title = 'Salida recuperada';
        for (final sp in outingSpots) {
          final candidate = sp.outingTitle?.trim();
          if (candidate != null && candidate.isNotEmpty) {
            title = candidate;
            break;
          }
        }

        var minFoundAt = outingSpots.first.foundAt;
        var maxFoundAt = outingSpots.first.foundAt;
        for (final sp in outingSpots.skip(1)) {
          if (sp.foundAt.isBefore(minFoundAt)) minFoundAt = sp.foundAt;
          if (sp.foundAt.isAfter(maxFoundAt)) maxFoundAt = sp.foundAt;
        }

        DateTime? idTime;
        if (entry.key.startsWith('outing_')) {
          final parsedMs = int.tryParse(entry.key.substring(7));
          if (parsedMs != null && parsedMs > 1577836800000) {
            idTime = DateTime.fromMillisecondsSinceEpoch(parsedMs);
          }
        }

        final startedAt = (idTime != null && idTime.isBefore(minFoundAt))
            ? idTime
            : minFoundAt;
        final endedAt = maxFoundAt.isBefore(startedAt)
            ? startedAt.add(const Duration(minutes: 30))
            : maxFoundAt;
        final durationSeconds =
            endedAt.difference(startedAt).inSeconds.clamp(60, 86400);

        final reconstructed = ForagingOuting(
          id: entry.key,
          title: title,
          startedAt: startedAt,
          endedAt: endedAt,
          durationSeconds: durationSeconds,
          distanceMeters: 0.0,
          routePoints: const [],
          notes: '',
          isManual: true,
        );
        await _upsertOutingInternal(reconstructed);
        recoveredCount++;
      }
      return recoveredCount;
    });
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
  bool _isRecoveringOrphans = false;

  OutingsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadOutings();
  }

  Future<void> loadOutings() async {
    try {
      final list = await _db.getAllOutings();
      if (!mounted) return;
      state = AsyncValue.data(list);
    } catch (e, st) {
      if (!mounted) return;
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

  Future<int> recoverOrphanedOutings(List<ForagingSpot> spots) async {
    if (_isRecoveringOrphans) return 0;
    _isRecoveringOrphans = true;
    try {
      final count = await _db.recoverOrphanedOutingsFromSpots(spots);
      if (count > 0 && mounted) {
        await loadOutings();
      }
      return count;
    } finally {
      _isRecoveringOrphans = false;
    }
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
  final DateTime? sessionStartedAt;
  final int baseDurationSeconds;
  final int elapsedSeconds;
  final double distanceMeters;
  final List<LatLng> routePoints;
  final LatLng? initialCenterPoint;
  final String notes;
  final bool isManual;

  const ActiveOutingState({
    this.isRecording = false,
    this.isPaused = false,
    this.activeOutingId,
    this.title = '',
    this.startedAt,
    this.sessionStartedAt,
    this.baseDurationSeconds = 0,
    this.elapsedSeconds = 0,
    this.distanceMeters = 0.0,
    this.routePoints = const [],
    this.initialCenterPoint,
    this.notes = '',
    this.isManual = false,
  });

  ActiveOutingState copyWith({
    bool? isRecording,
    bool? isPaused,
    String? activeOutingId,
    String? title,
    DateTime? startedAt,
    DateTime? sessionStartedAt,
    int? baseDurationSeconds,
    int? elapsedSeconds,
    double? distanceMeters,
    List<LatLng>? routePoints,
    LatLng? initialCenterPoint,
    String? notes,
    bool? isManual,
  }) {
    return ActiveOutingState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      activeOutingId: activeOutingId ?? this.activeOutingId,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      baseDurationSeconds: baseDurationSeconds ?? this.baseDurationSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      routePoints: routePoints ?? this.routePoints,
      initialCenterPoint: initialCenterPoint ?? this.initialCenterPoint,
      notes: notes ?? this.notes,
      isManual: isManual ?? this.isManual,
    );
  }

  ForagingOuting? toForagingOuting({int? overrideDurationSeconds}) {
    if (activeOutingId == null) return null;
    final duration = overrideDurationSeconds ?? elapsedSeconds;
    return ForagingOuting(
      id: activeOutingId!,
      title: title.trim().isEmpty ? 'Salida al monte' : title.trim(),
      startedAt: startedAt ?? DateTime.now(),
      endedAt: DateTime.now(),
      durationSeconds: duration > 0 ? duration : 0,
      distanceMeters: distanceMeters,
      routePoints: List<LatLng>.from(routePoints),
      notes: notes,
      isManual: isManual,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRecording': isRecording,
      'isPaused': isPaused,
      'activeOutingId': activeOutingId,
      'title': title,
      'startedAt': startedAt?.toIso8601String(),
      'sessionStartedAt': sessionStartedAt?.toIso8601String(),
      'baseDurationSeconds': baseDurationSeconds,
      'elapsedSeconds': elapsedSeconds,
      'distanceMeters': distanceMeters,
      'routePoints': routePoints
          .map((pt) => {'lat': pt.latitude, 'lng': pt.longitude})
          .toList(),
      'initialCenterPoint': initialCenterPoint != null
          ? {
              'lat': initialCenterPoint!.latitude,
              'lng': initialCenterPoint!.longitude,
            }
          : null,
      'notes': notes,
      'isManual': isManual,
    };
  }

  factory ActiveOutingState.fromMap(Map<String, dynamic> map) {
    final rawPts = map['routePoints'];
    final parsedPoints = <LatLng>[];
    if (rawPts is List) {
      for (final item in rawPts) {
        if (item is Map) {
          final lat = (item['lat'] as num?)?.toDouble();
          final lng = (item['lng'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            parsedPoints.add(LatLng(lat, lng));
          }
        }
      }
    }

    LatLng? parsedInitialCenter;
    final rawCenter = map['initialCenterPoint'];
    if (rawCenter is Map) {
      final lat = (rawCenter['lat'] as num?)?.toDouble();
      final lng = (rawCenter['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        parsedInitialCenter = LatLng(lat, lng);
      }
    }

    return ActiveOutingState(
      isRecording: map['isRecording'] == true,
      isPaused: map['isPaused'] == true,
      activeOutingId: map['activeOutingId'] as String?,
      title: map['title'] as String? ?? '',
      startedAt: map['startedAt'] is String
          ? DateTime.tryParse(map['startedAt'] as String)
          : null,
      sessionStartedAt: map['sessionStartedAt'] is String
          ? DateTime.tryParse(map['sessionStartedAt'] as String)
          : null,
      baseDurationSeconds: (map['baseDurationSeconds'] as num?)?.toInt() ?? 0,
      elapsedSeconds: (map['elapsedSeconds'] as num?)?.toInt() ?? 0,
      distanceMeters: (map['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      routePoints: parsedPoints,
      initialCenterPoint: parsedInitialCenter,
      notes: map['notes'] as String? ?? '',
      isManual: map['isManual'] == true,
    );
  }
}

class ActiveOutingRecorder extends StateNotifier<ActiveOutingState> {
  static const String _activeStatePrefsKey = 'zizai_active_outing_state_v1';
  static const int _autoSaveIntervalSeconds = 15;

  final OutingsDatabase _db;
  final Future<void> Function(ForagingOuting)? _onOutingPersisted;

  Timer? _timer;
  StreamSubscription<Position>? _positionSub;
  static const Distance _distanceCalc = Distance();
  DateTime? _lastPauseTime;
  int _accumulatedPausedSeconds = 0;
  bool _allowNextPointJump = false;
  LatLng? _lastRejectedJumpPoint;
  int _ticksSinceLastSave = 0;
  int _snapshotGeneration = 0;

  ActiveOutingRecorder({
    OutingsDatabase? db,
    Future<void> Function(ForagingOuting)? onOutingPersisted,
  })  : _db = db ?? OutingsDatabase(),
        _onOutingPersisted = onOutingPersisted,
        super(const ActiveOutingState()) {
    unawaited(restoreActiveOutingIfNeeded());
  }

  int _computeCurrentDurationSeconds() {
    final currentPauseSecs = (state.isPaused && _lastPauseTime != null)
        ? DateTime.now().difference(_lastPauseTime!).inSeconds
        : 0;
    final totalPaused =
        _accumulatedPausedSeconds + (currentPauseSecs > 0 ? currentPauseSecs : 0);

    if (state.sessionStartedAt != null) {
      final sessionSecs =
          DateTime.now().difference(state.sessionStartedAt!).inSeconds -
              totalPaused;
      final total =
          state.baseDurationSeconds + (sessionSecs > 0 ? sessionSecs : 0);
      return total > state.elapsedSeconds ? total : state.elapsedSeconds;
    }

    if (state.startedAt != null) {
      final totalSecs =
          DateTime.now().difference(state.startedAt!).inSeconds - totalPaused;
      return totalSecs > 0 ? totalSecs : 0;
    }

    return state.elapsedSeconds;
  }

  /// Restaura automáticamente una salida activa que se estaba grabando si la app fue cerrada inesperadamente.
  Future<void> restoreActiveOutingIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_activeStatePrefsKey);
      if (raw == null || raw.isEmpty) return;

      final decoded = json.decode(raw);
      if (decoded is! Map<String, dynamic>) return;

      final restoredState = ActiveOutingState.fromMap(decoded);
      if (!mounted || state.isRecording) return;
      if (!restoredState.isRecording || restoredState.activeOutingId == null) {
        return;
      }

      _accumulatedPausedSeconds =
          (decoded['accumulatedPausedSeconds'] as num?)?.toInt() ?? 0;
      _lastPauseTime = decoded['lastPauseTime'] is String
          ? DateTime.tryParse(decoded['lastPauseTime'] as String)
          : null;
      _allowNextPointJump = true;
      _lastRejectedJumpPoint = null;
      _ticksSinceLastSave = 0;

      state = restoredState;
      final refreshedElapsed = _computeCurrentDurationSeconds();
      if (refreshedElapsed != state.elapsedSeconds) {
        state = state.copyWith(elapsedSeconds: refreshedElapsed);
      }

      _startTimer();
      unawaited(persistActiveOutingSnapshot());
      if (!state.isManual) {
        unawaited(_startGpsStream());
      }
    } catch (_) {}
  }

  /// Persiste inmediatamente la salida activa tanto en SharedPreferences como en OutingsDatabase.
  Future<void> persistActiveOutingSnapshot() async {
    if (!mounted || !state.isRecording || state.activeOutingId == null) return;
    final gen = ++_snapshotGeneration;
    final durationSecs = _computeCurrentDurationSeconds();
    final outing = state.toForagingOuting(overrideDurationSeconds: durationSecs);
    if (outing == null) return;

    final snapshotMap = state.toMap()
      ..['elapsedSeconds'] = durationSecs
      ..['accumulatedPausedSeconds'] = _accumulatedPausedSeconds
      ..['lastPauseTime'] = _lastPauseTime?.toIso8601String();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (gen != _snapshotGeneration || !mounted || !state.isRecording) return;
      await prefs.setString(_activeStatePrefsKey, json.encode(snapshotMap));
      await _db.upsertOuting(outing);
      if (mounted) {
        await _onOutingPersisted?.call(outing);
      }
    } catch (_) {}
  }

  Future<void> _clearPersistedActiveOuting(int expectedGeneration) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (expectedGeneration == _snapshotGeneration) {
        await prefs.remove(_activeStatePrefsKey);
      }
    } catch (_) {}
  }

  Future<void> _persistFinishedAndClearSnapshot(
    ForagingOuting completed,
    int expectedGeneration,
  ) async {
    try {
      await _db.upsertOuting(completed);
      if (mounted) {
        await _onOutingPersisted?.call(completed);
      }
      await _clearPersistedActiveOuting(expectedGeneration);
    } catch (_) {}
  }

  Future<void> startOuting(
    String title, {
    LatLng? initialPoint,
    bool isManual = false,
  }) async {
    final now = DateTime.now();
    final id = 'outing_${now.millisecondsSinceEpoch}';
    final startPts =
        initialPoint != null && !isManual ? <LatLng>[initialPoint] : <LatLng>[];
    _lastPauseTime = null;
    _accumulatedPausedSeconds = 0;
    _allowNextPointJump = false;
    _lastRejectedJumpPoint = null;
    _ticksSinceLastSave = 0;

    state = ActiveOutingState(
      isRecording: true,
      isPaused: false,
      activeOutingId: id,
      title: title.trim().isEmpty ? 'Salida al monte' : title.trim(),
      startedAt: now,
      sessionStartedAt: null,
      baseDurationSeconds: 0,
      elapsedSeconds: 0,
      distanceMeters: 0.0,
      routePoints: startPts,
      initialCenterPoint: initialPoint,
      isManual: isManual,
    );

    _startTimer();
    await persistActiveOutingSnapshot();
    if (!isManual) {
      await _startGpsStream();
    } else if (initialPoint == null) {
      unawaited(_resolveInitialManualCenter(id));
    }
  }

  /// Reactiva una salida ya finalizada conservando su ID, setas previas, ruta y tiempo acumulado.
  Future<void> resumeOuting(
    ForagingOuting outing, {
    LatLng? initialPoint,
    bool? forceManual,
  }) async {
    if (state.isRecording && state.activeOutingId == outing.id) {
      _startTimer();
      if (!state.isManual) {
        await _startGpsStream();
      }
      return;
    }

    if (state.isRecording && state.activeOutingId != null) {
      final previous = finishOuting();
      if (previous != null) {
        try {
          await _db.upsertOuting(previous);
          if (mounted) {
            await _onOutingPersisted?.call(previous);
          }
        } catch (_) {}
      }
    }

    final effectiveManual = forceManual ?? outing.isManual;
    final pts = List<LatLng>.from(outing.routePoints);
    if (!effectiveManual && initialPoint != null && pts.isEmpty) {
      pts.add(initialPoint);
    }

    _lastPauseTime = null;
    _accumulatedPausedSeconds = 0;
    _allowNextPointJump = true;
    _lastRejectedJumpPoint = null;
    _ticksSinceLastSave = 0;

    state = ActiveOutingState(
      isRecording: true,
      isPaused: false,
      activeOutingId: outing.id,
      title: outing.title,
      startedAt: outing.startedAt,
      sessionStartedAt: DateTime.now(),
      baseDurationSeconds: outing.durationSeconds,
      elapsedSeconds: outing.durationSeconds,
      distanceMeters: outing.distanceMeters,
      routePoints: pts,
      initialCenterPoint:
          initialPoint ?? (pts.isNotEmpty ? pts.last : null),
      notes: outing.notes,
      isManual: effectiveManual,
    );

    _startTimer();
    await persistActiveOutingSnapshot();
    if (!effectiveManual) {
      await _startGpsStream();
    } else if (state.initialCenterPoint == null) {
      unawaited(_resolveInitialManualCenter(outing.id));
    }
  }

  Future<void> _resolveInitialManualCenter(String outingId) async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      final perm = await Geolocator.checkPermission();
      if (perm != LocationPermission.whileInUse &&
          perm != LocationPermission.always) {
        return;
      }
      Position? pos;
      try {
        pos = await Geolocator.getLastKnownPosition();
      } catch (_) {}
      pos ??= await Geolocator.getCurrentPosition();
      if (mounted &&
          state.isRecording &&
          state.activeOutingId == outingId &&
          state.initialCenterPoint == null) {
        state = state.copyWith(
          initialCenterPoint: LatLng(pos.latitude, pos.longitude),
        );
      }
    } catch (_) {}
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
        final computedSecs = _computeCurrentDurationSeconds();
        state = state.copyWith(
          elapsedSeconds: computedSecs > 0 ? computedSecs : 0,
        );
        _ticksSinceLastSave++;
        if (_ticksSinceLastSave >= _autoSaveIntervalSeconds) {
          _ticksSinceLastSave = 0;
          unawaited(persistActiveOutingSnapshot());
        }
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
      if (!mounted || !state.isRecording || state.isManual) return;

      if (state.routePoints.isEmpty) {
        final activeId = state.activeOutingId;
        unawaited(() async {
          try {
            Position? seedPos;
            try {
              seedPos = await Geolocator.getLastKnownPosition();
            } catch (_) {}
            seedPos ??= await Geolocator.getCurrentPosition();
            if (mounted &&
                state.isRecording &&
                state.activeOutingId == activeId &&
                state.routePoints.isEmpty) {
              addRoutePoint(LatLng(seedPos.latitude, seedPos.longitude));
            }
          } catch (_) {}
        }());
      }

      _positionSub = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (pos) {
          if (mounted && state.isRecording && !state.isPaused) {
            // Descartar lecturas ruidosas con margen de error excesivo (> 35 m en monte),
            // salvo si aún no existe ningún punto inicial en la ruta.
            if (pos.accuracy > 35.0 && state.routePoints.isNotEmpty) return;
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
      if (addedMeters > 400.0) {
        final confirmedRealMove = _allowNextPointJump ||
            (_lastRejectedJumpPoint != null &&
                _distanceCalc.as(
                      LengthUnit.Meter,
                      _lastRejectedJumpPoint!,
                      newPoint,
                    ) <=
                    100.0);
        if (!confirmedRealMove) {
          // Descarta un único salto anómalo puntual, pero recuerda el punto por si el siguiente lo confirma.
          _lastRejectedJumpPoint = newPoint;
          return;
        }
        // Evitar inflar los km de senderismo ante traslados largos en coche o reanudaciones lejanas.
        if (addedMeters > 2000.0) {
          addedMeters = 0.0;
        }
      }
    }
    _allowNextPointJump = false;
    _lastRejectedJumpPoint = null;
    pts.add(newPoint);
    state = state.copyWith(
      routePoints: pts,
      distanceMeters: state.distanceMeters + addedMeters,
    );
    unawaited(persistActiveOutingSnapshot());
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
      _allowNextPointJump = true;
      _lastRejectedJumpPoint = null;
    }
    state = state.copyWith(isPaused: willPause);
    unawaited(persistActiveOutingSnapshot());
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
    unawaited(persistActiveOutingSnapshot());
  }

  ForagingOuting? finishOuting() {
    if (!state.isRecording || state.activeOutingId == null) return null;
    _timer?.cancel();
    _positionSub?.cancel();

    final finalDuration = _computeCurrentDurationSeconds();

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
    _allowNextPointJump = false;
    _lastRejectedJumpPoint = null;
    _ticksSinceLastSave = 0;
    final gen = ++_snapshotGeneration;
    state = const ActiveOutingState();
    unawaited(_persistFinishedAndClearSnapshot(completed, gen));
    return completed;
  }

  void cancelOuting() {
    _timer?.cancel();
    _positionSub?.cancel();
    _lastPauseTime = null;
    _accumulatedPausedSeconds = 0;
    _allowNextPointJump = false;
    _lastRejectedJumpPoint = null;
    _ticksSinceLastSave = 0;
    final gen = ++_snapshotGeneration;
    state = const ActiveOutingState();
    unawaited(_clearPersistedActiveOuting(gen));
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
  final db = ref.watch(outingsDatabaseProvider);
  final outingsNotifier = ref.read(outingsProvider.notifier);
  return ActiveOutingRecorder(
    db: db,
    onOutingPersisted: (_) async {
      if (outingsNotifier.mounted) {
        await outingsNotifier.loadOutings();
      }
    },
  );
});
