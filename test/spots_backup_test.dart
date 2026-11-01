import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:perretxikotan/features/ai_identifier/models/chat_message.dart';
import 'package:perretxikotan/features/backup/services/google_drive_backup_service.dart';
import 'package:perretxikotan/features/catalog/models/mushroom.dart';
import 'package:perretxikotan/features/map/models/foraging_spot.dart';
import 'package:perretxikotan/features/map/services/offline_map_service.dart';
import 'package:perretxikotan/features/outings/models/foraging_outing.dart';

void main() {
  group('Perretxikotan Models & Full Activity ZIP Backup Tests', () {
    test('ForagingSpot serializes outing linkage, quantity and weight', () {
      final original = ForagingSpot(
        id: 'spot_gorbeia_01',
        title: 'Hayedo de Altube',
        latitude: 43.0125,
        longitude: -2.8451,
        mushroomId: 'boletus_edulis',
        mushroomName: 'Hongo calabaza • Onddo zuria',
        note: 'Tres ejemplares sanos junto al arroyo bajo hojarasca húmeda.',
        foundAt: DateTime.utc(2026, 10, 18, 9, 30),
        outingId: 'outing_001',
        outingTitle: 'Vuelta circular por Altube',
        quantityCount: 3,
        weightGrams: 480,
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
      expect(restored.isFromOuting, isTrue);
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
          note: 'Ejemplares firmes tras lluvias de otoño.',
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
          forestZone: 'Parque Natural de Urbasa y Andia',
          notes: 'Mañana fresca con niebla baja.',
          startedAt: DateTime.utc(2026, 10, 15, 8, 0),
          endedAt: DateTime.utc(2026, 10, 15, 11, 30),
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
          minLat: 42.98,
          maxLat: 43.09,
          minLon: -2.90,
          maxLon: -2.72,
          minZoom: 11,
          maxZoom: 14,
          isTopoLayer: true,
          tileCount: 145,
          sizeBytes: 3100000,
          downloadedAt: DateTime.utc(2026, 10, 14, 18, 0),
        ),
      ];

      final zipBytes = await GoogleDriveBackupService.createBackupArchiveBytes(
        spots,
        outings: outings,
        favoriteIds: favorites,
        aiMessages: aiMessages,
        offlineRegions: offlineRegions,
      );
      expect(zipBytes, isNotEmpty);

      final payload =
          await GoogleDriveBackupService.extractFullActivityBackupBytes(
        zipBytes,
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
  });
}
