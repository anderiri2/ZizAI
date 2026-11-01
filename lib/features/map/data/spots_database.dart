import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/foraging_spot.dart';

class SpotsDatabase {
  static const String _tableName = 'foraging_spots';
  static const String _prefsFallbackKey = 'perretxikotan_spots_json_v2';
  static const String _seededKey = 'perretxikotan_spots_seeded_v2';

  Database? _db;

  Future<Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null) return _db;
    try {
      final dbDir = await getDatabasesPath();
      final fullPath = p.join(dbDir, 'perretxikotan_spots_v2.db');
      _db = await openDatabase(
        fullPath,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              latitude REAL NOT NULL,
              longitude REAL NOT NULL,
              mushroomId TEXT,
              mushroomName TEXT,
              notes TEXT NOT NULL,
              foundAt TEXT NOT NULL,
              photoPath TEXT,
              outingId TEXT,
              outingTitle TEXT,
              quantityCount INTEGER NOT NULL DEFAULT 1,
              weightGrams INTEGER
            )
          ''');
        },
      );
      return _db;
    } catch (_) {
      return null;
    }
  }

  List<ForagingSpot> _initialSampleSpots() {
    return [
      ForagingSpot(
        id: 'sample_gorbeia_otzarreta',
        title: 'Hayedo de Otzarreta - Regata Zubizabala',
        latitude: 43.0358,
        longitude: -2.7289,
        mushroomId: 'boletus_aereus',
        mushroomName: 'Onddo beltza / Hongo negro',
        notes:
            'Zona húmeda junto al arroyo entre hayas trasmochas. Salieron 4 ejemplares sanos en la ladera orientada al sur tras tres días de lluvia templada.',
        foundAt: DateTime(2026, 10, 18, 9, 40),
        outingId: 'outing_gorbeia_otzarreta',
        outingTitle: 'Vuelta circular por Otzarreta (Gorbeia)',
        quantityCount: 4,
        weightGrams: 720,
      ),
      ForagingSpot(
        id: 'sample_gorbeia_gibelurdina',
        title: 'Ladera alta de Otzarreta',
        latitude: 43.0392,
        longitude: -2.7341,
        mushroomId: 'russula_cyanoxantha',
        mushroomName: 'Urretxa / Gibelurdina / Carbonera',
        notes:
            'Entre la hojarasca de haya subiendo hacia el collado. Ejemplares muy firmes y limpios.',
        foundAt: DateTime(2026, 10, 18, 10, 55),
        outingId: 'outing_gorbeia_otzarreta',
        outingTitle: 'Vuelta circular por Otzarreta (Gorbeia)',
        quantityCount: 6,
        weightGrams: 480,
      ),
      ForagingSpot(
        id: 'sample_urbasa_baquedano',
        title: 'Vaguada sombría de Urbasa',
        latitude: 42.8331,
        longitude: -2.1164,
        mushroomId: 'cantharellus_cibarius',
        mushroomName: 'Ziza horia / Rebozuelo',
        notes:
            'Corro abundante entre el musgo húmedo en una vaguada sombría. Buscar también lengua de gato (Tripaki argia) unos 30 metros más arriba.',
        foundAt: DateTime(2026, 10, 24, 10, 15),
        outingId: 'outing_urbasa_hayedo',
        outingTitle: 'Ruta micológica por Urbasa',
        quantityCount: 14,
        weightGrams: 390,
      ),
      ForagingSpot(
        id: 'sample_urbasa_tripaki',
        title: 'Hayedo kárstico de Urbasa',
        latitude: 42.8364,
        longitude: -2.1215,
        mushroomId: 'hydnum_repandum',
        mushroomName: 'Tripaki argia / Lengua de gato',
        notes:
            'Hilera larga junto a las rocas calizas cubiertas de musgo.',
        foundAt: DateTime(2026, 10, 24, 11, 30),
        outingId: 'outing_urbasa_hayedo',
        outingTitle: 'Ruta micológica por Urbasa',
        quantityCount: 9,
        weightGrams: 410,
      ),
      ForagingSpot(
        id: 'sample_aralar_lizarrusti',
        title: 'Claros de Lizarrusti (Aralar)',
        latitude: 42.9635,
        longitude: -2.0992,
        mushroomId: 'calocybe_gambosa',
        mushroomName: 'Udaberriko ziza / Perretxiko',
        notes:
            'Punto suelto registrado en el Mapa Global: pradera montana junto a espinos albares (elorri zuri). El corro marca una medialuna más verde cada mes de mayo.',
        foundAt: DateTime(2026, 5, 12, 9, 0),
        quantityCount: 11,
        weightGrams: 540,
      ),
    ];
  }

  Future<List<ForagingSpot>> getAllSpots() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadySeeded = prefs.getBool(_seededKey) ?? false;

    final db = await _getDatabase();
    if (db != null) {
      final rows = await db.query(_tableName, orderBy: 'foundAt DESC');
      if (rows.isEmpty && !alreadySeeded) {
        final samples = _initialSampleSpots();
        for (final s in samples) {
          await db.insert(
            _tableName,
            s.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await prefs.setBool(_seededKey, true);
        return samples;
      }
      return rows.map((r) => ForagingSpot.fromMap(r)).toList();
    }

    final raw = prefs.getString(_prefsFallbackKey);
    if (raw == null && !alreadySeeded) {
      final samples = _initialSampleSpots();
      await _saveFallbackList(prefs, samples);
      await prefs.setBool(_seededKey, true);
      return samples;
    }
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw) as List<dynamic>;
    final list = decoded
        .map((e) => ForagingSpot.fromMap(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => b.foundAt.compareTo(a.foundAt));
    return list;
  }

  Future<void> upsertSpot(ForagingSpot spot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);

    final db = await _getDatabase();
    if (db != null) {
      await db.insert(
        _tableName,
        spot.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return;
    }

    final current = await getAllSpots();
    final idx = current.indexWhere((s) => s.id == spot.id);
    if (idx >= 0) {
      current[idx] = spot;
    } else {
      current.insert(0, spot);
    }
    await _saveFallbackList(prefs, current);
  }

  Future<void> deleteSpot(String id) async {
    final db = await _getDatabase();
    if (db != null) {
      await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final current = await getAllSpots();
    current.removeWhere((s) => s.id == id);
    await _saveFallbackList(prefs, current);
  }

  /// Desvincula los puntos de una salida para que se conserven como puntos sueltos en el Mapa Global.
  Future<void> detachSpotsFromOuting(String outingId) async {
    final current = await getAllSpots();
    final updated = current.map((s) {
      if (s.outingId == outingId) {
        return s.copyWith(clearOuting: true);
      }
      return s;
    }).toList();
    await replaceAllSpots(updated);
  }

  /// Elimina todos los puntos asociados a una salida concreta.
  Future<void> deleteSpotsByOuting(String outingId) async {
    final db = await _getDatabase();
    if (db != null) {
      await db.delete(
        _tableName,
        where: 'outingId = ?',
        whereArgs: [outingId],
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final current = await getAllSpots();
    current.removeWhere((s) => s.outingId == outingId);
    await _saveFallbackList(prefs, current);
  }

  Future<void> replaceAllSpots(List<ForagingSpot> spots) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_seededKey, true);

    final db = await _getDatabase();
    if (db != null) {
      await db.transaction((txn) async {
        await txn.delete(_tableName);
        for (final s in spots) {
          await txn.insert(
            _tableName,
            s.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return;
    }

    await _saveFallbackList(prefs, spots);
  }

  /// Fusión inteligente por ID (combina los puntos locales con los recibidos sin perder ninguno).
  Future<void> mergeSpots(List<ForagingSpot> incomingSpots) async {
    final existing = await getAllSpots();
    final byId = <String, ForagingSpot>{
      for (final s in existing) s.id: s,
    };
    for (final inc in incomingSpots) {
      byId[inc.id] = inc;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => b.foundAt.compareTo(a.foundAt));
    await replaceAllSpots(merged);
  }

  Future<void> _saveFallbackList(
    SharedPreferences prefs,
    List<ForagingSpot> spots,
  ) async {
    final encoded = json.encode(spots.map((s) => s.toMap()).toList());
    await prefs.setString(_prefsFallbackKey, encoded);
  }
}

final spotsDatabaseProvider = Provider<SpotsDatabase>((ref) {
  return SpotsDatabase();
});

class ForagingSpotsNotifier extends StateNotifier<AsyncValue<List<ForagingSpot>>> {
  final SpotsDatabase _db;

  ForagingSpotsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadSpots();
  }

  Future<void> loadSpots() async {
    try {
      final spots = await _db.getAllSpots();
      state = AsyncValue.data(spots);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveSpot(ForagingSpot spot) async {
    await _db.upsertSpot(spot);
    await loadSpots();
  }

  Future<void> removeSpot(String id) async {
    await _db.deleteSpot(id);
    await loadSpots();
  }

  Future<void> detachOutingSpots(String outingId) async {
    await _db.detachSpotsFromOuting(outingId);
    await loadSpots();
  }

  Future<void> deleteOutingSpots(String outingId) async {
    await _db.deleteSpotsByOuting(outingId);
    await loadSpots();
  }

  Future<void> restoreSpots(
    List<ForagingSpot> spots, {
    bool merge = true,
  }) async {
    if (merge) {
      await _db.mergeSpots(spots);
    } else {
      await _db.replaceAllSpots(spots);
    }
    await loadSpots();
  }

  Future<void> mergeSpots(List<ForagingSpot> spots) =>
      restoreSpots(spots, merge: true);

  Future<void> replaceAllSpots(List<ForagingSpot> spots) =>
      restoreSpots(spots, merge: false);
}

final foragingSpotsProvider =
    StateNotifierProvider<ForagingSpotsNotifier, AsyncValue<List<ForagingSpot>>>(
        (ref) {
  final db = ref.watch(spotsDatabaseProvider);
  return ForagingSpotsNotifier(db);
});
