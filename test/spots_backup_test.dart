import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zizai/features/ai_identifier/models/chat_message.dart';
import 'package:zizai/features/backup/services/google_drive_backup_service.dart';
import 'package:zizai/features/catalog/models/mushroom.dart';
import 'package:zizai/features/map/data/spots_database.dart';
import 'package:zizai/features/map/models/foraging_spot.dart';
import 'package:zizai/features/map/models/forest_zone.dart';
import 'package:zizai/features/map/models/tree_species.dart';
import 'package:zizai/features/map/services/offline_map_service.dart';
import 'package:zizai/features/outings/models/foraging_outing.dart';

void main() {
  group('ZizAI Models & Full Activity ZIP Backup Tests', () {
    test('ForagingSpot serializes outing linkage, quantity and weight', () {
      final original = ForagingSpot(
        id: 'spot_gorbeia_01',
        title: 'Hayedo de Altube',
        latitude: 43.0125,
        longitude: -2.8451,
        mushroomId: 'boletus_edulis',
        mushroomName: 'Hongo calabaza • Onddo zuria',
        notes: 'Tres ejemplares sanos junto al arroyo bajo hojarasca húmeda.',
        foundAt: DateTime.utc(2026, 10, 18, 9, 30),
        outingId: 'outing_001',
        outingTitle: 'Vuelta circular por Altube',
        quantityCount: 3,
        weightGrams: 480,
        treeType: 'beech',
      );

      final jsonMap = original.toJson();
      final restored = ForagingSpot.fromJson(jsonMap);

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.latitude, closeTo(43.0125, 0.00001));
      expect(restored.longitude, closeTo(-2.8451, 0.00001));
      expect(restored.mushroomId, 'boletus_edulis');
      expect(restored.outingId, 'outing_001');
      expect(restored.outingTitle, 'Vuelta circular por Altube');
      expect(restored.quantityCount, 3);
      expect(restored.weightGrams, 480);
      expect(restored.treeType, 'beech');
      expect(restored.isFromOuting, isTrue);

      // Legacy map without treeType parses cleanly as null
      final legacyMap = Map<String, dynamic>.from(jsonMap)..remove('treeType');
      final legacySpot = ForagingSpot.fromJson(legacyMap);
      expect(legacySpot.treeType, isNull);
    });

    test('createBackupArchiveBytes and extractFullActivityBackupBytes preserve all activity', () async {
      final spots = <ForagingSpot>[
        ForagingSpot(
          id: 'spot_1',
          title: 'Robledal de Urbasa',
          latitude: 42.8510,
          longitude: -2.1620,
          mushroomId: 'boletus_aereus',
          mushroomName: 'Hongo negro • Onddo beltza',
          notes: 'Ejemplares firmes tras lluvias de otoño.',
          foundAt: DateTime.utc(2026, 10, 15, 10, 0),
          outingId: 'out_urbasa_1',
          outingTitle: 'Salida por Urbasa Norte',
          quantityCount: 4,
          weightGrams: 650,
        ),
      ];

      final outings = <ForagingOuting>[
        ForagingOuting(
          id: 'out_urbasa_1',
          title: 'Salida por Urbasa Norte',
          notes: 'Mañana fresca con niebla baja.',
          startedAt: DateTime.utc(2026, 10, 15, 8, 0),
          endedAt: DateTime.utc(2026, 10, 15, 11, 30),
          durationSeconds: 12600,
          distanceMeters: 6420,
          routePoints: const <LatLng>[
            LatLng(42.8500, -2.1600),
            LatLng(42.8510, -2.1620),
            LatLng(42.8535, -2.1650),
          ],
        ),
      ];

      final favorites = <String>['boletus_aereus', 'cantharellus_cibarius'];

      final aiMessages = <AiChatMessage>[
        AiChatMessage(
          id: 'msg_1',
          isUser: true,
          text: '¿Cómo diferencio Amanita caesarea de Amanita muscaria?',
          createdAt: DateTime.utc(2026, 10, 15, 12, 0),
          isPendingSync: false,
        ),
      ];

      final offlineRegions = <OfflineMapRegion>[
        OfflineMapRegion(
          id: 'region_gorbeia',
          name: 'Parque Natural del Gorbeia',
          description: 'Hayedos de Otzarreta y Altube',
          north: 43.09,
          south: 42.98,
          east: -2.72,
          west: -2.90,
          minZoom: 11,
          maxZoom: 14,
          isTopoLayer: true,
          tilesCount: 145,
          sizeBytes: 3100000,
          downloadedAt: DateTime.utc(2026, 10, 14, 18, 0),
        ),
      ];

      final forestZones = <ForestZone>[
        ForestZone(
          id: 'zone_urbasa_oak',
          name: 'Robledal de Urbasa',
          treeType: TreeSpecies.oak.id,
          points: const <LatLng>[
            LatLng(42.848, -2.168),
            LatLng(42.856, -2.168),
            LatLng(42.856, -2.156),
            LatLng(42.848, -2.156),
          ],
          notes: 'Zona húmeda orientada al norte',
          createdAt: DateTime.utc(2026, 10, 14, 19, 0),
        ),
      ];

      final zipBytes = await GoogleDriveBackupService.createBackupArchiveBytes(
        spots,
        outings: outings,
        favoriteIds: favorites,
        aiMessages: aiMessages,
        offlineRegions: offlineRegions,
        forestZones: forestZones,
      );
      expect(zipBytes, isNotEmpty);

      final payload =
          await GoogleDriveBackupService.extractFullActivityBackupBytes(
        zipBytes,
        customPhotosParentDir: Directory.systemTemp,
      );

      expect(payload.spots.length, 1);
      expect(payload.spots.first.title, 'Robledal de Urbasa');
      expect(payload.spots.first.outingId, 'out_urbasa_1');
      expect(payload.spots.first.quantityCount, 4);
      expect(payload.outings.length, 1);
      expect(payload.outings.first.routePoints.length, 3);
      expect(payload.favoriteIds, contains('boletus_aereus'));
      expect(payload.aiMessages.length, 1);
      expect(payload.offlineRegions.length, 1);
      expect(payload.offlineRegions.first.name, 'Parque Natural del Gorbeia');
      expect(payload.forestZones.length, 1);
      expect(payload.forestZones.first.name, 'Robledal de Urbasa');
      expect(payload.forestZones.first.treeType, 'oak');
      expect(payload.forestZones.first.points.length, 4);
    });

    test('Mushroom model parses trilingual fields and confusions', () {
      final sampleJson = {
        'id': 'lactarius_deliciosus',
        'commonNameEs': 'Níscalo',
        'nameEu': 'Esnegorri',
        'scientificName': 'Lactarius deliciosus',
        'family': 'Russulaceae',
        'edibility': 'good',
        'edibilityDetail': 'Buen comestible muy apreciado a la plancha.',
        'capDescription': 'Convexo a embudado con bandas concéntricas anaranjadas.',
        'hymeniumDescription': 'Láminas anaranjadas que verdean al roce.',
        'stipeDescription': 'Cilíndrico, hueco con hoyuelos (escrobículos).',
        'fleshDescription': 'Compacta con látex color zanahoria.',
        'habitat': 'Pinares de repoblación y autóctonos.',
        'season': 'Otoño',
        'frequency': 'Muy frecuente',
        'images': ['assets/images/mushrooms/lactarius_deliciosus_1.jpg'],
        'confusions': [
          {
            'targetId': 'lactarius_torminosus',
            'speciesName': 'Falso níscalo (Lactarius torminosus)',
            'edibilityWarning': 'Tóxica gastrointestinal',
            'differences': 'Margen barbado lanoso y látex blanco picante.'
          }
        ]
      };

      final mushroom = Mushroom.fromJson(sampleJson);
      expect(mushroom.commonNameEs, 'Níscalo');
      expect(mushroom.nameEu, 'Esnegorri');
      expect(mushroom.edibility, EdibilityLevel.good);
      expect(mushroom.confusions.first.targetId, 'lactarius_torminosus');
    });

    test('ForagingOuting supports isManual mode without GPS and formats label correctly', () {
      final manualOuting = ForagingOuting(
        id: 'outing_manual_01',
        title: 'Paseo micológico por Pagoeta',
        startedAt: DateTime.utc(2026, 10, 20, 10, 0),
        endedAt: DateTime.utc(2026, 10, 20, 12, 30),
        durationSeconds: 9000,
        distanceMeters: 0.0,
        routePoints: const [],
        notes: 'Salida manual sin GPS.',
        isManual: true,
      );

      expect(manualOuting.isManual, isTrue);
      expect(manualOuting.formattedDistanceKm, 'Manual (Sin GPS)');
      expect(manualOuting.formattedDuration, '2h 30m');

      final map = manualOuting.toMap();
      expect(map['isManual'], 1);

      final restored = ForagingOuting.fromMap(map);
      expect(restored.isManual, isTrue);
      expect(restored.title, 'Paseo micológico por Pagoeta');
    });

    test('ForestZone containsPoint and findContainingZone prioritize smallest nested polygon', () {
      final largeOak = ForestZone(
        id: 'large_oak',
        name: 'Gran Robledal',
        treeType: TreeSpecies.oak.id,
        points: const [
          LatLng(43.00, -2.85),
          LatLng(43.06, -2.85),
          LatLng(43.06, -2.75),
          LatLng(43.00, -2.75),
        ],
        notes: '',
        createdAt: DateTime.utc(2026, 10, 10),
      );
      final nestedBeech = ForestZone(
        id: 'nested_beech',
        name: 'Rodales de Haya',
        treeType: TreeSpecies.beech.id,
        points: const [
          LatLng(43.02, -2.82),
          LatLng(43.04, -2.82),
          LatLng(43.04, -2.78),
          LatLng(43.02, -2.78),
        ],
        notes: '',
        createdAt: DateTime.utc(2026, 10, 11),
      );

      expect(nestedBeech.approximateArea < largeOak.approximateArea, isTrue);
      expect(largeOak.containsPoint(const LatLng(43.03, -2.80)), isTrue);
      expect(nestedBeech.containsPoint(const LatLng(43.03, -2.80)), isTrue);
      expect(nestedBeech.containsPoint(const LatLng(43.01, -2.84)), isFalse);

      // Inside both: must pick smallest polygon regardless of list order
      final detected1 = ForestZone.findContainingZone(
        const LatLng(43.03, -2.80),
        [largeOak, nestedBeech],
      );
      final detected2 = ForestZone.findContainingZone(
        const LatLng(43.03, -2.80),
        [nestedBeech, largeOak],
      );
      expect(detected1?.id, 'nested_beech');
      expect(detected2?.id, 'nested_beech');

      // Inside only outer zone
      final outerOnly = ForestZone.findContainingZone(
        const LatLng(43.01, -2.84),
        [largeOak, nestedBeech],
      );
      expect(outerOnly?.id, 'large_oak');

      // Outside all zones
      final outside = ForestZone.findContainingZone(
        const LatLng(42.90, -2.50),
        [largeOak, nestedBeech],
      );
      expect(outside, isNull);
    });

    test('SpotsDatabase.assignTreeTypesFromForestZones updates unassigned spots without overwriting manual ones', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final spotsDb = SpotsDatabase();

      final beechZone = ForestZone(
        id: 'zone_gorbeia_beech',
        name: 'Hayedo de Otzarreta',
        treeType: TreeSpecies.beech.id,
        points: const [
          LatLng(43.02, -2.82),
          LatLng(43.05, -2.82),
          LatLng(43.05, -2.78),
          LatLng(43.02, -2.78),
        ],
        notes: '',
        createdAt: DateTime.utc(2026, 10, 12),
      );

      await spotsDb.upsertSpot(
        ForagingSpot(
          id: 'spot_legacy_inside',
          title: 'Setal antiguo',
          latitude: 43.035,
          longitude: -2.800,
          notes: '',
          foundAt: DateTime.utc(2025, 10, 1),
          treeType: null,
        ),
      );
      await spotsDb.upsertSpot(
        ForagingSpot(
          id: 'spot_manual_inside',
          title: 'Setal bajo pino aislado',
          latitude: 43.036,
          longitude: -2.801,
          notes: '',
          foundAt: DateTime.utc(2025, 10, 2),
          treeType: TreeSpecies.pine.id,
        ),
      );
      await spotsDb.upsertSpot(
        ForagingSpot(
          id: 'spot_outside',
          title: 'Setal exterior',
          latitude: 42.900,
          longitude: -2.600,
          notes: '',
          foundAt: DateTime.utc(2025, 10, 3),
          treeType: null,
        ),
      );

      final updatedCount = await spotsDb.assignTreeTypesFromForestZones([beechZone]);
      expect(updatedCount, 1);

      final allSpots = await spotsDb.getAllSpots();
      final byId = {for (final s in allSpots) s.id: s};
      expect(byId['spot_legacy_inside']?.treeType, TreeSpecies.beech.id);
      expect(byId['spot_manual_inside']?.treeType, TreeSpecies.pine.id);
      expect(byId['spot_outside']?.treeType, isNull);
    });

    test('ForestZone.orderContourPoints removes crossings and near-duplicate taps', () {
      // Zigzag "bowtie" order: NW -> SE -> NE -> near-duplicate NE -> SW -> W
      final rawZigzag = const [
        LatLng(43.10, -2.60), // NW (anchor)
        LatLng(43.00, -2.50), // SE (crosses center)
        LatLng(43.10, -2.50), // NE (crosses center)
        LatLng(43.1000001, -2.5000001), // Near-duplicate NE (< 1e-6)
        LatLng(43.00, -2.60), // SW
        LatLng(43.05, -2.63), // West mid-point
      ];

      final ordered = ForestZone.orderContourPoints(rawZigzag);
      expect(ordered.length, 5);
      // Anchor point stays at index 0
      expect(ordered.first.latitude, closeTo(43.10, 1e-9));
      expect(ordered.first.longitude, closeTo(-2.60, 1e-9));

      // Verify no non-adjacent edges intersect in the resulting contour
      bool hasCrossing = false;
      bool ccw(LatLng a, LatLng b, LatLng c) =>
          ((c.latitude - a.latitude) * (b.longitude - a.longitude) -
              (b.latitude - a.latitude) * (c.longitude - a.longitude)) >
          0;
      for (int i = 0; i < ordered.length; i++) {
        final a = ordered[i];
        final b = ordered[(i + 1) % ordered.length];
        for (int j = i + 2; j < ordered.length; j++) {
          if (i == 0 && j == ordered.length - 1) continue;
          final c = ordered[j];
          final d = ordered[(j + 1) % ordered.length];
          final cross = (ccw(a, c, d) != ccw(b, c, d)) &&
              (ccw(a, b, c) != ccw(a, b, d));
          if (cross) hasCrossing = true;
        }
      }
      expect(hasCrossing, isFalse);

      final zone = ForestZone(
        id: 'ordered_zone',
        name: 'Ordered Zone',
        treeType: TreeSpecies.oak.id,
        points: ordered,
        notes: '',
        createdAt: DateTime(2026, 11, 15),
      );
      expect(zone.containsPoint(const LatLng(43.05, -2.55)), isTrue);
      expect(zone.approximateArea, greaterThan(1000000));
    });
  });
}
