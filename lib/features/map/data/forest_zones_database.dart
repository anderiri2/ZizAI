import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/forest_zone.dart';

/// Persistence layer for user-drawn [ForestZone] polygons.
/// Uses SQLite on mobile/desktop and falls back cleanly to SharedPreferences on
/// web or headless unit-test environments without `sqflite` FFI.
class ForestZonesDatabase {
  static const _dbName = 'zizai_forest_zones_v1.db';
  static const _tableName = 'forest_zones';
  static const _fallbackPrefsKey = 'zizai_forest_zones_json_v1';

  Database? _db;

  Future<Database?> _getDatabase() async {
    if (kIsWeb) return null;
    if (_db != null && _db!.isOpen) return _db;
    try {
      final databasesPath = await getDatabasesPath();
      final fullPath = path.join(databasesPath, _dbName);
      _db = await openDatabase(
        fullPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              treeType TEXT NOT NULL,
              pointsJson TEXT NOT NULL,
              notes TEXT NOT NULL,
              createdAt TEXT NOT NULL
            )
          ''');
        },
      );
      return _db;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _zoneToRow(ForestZone zone) {
    final map = zone.toMap();
    return {
      'id': zone.id,
      'name': zone.name,
      'treeType': zone.treeType,
      'pointsJson': jsonEncode(map['points']),
      'notes': zone.notes,
      'createdAt': zone.createdAt.toIso8601String(),
    };
  }

  Future<List<ForestZone>> _loadFallbackList() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_fallbackPrefsKey);
    if (raw == null || raw.trim().isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final zones = decoded
          .map((item) => ForestZone.fromMap(Map<String, dynamic>.from(item)))
          .toList();
      zones.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return zones;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveFallbackList(List<ForestZone> zones) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(zones.map((z) => z.toMap()).toList());
    await prefs.setString(_fallbackPrefsKey, encoded);
  }

  Future<List<ForestZone>> getAllZones() async {
    final db = await _getDatabase();
    if (db == null) {
      return _loadFallbackList();
    }
    final rows = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );
    return rows.map((row) => ForestZone.fromMap(row)).toList();
  }

  Future<void> insertZone(ForestZone zone) async {
    final db = await _getDatabase();
    if (db == null) {
      final zones = await _loadFallbackList();
      final idx = zones.indexWhere((z) => z.id == zone.id);
      if (idx >= 0) {
        zones[idx] = zone;
      } else {
        zones.add(zone);
      }
      await _saveFallbackList(zones);
      return;
    }
    await db.insert(
      _tableName,
      _zoneToRow(zone),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateZone(ForestZone zone) async {
    await insertZone(zone);
  }

  Future<void> deleteZone(String id) async {
    final db = await _getDatabase();
    if (db == null) {
      final zones = await _loadFallbackList();
      zones.removeWhere((z) => z.id == id);
      await _saveFallbackList(zones);
      return;
    }
    await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> restoreZones(
    List<ForestZone> zones, {
    bool merge = true,
  }) async {
    final db = await _getDatabase();
    if (db == null) {
      if (!merge) {
        await _saveFallbackList(zones);
        return;
      }
      final existing = await _loadFallbackList();
      final byId = <String, ForestZone>{
        for (final z in existing) z.id: z,
      };
      for (final z in zones) {
        byId[z.id] = z;
      }
      await _saveFallbackList(byId.values.toList());
      return;
    }

    await db.transaction((txn) async {
      if (!merge) {
        await txn.delete(_tableName);
        for (final z in zones) {
          await txn.insert(
            _tableName,
            _zoneToRow(z),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        return;
      }

      for (final z in zones) {
        await txn.insert(
          _tableName,
          _zoneToRow(z),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}

final forestZonesDatabaseProvider = Provider<ForestZonesDatabase>((ref) {
  return ForestZonesDatabase();
});

class ForestZonesNotifier extends StateNotifier<AsyncValue<List<ForestZone>>> {
  final ForestZonesDatabase _db;

  ForestZonesNotifier(this._db) : super(const AsyncValue.loading()) {
    loadZones();
  }

  Future<void> loadZones() async {
    try {
      final zones = await _db.getAllZones();
      state = AsyncValue.data(zones);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addZone(ForestZone zone) async {
    await _db.insertZone(zone);
    await loadZones();
  }

  Future<void> updateZone(ForestZone zone) async {
    await _db.updateZone(zone);
    await loadZones();
  }

  Future<void> deleteZone(String id) async {
    await _db.deleteZone(id);
    await loadZones();
  }

  Future<void> mergeZones(List<ForestZone> zones) async {
    await _db.restoreZones(zones, merge: true);
    await loadZones();
  }

  Future<void> replaceAllZones(List<ForestZone> zones) async {
    await _db.restoreZones(zones, merge: false);
    await loadZones();
  }
}

final forestZonesProvider =
    StateNotifierProvider<ForestZonesNotifier, AsyncValue<List<ForestZone>>>(
  (ref) {
    final db = ref.watch(forestZonesDatabaseProvider);
    return ForestZonesNotifier(db);
  },
);
