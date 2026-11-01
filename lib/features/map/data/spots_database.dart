import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import '../models/foraging_spot.dart';

class SpotsDatabase {
  static const String _tableName = 'foraging_spots';
  static const String _prefsFallbackKey = 'perretxikotan_spots_json';
  static const String _seededKey = 'perretxikotan_spots_seeded';

  Database? _db;

  Future<Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null) return _db;
    try {
      final dbDir = await getDatabasesPath();
      final fullPath = p.join(dbDir, 'perretxikotan_spots.db');
      _db = await openDatabase(
        fullPath,
        version: 1,
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
              photoPath TEXT
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
        title: 'Hayedo de Otzarreta (Gorbeia)',
        latitude: 43.0358,
        longitude: -2.7289,
        mushroomId: 'boletus_aereus',
        mushroomName: 'Onddo beltza / Hongo negro (Boletus aereus)',
        notes:
            'Zona húmeda junto al arroyo de Zubizabala entre hayas trasnoches. Salieron 4 ejemplares sanos en la ladera orientada al sur tras tres días de lluvia templada.',
        foundAt: DateTime(2026, 10, 18),
      ),
      ForagingSpot(
        id: 'sample_urbasa_baquedano',
        title: 'Robledal y Hayedo de Urbasa',
        latitude: 42.8331,
        longitude: -2.1164,
        mushroomId: 'cantharellus_cibarius',
        mushroomName: 'Ziza horia / Rebozuelo (Cantharellus cibarius)',
        notes:
            'Corro abundante entre el musgo húmedo en una vaguada sombría. Buscar también lengua de gato (Tripaki argia) unos 30 metros más arriba.',
        foundAt: DateTime(2026, 10, 24),
      ),
      ForagingSpot(
        id: 'sample_aralar_lizarrusti',
        title: 'Claros de Lizarrusti (Aralar)',
        latitude: 42.9635,
        longitude: -2.0992,
        mushroomId: 'calocybe_gambosa',
        mushroomName: 'Udaberriko ziza / Perretxiko (Calocybe gambosa)',
        notes:
            'Pradera montana junto a espinos albares (elorri zuri). El corro marca una medialuna más verde en la hierba cada mes de mayo.',
        foundAt: DateTime(2026, 5, 12),
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

    // Fallback en SharedPreferences (para tests o plataformas sin sqflite nativo)
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

  Future<void> restoreSpots(List<ForagingSpot> spots) async {
    await _db.replaceAllSpots(spots);
    await loadSpots();
  }
}

final foragingSpotsProvider =
    StateNotifierProvider<ForagingSpotsNotifier, AsyncValue<List<ForagingSpot>>>(
        (ref) {
  final db = ref.watch(spotsDatabaseProvider);
  return ForagingSpotsNotifier(db);
});
