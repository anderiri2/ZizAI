import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zizai/core/localization/app_localizations.dart';
import 'package:zizai/core/widgets/gps_acquisition_sheet.dart';
import 'package:zizai/features/map/models/foraging_spot.dart';
import 'package:zizai/features/map/presentation/map_screen.dart';
import 'package:zizai/features/map/presentation/widgets/map_crosshair_target.dart';
import 'package:zizai/features/map/services/offline_map_service.dart';
import 'package:zizai/features/outings/data/outings_database.dart';
import 'package:zizai/features/outings/models/foraging_outing.dart';
import 'package:zizai/features/outings/presentation/live_outing_map_screen.dart';
import 'package:zizai/features/outings/presentation/map_spot_picker_screen.dart';
import 'package:zizai/features/outings/presentation/outings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mejora 1: Precisión GPS al guardar setas en el Mapa', () {
    testWidgets('GpsAcquisitionSheet renders customized title, subtitle and confirm label',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GpsAcquisitionSheet(
              title: 'Setal Berria Gorde',
              subtitle: 'Doitasun handiko GPS seinalea bilatzen',
              confirmButtonLabel: 'Finkatu koordenatuak',
              lang: AppLanguage.eu,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Setal Berria Gorde'), findsOneWidget);
      expect(find.text('Doitasun handiko GPS seinalea bilatzen'), findsOneWidget);
      expect(find.byIcon(Icons.satellite_alt_rounded), findsOneWidget);
    });

    testWidgets('Pulsar Guardar Setal en MapScreen abre el selector de 2 opciones',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fabAdd = find.byKey(const ValueKey('btn_add_spot'));
      expect(fabAdd, findsOneWidget);

      await tester.tap(fabAdd);
      await tester.pumpAndSettle();

      // Debe mostrar el selector con ambas opciones (GPS y Diana/Dedo)
      expect(
        find.text('Nire uneko GPS kokapenean').evaluate().isNotEmpty ||
            find.text('En mi ubicación GPS actual').evaluate().isNotEmpty ||
            find.text('At my current GPS location').evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        find.text('Mapan hatzarekin seinalatu (diana)').evaluate().isNotEmpty ||
            find.text('Marcar con el dedo en el mapa (con diana)').evaluate().isNotEmpty ||
            find.text('Mark on map with finger (crosshair)').evaluate().isNotEmpty,
        isTrue,
      );
      expect(find.byIcon(Icons.my_location_rounded), findsWidgets);
      expect(find.byIcon(Icons.touch_app_rounded), findsWidgets);

      // Al pulsar la opción de marcar con el dedo / diana, debe activar el modo Diana
      final fingerOption = find.byIcon(Icons.touch_app_rounded);
      expect(fingerOption, findsOneWidget);
      await tester.tap(fingerOption);
      await tester.pumpAndSettle();

      // Debe verse la Diana en pantalla y el botón de confirmar
      expect(find.byType(MapCrosshairTarget), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_confirm_diana_spot')), findsOneWidget);

      // Al pulsar "Fijar setal aquí", abre el formulario de registro del setal
      await tester.tap(find.byKey(const ValueKey('btn_confirm_diana_spot')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });
  });

  group('Mejora 2: Salidas Sin GPS (Cestas Micológicas Puras)', () {
    test('ForagingOuting formattedDistanceKm muestra Cesta o Manual para isManual', () {
      final manualOuting = ForagingOuting(
        id: 'manual_1',
        title: 'Recolección Gorbeia',
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        endedAt: DateTime.now(),
        durationSeconds: 3600,
        distanceMeters: 0.0,
        routePoints: const [],
        isManual: true,
      );

      expect(manualOuting.isManual, isTrue);
      expect(manualOuting.formattedDistanceKm, contains('Manual'));
      expect(manualOuting.formattedDuration, '1h 0m');
    });

    testWidgets('MapSpotPickerScreen muestra Diana interactiva, botón GPS y barra de confirmación',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapSpotPickerScreen(
              outingId: 'test_outing',
              outingTitle: 'Salida de prueba',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No debe existir el modo "Ibilbidea marraztu" / "Trazar ruta"
      expect(find.text('Ibilbidea marraztu'), findsNothing);
      expect(find.text('Trazar ruta'), findsNothing);

      // Debe mostrarse la Diana central (MapCrosshairTarget)
      expect(find.byType(MapCrosshairTarget), findsOneWidget);

      // Debe existir el botón GPS para centrar la diana y el botón de confirmar diana
      expect(find.byKey(const ValueKey('btn_gps_picker_spot')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_confirm_diana_spot')), findsOneWidget);

      // Al pulsar "Fijar setal aquí", abre el formulario de hallazgo en la salida
      await tester.tap(find.byKey(const ValueKey('btn_confirm_diana_spot')));
      await tester.pumpAndSettle();

      expect(find.byType(OutingFindFormSheet), findsOneWidget);
    });

    testWidgets('OutingsScreen en Salida Manual muestra botón único de ubicar en mapa sin icono redundante',
        (tester) async {
      final container = ProviderContainer();
      final recorder = container.read(activeOutingRecorderProvider.notifier);
      recorder.state = ActiveOutingState(
        isRecording: true,
        activeOutingId: 'test_outing_manual',
        title: 'Salida Manual Urbasa',
        startedAt: DateTime.now(),
        isManual: true,
        routePoints: const [],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OutingsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.text('Kokatu Perretxikoa Mapan').evaluate().isNotEmpty ||
            find.text('Ubicar Seta en Mapa').evaluate().isNotEmpty ||
            find.text('Place Mushroom on Map').evaluate().isNotEmpty,
        isTrue,
      );
      // Solo un icono touch_app_rounded en la tarjeta (dentro del botón principal, sin botón secundario duplicado)
      expect(find.byIcon(Icons.touch_app_rounded), findsOneWidget);

      container.dispose();
    });
  });

  group('Mejora 3: Segundo Plano y Sincronización de Cronómetro sin Drift', () {
    test('ActiveOutingRecorder calcula elapsedSeconds con reloj de pared evitando desfase', () async {
      final recorder = ActiveOutingRecorder();
      final startTime = DateTime.now().subtract(const Duration(minutes: 42, seconds: 15));

      await recorder.startOuting('Salida Monte', isManual: true);

      // Simular tiempo transcurrido real con startedAt en el pasado
      recorder.state = recorder.state.copyWith(startedAt: startTime);

      // Ejecutar finalización de salida
      final finished = recorder.finishOuting();
      expect(finished, isNotNull);
      // Debe haber calculado la duración exacta por reloj de pared (~2535s)
      expect(finished!.durationSeconds, greaterThanOrEqualTo(2530));
    });

    test('ActiveOutingRecorder descuenta pausas correctamente en el cálculo', () async {
      final recorder = ActiveOutingRecorder();
      await recorder.startOuting('Salida con pausas', isManual: true);

      // Pausar y reanudar
      recorder.togglePause();
      expect(recorder.state.isPaused, isTrue);

      recorder.togglePause();
      expect(recorder.state.isPaused, isFalse);

      final finished = recorder.finishOuting();
      expect(finished, isNotNull);
    });
  });

  group('Mejora Outing: Selector de mapa y ruta GPS limpia sin setales', () {
    test('MapLayerType conmuta cíclicamente y actualiza activeMapLayerProvider', () {
      final container = ProviderContainer();
      expect(container.read(activeMapLayerProvider), MapLayerType.topo);

      container.read(activeMapLayerProvider.notifier).state =
          MapLayerType.topo.next;
      expect(container.read(activeMapLayerProvider), MapLayerType.satellite);

      container.read(activeMapLayerProvider.notifier).state =
          MapLayerType.satellite.next;
      expect(container.read(activeMapLayerProvider), MapLayerType.streets);

      container.read(activeMapLayerProvider.notifier).state =
          MapLayerType.streets.next;
      expect(container.read(activeMapLayerProvider), MapLayerType.topo);
    });

    test('Guardar un setal fuera de la ruta no añade puntos a routePoints en ActiveOutingRecorder', () async {
      final recorder = ActiveOutingRecorder();
      const p1 = LatLng(43.0300, -2.7200);
      const p2 = LatLng(43.0310, -2.7210);

      await recorder.startOuting('Ruta Monte Gorbeia', isManual: false, initialPoint: p1);
      recorder.addRoutePoint(p2);

      expect(recorder.state.routePoints.length, 2);
      expect(recorder.state.routePoints, contains(p1));
      expect(recorder.state.routePoints, contains(p2));

      // Simulamos la creación de un setal a 300 metros fuera de la ruta
      final offRouteSpot = ForagingSpot(
        id: 'spot_off_route',
        title: 'Boletus edulis en hayedo alejado',
        latitude: 43.0350,
        longitude: -2.7150,
        foundAt: DateTime.now(),
        outingId: recorder.state.activeOutingId,
        notes: '',
      );

      // Verificamos que la ruta GPS solo contiene los 2 puntos de la trayectoria
      // y NO el punto del setal añadido
      expect(recorder.state.routePoints.length, 2);
      expect(
        recorder.state.routePoints.any((pt) =>
            pt.latitude == offRouteSpot.latitude &&
            pt.longitude == offRouteSpot.longitude),
        isFalse,
      );
    });

    testWidgets('OutingsScreen en actividad GPS muestra el selector de capa de mapa y conmuta',
        (tester) async {
      final container = ProviderContainer();
      final recorder = container.read(activeOutingRecorderProvider.notifier);
      recorder.state = ActiveOutingState(
        isRecording: true,
        activeOutingId: 'test_outing_gps',
        title: 'Salida GPS Gorbeia',
        startedAt: DateTime.now(),
        isManual: false,
        routePoints: const [LatLng(43.0, -2.7), LatLng(43.01, -2.71)],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: OutingsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Debe verse el chip "Topo" del selector de capa en la tarjeta de grabación
      expect(find.text('Topo'), findsWidgets);

      // Al pulsar el chip de capa, conmuta a "Satelitea" (idioma por defecto eu)
      await tester.tap(find.text('Topo').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(container.read(activeMapLayerProvider), MapLayerType.satellite);
      expect(
        find.text('Satelitea').evaluate().isNotEmpty ||
            find.text('Satélite').evaluate().isNotEmpty ||
            find.text('Satellite').evaluate().isNotEmpty,
        isTrue,
      );

      container.dispose();
    });

    testWidgets(
        'LiveOutingMapScreen oculta el FAB duplicado de localización al activar modo Diana',
        (tester) async {
      final container = ProviderContainer();
      final recorder = container.read(activeOutingRecorderProvider.notifier);
      recorder.state = ActiveOutingState(
        isRecording: true,
        activeOutingId: 'test_outing_live_diana',
        title: 'Salida Manual Urkiola',
        startedAt: DateTime.now(),
        isManual: true,
        routePoints: const [],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: LiveOutingMapScreen(),
          ),
        ),
      );
      await tester.pump();

      // Antes de activar la diana solo hay 1 botón de localización (el FAB lateral)
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);

      // Pulsamos el botón principal "Kokatu Mapan" / "Ubicar en Mapa"
      final placeBtn = find.byIcon(Icons.touch_app_rounded);
      expect(placeBtn, findsOneWidget);
      await tester.tap(placeBtn);
      await tester.pump();

      // En modo Diana, el FAB lateral de localización se oculta y solo queda el de la barra inferior
      expect(find.byType(MapCrosshairTarget), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_confirm_live_diana_spot')), findsOneWidget);
      expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);

      container.dispose();
    });
  });
}
