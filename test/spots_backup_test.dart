import 'package:flutter_test/flutter_test.dart';
import 'package:perretxikotan/features/backup/services/google_drive_backup_service.dart';
import 'package:perretxikotan/features/map/models/foraging_spot.dart';

void main() {
  group('Empaquetado y Restauración de Backup de Setales (ZIP)', () {
    test('Empaqueta ubicaciones y notas descriptivas en ZIP y las restaura íntegramente', () async {
      final originalSpots = [
        ForagingSpot(
          id: 'spot_1',
          title: 'Hayedo de Altube - Vaguada norte',
          latitude: 43.0012,
          longitude: -2.8645,
          mushroomId: 'boletus_edulis',
          mushroomName: 'Udazkeneko onddo zuri / Hongo blanco',
          notes: 'Debajo de tres hayas grandes junto al muro de piedra.',
          foundAt: DateTime(2026, 10, 15, 10, 30),
        ),
        ForagingSpot(
          id: 'spot_2',
          title: 'Pinar de Izki',
          latitude: 42.6921,
          longitude: -2.4730,
          mushroomId: 'lactarius_deliciosus',
          mushroomName: 'Esnegorria / Níscalo',
          notes: 'Muchos ejemplares jóvenes entre brezos y musgo húmedo.',
          foundAt: DateTime(2026, 10, 29, 9, 15),
        ),
      ];

      final zipBytes =
          GoogleDriveBackupService.createBackupArchiveBytes(originalSpots);
      expect(zipBytes, isNotEmpty);

      final restoredSpots =
          await GoogleDriveBackupService.extractSpotsFromBackupBytes(zipBytes);

      expect(restoredSpots.length, equals(2));
      expect(restoredSpots[0].id, equals('spot_1'));
      expect(restoredSpots[0].title, equals('Hayedo de Altube - Vaguada norte'));
      expect(restoredSpots[0].mushroomId, equals('boletus_edulis'));
      expect(
        restoredSpots[0].notes,
        equals('Debajo de tres hayas grandes junto al muro de piedra.'),
      );
      expect(restoredSpots[1].id, equals('spot_2'));
      expect(restoredSpots[1].mushroomId, equals('lactarius_deliciosus'));
    });
  });
}
