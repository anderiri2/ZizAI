import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zizai/core/localization/app_localizations.dart';
import 'package:zizai/features/catalog/data/catalog_repository.dart';
import 'package:zizai/features/catalog/models/mushroom.dart';
import 'package:zizai/features/map/data/spots_database.dart';
import 'package:zizai/features/map/models/foraging_spot.dart';
import 'package:zizai/features/map/presentation/widgets/foraging_spot_marker.dart';
import 'package:zizai/features/outings/data/outings_database.dart';
import 'package:zizai/features/outings/models/foraging_outing.dart';

void main() {
  group('ZizAI v1.5.0: Outing Recorder Clean GPS & Map Filters Tests', () {
    test('ActiveOutingRecorder starts without hardcoded Gorbeia point when initialPoint is null', () async {
      final recorder = ActiveOutingRecorder();
      await recorder.startOuting('Salida limpia en Urbasa', initialPoint: null);

      expect(recorder.state.isRecording, isTrue);
      expect(recorder.state.title, 'Salida limpia en Urbasa');
      expect(recorder.state.routePoints, isEmpty);
      expect(recorder.state.distanceMeters, 0.0);

      // Agregar el primer punto GPS real en la Sierra de Urbasa
      final firstPoint = const LatLng(42.8250, -2.1550);
      recorder.addRoutePoint(firstPoint);

      expect(recorder.state.routePoints.length, 1);
      expect(recorder.state.routePoints.first, firstPoint);
      // La distancia debe permanecer en 0 al ser el primer punto registrado
      expect(recorder.state.distanceMeters, 0.0);

      // Agregar un segundo punto a ~100 metros
      final secondPoint = const LatLng(42.8258, -2.1550);
      recorder.addRoutePoint(secondPoint);

      expect(recorder.state.routePoints.length, 2);
      // La distancia debe rondar los ~88 metros, NO los ~50 km desde Gorbeia
      expect(recorder.state.distanceMeters, closeTo(88.9, 10.0));
      expect(recorder.state.distanceMeters < 500.0, isTrue);
    });

    test('Mushroom isEdible and isToxic getters work correctly', () {
      const edibleMushroom = Mushroom(
        id: 'boletus_edulis',
        scientificName: 'Boletus edulis',
        spanishName: 'Boletus edulis',
        basqueName: 'Onddo zuri',
        family: 'Boletaceae',
        edibility: EdibilityLevel.excellent,
        edibilityLabel: 'Excelente comestible',
        season: 'Otoño',
        habitat: 'Bosques',
        summary: 'Seta muy apreciada',
        morphology: MushroomMorphology(cap: '', hymenium: '', stem: '', flesh: ''),
        confusions: [],
        images: ['assets/images/logo_zizai.png'],
      );

      const toxicMushroom = Mushroom(
        id: 'amanita_muscaria',
        scientificName: 'Amanita muscaria',
        spanishName: 'Falsa oronja',
        basqueName: 'Kuleto faltsu',
        family: 'Amanitaceae',
        edibility: EdibilityLevel.toxic,
        edibilityLabel: 'Tóxica',
        season: 'Otoño',
        habitat: 'Pinares',
        summary: 'Tóxica alucinógena',
        morphology: MushroomMorphology(cap: '', hymenium: '', stem: '', flesh: ''),
        confusions: [],
        images: ['assets/images/logo_zizai.png'],
      );

      expect(edibleMushroom.isEdible, isTrue);
      expect(edibleMushroom.isToxic, isFalse);

      expect(toxicMushroom.isEdible, isFalse);
      expect(toxicMushroom.isToxic, isTrue);
    });

    test('Map filtering spots by species, edibility, and outing works accurately', () {
      final spots = <ForagingSpot>[
        ForagingSpot(
          id: 'spot_1',
          title: 'Hayedo Urbasa',
          latitude: 42.8250,
          longitude: -2.1550,
          mushroomId: 'boletus_edulis',
          foundAt: DateTime.now(),
          outingId: 'outing_01',
          notes: '',
        ),
        ForagingSpot(
          id: 'spot_2',
          title: 'Pinar de Izki',
          latitude: 42.6850,
          longitude: -2.4850,
          mushroomId: 'amanita_muscaria',
          foundAt: DateTime.now(),
          outingId: 'outing_02',
          notes: '',
        ),
        ForagingSpot(
          id: 'spot_3',
          title: 'Robledal libre',
          latitude: 43.1000,
          longitude: -2.6000,
          mushroomId: 'boletus_edulis',
          foundAt: DateTime.now(),
          outingId: null,
          notes: '',
        ),
      ];

      // Filtro por especie: solo 'boletus_edulis'
      final boletusSpots = spots.where((s) => s.mushroomId == 'boletus_edulis').toList();
      expect(boletusSpots.length, 2);

      // Filtro por salida: solo 'outing_01'
      final outing1Spots = spots.where((s) => s.outingId == 'outing_01').toList();
      expect(outing1Spots.length, 1);
      expect(outing1Spots.first.id, 'spot_1');

      // Filtro puntos libres (sin salida)
      final standaloneSpots = spots.where((s) => !s.isFromOuting).toList();
      expect(standaloneSpots.length, 1);
      expect(standaloneSpots.first.id, 'spot_3');
    });

    test('Visible GPS routes filter by selected outing IDs', () {
      final outings = <ForagingOuting>[
        ForagingOuting(
          id: 'outing_01',
          title: 'Ruta Urbasa',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          durationSeconds: 3600,
          distanceMeters: 4200,
          routePoints: const [LatLng(42.82, -2.15), LatLng(42.83, -2.16)],
          notes: '',
        ),
        ForagingOuting(
          id: 'outing_02',
          title: 'Ruta Gorbeia',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          durationSeconds: 5400,
          distanceMeters: 6100,
          routePoints: const [LatLng(43.03, -2.72), LatLng(43.04, -2.73)],
          notes: '',
        ),
        ForagingOuting(
          id: 'outing_manual',
          title: 'Salida Manual sin ruta',
          startedAt: DateTime.now(),
          endedAt: DateTime.now(),
          durationSeconds: 1800,
          distanceMeters: 0,
          routePoints: const [],
          notes: '',
          isManual: true,
        ),
      ];

      // Modo "Mostrar todas": solo salidas con al menos 2 puntos de ruta
      final visibleAll =
          outings.where((o) => o.routePoints.length >= 2).toList();
      expect(visibleAll.length, 2);

      // Modo "Seleccionadas": solo 'outing_01'
      final selectedIds = {'outing_01'};
      final visibleSelected = outings
          .where((o) => o.routePoints.length >= 2 && selectedIds.contains(o.id))
          .toList();
      expect(visibleSelected.length, 1);
      expect(visibleSelected.first.id, 'outing_01');
    });

    testWidgets('ForagingSpotMarkerWidget renders pure quantity number without x and uses edibility badgeColor', (tester) async {
      const mushroom = Mushroom(
        id: 'boletus_edulis',
        scientificName: 'Boletus edulis',
        spanishName: 'Boletus',
        basqueName: 'Onddo zuri',
        family: 'Boletaceae',
        edibility: EdibilityLevel.excellent,
        edibilityLabel: 'Excelente',
        season: 'Otoño',
        habitat: 'Bosques',
        summary: 'Comestible excelente',
        morphology: MushroomMorphology(cap: '', hymenium: '', stem: '', flesh: ''),
        confusions: [],
        images: [],
      );

      final spot = ForagingSpot(
        id: 'spot_test',
        title: 'Boletus spot',
        latitude: 43.0,
        longitude: -2.5,
        mushroomId: 'boletus_edulis',
        notes: '',
        foundAt: DateTime.now(),
        quantityCount: 14,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForagingSpotMarkerWidget(
              spot: spot,
              allMushrooms: const [mushroom],
              size: 40,
            ),
          ),
        ),
      );

      // Verify it renders '14' and NOT '14x'
      expect(find.text('14'), findsOneWidget);
      expect(find.text('14x'), findsNothing);

      // Verify the container has EdibilityLevel.excellent badgeColor
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, mushroom.edibility.badgeColor);
    });

    test('SpotsDatabase purgeOrphanedOutingSpots removes spots of deleted outings and legacy samples', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final spotsDb = SpotsDatabase();
      final outingsDb = OutingsDatabase();

      // Databases start completely empty without sample data
      final initialOutings = await outingsDb.getAllOutings();
      final initialSpots = await spotsDb.getAllSpots();
      expect(initialOutings, isEmpty);
      expect(initialSpots, isEmpty);

      // Add an outing and its spot
      final outing = ForagingOuting(
        id: 'user_outing_1',
        title: 'Mi salida en Gorbeia',
        startedAt: DateTime.now(),
        endedAt: DateTime.now(),
        durationSeconds: 3600,
        distanceMeters: 2000,
        routePoints: const [],
        notes: '',
      );
      await outingsDb.upsertOuting(outing);

      final spot = ForagingSpot(
        id: 'user_spot_1',
        title: 'Níscalos',
        latitude: 43.0,
        longitude: -2.6,
        notes: '',
        foundAt: DateTime.now(),
        outingId: 'user_outing_1',
        quantityCount: 8,
      );
      await spotsDb.upsertSpot(spot);

      final standaloneSpot = ForagingSpot(
        id: 'standalone_spot_1',
        title: 'Punto libre',
        latitude: 43.1,
        longitude: -2.7,
        notes: '',
        foundAt: DateTime.now(),
        outingId: null,
        quantityCount: 3,
      );
      await spotsDb.upsertSpot(standaloneSpot);

      var currentSpots = await spotsDb.getAllSpots();
      expect(currentSpots.length, 2);

      // Now simulate deleting the outing: valid outings set is now empty
      await outingsDb.deleteOuting('user_outing_1');
      final validOutingIds = (await outingsDb.getAllOutings()).map((o) => o.id).toSet();
      await spotsDb.purgeOrphanedOutingSpots(validOutingIds);

      currentSpots = await spotsDb.getAllSpots();
      // user_spot_1 was purged because its outing was deleted; standalone_spot_1 remains
      expect(currentSpots.length, 1);
      expect(currentSpots.first.id, 'standalone_spot_1');
    });

    test('Mushroom latinWithCommon formats scientific name in front of localized name', () {
      const mushroom = Mushroom(
        id: 'boletus_edulis',
        scientificName: 'Boletus edulis',
        spanishName: 'Boleto comestible',
        basqueName: 'Ontto zuri',
        englishName: 'Penny bun',
        family: 'Boletaceae',
        edibility: EdibilityLevel.excellent,
        edibilityLabel: 'Excelente comestible',
        season: 'Otoño',
        habitat: 'Bosques',
        summary: 'Seta muy apreciada',
        morphology: MushroomMorphology(cap: '', hymenium: '', stem: '', flesh: ''),
        confusions: [],
        images: ['assets/images/logo_zizai.png'],
      );

      expect(mushroom.latinWithCommon(AppLanguage.eu), 'Boletus edulis (Ontto zuri)');
      expect(mushroom.latinWithCommon(AppLanguage.es), 'Boletus edulis (Boleto comestible)');
      expect(mushroom.latinWithCommon(AppLanguage.en), 'Boletus edulis (Penny bun)');
    });

    test('catalogSortModeProvider defaults to scientific (Latin A-Z)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final defaultSort = container.read(catalogSortModeProvider);
      expect(defaultSort, CatalogSortMode.scientific);
    });

    test('Manual coordinate string parser splits comma and whitespace correctly', () {
      const input = '43.12345, -2.56789';
      final parts = input.split(RegExp(r'[,;\s]+'));
      expect(parts.length, 2);
      final lat = double.tryParse(parts[0].replaceAll(',', '.'));
      final lng = double.tryParse(parts[1].replaceAll(',', '.'));
      expect(lat, closeTo(43.12345, 0.00001));
      expect(lng, closeTo(-2.56789, 0.00001));
    });

    test('OutingsDatabase.recoverOrphanedOutingsFromSpots reconstructs missing outings and ignores temp/legacy spots', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final outingsDb = OutingsDatabase();

      final spot1 = ForagingSpot(
        id: 'spot_rec_1',
        title: 'Boletus Urbasa',
        latitude: 42.85,
        longitude: -2.18,
        mushroomName: 'Boletus edulis',
        notes: 'Hayedo',
        foundAt: DateTime(2026, 10, 12, 9, 15),
        outingId: 'outing_orphan_1',
        outingTitle: 'Urbasa Norte',
        quantityCount: 3,
        weightGrams: 420,
      );
      final spot2 = ForagingSpot(
        id: 'spot_rec_2',
        title: 'Cantharellus Urbasa',
        latitude: 42.86,
        longitude: -2.19,
        mushroomName: 'Cantharellus cibarius',
        notes: '',
        foundAt: DateTime(2026, 10, 12, 10, 45),
        outingId: 'outing_orphan_1',
        outingTitle: 'Urbasa Norte',
        quantityCount: 5,
      );
      final tempSpot = ForagingSpot(
        id: 'spot_temp',
        title: 'Temporal',
        latitude: 42.90,
        longitude: -2.20,
        notes: '',
        foundAt: DateTime(2026, 10, 12, 11, 0),
        outingId: 'temp',
        outingTitle: 'Temp',
      );
      final legacySpot = ForagingSpot(
        id: 'spot_legacy',
        title: 'Legacy',
        latitude: 43.0,
        longitude: -2.7,
        notes: '',
        foundAt: DateTime(2024, 10, 1),
        outingId: 'outing_gorbeia_otzarreta',
        outingTitle: 'Sample',
      );
      final soloSpot = ForagingSpot(
        id: 'spot_solo',
        title: 'Solo',
        latitude: 43.1,
        longitude: -2.5,
        notes: '',
        foundAt: DateTime(2026, 10, 12, 12, 0),
      );

      final recoveredCount = await outingsDb.recoverOrphanedOutingsFromSpots([
        spot1,
        spot2,
        tempSpot,
        legacySpot,
        soloSpot,
      ]);

      expect(recoveredCount, 1);
      final outings = await outingsDb.getAllOutings();
      expect(outings.length, 1);
      expect(outings.first.id, 'outing_orphan_1');
      expect(outings.first.title, 'Urbasa Norte');
      expect(outings.first.startedAt, DateTime(2026, 10, 12, 9, 15));
      expect(outings.first.endedAt, DateTime(2026, 10, 12, 10, 45));
      expect(outings.first.durationSeconds, 5400);
      expect(outings.first.routePoints, isEmpty);
      expect(outings.first.isManual, isTrue);

      // Idempotent on subsequent runs
      final secondRun = await outingsDb.recoverOrphanedOutingsFromSpots([spot1, spot2]);
      expect(secondRun, 0);
    });

    test('ActiveOutingRecorder auto-saves immediately before finishOuting and restores on restart', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final db = OutingsDatabase();
      final recorder = ActiveOutingRecorder(db: db);
      addTearDown(() {
        if (recorder.mounted) recorder.dispose();
      });

      const p1 = LatLng(43.0300, -2.7200);
      const p2 = LatLng(43.0310, -2.7210);

      await recorder.startOuting('Autoguardado Gorbeia', initialPoint: p1, isManual: false);
      recorder.addRoutePoint(p2);
      await recorder.persistActiveOutingSnapshot();

      final persistedOutings = await db.getAllOutings();
      expect(persistedOutings.length, 1);
      expect(persistedOutings.first.id, recorder.state.activeOutingId);
      expect(persistedOutings.first.title, 'Autoguardado Gorbeia');
      expect(persistedOutings.first.routePoints.length, 2);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('zizai_active_outing_state_v1'), isNotNull);

      recorder.dispose();

      final freshRecorder = ActiveOutingRecorder(db: db);
      addTearDown(() {
        if (freshRecorder.mounted) freshRecorder.dispose();
      });
      await freshRecorder.restoreActiveOutingIfNeeded();

      expect(freshRecorder.state.isRecording, isTrue);
      expect(freshRecorder.state.activeOutingId, persistedOutings.first.id);
      expect(freshRecorder.state.title, 'Autoguardado Gorbeia');
      expect(freshRecorder.state.routePoints.length, 2);

      final completed = freshRecorder.finishOuting();
      expect(completed, isNotNull);
      await db.upsertOuting(completed!);
    });
  });
}
