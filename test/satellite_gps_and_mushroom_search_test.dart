import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zizai/core/localization/app_localizations.dart';
import 'package:zizai/core/services/gps_accuracy_service.dart';
import 'package:zizai/features/catalog/models/mushroom.dart';
import 'package:zizai/features/catalog/presentation/widgets/mushroom_search_picker.dart';
import 'package:zizai/features/map/models/foraging_spot.dart';
import 'package:zizai/features/map/presentation/widgets/foraging_spot_marker.dart';
import 'package:zizai/features/map/services/offline_map_service.dart';
import 'package:zizai/features/outings/data/outings_database.dart';

void main() {
  group('Mejora 1: Cartografía Satelital y Capas de Mapa', () {
    test('MapLayerType.satellite genera URL ArcGIS correcta con formato {z}/{y}/{x}', () {
      final satellite = MapLayerType.satellite;
      expect(satellite.id, 'satellite');
      expect(satellite.maxZoom, 19);
      expect(
        satellite.urlTemplate,
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      );

      final tileUrl = satellite.tileUrlFor(12, 2045, 1532);
      expect(
        tileUrl,
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/12/1532/2045',
      );
    });

    test('MapLayerType.fromString parsea correctamente y da fallback seguro', () {
      expect(MapLayerType.fromString('satellite'), MapLayerType.satellite);
      expect(MapLayerType.fromString('streets'), MapLayerType.streets);
      expect(MapLayerType.fromString('osm'), MapLayerType.streets);
      expect(MapLayerType.fromString('topo'), MapLayerType.topo);
      expect(MapLayerType.fromString('unknown_val'), MapLayerType.topo);
    });

    test('OfflineMapRegion serializa y deserializa layerType con retrocompatibilidad', () {
      final region = OfflineMapRegion(
        id: 'region_sat_1',
        name: 'Hayedo de Otzarreta (Gorbeia)',
        description: 'Zona de bosque caducifolio',
        north: 43.05,
        south: 43.02,
        east: -2.70,
        west: -2.74,
        tilesCount: 48,
        sizeBytes: 1024 * 1024 * 3,
        downloadedAt: DateTime(2026, 11, 7),
        layerType: MapLayerType.satellite,
      );

      final map = region.toMap();
      expect(map['layerType'], 'satellite');
      expect(map['isTopoLayer'], isFalse);

      final restored = OfflineMapRegion.fromMap(map);
      expect(restored.layerType, MapLayerType.satellite);
      expect(restored.isTopoLayer, isFalse);

      // Retrocompatibilidad con datos antiguos que solo tenían 'isTopoLayer: true'
      final legacyMap = {
        'id': 'legacy_1',
        'name': 'Zona Antigua',
        'north': 43.0,
        'south': 42.9,
        'east': -2.5,
        'west': -2.6,
        'isTopoLayer': true,
      };
      final fromLegacy = OfflineMapRegion.fromMap(legacyMap);
      expect(fromLegacy.layerType, MapLayerType.topo);
      expect(fromLegacy.isTopoLayer, isTrue);
    });
  });

  group('Mejora 2: Adquisición GPS y Filtro de Ruido en Rutas', () {
    test('GpsAccuracyService clasifica la precisión correctamente', () {
      expect(
        GpsAccuracyService.classifyAccuracy(6.0),
        GpsSignalQuality.optimal,
      );
      expect(
        GpsAccuracyService.classifyAccuracy(14.9),
        GpsSignalQuality.optimal,
      );
      expect(
        GpsAccuracyService.classifyAccuracy(15.1),
        GpsSignalQuality.acceptable,
      );
      expect(
        GpsAccuracyService.classifyAccuracy(35.0),
        GpsSignalQuality.acceptable,
      );
      expect(
        GpsAccuracyService.classifyAccuracy(35.1),
        GpsSignalQuality.poor,
      );
      expect(
        GpsAccuracyService.classifyAccuracy(120.0),
        GpsSignalQuality.poor,
      );
    });

    test('ActiveOutingRecorder filtra saltos anómalos (> 400m de golpe) en ruta', () async {
      final recorder = ActiveOutingRecorder();
      await recorder.startOuting(
        'Salida test en Gorbeia',
        initialPoint: const LatLng(43.0340, -2.7270),
      );

      expect(recorder.state.routePoints.length, 1);
      expect(recorder.state.distanceMeters, 0.0);

      // Paso normal de caminata: ~25 metros
      recorder.addRoutePoint(const LatLng(43.0342, -2.7270));
      expect(recorder.state.routePoints.length, 2);
      expect(recorder.state.distanceMeters, greaterThan(15.0));
      expect(recorder.state.distanceMeters, lessThan(40.0));

      final distBeforeJump = recorder.state.distanceMeters;

      // Salto errático de GPS por rebote multipath en el bosque: ~2 kilómetros
      recorder.addRoutePoint(const LatLng(43.0550, -2.7270));
      // Debe haber sido descartado por superar los 400 metros de golpe
      expect(recorder.state.routePoints.length, 2);
      expect(recorder.state.distanceMeters, distBeforeJump);

      // Paso siguiente válido: ~30 metros
      recorder.addRoutePoint(const LatLng(43.0344, -2.7270));
      expect(recorder.state.routePoints.length, 3);
      expect(recorder.state.distanceMeters, greaterThan(distBeforeJump));
    });
  });

  group('Mejora 3: Buscador Reactivo de Setas en Salidas', () {
    const boletus = Mushroom(
      id: 'boletus_edulis',
      scientificName: 'Boletus edulis',
      spanishName: 'Boleto comestible',
      basqueName: 'Onddo zuri',
      family: 'Boletaceae',
      edibility: EdibilityLevel.excellent,
      edibilityLabel: 'Excelente comestible',
      season: 'Otoño',
      habitat: 'Bosques',
      summary: 'Seta rey de los hayedos',
      morphology: MushroomMorphology(cap: '', hymenium: '', stem: '', flesh: ''),
      confusions: [],
      images: ['assets/images/logo_zizai.png'],
    );

    const cantharellus = Mushroom(
      id: 'cantharellus_cibarius',
      scientificName: 'Cantharellus cibarius',
      spanishName: 'Rebozuelo',
      basqueName: 'Zizahori',
      family: 'Cantharellaceae',
      edibility: EdibilityLevel.good,
      edibilityLabel: 'Buen comestible',
      season: 'Otoño',
      habitat: 'Robledales y hayedos',
      summary: 'Seta amarilla aromática',
      morphology: MushroomMorphology(cap: '', hymenium: '', stem: '', flesh: ''),
      confusions: [],
      images: ['assets/images/logo_zizai.png'],
    );

    testWidgets('MushroomSearchPicker renderiza la seta seleccionada y chips rápidos', (tester) async {
      Mushroom? pickedMushroom = boletus;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, setState) => MushroomSearchPicker(
                selectedMushroom: pickedMushroom,
                catalogMushrooms: const [boletus, cantharellus],
                lang: AppLanguage.es,
                onMushroomChanged: (m) => setState(() => pickedMushroom = m),
              ),
            ),
          ),
        ),
      );

      // Verifica que muestra el nombre científico en cursiva y el nombre común (en tarjeta y en chips)
      expect(find.text('Boletus edulis'), findsOneWidget);
      expect(find.text('Boleto comestible'), findsWidgets);

      // Verifica los chips rápidos de otoño
      expect(find.text('Rebozuelo'), findsOneWidget);

      // Al tocar el chip rápido de Rebozuelo, se actualiza la selección
      await tester.tap(find.text('Rebozuelo'));
      await tester.pumpAndSettle();

      expect(pickedMushroom?.id, 'cantharellus_cibarius');
      expect(find.text('Cantharellus cibarius'), findsOneWidget);
    });

    testWidgets('ForagingSpotMarker con rotación de mapa a 180° mantiene rotate: true y texto orientado', (tester) async {
      final spot = ForagingSpot(
        id: 'spot_rot_test',
        title: 'Boletus spot',
        latitude: 43.0,
        longitude: -2.5,
        mushroomId: 'boletus_edulis',
        notes: '',
        foundAt: DateTime.now(),
        quantityCount: 14,
      );

      final marker = Marker(
        point: LatLng(spot.latitude, spot.longitude),
        rotate: true,
        child: ForagingSpotMarkerWidget(
          spot: spot,
          allMushrooms: const [boletus],
        ),
      );

      expect(marker.rotate, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ForagingSpotMarkerWidget(
              spot: spot,
              allMushrooms: const [boletus],
            ),
          ),
        ),
      );

      expect(find.text('14'), findsOneWidget);
    });
  });
}
